"""Check mobile paste/submit and linked-variable edit/inspect/save against a real bundle."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright, expect
from benchmark_workflows import bootstrap, context_for, next_frames
from check_feature_browser import labels, read_text

async def check(args):
    document = {'i': 'core-workflow', 'n': 'Core workflow',
                'c': '2026-10-01T00:00:00Z', 'u': '2026-10-01T00:00:00Z',
                'l': [{'i': 'parameter', 's': 'a = 2', 'r': '2'},
                      {'i': 'function', 's': 'f = a*sin(x)'}]}
    async with async_playwright() as pw:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await pw.chromium.launch(**options)
        context, page, errors = await context_for(browser,
            {'viewport': {'width': 390, 'height': 844}, 'has_touch': True, 'cpu': 1}, document)
        output = Path(args.output)
        output.mkdir(parents=True, exist_ok=True)
        try:
            await bootstrap(page, args.url)
            await page.get_by_role('button', name='Edit expression', exact=True).click()
            editor = page.get_by_role('textbox', name='Expression', exact=True)
            await editor.click()
            await next_frames(page)
            await editor.fill('(3+4)*5')
            await expect(editor).to_have_value('(3+4)*5')
            await editor.press('Enter')
            await page.wait_for_function("JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.history')))[0].r==='35'")
            await page.get_by_role('button', name='Math preview', exact=True).click()
            await page.keyboard.press('Control+2')
            await page.get_by_role('button', name='Link line to graph', exact=True).last.click()
            linked = page.get_by_role('button', name='Linked Y3: Core workflow', exact=True)
            await linked.click()
            await page.get_by_role('button', name='Edit a', exact=True).click()
            boxes = page.get_by_role('textbox')
            parameter = boxes.first
            await expect(parameter).to_be_focused()
            await expect(parameter).to_have_value('a = 2')
            await next_frames(page)
            await parameter.fill('a = 3')
            await expect(parameter).to_have_value('a = 3')
            await page.wait_for_function("(localStorage.getItem('flutter.crisp.functions')||'').includes('(3)*sin(x)')")
            await page.get_by_role('button', name=re.compile(r'^Graphing')).click()
            await linked.click()
            assert re.search(r'a = 3(?:\.0)?(?:\n|$)', await labels(page))
            await page.get_by_role('button', name='Close', exact=True).click()
            await page.get_by_role('button', name='Trace curve', exact=True).click()
            await page.wait_for_function("[...document.querySelectorAll('[aria-label]')].some(e=>/x = .*y = /.test(e.getAttribute('aria-label')))")
            await page.screenshot(path=str(output/'mobile-inspect.png'))
            await page.reload(wait_until='domcontentloaded')
            await page.locator('canvas').first.wait_for(timeout=300000)
            await page.locator('flt-semantics-placeholder').evaluate('(e)=>e.click()')
            await page.keyboard.press('Control+3')
            await linked.click()
            assert re.search(r'a = 3(?:\.0)?(?:\n|$)', await labels(page))
            assert not errors, errors
            report = {'mobileTextEntry': True, 'submitResult': 35, 'variableDefinitionFocused': True,
                      'linkedGraphUpdated': True, 'traceInspected': True, 'savedReloadRestored': True,
                      'pageErrors': errors}
            (output/'core-workflow.json').write_text(json.dumps(report, indent=2)+'\n')
            print(json.dumps(report), flush=True)
        except Exception:
            (output/'failure-labels.txt').write_text(await labels(page))
            await page.screenshot(path=str(output/'failure.png'))
            raise
        finally:
            await browser.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766')
    parser.add_argument('--chromium')
    parser.add_argument('--output', default='browser-results/core-workflow')
    asyncio.run(check(parser.parse_args()))
