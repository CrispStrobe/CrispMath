"""Measure actual UI workflows in desktop/phone browser profiles.

Measures automation-to-observed-state latency and browser RAF intervals, not
physical-device FPS. CPU throttling is configured on the page CDP session; worker timing is not calibrated.
"""
import argparse
import asyncio
import json
from pathlib import Path
import platform
from datetime import datetime, timezone
import re
import time
from playwright.async_api import async_playwright, expect
from check_feature_browser import labels, type_text, read_text
from workflow_metrics import large_document, summarize

PROFILES = {'desktop': {'viewport': {'width': 1280, 'height': 900}, 'cpu': 1},
            'phone': {'viewport': {'width': 390, 'height': 844}, 'has_touch': True, 'cpu': 4}}
FRAME_PROBE = '''() => {window.workflowFrames=[]; let previous=null;
 window.workflowFrameProbe=true;
 function frame(now){if(!window.workflowFrameProbe)return;
 if(previous!==null)window.workflowFrames.push(now-previous);previous=now;requestAnimationFrame(frame)}
 requestAnimationFrame(frame)}'''


async def next_frames(page):
    await page.evaluate('() => new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve)))')


async def graph_x_min(page):
    await page.get_by_role('button', name=re.compile(r'^Graph bounds\b')).click()
    value = float(await read_text(page.get_by_role('textbox', name='x minimum', exact=True)))
    await page.get_by_role('button', name='Cancel', exact=True).click()
    await page.get_by_role('textbox', name='x minimum', exact=True).wait_for(state='hidden')
    await next_frames(page)
    return value


async def bootstrap(page, url):
    await page.goto(url, wait_until='domcontentloaded')
    await page.locator('canvas').first.wait_for(timeout=300000)
    await page.locator('flt-semantics-placeholder').evaluate('(element)=>element.click()')
    await page.get_by_role('button', name=re.compile('Evaluate')).wait_for()


async def context_for(browser, profile, document=None):
    options = {'viewport': profile['viewport'], 'has_touch': profile.get('has_touch', False),
               'permissions': ['clipboard-read', 'clipboard-write']}
    context = await browser.new_context(**options)
    preferences = {'crisp.onboardingDismissed': True, 'crisp.locale': 'en'}
    if document:
        preferences.update({'crisp.notepadIndex': json.dumps([document['i']]),
                            'crisp.notepadDoc.' + document['i']: json.dumps(document),
                            'crisp.currentNotepadDoc': document['i']})
    await context.add_init_script('''if(!sessionStorage.getItem('workflowSeeded')) {
      for(const [key,value] of Object.entries('''+json.dumps(preferences)+'''))
       localStorage.setItem('flutter.'+key,JSON.stringify(value));
      sessionStorage.setItem('workflowSeeded','true') }''')
    page = await context.new_page()
    page.set_default_timeout(120000)
    session = await context.new_cdp_session(page)
    await session.send('Emulation.setCPUThrottlingRate', {'rate': profile['cpu']})
    errors = []
    page.on('pageerror', lambda error: errors.append(str(error)))
    def console(message):
        if message.type == 'error' and any(token in message.text for token in
                ['EXCEPTION CAUGHT', 'setState()', 'RenderFlex', 'Unhandled']):
            errors.append(message.text)
    page.on('console', console)
    return context, page, errors


def write_report(args, results):
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    Path(args.output).write_text(json.dumps(results, indent=2)+'\n')


async def measure_profile(browser, name, profile, args, results):
    print('Measuring '+name, flush=True)
    result = {'profile': name, **profile, 'status': 'running', 'startup_cold_ms': [], 'startup_warm_ms': []}
    results['profiles'].append(result)
    for _ in range(args.startups):
        context, page, errors = await context_for(browser, profile)
        started = time.perf_counter()
        await bootstrap(page, args.url)
        result['startup_cold_ms'].append((time.perf_counter()-started)*1000)
        started = time.perf_counter()
        await page.reload(wait_until='domcontentloaded')
        await page.locator('canvas').first.wait_for()
        await page.locator('flt-semantics-placeholder').evaluate('(element)=>element.click()')
        await page.get_by_role('button', name=re.compile('Evaluate')).wait_for()
        result['startup_warm_ms'].append((time.perf_counter()-started)*1000)
        assert not errors, errors
        await context.close()
        write_report(args, results)
    context, page, errors = await context_for(browser, profile)
    try:
        await bootstrap(page, args.url)
        print('Calculations', flush=True)
        calculations = []
        for index in range(args.trials):
            expression = f'{31+index}+37'
            await page.get_by_role('button', name='clear', exact=True).click()
            await page.keyboard.type(expression)
            started = time.perf_counter()
            await page.get_by_role('button', name=re.compile('Evaluate')).click()
            await page.wait_for_function('''expected=>{
              const raw=localStorage.getItem('flutter.crisp.history');
              if(!raw)return false;try{return JSON.parse(JSON.parse(raw))[0].r===expected}catch{return false}}''', arg=str(68+index), timeout=15000)
            calculations.append((time.perf_counter()-started)*1000)
        result['calculate_ms'] = calculations
        write_report(args, results)
        print('Graph interaction', flush=True)
        await page.keyboard.press('Control+3')
        await next_frames(page)
        await page.locator('[aria-label="Updating graph"]').wait_for(state='hidden')
        await page.get_by_role('button', name='Trace curve', exact=True).click()
        await page.wait_for_function("document.body.innerText.includes('x = ') || [...document.querySelectorAll('[aria-label]')].some(element=>element.getAttribute('aria-label').includes('x = '))")
        await page.mouse.click(profile['viewport']['width']*.7, 400)
        traces = []
        for _ in range(args.trials):
            before = re.search(r'x = ([^,]+), y = ', await labels(page)).group(1)
            started = time.perf_counter()
            await page.keyboard.press('ArrowRight')
            await page.wait_for_function('''before=>{
             const text=document.body.innerText+' '+[...document.querySelectorAll('[aria-label]')].map(element=>element.getAttribute('aria-label')).join(' ');
             const match=text.match(/x = ([^,]+), y = /);return match&&match[1]!==before}''', arg=before)
            traces.append((time.perf_counter()-started)*1000)
        result['trace_key_ms'] = traces
        write_report(args, results)
        await page.get_by_role('button', name='Trace curve', exact=True).click()
        x_min_before = await graph_x_min(page)
        await page.evaluate(FRAME_PROBE)
        pans = []
        for _ in range(args.trials):
            started = time.perf_counter()
            width = profile['viewport']['width']
            await page.mouse.move(width*.5, 400)
            await page.mouse.down()
            await page.mouse.move(width*.5+40, 430, steps=10)
            await page.mouse.up()
            await next_frames(page)
            await page.locator('[aria-label="Updating graph"]').wait_for(state='hidden')
            pans.append((time.perf_counter()-started)*1000)
        result['pan_to_idle_ms'] = pans
        frames = await page.evaluate('() => {window.workflowFrameProbe=false;return window.workflowFrames}')
        result['pan_frame_intervals_ms'] = frames
        result['pan_frames_over_50ms'] = sum(frame>50 for frame in frames)
        x_min_after = await graph_x_min(page)
        assert x_min_after != x_min_before, 'Pointer pans did not change graph bounds'
        result['pan_x_min_before_after'] = [x_min_before, x_min_after]
        write_report(args, results)
        assert not errors, errors
    finally:
        await context.close()
    result['notepad'] = []
    for rows in args.rows:
        print(f'Notepad {rows} rows', flush=True)
        document = large_document(rows)
        context, page, errors = await context_for(browser, profile, document)
        try:
            await bootstrap(page, args.url)
            started = time.perf_counter()
            await page.get_by_role('button', name=re.compile('^Notepad')).click()
            await page.get_by_role('button', name=re.compile('^Add line')).wait_for(timeout=15000)
            field = page.get_by_role('textbox').first
            await field.click()
            await expect(field).to_have_value('v0 = 1')
            open_ms = (time.perf_counter()-started)*1000
            edits = []
            for base in range(2, 2+args.trials):
                await field.click()
                await expect(field).to_have_value(f'v0 = {base-1}')
                await next_frames(page)
                started = time.perf_counter()
                await field.fill(f'v0 = {base}')
                await next_frames(page)
                await expect(field).to_have_value(f'v0 = {base}')
                print(f'Editing {rows} rows: v0 = {base}', flush=True)
                await page.wait_for_function('''expected=>{
                 const raw=localStorage.getItem('flutter.crisp.notepadDoc.performance-doc');if(!raw)return false;
                 const document=JSON.parse(JSON.parse(raw));
                 return document.l[0].s==='v0 = '+expected.base&&document.l.at(-1).r===String(expected.last)}''', arg={'base': base, 'last': rows+base-1}, timeout=max(120000, rows*100))
                edits.append((time.perf_counter()-started)*1000)
            assert not errors, errors
            result['notepad'].append({'rows': rows, 'open_ms': open_ms, 'edit_to_saved_result_ms': edits})
            write_report(args, results)
        except Exception:
            print('Notepad failure', await page.evaluate('''() => {const document=JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.notepadDoc.performance-doc')));return {updated:document.u,first:document.l[0],last:document.l.at(-1)}}'''), flush=True)
            raise
        finally:
            await context.close()
    result['status'] = 'passed'
    return result


async def run(args):
    results = {'source': args.source, 'host': platform.platform(),
               'measured_at': datetime.now(timezone.utc).isoformat(),
               'trials': args.trials, 'startup_trials': args.startups,
               'notepad_entry': 'atomic text replacement after Flutter focus synchronization',
               'measurement': 'browser UI latency; not physical FPS; page CDP CPU throttle, worker timing not calibrated', 'profiles': []}
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        results['browser'] = browser.version
        try:
            for name in args.profiles:
                profile = await measure_profile(browser, name, PROFILES[name], args, results)
                profile['summary'] = {key: summarize(value) for key,value in profile.items()
                                      if key.endswith('_ms') and isinstance(value, list) and value}
                for document in profile['notepad']:
                    document['summary'] = summarize(document['edit_to_saved_result_ms'])
                write_report(args, results)
                print(json.dumps(profile), flush=True)
        except Exception as error:
            results['status'] = 'failed'
            results['error'] = str(error)
            write_report(args, results)
            raise
        finally:
            await browser.close()
    results['status'] = 'passed'
    write_report(args, results)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--profiles', nargs='+', choices=PROFILES, default=list(PROFILES))
    parser.add_argument('--rows', type=int, nargs='+', default=[500, 2000])
    parser.add_argument('--trials', type=int, default=5)
    parser.add_argument('--startups', type=int, default=3)
    parser.add_argument('--source', default='local working tree')
    parser.add_argument('--output', default='browser-results/workflow-performance.json')
    arguments = parser.parse_args()
    if arguments.trials < 1 or arguments.startups < 1 or min(arguments.rows) < 1:
        parser.error('trials, startups and rows must all be positive')
    asyncio.run(run(arguments))
