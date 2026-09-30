"""Playwright regression for touch tracing with web accessibility enabled."""
import argparse
import asyncio
import re
from pathlib import Path
from playwright.async_api import async_playwright

async def read_x(page):
    text = await page.locator('body').inner_text() + '\n' + await page.locator('[aria-label]').evaluate_all("els=>els.map(e=>e.getAttribute('aria-label')).join('\\n')")
    return float(re.search(r'x = ([^,]+), y = ', text).group(1))

async def check(args):
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        try:
            device = {'viewport': {'width': 390, 'height': 844}, 'has_touch': True}
            context = await browser.new_context(**device)
            page = await context.new_page()
            page.set_default_timeout(60000)
            errors = []
            def page_error(error):
                detail = str(error) + '\n' + (error.stack or '')
                errors.append(detail)
                print('Page error:', detail, flush=True)
            page.on('pageerror', page_error)
            def console(message):
                if message.type == 'error' and any(s in message.text for s in ['EXCEPTION CAUGHT', 'setState()', 'RenderFlex', 'Unhandled']):
                    errors.append(message.text)
            page.on('console', console)
            await page.add_init_script("localStorage.setItem('flutter.crisp.onboardingDismissed','true')")
            await page.goto(args.url, wait_until='domcontentloaded')
            await page.locator('canvas').first.wait_for(timeout=90000)
            await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
            await page.get_by_role('button', name=re.compile('^Graphing')).click()
            trace = page.get_by_role('button', name=re.compile('^Trace curve'))
            for _ in range(6):
                if await trace.count():
                    break
                await page.mouse.move(340, 70)
                await page.mouse.wheel(180, 0)
                await page.wait_for_timeout(200)
            await trace.click()
            await page.wait_for_function("document.body.innerText.includes('x = ') || [...document.querySelectorAll('[aria-label]')].some(e=>(e.getAttribute('aria-label')||'').includes('x = '))", timeout=90000)
            before = await read_x(page)
            await page.touchscreen.tap(280, 400)
            await page.wait_for_timeout(200)
            tapped = await read_x(page)
            assert tapped > before, (before, tapped)
            session = await context.new_cdp_session(page)
            await session.send('Input.dispatchTouchEvent', {'type': 'touchStart', 'touchPoints': [{'x': 280, 'y': 400}]})
            await session.send('Input.dispatchTouchEvent', {'type': 'touchMove', 'touchPoints': [{'x': 230, 'y': 400}]})
            await session.send('Input.dispatchTouchEvent', {'type': 'touchEnd', 'touchPoints': []})
            await page.wait_for_timeout(200)
            dragged = await read_x(page)
            assert dragged < tapped, (tapped, dragged)
            print({'beforeX': before, 'tappedX': tapped, 'draggedX': dragged}, flush=True)
            assert not errors, errors
            Path(args.screenshots).mkdir(parents=True, exist_ok=True)
            await page.screenshot(path=str(Path(args.screenshots) / 'mobile-touch-trace.png'))
            print({'viewport': str(device['viewport']), 'touchTap': True, 'touchDrag': True, 'beforeX': before, 'tappedX': tapped, 'draggedX': dragged, 'pageErrors': errors})
        finally:
            await browser.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--screenshots', default='/tmp/crispmath-feature-screenshots')
    asyncio.run(check(parser.parse_args()))
