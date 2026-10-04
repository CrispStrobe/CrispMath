"""Verify downloaded worksheet snapshots, linked graphs and undefined table values."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for
from workflow_metrics import large_document

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        for width, height in [(1280, 900), (390, 844)]:
            doc = large_document(3)
            doc['i'] = 'export-snapshot'
            doc['n'] = 'Shared <worksheet> & values'
            doc['l'] = [{'i': str(i), 's': src} for i, src in enumerate(['a=3', 'f(x)=a/x', '2+2'])]
            context, page, errors = await context_for(browser, {'viewport': {'width': width, 'height': height}, 'cpu': 1}, doc)
            try:
                await bootstrap(page, args.url)
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await page.get_by_role('button', name='Document menu', exact=True).click()
                await page.locator('[aria-label="Recalculate all"]').click()
                await page.wait_for_function('''() => {
                  const raw = localStorage.getItem('flutter.crisp.notepadDoc.export-snapshot');
                  return raw && JSON.parse(JSON.parse(raw)).l[2].r === '4';
                }''')
                await page.get_by_role('button', name='Link line to graph', exact=True).nth(1).click()
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await page.get_by_role('button', name='Document menu', exact=True).click()
                await page.locator('[aria-label="Worksheet export preview"]').click()
                await page.get_by_role('button', name='Save HTML', exact=True).wait_for()
                await page.screenshot(path=str(output / f'preview-{width}.png'))
                for format in ['HTML', 'MD', 'TEX', 'PDF']:
                    async with page.expect_download() as info:
                        await page.get_by_role('button', name='Save ' + format, exact=True).click()
                    download = await info.value
                    target = output / f'worksheet-{width}.{format.lower()}'
                    await download.save_as(target)
                    data = target.read_bytes()
                    if format == 'PDF':
                        assert data.startswith(b'%PDF') and len(data) > 2000
                    else:
                        text = data.decode()
                        assert 'Undefined' in text and '4' in text, text
                        if format == 'HTML':
                            assert '<svg' in text and '&lt;worksheet&gt;' in text
                            rows = {float(x): y for x, y in re.findall(r'<td>([-+.\de]+)</td><td>([^<]+)</td>', text)}
                            assert rows[0] == 'Undefined' and float(rows[2]) == 1.5, rows
                        if format == 'TEX':
                            assert text.startswith('\\documentclass'), text
                assert not errors, errors
                report['checks'].append({'width': width, 'formats': ['html', 'md', 'tex', 'pdf'], 'linkedGraph': True, 'undefinedPoint': True})
            except Exception as error:
                report['error'] = str(error)
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
    parser.add_argument('--output', default='browser-results/worksheet-export')
    asyncio.run(check(parser.parse_args()))
