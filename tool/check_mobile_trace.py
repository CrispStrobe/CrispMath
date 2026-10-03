"""Playwright regression for touch tracing with web accessibility enabled."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright

async def read_x(page):
    text = await page.locator('body').inner_text() + '\n' + await page.locator('[aria-label]').evaluate_all("els=>els.map(e=>e.getAttribute('aria-label')).join('\\n')")
    return float(re.search(r'x = ([^,]+), y = ', text).group(1))

async def trace_ready(page, trace):
    if await trace.count() != 1:
        return {'ready': False, 'matches': await trace.count()}
    return await trace.evaluate("""el => {
        const r = el.getBoundingClientRect();
        const x = r.x + r.width / 2, y = r.y + r.height / 2;
        const hit = document.elementFromPoint(x, y);
        const toolbarLeft = window.innerWidth - 160;
        return {ready: r.width > 0 && r.height > 0 &&
            r.x >= toolbarLeft && r.right <= window.innerWidth &&
            r.y >= 0 && r.bottom <= window.innerHeight &&
            !!hit && (hit === el || el.contains(hit)),
            box: {x: r.x, y: r.y, width: r.width, height: r.height},
            hitTag: hit?.tagName, hitText: hit?.textContent?.slice(0, 120)};
    }""")


async def reveal_trace(page, session, trace, readiness):
    heading = page.get_by_role('heading', name=re.compile('^Graphing')).first
    await heading.wait_for()
    heading_box = await heading.bounding_box()
    assert heading_box, 'Graph heading must have visible geometry'
    width = page.viewport_size['width']
    toolbar_y = heading_box['y'] + heading_box['height'] / 2
    start_x, end_x = width - 24, width - 132
    for _ in range(8):
        state = await trace_ready(page, trace)
        readiness.append(state)
        if state['ready']:
            # Check normal Playwright actionability too; never force a click
            # through the clipped toolbar or its overlapping heading.
            await trace.click(trial=True, timeout=3000)
            return
        await session.send('Input.dispatchTouchEvent', {
            'type': 'touchStart', 'touchPoints': [{'x': start_x, 'y': toolbar_y}]})
        for step in range(1, 9):
            x = start_x + (end_x - start_x) * step / 8
            await session.send('Input.dispatchTouchEvent', {
                'type': 'touchMove', 'touchPoints': [{'x': x, 'y': toolbar_y}]})
            await page.wait_for_timeout(30)
        # Stop the finger before lifting so fling momentum cannot carry the
        # newly revealed icon straight past the narrow toolbar viewport.
        await page.wait_for_timeout(180)
        await session.send('Input.dispatchTouchEvent', {
            'type': 'touchMove', 'touchPoints': [{'x': end_x, 'y': toolbar_y}]})
        await session.send('Input.dispatchTouchEvent', {
            'type': 'touchEnd', 'touchPoints': []})
        await page.wait_for_timeout(250)
        state = await trace_ready(page, trace)
        readiness.append(state)
        if state['ready']:
            await trace.click(trial=True, timeout=3000)
            return
        # A real horizontal wheel event also exercises Flutter's scrollable
        # toolbar when accessibility owns the touch event target.
        await page.mouse.move(start_x, toolbar_y)
        await page.mouse.wheel(80, 0)
        await page.wait_for_timeout(250)
    raise AssertionError(f'Trace control never became visible and hittable: {readiness}')


async def check(args):
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        page = None
        readiness = []
        output = Path(args.screenshots)
        output.mkdir(parents=True, exist_ok=True)
        errors = []
        try:
            device = {'viewport': {'width': 390, 'height': 844}, 'has_touch': True}
            context = await browser.new_context(**device)
            page = await context.new_page()
            page.set_default_timeout(60000)
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
            session = await context.new_cdp_session(page)
            await reveal_trace(page, session, trace, readiness)
            await trace.click()
            await page.wait_for_function("document.body.innerText.includes('x = ') || [...document.querySelectorAll('[aria-label]')].some(e=>(e.getAttribute('aria-label')||'').includes('x = '))", timeout=90000)
            before = await read_x(page)
            await page.touchscreen.tap(280, 400)
            await page.wait_for_timeout(200)
            tapped = await read_x(page)
            assert tapped > before, (before, tapped)
            await session.send('Input.dispatchTouchEvent', {'type': 'touchStart', 'touchPoints': [{'x': 280, 'y': 400}]})
            await session.send('Input.dispatchTouchEvent', {'type': 'touchMove', 'touchPoints': [{'x': 230, 'y': 400}]})
            await session.send('Input.dispatchTouchEvent', {'type': 'touchEnd', 'touchPoints': []})
            await page.wait_for_timeout(200)
            dragged = await read_x(page)
            assert dragged < tapped, (tapped, dragged)
            print({'beforeX': before, 'tappedX': tapped, 'draggedX': dragged}, flush=True)
            assert not errors, errors
            await page.screenshot(path=str(output / 'mobile-touch-trace.png'))
            report = {'passed': True, 'viewport': device['viewport'],
                      'touchTap': True, 'touchDrag': True, 'beforeX': before,
                      'tappedX': tapped, 'draggedX': dragged, 'pageErrors': errors,
                      'toolbarReadiness': readiness}
            (output / 'mobile-touch-trace.json').write_text(json.dumps(report, indent=2) + '\n')
            print(report)
        except Exception as error:
            report = {'passed': False, 'error': str(error), 'pageErrors': errors,
                      'toolbarReadiness': readiness}
            if page is not None:
                try:
                    await page.screenshot(path=str(output / 'mobile-touch-trace-failure.png'))
                    (output / 'mobile-touch-trace-semantics.txt').write_text(
                        await page.locator('body').inner_text())
                except Exception as capture_error:
                    report['captureError'] = str(capture_error)
            (output / 'mobile-touch-trace.json').write_text(json.dumps(report, indent=2) + '\n')
            raise
        finally:
            await browser.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--screenshots', default='/tmp/crispmath-feature-screenshots')
    asyncio.run(check(parser.parse_args()))
