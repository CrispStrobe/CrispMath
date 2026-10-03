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


from statistics_ui_reference_checks import rendered_rows, hypothesis_rows

# GOF p=erfc(sqrt(5)); t mean=1e10, SD=1, n=3 gives t=sqrt(3)*1e10.
# The df2 survival asymptote is 1/(2*t²), hence upper=1/6e20.
TEST_CASES = [
    ('chi-square-empty-bin', {'Observed counts': '0, 10', 'Expected counts': '5, 5'},
     {'χ² statistic': '10', 'Degrees of freedom': '1', 'p-value (upper tail)': '0.001565'}),
    ('student-t-far-upper-tail', {'Sample data': '9999999999, 10000000000, 10000000001', 'Hypothesized mean μ₀': '0'},
     {'t-statistic': '1.7321e+10', 'Degrees of freedom': '2',
      'p-value (two-sided)': '3.3333e-21', 'p-value (upper tail)': '1.6667e-21'}),
]


async def real_click(page, locator, *, horizontal=False):
    """Reveal clipped Flutter controls with real wheel events, never force."""
    await locator.wait_for(state='attached')
    for _ in range(12):
        if await locator.count() == 1:
            state = await locator.evaluate("""el=>{
              const r=el.getBoundingClientRect(), x=r.x+r.width/2,y=r.y+r.height/2;
              const hit=document.elementFromPoint(x,y);
              return {ready:r.width>0&&r.height>0&&x>0&&x<innerWidth&&y>0&&y<innerHeight&&
                !!hit&&(hit===el||el.contains(hit)),y};
            }""")
            if state['ready']:
                await locator.click(trial=True, timeout=3000)
                await locator.click()
                return
        else:
            state = {}
        width,height = page.viewport_size['width'],page.viewport_size['height']
        if horizontal:
            descriptive = page.get_by_label('Descriptive', exact=True).first
            box = await descriptive.bounding_box()
            assert box, 'Statistics tab bar must have actual geometry'
            await page.mouse.move(width-30, box['y']+box['height']/2)
            await page.mouse.wheel(180, 0)
        else:
            await page.mouse.move(width*.8, height*.65)
            await page.mouse.wheel(0, -220 if state.get('y',height)<140 else 220)
        await next_frames(page)
    raise AssertionError(f'Control could not be revealed: {await locator.count()} matches')


async def check_hypothesis(page, case_id, inputs, references, item, output, width):
    await real_click(page, page.get_by_label('Tests', exact=True), horizontal=True)
    choice = 'χ² goodness-of-fit' if case_id == 'chi-square-empty-bin' else 'One-sample t'
    await real_click(page, page.get_by_label(choice, exact=True).or_(
        page.get_by_text(choice, exact=True)).first)
    for label, value in inputs.items():
        field = page.get_by_role('textbox', name=re.compile('^'+re.escape(label)))
        await real_click(page, field)
        await field.fill(value)
        await expect(field).to_have_value(value)
        await next_frames(page)
    successors = {'χ² statistic': 'Degrees of freedom',
                  'Degrees of freedom': 'p-value (upper tail)',
                  'p-value (upper tail)': 'Reject H₀'} if case_id == 'chi-square-empty-bin' else {
                      't-statistic': 'Degrees of freedom',
                      'Degrees of freedom': 'p-value (two-sided)',
                      'p-value (two-sided)': 'p-value (upper tail)',
                      'p-value (upper tail)': 'p-value (lower tail)'}
    # Flutter renders the results as one aria-labelled semantic group; its
    # ordered text preserves actual row/value pairing. Never concatenate
    # labels from unrelated nodes or read a hidden computation API.
    first_label = 'χ² statistic' if case_id == 'chi-square-empty-bin' else 'Sample mean x̄'
    group = page.get_by_label(re.compile('^'+re.escape(first_label)+r'\s'))
    await group.wait_for(state='attached')
    item['geometry'] = []
    for _ in range(12):
        assert await group.count() == 1, await group.count()
        text = await group.get_attribute('aria-label')
        rows = hypothesis_rows(text, successors)
        for label,value in references.items():
            assert rows[label]['value'] == value, (case_id,label,rows[label],value)
        state = await group.evaluate("""el=>{
          const r=el.getBoundingClientRect();
          return {x:r.x,y:r.y,width:r.width,height:r.height,
            visible:r.width>0&&r.height>0&&r.x>=0&&r.right<=innerWidth&&
              r.y>=140&&r.bottom<=innerHeight};
        }""")
        item['geometry'].append(state)
        if state['visible']:
            item.update({'renderedTable': text, 'rows': rows,
                         'tableSource': 'single-rendered-aria-label'})
            break
        await page.mouse.move(page.viewport_size['width']*.8, page.viewport_size['height']*.65)
        await page.mouse.wheel(0, -160 if state['y']<140 else 160)
        await next_frames(page)
    else:
        raise AssertionError((case_id,'Result group not fully visible',item['geometry'],text))
    assert 'Reject H₀ at α' in text, (case_id,text)
    await page.screenshot(path=str(output / f'{case_id}-{width}-result.png'))


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
                for case_id, source, references in CASES + TEST_CASES:
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
                        if isinstance(source, dict):
                            await check_hypothesis(page, case_id, source, references, item, output, width)
                        else:
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
