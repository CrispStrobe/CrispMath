"""Capture real browser workflows at consistent phone, tablet and desktop sizes.
These are web screenshots; they do not represent native simulator/device tests.
"""
import argparse
import asyncio
import html
import json
import re
from pathlib import Path
from urllib.parse import urljoin
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames

PROFILES = [
    ('iphone', {'viewport': {'width': 440, 'height': 956}, 'has_touch': True, 'cpu': 1}),
    ('ipad', {'viewport': {'width': 1032, 'height': 1376}, 'has_touch': True, 'cpu': 1}),
    ('desktop', {'viewport': {'width': 1440, 'height': 1000}, 'cpu': 1}),
]
DOCUMENT = {'i': 'gallery', 'n': 'A connected math worksheet',
            'c': '2026-10-02T00:00:00Z', 'u': '2026-10-02T00:00:00Z',
            'l': [{'i': 'heading', 's': '## Explore a function'},
                  {'i': 'amplitude', 's': 'a = 3'},
                  {'i': 'function', 's': 'f = a*sin(x)'},
                  {'i': 'integral', 's': 'integrate(x^2, x, 0, 1)'},
                  {'i': 'units', 's': '5 km + 300 m'}]}

async def capture(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    manifest = {'source': args.source, 'url': args.url, 'kind': 'web-browser',
                'profiles': [], 'screenshots': [], 'pageErrors': []}
    async with async_playwright() as pw:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await pw.chromium.launch(**options)
        try:
            for name, profile in PROFILES:
                context, page, errors = await context_for(browser, profile, DOCUMENT)
                try:
                    await bootstrap(page, args.url)
                    deployed = await context.request.get(urljoin(args.url, 'build-info.json'))
                    observed_source = (await deployed.json())['source']
                    assert observed_source == args.source, f'Gallery source mismatch: {observed_source}'
                    await page.get_by_role('button', name='Edit expression', exact=True).click()
                    editor = page.get_by_role('textbox', name='Expression', exact=True)
                    for expression, result in [('integrate(x^2,(x,0,1))', '1/3')]:
                        await editor.click()
                        await next_frames(page)
                        await editor.fill(expression)
                        await editor.press('Enter')
                        await page.wait_for_function("expected=>JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.history')))[0].r===expected", arg=result)
                    await page.get_by_role('button', name='Math preview', exact=True).click()
                    await page.evaluate('document.activeElement.blur()')
                    await page.mouse.move(1, 1)
                    await page.wait_for_timeout(500)
                    await next_frames(page)
                    async def shot(scene):
                        file = f'{name}-{scene}.png'
                        await page.screenshot(path=str(output/file), animations='disabled')
                        manifest['screenshots'].append({'profile': name, 'scene': scene, 'file': file,
                            'width': profile['viewport']['width'], 'height': profile['viewport']['height']})
                    await shot('calculator')
                    await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                    await page.get_by_role('button', name='Document menu', exact=True).click()
                    await page.locator('[aria-label="Recalculate all"]').click()
                    await page.wait_for_function("""() => {
                        const raw=localStorage.getItem('flutter.crisp.notepadDoc.gallery');
                        if(!raw)return false;
                        const lines=JSON.parse(JSON.parse(raw)).l;
                        return lines.find(l=>l.i==='amplitude').r==='3' &&
                          lines.find(l=>l.i==='integral').r==='1/3';
                    }""", timeout=150000)
                    await page.get_by_role('button', name='Link line to graph', exact=True).nth(1).click()
                    await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                    await next_frames(page)
                    await shot('worksheet')
                    await page.get_by_role('button', name=re.compile(r'^Graphing')).click()
                    await page.locator('[aria-label="Updating graph"]').wait_for(state='hidden')
                    await page.get_by_role('button', name='Trace curve', exact=True).click()
                    await page.wait_for_function("[...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label').includes('x = '))")
                    await next_frames(page)
                    await shot('graph-trace')
                    linked = page.get_by_role('button', name='Linked Y3: A connected math worksheet', exact=True)
                    await linked.click()
                    await page.get_by_role('button', name='Edit a', exact=True).wait_for()
                    await shot('linked-source')
                    assert not errors, errors
                    manifest['profiles'].append({'name': name, **profile, 'passed': True})
                except Exception as error:
                    manifest['profiles'].append({'name': name, **profile, 'passed': False, 'error': str(error)})
                    manifest['failureState'] = await page.evaluate("({savedDocument:localStorage.getItem('flutter.crisp.notepadDoc.gallery'), labels:[...document.querySelectorAll('[aria-label]')].map(e=>e.getAttribute('aria-label'))})")
                    await page.screenshot(path=str(output/f'{name}-failure.png'))
                    raise
                finally:
                    manifest['pageErrors'].extend(errors)
                    await context.close()
        finally:
            (output/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
            await browser.close()
    (output/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    cards = ''.join(f'<figure><a href="{html.escape(s["file"])}"><img loading="lazy" src="{html.escape(s["file"])}" alt="{html.escape(s["profile"]+" "+s["scene"])}"></a><figcaption>{html.escape(s["profile"]+" · "+s["scene"])}</figcaption></figure>' for s in manifest['screenshots'])
    (output/'index.html').write_text('<!doctype html><meta charset="utf-8"><title>CrispMath workflow gallery</title><style>body{font:16px system-ui;background:#eef1f5;color:#172033;margin:32px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:24px}figure{margin:0;background:white;padding:16px;border-radius:12px}img{width:100%;height:480px;object-fit:contain}figcaption{padding:12px 0}</style><h1>CrispMath workflow gallery</h1><p>Actual web app captures. Source '+html.escape(args.source)+'. Native Apple captures and physical-device tests are recorded separately.</p><main>'+cards+'</main>')
    print(json.dumps(manifest), flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--source', required=True)
    parser.add_argument('--chromium')
    parser.add_argument('--output', default='browser-results/gallery')
    asyncio.run(capture(parser.parse_args()))
