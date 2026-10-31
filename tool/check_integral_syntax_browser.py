"""Live regression: calculator and worksheet accept both definite-integral forms."""
import argparse
import asyncio
import json
import re
import time
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit
from playwright.async_api import async_playwright, expect
from benchmark_workflows import bootstrap, context_for, next_frames
from check_round6_statistics_browser import real_click

CASES = ['integrate(x^2,x,0,1)', 'integrate(x^2,(x,0,1))']
TRACE_PREFIX = '[CALC-INPUT-TRACE] '
TRACE_LIMIT = 512


def diagnostic_url(url):
    parts = urlsplit(url)
    query = [(key, value) for key, value in parse_qsl(parts.query, keep_blank_values=True)
             if key != 'crispInputTrace']
    query.append(('crispInputTrace', '1'))
    return urlunsplit(parts._replace(query=urlencode(query)))


def collect_trace(message, report):
    """Capture only our structured, text-free Flutter instrumentation."""
    _, separator, payload = message.partition(TRACE_PREFIX)
    if not separator:
        return
    try:
        event = json.loads(payload)
    except (TypeError, ValueError):
        report['flutterTraceMalformed'] += 1
        return
    if not isinstance(event, dict):
        report['flutterTraceMalformed'] += 1
    elif len(report['flutterTrace']) < TRACE_LIMIT:
        report['flutterTrace'].append(event)
    else:
        report['flutterTraceDropped'] += 1


async def editor_state(editor, stage, report):
    state = await editor.evaluate('''el => {
        if (!window.crispInputNodeIds) {
            window.crispInputNodeIds = new WeakMap();
            window.crispInputNextNodeId = 1;
        }
        const id = node => {
            if (!node) return null;
            if (!window.crispInputNodeIds.has(node))
                window.crispInputNodeIds.set(node, window.crispInputNextNodeId++);
            return window.crispInputNodeIds.get(node);
        };
        return {value: el.value, focused: el === document.activeElement,
            nodeId: id(el), connected: el.isConnected,
            activeNodeId: id(document.activeElement),
            activeConnected: document.activeElement?.isConnected ?? false,
            selectionStart: el.selectionStart, selectionEnd: el.selectionEnd};
    }''')
    state.update({'stage': stage, 'traceCount': len(report['flutterTrace'])})
    report['editorStates'].append(state)


async def wait_for_app_input(page, report, expected, start_index=0, timeout=15.0):
    """Wait until the app's own editor, not just the DOM node, holds `expected`.

    `editorIsTarget` is emitted by the Flutter-side trace, so this fails when
    the browser input shows text that never reached the editing client.
    """
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if any(event.get('stage') == 'editor-to-math' and
               event.get('editorIsTarget') is True and event.get('mathIsTarget') is True
               for event in report['flutterTrace'][start_index:]):
            return
        await page.wait_for_timeout(100)
    raise AssertionError(
        f'Flutter editor never received {expected!r}; '
        f'last trace: {report["flutterTrace"][-1:] or "none"}')


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
        context, page, errors = await context_for(browser, {'viewport': {'width': 1280, 'height': 900}, 'cpu': 1}, document)
        report = {'url': args.url, 'calculator': [], 'editorStates': [], 'pageErrors': errors,
                  'flutterTrace': [], 'flutterTraceMalformed': 0, 'flutterTraceDropped': 0}
        page.on('console', lambda message: collect_trace(message.text, report))
        try:
            await bootstrap(page, diagnostic_url(args.url))
            await real_click(page, page.get_by_role(
                'button', name='Edit expression', exact=True))
            for source in CASES:
                editor = page.get_by_role('textbox', name='Expression', exact=True)
                await real_click(page, editor)
                await next_frames(page)
                # Real key events exercise the currently focused Flutter text
                # client; a DOM value alone did not prove the app received it.
                await page.keyboard.type(source, delay=10)
                await next_frames(page)
                await expect(editor).to_have_value(source)
                await editor.press('Enter')
                await page.wait_for_function('''source => {
                    const raw=localStorage.getItem('flutter.crisp.history');
                    if(!raw)return false;
                    const r=JSON.parse(JSON.parse(raw))[0];
                    return r.e===source && r.r==='1/3' && r.evidence?.accuracy==='exact' && r.evidence?.method==='polynomialIntegration';
                }''', arg=source, timeout=60000)
                report['calculator'].append({'source': source, 'result': '1/3'})
                # Require the next result to be a new history entry, not the prior pass.
                if source != CASES[-1]:
                    await expect(editor).to_have_value('')
                    await real_click(page, editor)
                    await next_frames(page)
                    await editor_state(editor, 'before typing', report)
                    trace_start = len(report['flutterTrace'])
                    await page.keyboard.type('2+2', delay=10)
                    await editor_state(editor, 'after fill', report)
                    await expect(editor).to_have_value('2+2')
                    # A DOM value is not proof: the field can show text while
                    # Flutter's editing client never received it. When the app
                    # is built with the input trace, require the app itself to
                    # hold the text before submitting.
                    if report['flutterTrace']:
                        await wait_for_app_input(page, report, '2+2', start_index=trace_start)
                    await next_frames(page)
                    await editor_state(editor, 'before Enter', report)
                    await expect(editor).to_have_value('2+2')
                    await expect(editor).to_be_focused()
                    await page.screenshot(path=str(output/'before-second-enter.png'))
                    report['beforeSecondEnterScreenshot'] = 'before-second-enter.png'
                    await editor.press('Enter')
                    await page.wait_for_function("""() => {
                        const entry=JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.history')))[0];
                        return entry.e==='2+2' && entry.r==='4';
                    }""", timeout=15000)
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
