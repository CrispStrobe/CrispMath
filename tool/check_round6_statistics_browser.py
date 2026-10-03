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


async def visible_row(page, label):
    """Read rendered text to the right of its row label, using DOM geometry."""
    return await page.evaluate('''label => {
      const nodes=[...document.querySelectorAll('flt-semantics[aria-label], flt-semantics span')];
      const entries=nodes.map(node=>({
        text:(node.getAttribute('aria-label') || node.innerText || '').trim(),
        box:node.getBoundingClientRect()
      })).filter(entry=>entry.box.width>0 && entry.box.height>0 &&
          entry.box.height<80 && entry.box.top>=0 && entry.box.bottom<=innerHeight);
      const rowLabels=entries.filter(entry=>entry.text===label);
      for(const owner of rowLabels) {
        const candidates=entries.filter(entry=>
          entry.box.left>=owner.box.right-2 &&
          Math.abs((entry.box.top+entry.box.bottom-owner.box.top-owner.box.bottom)/2)<8 &&
          /^(?:[+-]?\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?|Infinity|-Infinity|Undefined|NaN)$/.test(entry.text));
        const unique=[...new Set(candidates.map(entry=>entry.text))];
        if(unique.length===1)return {label,value:unique[0],
          labelBounds:{x:owner.box.x,y:owner.box.y,width:owner.box.width,height:owner.box.height},
          candidates:candidates.map(entry=>({text:entry.text,x:entry.box.x,y:entry.box.y}))};
      }
      return null;
    }''', label)


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
                        # Poll only rendered semantics. Physical wheel scrolling
                        # brings lower rows into view on the small phone layout.
                        for step in range(12):
                            await next_frames(page)
                            for label, expected in references.items():
                                if label in item['rows']:
                                    continue
                                row = await visible_row(page, label)
                                if row is not None:
                                    item['rows'][label] = row
                                    assert row['value'] == expected, (case_id, row, expected)
                                    await page.screenshot(path=str(output /
                                        f'{case_id}-{width}-row-{len(item["rows"])}.png'))
                            if len(item['rows']) == len(references):
                                break
                            await page.mouse.move(width * .75, height * .65)
                            await page.mouse.wheel(0, 180)
                            await page.wait_for_timeout(150)
                        assert set(item['rows']) == set(references), item
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
