"""Verify actual worker provenance, visible details, save/reload and screenshots."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames

CASES = [
    ('1 + 1', '2', 'exact', 'integerArithmetic'),
    ('integrate(x^2, x, 0, 1)', '1/3', 'exact', 'polynomialIntegration'),
    ('integrate(exp(x^2), x, 0, 1)', None, 'approximate', 'simpsonIntegration'),
    ('simplify(sin(x))', None, 'symbolic', 'simplification'),
]

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    document = {'i': 'result-evidence', 'n': 'Methods and precision',
                'c': '2026-10-02T00:00:00Z', 'u': '2026-10-02T00:00:00Z',
                'l': [{'i': str(i), 's': ''} for i in range(len(CASES))]}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        context, page, errors = await context_for(browser,
            {'viewport': {'width': 1280, 'height': 900}, 'cpu': 1}, document)
        try:
            await bootstrap(page, args.url)
            await page.keyboard.press('Control+2')
            for i, (source, result, accuracy, method) in enumerate(CASES):
                editor = page.get_by_role('textbox').nth(i)
                await editor.click()
                await next_frames(page)
                await editor.fill(source)
                await page.wait_for_function('''item => {
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.result-evidence');
                  if(!raw)return false;
                  const line=JSON.parse(JSON.parse(raw)).l.find(line=>line.i===item.id);
                  return line&&line.s===item.source&&line.r&&line.evidence&&
                    (!item.result||line.r===item.result)&&
                    line.evidence.accuracy===item.accuracy&&line.evidence.method===item.method;
                }''', arg={'id': str(i), 'source': source, 'result': result,
                           'accuracy': accuracy, 'method': method}, timeout=150000)
            raw = await page.evaluate("localStorage.getItem('flutter.crisp.notepadDoc.result-evidence')")
            saved = json.loads(json.loads(raw))
            assert abs(float(saved['l'][2]['r']) - 1.4626517459) < 1e-7
            assert saved['l'][3]['evidence'].get('unchanged') is True
            await page.get_by_role('button', name='Approximate · Numerical integration (Simpson’s rule)', exact=True).click()
            await page.get_by_text('Result details', exact=True).wait_for()
            await page.screenshot(path=str(output/'numerical-method.png'))
            await page.get_by_role('button', name='Close', exact=True).click()
            await page.reload(wait_until='domcontentloaded')
            await page.locator('canvas').first.wait_for(timeout=300000)
            await page.locator('flt-semantics-placeholder').evaluate('(element)=>element.click()')
            await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
            await page.get_by_role('button', name='Approximate · Numerical integration (Simpson’s rule)', exact=True).wait_for()
            await page.screenshot(path=str(output/'worksheet-methods.png'))
            assert not errors, errors
            report = {'cases': saved['l'], 'restored': True, 'pageErrors': errors}
            (output/'result-evidence.json').write_text(json.dumps(report, indent=2)+'\n')
            print(json.dumps(report), flush=True)
        except Exception:
            await page.screenshot(path=str(output/'failure.png'), timeout=10000)
            (output/'failure-state.json').write_text(json.dumps(
                {'savedDocument': await page.evaluate("localStorage.getItem('flutter.crisp.notepadDoc.result-evidence')"),
                 'pageErrors': errors}, indent=2))
            raise
        finally:
            await context.close()
            await browser.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/provenance')
    asyncio.run(check(parser.parse_args()))
