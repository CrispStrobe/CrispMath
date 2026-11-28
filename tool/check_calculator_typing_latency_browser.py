"""Measure keystroke latency in the real calculator editor.

Types expressions one key at a time with pauses longer than the live-preview
debounce, so every pause lets the preview run before the next key. For each
key it records the time from the key press until the editor holds the new
text and a frame has been painted, plus every main-thread long task observed
while typing. Run it against several builds to compare them.
"""
import argparse
import asyncio
import json
import statistics
from pathlib import Path

from playwright.async_api import async_playwright, expect

from benchmark_workflows import bootstrap, context_for, next_frames
from check_round6_statistics_browser import real_click

EXPRESSIONS = {
    'arithmetic': '9.5-2+3*4',
    'integral': 'integrate(x^2*sin(x),x)',
    'factor': 'factor(x^12-1)',
}

LONG_TASKS = '''() => {
  window.__longTasks = [];
  new PerformanceObserver(list => {
    for (const e of list.getEntries()) window.__longTasks.push(e.duration);
  }).observe({type: 'longtask', buffered: false});
}'''


async def type_measured(page, editor, text, pause_ms):
    latencies = []
    typed = ''
    for ch in text:
        typed += ch
        start = await page.evaluate('performance.now()')
        await page.keyboard.type(ch)
        await page.wait_for_function('''([sel, expected]) => {
          const el = document.querySelector(sel);
          return el && el.value === expected;
        }''', arg=['input[aria-label="Expression"], textarea[aria-label="Expression"]', typed],
            polling='raf')
        end = await page.evaluate(
            'new Promise(r => requestAnimationFrame(() => r(performance.now())))')
        latencies.append(end - start)
        await page.wait_for_timeout(pause_ms)
    await expect(editor).to_have_value(text)
    return latencies


def summary(values):
    ordered = sorted(values)
    return {
        'count': len(values),
        'median_ms': round(statistics.median(ordered), 1) if ordered else None,
        'p95_ms': round(ordered[int(0.95 * (len(ordered) - 1))], 1) if ordered else None,
        'max_ms': round(ordered[-1], 1) if ordered else None,
    }


def hot_functions(profile, limit=40):
    """Self and inclusive time per function from a CDP CPU profile."""
    nodes = {n['id']: n for n in profile['nodes']}
    parent = {}
    for n in profile['nodes']:
        for c in n.get('children', []):
            parent[c] = n['id']
    samples = profile.get('samples', [])
    deltas = profile.get('timeDeltas', [])
    self_ms, total_ms = {}, {}

    def name(node):
        f = node['callFrame']
        return f"{f['functionName'] or '(anonymous)'} {f['url'].rsplit('/', 1)[-1]}:{f['lineNumber']}"
    for sample, delta in zip(samples, deltas[1:] + [0]):
        ms = delta / 1000
        node = nodes[sample]
        key = name(node)
        self_ms[key] = self_ms.get(key, 0) + ms
        seen = set()
        cur = sample
        while cur is not None:
            k = name(nodes[cur])
            if k not in seen:
                total_ms[k] = total_ms.get(k, 0) + ms
                seen.add(k)
            cur = parent.get(cur)
    top = lambda d: [[k, round(v, 1)] for k, v in sorted(d.items(), key=lambda kv: -kv[1])[:limit]]
    return {'self': top(self_ms), 'total': top(total_ms)}


async def measure(browser, label, url, cpu, pause_ms, cpu_profile=False):
    context, page, errors = await context_for(browser, {
        'viewport': {'width': 1280, 'height': 900}, 'cpu': cpu})
    result = {'label': label, 'url': url, 'cpu': cpu, 'expressions': {}}
    session = await context.new_cdp_session(page) if cpu_profile else None
    try:
        await bootstrap(page, url)
        await real_click(page, page.get_by_role(
            'button', name='Edit expression', exact=True))
        editor = page.get_by_role('textbox', name='Expression', exact=True)
        await real_click(page, editor)
        await expect(editor).to_be_focused()
        # Warm up the engine so first-call initialisation is not counted.
        await type_measured(page, editor, '1+1', pause_ms)
        await page.keyboard.press('Enter')
        await expect(editor).to_have_value('')
        await next_frames(page)
        for name, text in EXPRESSIONS.items():
            await page.evaluate(LONG_TASKS)
            if session:
                await session.send('Profiler.enable')
                await session.send('Profiler.setSamplingInterval', {'interval': 200})
                await session.send('Profiler.start')
            latencies = await type_measured(page, editor, text, pause_ms)
            await page.wait_for_timeout(500)
            long_tasks = await page.evaluate('window.__longTasks')
            if session:
                profile = (await session.send('Profiler.stop'))['profile']
                result.setdefault('hot', {})[name] = hot_functions(profile)
            result['expressions'][name] = {
                'text': text,
                'keys': summary(latencies),
                'long_tasks': {'count': len(long_tasks),
                               'total_ms': round(sum(long_tasks), 1),
                               'max_ms': round(max(long_tasks), 1) if long_tasks else 0},
            }
            await editor.fill('')
            await expect(editor).to_have_value('')
            await next_frames(page)
        result['errors'] = errors
    finally:
        await context.close()
    return result


async def run(args):
    results = []
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(
            args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        try:
            for target in args.target:
                label, url = target.split('=', 1)
                results.append(await measure(browser, label, url, args.cpu, args.pause,
                                             args.cpu_profile))
        finally:
            await browser.close()
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    Path(args.output).write_text(json.dumps(results, indent=2) + '\n')
    for r in results:
        for name, e in r['expressions'].items():
            print(f"{r['label']:>8} {name:>10}: key median {e['keys']['median_ms']} ms, "
                  f"p95 {e['keys']['p95_ms']} ms, max {e['keys']['max_ms']} ms; "
                  f"long tasks {e['long_tasks']['count']} "
                  f"(total {e['long_tasks']['total_ms']} ms, max {e['long_tasks']['max_ms']} ms)")
        for name, hot in r.get('hot', {}).items():
            print(f"--- {r['label']} {name}: top inclusive")
            for fn, ms in hot['total'][:30]:
                print(f"{ms:>9} ms  {fn}")
            print(f"--- {r['label']} {name}: top self")
            for fn, ms in hot['self'][:20]:
                print(f"{ms:>9} ms  {fn}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', action='append', required=True,
                        help='label=url, repeatable')
    parser.add_argument('--cpu', type=float, default=4,
                        help='CPU throttling rate (4 approximates a phone)')
    parser.add_argument('--pause', type=int, default=250,
                        help='ms between keys; above the 150 ms preview debounce')
    parser.add_argument('--cpu-profile', action='store_true',
                        help='record a CPU profile per expression (use a --profile build)')
    parser.add_argument('--output', default='browser-results/typing-latency.json')
    asyncio.run(run(parser.parse_args()))
