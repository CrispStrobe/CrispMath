"""Verify calendar routing and arithmetic through actual document entry/save."""
import argparse
import asyncio
import json
from pathlib import Path
from playwright.async_api import async_playwright, expect
from benchmark_workflows import bootstrap, context_for, next_frames

CASES = [
    ('2026-10-01', 'Thursday, 1 October 2026'),
    ('2026-10-01 - 2026-09-30', '1 days'),
    ('2026-10-01 + 2 days', '2026-10-03'),
    ('2026 - 10 - 1', '2015'),
    ('if(true, 2026-10-01 + 2 days, 2026-10-01)', '2026-10-03'),
    ('if(false, 2026-10-01, 2026-10-01 - 2026-09-30)', '1 days'),
]


async def check(args):
    document = {'i': 'calendar-check', 'n': 'Calendar routing',
                'c': '2026-10-01T00:00:00Z', 'u': '2026-10-01T00:00:00Z',
                'l': [{'i': str(index), 's': ''} for index in range(len(CASES))]}
    async with async_playwright() as pw:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await pw.chromium.launch(**options)
        context, page, errors = await context_for(browser,
            {'viewport': {'width': 1280, 'height': 900}, 'cpu': 1}, document)
        try:
            await bootstrap(page, args.url)
            await page.keyboard.press('Control+2')
            records = []
            for index, (source, expected) in enumerate(CASES):
                editor = page.get_by_role('textbox').nth(index)
                await editor.click()
                await next_frames(page)
                await editor.fill(source)
                await expect(editor).to_have_value(source)
                await next_frames(page)
                await page.wait_for_function('''item => {
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.calendar-check');
                  if(!raw)return false;
                  const line=JSON.parse(JSON.parse(raw)).l.find(line=>line.i===item.id);
                  return line&&line.s===item.source&&line.r===item.expected;
                }''', arg={'id': str(index), 'source': source, 'expected': expected},
                    timeout=args.result_timeout)
                records.append({'source': source, 'saved_result': expected})
            assert not errors, errors
            output = Path(args.output)
            output.parent.mkdir(parents=True, exist_ok=True)
            report = {'cases': records, 'pageErrors': errors}
            output.write_text(json.dumps(report, indent=2)+'\n')
            print(json.dumps(report), flush=True)
        except Exception:
            output = Path(args.output)
            output.parent.mkdir(parents=True, exist_ok=True)
            await page.screenshot(path=str(output.with_suffix('.failure.png')))
            state = await page.evaluate("localStorage.getItem('flutter.crisp.notepadDoc.calendar-check')")
            output.with_suffix('.failure.json').write_text(json.dumps(
                {'savedDocument': state, 'pageErrors': errors}, indent=2)+'\n')
            raise
        finally:
            await context.close()
            await browser.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--output', default='browser-results/calendar-routing.json')
    parser.add_argument('--result-timeout', type=int, default=120000)
    asyncio.run(check(parser.parse_args()))
