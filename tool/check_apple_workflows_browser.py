"""Exercise workflow links, real worksheet downloads/uploads and keyboard actions."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from urllib.parse import urlencode

from playwright.async_api import async_playwright
from benchmark_workflows import context_for, next_frames


async def current_document(page):
    return await page.evaluate('''() => {
      const id = JSON.parse(localStorage.getItem('flutter.crisp.currentNotepadDoc') || 'null');
      const raw = localStorage.getItem('flutter.crisp.notepadDoc.' + encodeURIComponent(id));
      return raw ? JSON.parse(JSON.parse(raw)) : null;
    }''')


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        for width, height in [(1032, 1376), (744, 1024), (390, 844)]:
            context, page, errors = await context_for(browser, {'viewport': {'width': width, 'height': height}, 'cpu': 1})
            try:
                url = args.url + ('&' if '?' in args.url else '?') + urlencode({
                    'action': 'worksheet', 'name': '50% + workflow',
                    'lines': 'a=3\nf(t)=t^2+a\nf(4)'})
                await page.goto(url, wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for(timeout=300000)
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                await page.wait_for_function('''() => {
                  const id=JSON.parse(localStorage.getItem('flutter.crisp.currentNotepadDoc')||'null');
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  if(!raw)return false;
                  const doc=JSON.parse(JSON.parse(raw));
                  return doc.n==='50% + workflow' && doc.l[2].r==='19';
                }''')
                doc = await current_document(page)
                assert doc['l'][2]['r'] == '19', doc

                async def menu(label):
                    await page.get_by_role('button', name='Document menu', exact=True).click()
                    await page.locator('[aria-label=' + json.dumps(label) + ']').click()

                async with page.expect_download() as download_info:
                    await menu('Save worksheet file')
                download = await download_info.value
                saved = output / f'worksheet-{width}.crispmath'
                await download.save_as(saved)
                payload = json.loads(saved.read_text())
                assert payload['format'] == 'crispmath.worksheet' and payload['version'] == 1
                assert payload['document']['l'][2]['s'] == 'f(4)'
                payload['document']['l'][2]['r'] = '999'
                async with page.expect_file_chooser() as chooser_info:
                    await menu('Open worksheet file')
                chooser = await chooser_info.value
                await chooser.set_files({'name': 'roundtrip.crispmath', 'mimeType': 'application/json',
                                         'buffer': json.dumps(payload).encode()})
                await page.wait_for_function('''old => {
                  const id=JSON.parse(localStorage.getItem('flutter.crisp.currentNotepadDoc')||'null');
                  if(id===old)return false;
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  return raw && JSON.parse(JSON.parse(raw)).l[2].r==='19';
                }''', arg=doc['i'])
                imported = await current_document(page)
                assert imported['i'] != doc['i'] and imported['l'][2]['r'] == '19'
                fields = page.get_by_role('textbox')
                await fields.first.click()
                await fields.first.press('Alt+ArrowDown')
                await fields.nth(1).press('Control+Shift+Enter')
                await page.wait_for_function('''() => {
                  const id=JSON.parse(localStorage.getItem('flutter.crisp.currentNotepadDoc'));
                  const doc=JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id))));
                  return doc.l.length===4;
                }''')
                await page.screenshot(path=str(output / f'workflow-{width}.png'))
                await page.reload(wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for()
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                # A workflow URL is an explicit create action on each visit.
                await page.wait_for_function('''() => {
                  const id=JSON.parse(localStorage.getItem('flutter.crisp.currentNotepadDoc')||'null');
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  return raw && JSON.parse(JSON.parse(raw)).l[2].r==='19';
                }''')
                assert not errors, errors
                report['checks'].append({'width': width, 'workflowLink': True,
                    'download': True, 'upload': True, 'untrustedCacheRecalculated': True,
                    'keyboardAddRow': True, 'reload': True})
            except Exception as error:
                report['error'] = str(error)
                report['document'] = await current_document(page)
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
    parser.add_argument('--output', default='browser-results/apple-workflows')
    asyncio.run(check(parser.parse_args()))
