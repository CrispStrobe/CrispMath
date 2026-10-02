"""Live regression: calculator and worksheet accept both definite-integral forms."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames

CASES = ['integrate(x^2,x,0,1)', 'integrate(x^2,(x,0,1))']

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    document = {'i': 'integral-syntax', 'n': 'Integral syntax regression',
        'c': '2026-10-02T00:00:00Z', 'u': '2026-10-02T00:00:00Z',
        'l': [{'i': str(i), 's': ''} for i in range(len(CASES))]}
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        context, page, errors = await context_for(browser, {'viewport': {'width': 1280, 'height': 900}}, document)
        report = {'url': args.url, 'calculator': [], 'pageErrors': errors}
        try:
            await bootstrap(page, args.url)
            await page.get_by_role('button', name='Edit expression', exact=True).click()
            for source in CASES:
                editor = page.get_by_role('textbox', name='Expression', exact=True)
                await editor.fill(source)
                await editor.press('Enter')
                await page.wait_for_function('''() => {
                    const raw=localStorage.getItem('flutter.crisp.history');
                    if(!raw)return false;
                    const r=JSON.parse(JSON.parse(raw))[0];
                    return r.r==='1/3' && r.evidence?.accuracy==='exact' && r.evidence?.method==='polynomialIntegration';
                }''', timeout=60000)
                report['calculator'].append({'source': source, 'result': '1/3'})
                # Require the next result to be a new history entry, not the prior pass.
                if source != CASES[-1]:
                    await editor.fill('2+2')
                    await editor.press('Enter')
                    await page.wait_for_function("JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.history')))[0].r==='4'")
            await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
            for i, source in enumerate(CASES):
                field = page.get_by_role('textbox').nth(i)
                await field.click()
                await next_frames(page)
                await field.fill(source)
                await page.wait_for_function('''index => {
                    const raw=localStorage.getItem('flutter.crisp.notepadDoc.integral-syntax');
                    return raw && JSON.parse(JSON.parse(raw)).l[index].r==='1/3';
                }''', arg=i)
            await page.wait_for_function('''() => {
                const raw=localStorage.getItem('flutter.crisp.notepadDoc.integral-syntax');
                if(!raw)return false;
                return JSON.parse(JSON.parse(raw)).l.every(l=>l.r==='1/3' && l.evidence?.accuracy==='exact');
            }''', timeout=60000)
            report['worksheet'] = await page.evaluate("JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.notepadDoc.integral-syntax'))).l")
            await next_frames(page)
            await page.screenshot(path=str(output/'integral-syntax.png'))
            assert not errors, errors
            report['passed'] = True
        except Exception as error:
            report['passed'] = False
            report['error'] = str(error)
            report['history'] = await page.evaluate("localStorage.getItem('flutter.crisp.history')")
            await page.screenshot(path=str(output/'failure.png'))
            raise
        finally:
            (output/'report.json').write_text(json.dumps(report, indent=2)+'\n')
            await context.close()
            await browser.close()
    print(json.dumps(report), flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://localhost:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--output', default='browser-results/integral-syntax')
    asyncio.run(check(parser.parse_args()))
