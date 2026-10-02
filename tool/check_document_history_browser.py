"""Exercise checkpoints, restore, backup downloads and conflict-preserving imports."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames
from workflow_metrics import large_document
from check_notepad_batch_browser import read_document

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        for width, height in [(1032, 1376), (390, 844)]:
            doc = large_document(3)
            doc['i'] = 'history-roundtrip'
            doc['n'] = 'History round trip'
            doc['l'] = [{'i': str(i), 's': source} for i, source in enumerate(['a=3', 'f(t)=t^2+a', 'f(4)'])]
            context, page, errors = await context_for(browser, {'viewport': {'width': width, 'height': height}, 'cpu': 1}, doc)
            try:
                await bootstrap(page, args.url)
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                async def menu(label):
                    await page.get_by_role('button', name='Document menu', exact=True).click()
                    await page.locator('[aria-label=' + json.dumps(label) + ']').click()
                async def result(value):
                    await page.wait_for_function('''expected => {
                      const raw=localStorage.getItem('flutter.crisp.notepadDoc.history-roundtrip');
                      return raw && JSON.parse(JSON.parse(raw)).l[2].r===expected;
                    }''', arg=value)
                async def edit(source):
                    field = page.get_by_role('textbox').first
                    await field.click()
                    await next_frames(page)
                    await field.fill(source)
                async def backups():
                    await page.get_by_role('button', name=re.compile(r'^Settings')).click()
                    target = page.get_by_role('button', name=re.compile('Workspace backups'))
                    for _ in range(12):
                        if await target.count():
                            bounds = await target.first.bounding_box()
                            if bounds and bounds['y'] > 88 and bounds['y'] + bounds['height'] < height - 60:
                                # Use an actual pointer click; Flutter's semantic scroll
                                # wrappers overlap in the DOM after wheel scrolling.
                                await page.mouse.click(bounds['x'] + bounds['width'] / 2, bounds['y'] + bounds['height'] / 2)
                                await page.get_by_role('button', name='Save backup', exact=True).wait_for(timeout=5000)
                                return
                        await page.mouse.move(width * .6, height * .5)
                        await page.mouse.wheel(0, 500)
                        await next_frames(page)
                    raise AssertionError('Workspace backups action was not reachable by scrolling')
                await menu('Recalculate all')
                await result('19')
                await menu('Document history')
                await page.get_by_role('button', name='Save checkpoint', exact=True).click()
                await page.get_by_role('button', name='Compare', exact=True).wait_for()
                await page.get_by_role('button', name='Close', exact=True).click()
                await edit('a=5')
                await result('21')
                await menu('Document history')
                await page.get_by_role('button', name='Compare', exact=True).first.click()
                await page.get_by_role('button', name='Restore checkpoint', exact=True).click()
                await result('19')
                restored = await read_document(page, doc['i'])
                assert restored['l'][0]['s'] == 'a=3' and restored['l'][0]['i'] == '0'
                await page.wait_for_function('''() => {
                  const raw=localStorage.getItem('flutter.crisp.documentCheckpoints');
                  return raw && JSON.parse(JSON.parse(raw)).some(c=>c.label==='Before restore');
                }''')
                await backups()
                async with page.expect_download() as info:
                    await page.get_by_role('button', name='Save backup', exact=True).click()
                download = await info.value
                target = output / f'backup-{width}.json'
                await download.save_as(target)
                payload = json.loads(target.read_text())
                assert payload['format'] == 'crispmath.backup' and len(payload['checkpoints']) >= 2
                assert 'r' not in payload['state']['notepadDocuments'][0]['l'][0]
                await page.get_by_role('button', name='Close', exact=True).click()
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await edit('a=7')
                await result('23')
                await backups()
                async with page.expect_file_chooser() as info:
                    await page.get_by_role('button', name='Open backup', exact=True).click()
                chooser = await info.value
                await chooser.set_files(target)
                await page.get_by_role('button', name='Import worksheets', exact=True).click()
                await page.wait_for_function('''() => {
                  const raw=localStorage.getItem('flutter.crisp.notepadIndex');
                  return raw && JSON.parse(JSON.parse(raw)).length>=2;
                }''')
                original = await read_document(page, doc['i'])
                assert original['l'][0]['s'] == 'a=7', original
                docs = await page.evaluate('''() => JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.notepadIndex'))).map(id => {
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  return raw ? JSON.parse(JSON.parse(raw)) : null;
                }).filter(Boolean)''')
                assert any(d['i'] != doc['i'] and d['l'][0]['s'] == 'a=3' for d in docs), docs
                await page.get_by_role('button', name='Previous workspace', exact=True).click()
                await page.get_by_role('button', name='Replace workspace', exact=True).wait_for()
                await page.screenshot(path=str(output / f'recovery-preview-{width}.png'))
                await page.get_by_role('button', name='Replace workspace', exact=True).click()
                await page.get_by_role('button', name='Close', exact=True).click()
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await result('23')
                await page.reload(wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for()
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await result('23')
                assert not errors, errors
                report['checks'].append({'width': width, 'checkpointRestore': True, 'rowIdsPreserved': True,
                    'backupDownloadUpload': True, 'conflictVersionsPreserved': True, 'recoveryRestore': True, 'reload': True})
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
    parser.add_argument('--output', default='browser-results/document-history')
    asyncio.run(check(parser.parse_args()))
