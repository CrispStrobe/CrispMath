"""Exercise rapid independent edits, cancel/retry and persisted results in the UI."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright, expect
from benchmark_workflows import bootstrap, context_for, next_frames
from workflow_metrics import large_document

async def read_document(page, doc_id):
    return await page.evaluate('''id => {
        const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+id);
        return raw ? JSON.parse(JSON.parse(raw)) : null;
    }''', doc_id)

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        rapid = large_document(5)
        rapid['i'] = 'rapid-edits'
        rapid['l'] = [{'i': str(i), 's': source, 'r': result} for i, (source, result) in enumerate([
            ('a = 1', '1'), ('b = 2', '2'), ('a + 10', '11'), ('b + 20', '22'), ('99', '99')])]
        for document, profile in [(rapid, {'viewport': {'width': 1280, 'height': 900}, 'cpu': 1}),
                (large_document(2000), {'viewport': {'width': 390, 'height': 844}, 'cpu': 4, 'has_touch': True})]:
            context, page, errors = await context_for(browser, profile, document)
            try:
                await bootstrap(page, args.url)
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                if document['i'] == 'rapid-edits':
                    first, second = page.get_by_role('textbox').nth(0), page.get_by_role('textbox').nth(1)
                    await first.click()
                    await next_frames(page)
                    await page.evaluate("() => {window.batchInputTimes=[]; document.addEventListener('input', () => window.batchInputTimes.push(performance.now()), true)}")
                    await first.fill('a = 4')
                    await next_frames(page)
                    # Flutter's native editor must change focus before fill reaches
                    # the second controller. A DOM-only fill can silently do nothing.
                    await second.click()
                    await next_frames(page)
                    await second.fill('b = 5')
                    input_times = await page.evaluate('window.batchInputTimes')
                    assert len(input_times) >= 2, input_times
                    interval = input_times[-1] - input_times[-2]
                    assert interval < 300, f'Edits missed debounce window: {interval}ms'
                    report['rapidInputIntervalMs'] = interval
                    await next_frames(page)
                    await page.wait_for_function('''() => {
                        const raw=localStorage.getItem('flutter.crisp.notepadDoc.rapid-edits');
                        if(!raw)return false;
                        const rows=JSON.parse(JSON.parse(raw)).l;
                        return rows[0].s==='a = 4' && rows[1].s==='b = 5' &&
                            rows.map(l=>l.r).join(',')==='4,5,14,25,99';
                    }''')
                    report['checks'].append({'rapidEdits': await read_document(page, document['i'])})
                    await page.screenshot(path=str(output/'rapid-edits.png'))
                else:
                    await page.get_by_role('button', name='Document menu', exact=True).click()
                    await page.locator('[aria-label="Recalculate all"]').click()
                    cancel = page.get_by_role('button', name='Cancel calculation', exact=True)
                    await cancel.click()
                    await expect(page.get_by_role('button', name='Retry', exact=True)).to_be_visible()
                    # A late worker answer must not bring back the cancelled tail.
                    await page.wait_for_timeout(1000)
                    stopped = await read_document(page, document['i'])
                    assert stopped['l'][-1].get('r') is None, 'Cancelled tail retained a stale result'
                    await page.screenshot(path=str(output/'cancelled-batch.png'))
                    await page.get_by_role('button', name='Retry', exact=True).click()
                    await page.wait_for_function('''() => {
                        const raw=localStorage.getItem('flutter.crisp.notepadDoc.performance-doc');
                        return raw && JSON.parse(JSON.parse(raw)).l.at(-1).r==='2000';
                    }''', timeout=180000)
                    await expect(page.get_by_role('button', name='Cancel calculation', exact=True)).to_have_count(0)
                    restored = await read_document(page, document['i'])
                    assert all(row.get('r') == str(i+1) and not row.get('e') for i, row in enumerate(restored['l']))
                    report['checks'].append({'rows': 2000, 'cancelledTail': True, 'retryAllCorrect': True})
                    await page.screenshot(path=str(output/'retried-batch.png'))
                assert not errors, errors
            except Exception as error:
                report['error'] = str(error)
                report['pageErrors'] = errors
                report['savedDocument'] = await read_document(page, document['i'])
                await page.screenshot(path=str(output/'failure.png'))
                raise
            finally:
                (output/'report.json').write_text(json.dumps(report, indent=2)+'\n')
                await context.close()
        report['passed'] = True
        (output/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        await browser.close()
    print(json.dumps(report), flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://localhost:8766/')
    parser.add_argument('--output', default='browser-results/notepad-batch')
    asyncio.run(check(parser.parse_args()))
