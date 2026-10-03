"""Verify extreme descriptive samples through the real statistics screen."""
import argparse
import asyncio
import json
import os
from pathlib import Path
import re
from urllib.parse import urljoin

from playwright.async_api import async_playwright, expect

from benchmark_workflows import bootstrap, context_for, next_frames


# Independent moments, expressed using the screen's four-place scientific
# display contract. SD(-a,a) = sqrt(2)*a, which rounds to 1.4142e+308.
CASES = [
    ('repeated-extremes', '1e308, 1e308',
     {'Count': '2', 'Mean': '1.0000e+308', 'Median': '1.0000e+308',
      'Std. deviation (n−1)': '0'}),
    ('opposite-extremes', '-1e308, 1e308',
     {'Count': '2', 'Mean': '0', 'Median': '0',
      'Std. deviation (n−1)': '1.4142e+308'}),
]


def rendered_rows(text):
    """Parse the actual merged StatsTable semantics with explicit row bounds."""
    number = r'(?:[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|Infinity|-Infinity|Undefined|NaN)'
    successors = {'Count': 'Sum', 'Mean': 'Median', 'Median': 'Mode',
                  'Std. deviation (n−1)': 'Variance (n)'}
    rows = {}
    for label, successor in successors.items():
        pattern = rf'(?:^|\s){re.escape(label)}\s+({number})\s+{re.escape(successor)}(?:\s|$)'
        matches = re.findall(pattern, text)
        assert len(matches) == 1, (label, text, matches)
        rows[label] = {'label': label, 'value': matches[0],
                       'nextRowLabel': successor}
    return rows


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'toolSource': os.environ.get('GITHUB_SHA'),
              'passed': False, 'checks': []}

    def save():
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(
            args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        try:
            for width, height in [(1280, 900), (390, 844)]:
                for case_id, source, references in CASES:
                    context, page, errors = await context_for(browser, {
                        'viewport': {'width': width, 'height': height},
                        'cpu': 1, 'has_touch': width < 600})
                    item = {'case': case_id, 'width': width, 'height': height,
                            'input': source, 'expected': references,
                            'rows': {}, 'passed': False}
                    report['checks'].append(item)
                    try:
                        await bootstrap(page, args.url)
                        response = await context.request.get(urljoin(
                            args.url.rstrip('/') + '/', 'build-info.json'))
                        assert response.ok, response.status
                        app_source = (await response.json())['source']
                        assert re.fullmatch(r'[0-9a-f]{40}', app_source), app_source
                        if args.expected_source:
                            assert app_source == args.expected_source, app_source
                        if 'appSource' in report:
                            assert report['appSource'] == app_source
                        report['appSource'] = app_source
                        await page.get_by_role('button', name=re.compile(r'^Analysis')).click()
                        # ListTile merges its title and subtitle into one
                        # rendered semantic text node, as the failed live
                        # report confirms. Match that actual card label.
                        await page.get_by_text(re.compile(
                            r'^Statistics\s+Descriptive stats, linear regression, '
                            r'normal & binomial distributions')).click()
                        field = page.get_by_role('textbox').first
                        await field.click()
                        await next_frames(page)
                        await field.fill(source)
                        await expect(field).to_have_value(source)
                        await next_frames(page)
                        # Flutter merges the complete card into a single text
                        # node; the hosted report and native screenshot confirm
                        # this actual structure. Keep strict label/value pairing.
                        table = page.get_by_text(re.compile(r'^Count\s+2\s+Sum\s')).first
                        await table.wait_for()
                        item['renderedTable'] = await table.inner_text()
                        item['rows'] = rendered_rows(item['renderedTable'])
                        for label, expected in references.items():
                            assert item['rows'][label]['value'] == expected, (
                                case_id, item['rows'][label], expected)
                        await page.screenshot(path=str(output /
                            f'{case_id}-{width}-upper.png'))
                        # The phone's lower sample-SD row needs physical scrolling
                        # for visual review. Read semantics again after scrolling.
                        await page.mouse.move(width * .75, height * .65)
                        await page.mouse.wheel(0, 350)
                        await page.wait_for_timeout(150)
                        await next_frames(page)
                        after_scroll = await table.inner_text()
                        assert rendered_rows(after_scroll) == item['rows'], after_scroll
                        await page.screenshot(path=str(output /
                            f'{case_id}-{width}-lower.png'))
                        assert not errors, errors
                        item['passed'] = True
                    except Exception as error:
                        item['error'] = repr(error)
                        item['pageErrors'] = errors
                        try:
                            item['renderedText'] = await page.locator('body').inner_text()
                            item['semanticLabels'] = await page.locator('[aria-label]').evaluate_all(
                                "els=>els.map(el=>el.getAttribute('aria-label'))")
                            await page.screenshot(path=str(output /
                                f'failure-{case_id}-{width}.png'))
                        except Exception as capture_error:
                            item['captureError'] = repr(capture_error)
                        save()
                        raise
                    finally:
                        save()
                        await context.close()
            report['passed'] = True
            save()
            print(json.dumps(report), flush=True)
        finally:
            await browser.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round6-statistics-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
