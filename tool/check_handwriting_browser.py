"""Check actual ink painting, decimal dots, undo and clear in the live dialog."""
import argparse
import asyncio
import base64
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright
from benchmark_workflows import bootstrap, context_for, next_frames

async def black_pixels(page, locator):
    png = await locator.screenshot()
    return await page.evaluate('''async encoded => {
      const image = new Image(); image.src = 'data:image/png;base64,' + encoded;
      await image.decode(); const canvas = document.createElement('canvas');
      canvas.width=image.width; canvas.height=image.height;
      const ctx=canvas.getContext('2d'); ctx.drawImage(image,0,0);
      const data=ctx.getImageData(0,0,canvas.width,canvas.height).data;
      let count=0; for(let i=0;i<data.length;i+=4) if(data[i]<100 && data[i+1]<100 && data[i+2]<100)count++;
      return count;
    }''', base64.b64encode(png).decode())

async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'checks': []}
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        for width, height in [(744, 1024), (390, 568)]:
            context, page, errors = await context_for(browser, {'viewport': {'width': width, 'height': height}, 'cpu': 1})
            try:
                await bootstrap(page, args.url)
                await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                write = page.get_by_role('button', name='Write math', exact=True)
                if await write.count():
                    await write.click()
                else:
                    await page.get_by_role('button', name='Document menu', exact=True).click()
                    await page.locator('[aria-label="Write math"]').click()
                paper = page.locator('[aria-label="Handwriting canvas"]')
                await paper.wait_for()
                await next_frames(page)
                empty = await black_pixels(page, paper)
                assert empty == 0, empty
                bounds = await paper.bounding_box()
                x, y = bounds['x'] + bounds['width'] * .4, bounds['y'] + bounds['height'] * .5
                await page.mouse.click(x, y)
                await next_frames(page)
                dot = await black_pixels(page, paper)
                assert dot >= 4, dot
                await page.mouse.move(x + 30, y - 20)
                await page.mouse.down()
                await page.mouse.move(x + 60, y + 20, steps=10)
                await next_frames(page)
                drawing = await black_pixels(page, paper)
                assert drawing > dot, (drawing, dot)
                await page.mouse.up()
                await page.get_by_role('button', name='Undo', exact=True).click()
                await next_frames(page)
                after_undo = await black_pixels(page, paper)
                assert after_undo == dot, (after_undo, dot)
                await page.screenshot(path=str(output / f'ink-{width}.png'))
                await page.get_by_role('button', name='Clear', exact=True).click()
                await next_frames(page)
                assert await black_pixels(page, paper) == 0
                assert not errors, errors
                report['checks'].append({'width': width, 'dotVisible': True, 'inProgressInkVisible': True, 'undo': True, 'clear': True})
            except Exception as error:
                report['error'] = str(error)
                report['pageErrors'] = errors
                await page.screenshot(path=str(output / 'failure.png'))
                raise
            finally:
                (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
                await context.close()
        report['passed'] = True
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        await browser.close()
    print(json.dumps(report), flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/handwriting')
    asyncio.run(check(parser.parse_args()))
