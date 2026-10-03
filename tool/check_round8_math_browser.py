"""Enter frozen round-eight math through real desktop and phone worksheets.

Independent answers precede app outputs. Only blank documents are seeded;
actual input, persisted source/result/evidence and reload controls are reused.
"""
import argparse
import asyncio
import os
import json
from pathlib import Path
import re
from urllib.parse import urljoin

from playwright.async_api import async_playwright, expect
from check_round6_statistics_browser import real_click

import check_new_math_browser as controls
from round8_reference_checks import (CASES, validate_result, normal_cdf_display,
                                     NORMAL_CDF_INPUTS, NORMAL_CDF_DISPLAY)

controls.CASES = CASES
controls.validate_result = validate_result
controls.AFTER_ENTRY = None

async def check_normal_cdf(args):
    output = Path(args.output) / 'normal-cdf'
    output.mkdir(parents=True, exist_ok=True)
    report = {'passed':False, 'toolSource':os.environ.get('GITHUB_SHA'),
              'precisionNote':'UI rounds to six decimal places; worker/unit tests prove finer CDF accuracy.',
              'checks':[]}
    def save():
        (output / 'report.json').write_text(json.dumps(report, indent=2)+'\n')
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox','--enable-unsafe-swiftshader'])
        try:
            for width,height in [(1280,900),(390,844)]:
                context,page,errors = await controls.context_for(browser, {
                    'viewport':{'width':width,'height':height}, 'cpu':1, 'has_touch':width<600})
                item = {'width':width,'height':height, 'expectedDisplay':NORMAL_CDF_DISPLAY,
                        'passed':False}
                report['checks'].append(item)
                try:
                    await controls.bootstrap(page,args.url)
                    response = await context.request.get(urljoin(args.url.rstrip('/')+'/', 'build-info.json'))
                    assert response.ok, response.status
                    source = (await response.json())['source']
                    assert re.fullmatch(r'[0-9a-f]{40}',source),source
                    if args.expected_source:
                        assert source == args.expected_source, source
                    report['appSource'] = source
                    item['appSource'] = source
                    await page.get_by_role('button',name=re.compile(r'^Analysis')).click()
                    await page.get_by_text(re.compile(r'^Statistics\s+Descriptive stats, linear regression, normal & binomial distributions')).click()
                    await real_click(page,page.get_by_label('Distributions',exact=True),horizontal=True)
                    for label,value in NORMAL_CDF_INPUTS.items():
                        field = page.get_by_role('textbox',name=re.compile('^'+re.escape(label)))
                        await real_click(page,field)
                        await controls.next_frames(page)
                        await field.fill(value)
                        await expect(field).to_have_value(value)
                        await controls.next_frames(page)
                    item['inputsReadBack'] = {}
                    for label,value in NORMAL_CDF_INPUTS.items():
                        field = page.get_by_role('textbox',name=re.compile('^'+re.escape(label)))
                        actual = await field.input_value()
                        assert actual == value,(label,actual,value)
                        item['inputsReadBack'][label] = actual
                    for _ in range(8):
                        nodes = await page.locator('flt-semantics').evaluate_all("""els=>{
                          const result=[],seen=new Set();
                          for(const el of els){
                            const r=el.getBoundingClientRect();
                            for(const text of [el.getAttribute('aria-label'),el.innerText]){
                              if(!text||!text.trim())continue;
                              const normalized=text.trim().replace(/\\s+/g,' ');
                              const key=normalized+JSON.stringify([r.x,r.y,r.width,r.height]);
                              if(seen.has(key))continue;seen.add(key);
                              result.push({text:normalized,box:{x:r.x,y:r.y,width:r.width,height:r.height}});
                            }
                          }return result;
                        }""")
                        item['renderedNodes'] = nodes
                        try:
                            item['actualRow'] = normal_cdf_display(nodes,width,height)
                            break
                        except AssertionError:
                            await page.mouse.move(width*.8,height*.65)
                            await page.mouse.wheel(0,100)
                            await controls.next_frames(page)
                    else:
                        raise AssertionError(('Normal CDF row missing/wrong or not visible',nodes))
                    assert not errors,errors
                    await page.screenshot(path=str(output/f'normal-cdf-{width}.png'))
                    item['passed'] = True
                except Exception as error:
                    item['error'] = repr(error)
                    item['pageErrors'] = errors
                    await page.screenshot(path=str(output/f'failure-normal-cdf-{width}.png'))
                    save()
                    raise
                finally:
                    save()
                    await context.close()
            report['passed'] = True
            save()
        finally:
            await browser.close()


async def check(args):
    await controls.check(args)
    await check_normal_cdf(args)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round8-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
