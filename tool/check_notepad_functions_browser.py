"""Exercise lexical worksheet functions, edits and persistence through the UI."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames
from check_notepad_batch_browser import read_document
from workflow_metrics import large_document

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        for profile in [{'viewport': {'width': 1280, 'height': 900}, 'cpu': 1},
                        {'viewport': {'width': 390, 'height': 844}, 'cpu': 4, 'has_touch': True}]:
            document = large_document(5)
            document['i'] = 'worksheet-functions'
            document['l'] = [{'i': str(i), 's': source} for i, source in enumerate([
                'a=2', 'f(x)=x^2+a', 'g(x,y)=f(x)-f(y)', 'g(3,2)', 'sin(f(0))'])]
            context, page, errors = await context_for(browser, profile, document)
            try:
                await bootstrap(page, args.url)
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await page.get_by_role('button', name='Document menu', exact=True).click()
                await page.locator('[aria-label="Recalculate all"]').click()
                async def result(expected):
                    await page.wait_for_function('''expected => {
                      const raw=localStorage.getItem('flutter.crisp.notepadDoc.worksheet-functions');
                      if(!raw)return false;
                      const rows=JSON.parse(JSON.parse(raw)).l;
                      return rows[3].r===expected && rows.every(r=>!r.e) && rows[4].r;
                    }''', arg=expected)
                await result('5')
                initial = await read_document(page, document['i'])
                assert abs(float(initial['l'][4]['r']) - 0.9092974268256817) < 1e-8, initial
                async def edit(index, source):
                    field = page.get_by_role('textbox').nth(index)
                    await field.click()
                    await next_frames(page)
                    await field.fill(source)
                    await next_frames(page)
                await edit(1, 'f(x)=x^3+a')
                await result('19')
                await edit(0, 'a=5')
                await result('19')
                await page.wait_for_function('''() => {
                    const rows=JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.notepadDoc.worksheet-functions'))).l;
                    return rows[0].r==='5' && rows[1].r.includes('5') && Math.abs(Number(rows[4].r)+0.9589242746631385)<1e-8;
                }''')
                await page.screenshot(path=str(output/f"functions-{profile['viewport']['width']}.png"))
                await page.reload(wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for()
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                await result('19')
                await edit(3, 'g(3)')
                await page.wait_for_function('''() => {
                    const rows=JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.notepadDoc.worksheet-functions'))).l;
                    return rows[3].e && rows[3].e.includes('expects 2 arguments') && !rows[3].r;
                }''')
                await edit(3, 'g(3,2)')
                await result('19')
                await edit(1, 'f(t)=t^3+a')
                await result('19')
                await page.get_by_role('button', name='Link line to graph', exact=True).nth(1).click()
                await page.wait_for_function("(localStorage.getItem('flutter.crisp.functions')||'').includes('x^3+(5)')")
                await page.screenshot(path=str(output/f"function-graph-{profile['viewport']['width']}.png"))
                assert not errors, errors
                report['checks'].append({'viewport': profile['viewport'], 'nestedCalls': True,
                    'bodyAndCaptureEdits': True, 'transcendentalCall': True, 'reload': True, 'arityRecovery': True, 'linkedFunctionGraph': True})
            except Exception as error:
                report['error'] = str(error)
                report['savedDocument'] = await read_document(page, document['i'])
                report['pageErrors'] = errors
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
    parser.add_argument('--output', default='browser-results/notepad-functions')
    asyncio.run(check(parser.parse_args()))
