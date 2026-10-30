"""Exercise answer chaining through the real calculator text editor."""
import argparse
import asyncio
import json
from pathlib import Path

from playwright.async_api import async_playwright, expect

from benchmark_workflows import bootstrap, context_for, next_frames
from check_round6_statistics_browser import real_click


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(
            args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        try:
            for width, height in [(1280, 900), (390, 844)]:
                context, page, errors = await context_for(browser, {
                    'viewport': {'width': width, 'height': height},
                    'has_touch': width < 600, 'cpu': 1,
                })
                item = {'width': width, 'height': height, 'passed': False}
                report['checks'].append(item)
                try:
                    await bootstrap(page, args.url)
                    await real_click(page, page.get_by_role(
                        'button', name='Edit expression', exact=True))
                    editor = page.get_by_role('textbox', name='Expression', exact=True)
                    await real_click(page, editor)

                    async def submit(expression, result):
                        await expect(editor).to_have_value(expression)
                        await editor.press('Enter')
                        await page.wait_for_function('''expected => {
                          const raw = localStorage.getItem('flutter.crisp.history');
                          if (!raw) return false;
                          const first = JSON.parse(JSON.parse(raw))[0];
                          return first && first.e === expected.expression &&
                              first.r === expected.result;
                        }''', arg={'expression': expression, 'result': result})
                        await page.get_by_role('button', name=(
                            expression + ' = ' + ('No Ans in memory.' if
                            result == 'Error: No Ans in memory' else result)),
                            exact=True).wait_for(state='attached')
                        # Persisting and rendering the history row may finish
                        # before Flutter clears the text editor. Wait for the
                        # real field to settle before starting the next edit.
                        await expect(editor).to_have_value('')
                        await next_frames(page)
                        await expect(editor).to_have_value('')
                        # Subsequent fill/Enter must reach Flutter's active text
                        # client, not only a detached browser-side input.
                        await expect(editor).to_be_focused()

                    # Type into the live Flutter text client. A programmatic
                    # fill only rewrites the DOM node, which Flutter stops
                    # listening to once it closes the input connection after a
                    # submit, so a later fill would never reach the app.
                    await real_click(page, editor)
                    await page.keyboard.type('Ans/2', delay=20)
                    await submit('Ans/2', 'Error: No Ans in memory')
                    await real_click(page, editor)
                    await page.keyboard.type('24', delay=20)
                    await submit('24', '24')
                    for operator, expression, result in [
                        ('/', 'Ans/2', '12'),
                        ('*', 'Ans*2', '24'),
                        ('+', 'Ans+2', '26'),
                    ]:
                        await real_click(page, editor)
                        await page.keyboard.type(operator + '2', delay=100)
                        await next_frames(page)
                        await submit(expression, result)
                    # A single batched edit must behave like the two keystrokes.
                    await real_click(page, editor)
                    await page.keyboard.type('/2', delay=20)
                    await submit('Ans/2', '13')
                    await page.screenshot(path=str(output / f'chaining-{width}.png'))
                    assert not errors, errors
                    item.update(passed=True, missingAnswer=True,
                                sequentialResults=['12', '24', '26'],
                                batchedResult='13')
                except Exception as error:
                    item['error'] = repr(error)
                    item['pageErrors'] = errors
                    await page.screenshot(path=str(output / f'failure-{width}.png'))
                    raise
                finally:
                    (output / 'report.json').write_text(
                        json.dumps(report, indent=2) + '\n')
                    await context.close()
            report['passed'] = True
            (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        finally:
            await browser.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/calculator-chaining')
    asyncio.run(check(parser.parse_args()))
