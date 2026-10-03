"""Exercise frozen ninth-audit answers through actual worksheets and module UI."""
import argparse
import asyncio
import json
import os
from pathlib import Path
import re
from urllib.parse import urljoin

from playwright.async_api import async_playwright, expect
import check_new_math_browser as controls
from check_round6_statistics_browser import real_click
from round9_reference_checks import (CASES, STATISTICS_CASES, CONSTRAINT_PROGRAM,
                                     validate_result, validate_statistics, validate_optimum, constraint_assignment_field)

controls.CASES = CASES
controls.validate_result = validate_result
controls.AFTER_ENTRY = None


async def reveal_tab(page, label):
    """Physically scroll the real constraint tab strip before clicking."""
    target = page.get_by_label(label, exact=True)
    for _ in range(10):
        box = await target.bounding_box()
        width = page.viewport_size['width']
        if box and box['x'] >= 0 and box['x']+box['width'] <= width:
            try:
                await target.click(trial=True, timeout=1500)
                await target.click()
                return
            except Exception:
                pass
        anchor = await page.get_by_label('Diophantine', exact=True).bounding_box()
        assert anchor, 'Constraint tab bar must have real geometry'
        await page.mouse.move(width-25,anchor['y']+anchor['height']/2)
        await page.mouse.wheel(180,0)
        await controls.next_frames(page)
    raise AssertionError(('Constraint tab could not be reached',label,box))


async def check_modules(args):
    output = Path(args.output) / 'modules'
    output.mkdir(parents=True, exist_ok=True)
    report = {'passed':False,'checks':[],'toolSource':os.environ.get('GITHUB_SHA'),
              'coverage':'constraint-only-diagnostic' if args.constraint_only else 'full-round9-modules',
              'comparisonNote':'Independent frozen sample moments and bounded integer objective; actual visible UI, no diagnostic engine API.'}
    def save():
        (output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox','--enable-unsafe-swiftshader'])
        try:
            for width,height in [(1280,900),(390,844)]:
                module_cases=[('shifted-quadratic-optimum',CONSTRAINT_PROGRAM,None)]
                if not args.constraint_only: module_cases=[*STATISTICS_CASES,*module_cases]
                for name,source,references in module_cases:
                    context,page,errors = await controls.context_for(browser,{
                        'viewport':{'width':width,'height':height},'cpu':1,'has_touch':width<600})
                    item = {'case':name,'width':width,'height':height,'source':source,
                            'kind':'statistics' if references else 'constraint','passed':False}
                    report['checks'].append(item)
                    try:
                        await controls.bootstrap(page,args.url)
                        response = await context.request.get(urljoin(args.url.rstrip('/')+'/', 'build-info.json'))
                        assert response.ok,response.status
                        app_source = (await response.json())['source']
                        assert re.fullmatch(r'[0-9a-f]{40}',app_source),app_source
                        if args.expected_source: assert app_source == args.expected_source,app_source
                        if report.get('appSource'): assert report['appSource']==app_source
                        report['appSource']=item['appSource']=app_source
                        await page.get_by_role('button',name=re.compile(r'^Analysis')).click()
                        if references:
                            card = page.get_by_text(re.compile(r'^Statistics\s+Descriptive stats, linear regression, normal & binomial distributions'))
                        else:
                            card = page.get_by_text(re.compile(r'^Constraint problems\s+Diophantine equations and cryptarithms'))
                        await real_click(page,card)
                        if not references: await reveal_tab(page,'Free-form')
                        field = page.get_by_role('textbox').first if references else page.get_by_role('textbox',name=re.compile(r'^Constraint program'))
                        await real_click(page,field)
                        await controls.next_frames(page)
                        await field.fill(source)
                        await expect(field).to_have_value(source)
                        await controls.next_frames(page)
                        await expect(field).to_have_value(source)
                        item['inputReadBack']=await field.input_value()
                        if references:
                            table = page.get_by_text(re.compile(r'^Count\s+3\s+Sum\s')).first
                            await table.wait_for(state='attached')
                            item['renderedTable']=await table.inner_text()
                            item['rows']=validate_statistics(item['renderedTable'],references)
                            item['upperGeometry']=await table.bounding_box()
                            await page.screenshot(path=str(output/f'{name}-{width}-upper.png'))
                            await page.mouse.move(width*.75,height*.65)
                            await page.mouse.wheel(0,350)
                            await controls.next_frames(page)
                            assert validate_statistics(await table.inner_text(),references)==item['rows']
                            item['lowerGeometry']=await table.bounding_box()
                            await page.screenshot(path=str(output/f'{name}-{width}-lower.png'))
                        else:
                            await real_click(page,page.get_by_role('button',name='Solve',exact=True))
                            header = page.get_by_text(re.compile(r'^Optimal: objective =')).first
                            await header.wait_for(state='attached',timeout=30000)
                            item['header']=await header.inner_text()
                            item['domBeforeResultFocus']=await page.locator('flt-semantics,input,textarea,[role="textbox"]').evaluate_all("""els=>els.map(el=>{
                              const r=el.getBoundingClientRect();return {tag:el.tagName,attributes:Object.fromEntries(Array.from(el.attributes).map(a=>[a.name,a.value])),
                              text:el.textContent,value:el.value??null,readOnly:el.readOnly??null,box:{x:r.x,y:r.y,width:r.width,height:r.height}};})""")
                            item['activeBeforeFocus']=await page.evaluate("""()=>({tag:document.activeElement.tagName,value:document.activeElement.value??null,role:document.activeElement.getAttribute('role')})""")
                            if args.constraint_only:
                                roles=await page.get_by_role('textbox').evaluate_all("""els=>els.map((el,index)=>{
                                  const r=el.getBoundingClientRect();return {index,tag:el.tagName,value:el.value??null,
                                  readOnly:el.readOnly===true||el.getAttribute('aria-readonly')==='true',disabled:el.disabled===true,
                                  attributes:Object.fromEntries(Array.from(el.attributes).map(a=>[a.name,a.value])),
                                  box:{x:r.x,y:r.y,width:r.width,height:r.height}};})""")
                                item['textboxRolesBeforeFocus']=roles
                                header_box=await header.bounding_box()
                                candidates=[node for node in roles if node['disabled'] and node['box']['width']>0
                                            and node['box']['height']>0 and node['box']['y']>=header_box['y']+header_box['height']]
                                assert len(candidates)==1,('Expected one actual disabled result placeholder below header',roles,header_box)
                                result_control=page.get_by_role('textbox').nth(candidates[0]['index'])
                                result_parent=result_control.locator('..')
                                assert await result_parent.evaluate("el=>el.tagName==='FLT-SEMANTICS'"), 'Measured semantic result parent required'
                                item['resultParentGeometry']=await result_parent.bounding_box()
                                await real_click(page,result_parent)
                                await controls.next_frames(page)
                                item['domAfterResultFocus']=await page.locator('input,textarea,[role="textbox"]').evaluate_all("""els=>els.map(el=>{
                                  const r=el.getBoundingClientRect();return {tag:el.tagName,attributes:Object.fromEntries(Array.from(el.attributes).map(a=>[a.name,a.value])),
                                  text:el.textContent,value:el.value??null,readOnly:el.readOnly??null,box:{x:r.x,y:r.y,width:r.width,height:r.height}};})""")
                                item['activeAfterFocus']=await page.evaluate("""()=>({tag:document.activeElement.tagName,value:document.activeElement.value??null,attributes:Object.fromEntries(Array.from(document.activeElement.attributes).map(a=>[a.name,a.value]))})""")
                                await expect(result_control).to_have_value(re.compile(r'.+'),timeout=10000)
                                item['assignment']=await result_control.input_value()
                                item['assignmentSource']='measured-semantic-parent-real-click-native-field-value'
                                item['optimum']=validate_optimum(item['header'],item['assignment'])
                                item['assignmentGeometry']=await result_parent.bounding_box()
                                assert item['assignmentGeometry']['y']>=header_box['y']+header_box['height']
                                await context.grant_permissions(['clipboard-read','clipboard-write'])
                                await real_click(page,page.get_by_role('button',name='Copy solutions',exact=True))
                                item['clipboardAssignment']=await page.evaluate('()=>navigator.clipboard.readText()')
                                assert item['clipboardAssignment']==item['assignment']
                                validate_optimum(item['header'],item['clipboardAssignment'])
                                await real_click(page,field)
                                await expect(field).to_have_value(source)
                                item['inputReadBackAfterResult']=await field.input_value()
                                await real_click(page,result_parent)
                                await expect(result_control).to_have_value(item['assignment'])
                                await page.screenshot(path=str(output/f'{name}-{width}-result.png'))
                                assert not errors,errors
                                item['passed']=True
                                continue
                            # Flutter SelectableText exposes its displayed text
                            # as a read-only native field, not a text-node label.
                            await page.wait_for_function(r"""()=>Array.from(document.querySelectorAll('input,textarea')).some(el=>
                              el.readOnly&&/^\s*[xy]\s*=\s*-?\d+\s*,\s*[xy]\s*=\s*-?\d+\s*$/.test(el.value))""",timeout=30000)
                            fields=await page.locator('input,textarea').evaluate_all("""els=>els.map((el,index)=>{
                              const r=el.getBoundingClientRect();return {index,tag:el.tagName.toLowerCase(),
                              readOnly:el.readOnly,value:el.value,box:{x:r.x,y:r.y,width:r.width,height:r.height}};})""")
                            item['renderedFields']=fields
                            selected=constraint_assignment_field(fields)
                            assignment=page.locator('input,textarea').nth(selected['index'])
                            item['assignment']=await assignment.input_value()
                            item['assignmentSource']='unique-rendered-read-only-field-value'
                            item['optimum']=validate_optimum(item['header'],item['assignment'])
                            for locator in [header,assignment]:
                                for _ in range(10):
                                    box=await locator.bounding_box()
                                    if box and box['y']>=140 and box['y']+box['height']<=height: break
                                    await page.mouse.move(width*.8,height*.65)
                                    await page.mouse.wheel(0,-160 if box and box['y']<140 else 160)
                                    await controls.next_frames(page)
                                else: raise AssertionError(('Constraint result not visibly reachable',box))
                            item['headerGeometry']=await header.bounding_box()
                            item['assignmentGeometry']=await assignment.bounding_box()
                            assert await field.input_value()==source
                            assert await assignment.input_value()==item['assignment']
                            await page.screenshot(path=str(output/f'{name}-{width}-result.png'))
                        assert not errors,errors
                        item['passed']=True
                    except Exception as error:
                        item['error']=repr(error)
                        item['pageErrors']=errors
                        item['domAtFailure']=await page.locator('input,textarea,[role="textbox"]').evaluate_all("els=>els.map(el=>({tag:el.tagName,value:el.value??null,readOnly:el.readOnly??null,attributes:Object.fromEntries(Array.from(el.attributes).map(a=>[a.name,a.value]))}))")
                        item['semanticLabels']=await page.locator('[aria-label]').evaluate_all("els=>els.map(el=>el.getAttribute('aria-label'))")
                        await page.screenshot(path=str(output/f'failure-{name}-{width}.png'))
                        save()
                        raise
                    finally:
                        save()
                        await context.close()
            report['passed']=True
            save()
        finally:
            await browser.close()


async def check(args):
    if not args.constraint_only: await controls.check(args)
    await check_modules(args)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--constraint-only',action='store_true',help='Diagnostic only: inspect the real constraint result DOM; skips worksheet/statistics checks')
    parser.add_argument('--url',default='http://127.0.0.1:8766/')
    parser.add_argument('--output',default='browser-results/round9-math-ui')
    parser.add_argument('--expected-source',default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
