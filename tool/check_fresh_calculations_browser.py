"""Check fresh-audit fixes through real worksheet entry, details and reload."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames
from check_notepad_batch_browser import read_document

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        for width, height in [(1280, 900), (390, 844)]:
            doc = {'i': 'fresh-live', 'n': 'Fresh mathematical checks', 'c': '2026-10-02T00:00:00Z', 'u': '2026-10-02T00:00:00Z', 'l': [{'i': str(i), 's': ''} for i in range(3)]}
            context, page, errors = await context_for(browser, {'viewport': {'width': width, 'height': height}, 'cpu': 1}, doc)
            try:
                await bootstrap(page, args.url)
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                for i, source in enumerate(['2^100', 'simplify((x^2-9)/(x^2+x-6))', 'eigenvalues(Matrix([[2,1],[1,2]]))']):
                    field = page.get_by_role('textbox').nth(i)
                    await field.click()
                    await next_frames(page)
                    await field.fill(source)
                    await page.wait_for_function('''item => {
                      const raw=localStorage.getItem('flutter.crisp.notepadDoc.fresh-live');
                      if(!raw)return false;const line=JSON.parse(JSON.parse(raw)).l[item.index];
                      return line.s===item.source && (line.r || line.e);
                    }''', arg={'index': i, 'source': source})
                saved = await read_document(page, doc['i'])
                assert not any(line.get('e') for line in saved['l']), saved
                assert saved['l'][0]['r'] == '1267650600228229401496703205376', saved
                assert saved['l'][0]['evidence']['accuracy'] == 'exact'
                domain = saved['l'][1]['evidence']['sourceDomain']
                assert '≠' in domain and '-3' in domain and '2' in domain, domain
                roots = saved['l'][2]['r'].strip('{}').split(',')
                assert sorted(float(v) for v in roots) == [1, 3], saved['l'][2]
                await page.get_by_role('button', name=re.compile(r'· domain$')).click()
                await page.get_by_text('Original domain: ' + domain, exact=True).wait_for()
                await page.screenshot(path=str(output / f'domain-{width}.png'))
                await page.get_by_role('button', name='Close', exact=True).click()
                await page.reload(wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for()
                await page.locator('flt-semantics-placeholder').evaluate('(element)=>element.click()')
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                assert (await read_document(page, doc['i']))['l'][1]['evidence']['sourceDomain'] == domain
                assert not errors, errors
                report['checks'].append({'width': width, 'exactLargeInteger': True, 'eigenvalues': True, 'originalDomainDetails': True, 'reload': True})
            except Exception as error:
                report['error'] = str(error)
                report['document'] = await read_document(page, doc['i'])
                report['pageErrors'] = errors
                await page.screenshot(path=str(output / 'failure.png'))
                raise
            finally:
                (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
                await context.close()
        report['passed'] = True
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        await browser.close()
    print(json.dumps(report), flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/fresh-calculations')
    asyncio.run(check(parser.parse_args()))
