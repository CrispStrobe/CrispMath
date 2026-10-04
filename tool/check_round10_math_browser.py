"""Exercise frozen tenth-audit answers through actual worksheets and module UI."""
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
from round10_reference_checks import (CASES, STATISTICS_CASES, CONSTRAINT_CASES,
                                     validate_result, validate_statistics, validate_optimum, constraint_assignment_field,
                                     LINSOLVE_SOURCE, validate_linsolve)

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
              'coverage':'constraint-only-diagnostic' if args.constraint_only else 'full-round10-modules',
              'comparisonNote':'Independent frozen sample moments and bounded integer objective; actual visible UI, no diagnostic engine API.'}
    def save():
        (output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(args=['--no-sandbox','--enable-unsafe-swiftshader'])
        try:
            for width,height in [(1280,900),(390,844)]:
                module_cases=[(name,program,None) for name,program in CONSTRAINT_CASES]
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
                            table = page.get_by_text(re.compile(r'^Count\s+\d+\s+Sum\s')).first
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
                            fields=await page.locator('input,textarea').evaluate_all("""els=>els.map((el,index)=>{
                              const r=el.getBoundingClientRect();return {index,tag:el.tagName.toLowerCase(),readOnly:el.readOnly,
                              value:el.value,box:{x:r.x,y:r.y,width:r.width,height:r.height}};})""")
                            item['renderedFields']=fields
                            selected=constraint_assignment_field(fields)
                            assignment=page.locator('input,textarea').nth(selected['index'])
                            assert await assignment.input_value()==await result_control.input_value()
                            item['assignment']=await assignment.input_value()
                            item['assignmentSource']='measured-semantic-parent-real-click-native-field-value'
                            item['optimum']=validate_optimum(name,item['header'],item['assignment'])
                            item['assignmentGeometry']=await result_parent.bounding_box()
                            item['headerGeometry']=header_box
                            box=item['assignmentGeometry']
                            assert box['y']>=header_box['y']+header_box['height'] and box['y']+box['height']<=height
                            assert box['x']>=0 and box['x']+box['width']<=width
                            assert header_box['y']>=140 and header_box['y']+header_box['height']<=height
                            await context.grant_permissions(['clipboard-read','clipboard-write'])
                            copy_button=page.get_by_role('button',name='Copy solutions',exact=True)
                            await copy_button.wait_for(state='attached')
                            assert await copy_button.count()==1,'Unique actual copy control required'
                            # Hovering during a trial locator click can rebuild
                            # Flutter tooltip semantics before its second lookup.
                            # Click the measured visible control once physically.
                            state=await copy_button.evaluate('''el=>{
                              const r=el.getBoundingClientRect(),x=r.x+r.width/2,y=r.y+r.height/2;
                              const hit=document.elementFromPoint(x,y);
                              return {x,y,width:r.width,height:r.height,
                                ready:r.width>0&&r.height>0&&r.x>=0&&r.right<=innerWidth&&r.y>=0&&r.bottom<=innerHeight&&!!hit&&(hit===el||el.contains(hit))};
                            }''')
                            assert state['ready'],state
                            item['copyControlGeometry']=state
                            await page.mouse.click(state['x'],state['y'])
                            item['clipboardAssignment']=await page.evaluate('()=>navigator.clipboard.readText()')
                            assert item['clipboardAssignment']==item['assignment']
                            validate_optimum(name,item['header'],item['clipboardAssignment'])
                            await real_click(page,field)
                            await expect(field).to_have_value(source)
                            item['inputReadBackAfterResult']=await field.input_value()
                            await real_click(page,result_parent)
                            await expect(result_control).to_have_value(item['assignment'])
                            await page.screenshot(path=str(output/f'{name}-{width}-result.png'))
                            assert not errors,errors
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


async def check_calculator(args):
    """The advertised linsolve signature exists in calculator, not worksheet."""
    output=Path(args.output)/'calculator'
    output.mkdir(parents=True,exist_ok=True)
    report={'passed':False,'checks':[],'coverage':'actual-calculator-linsolve',
            'toolSource':os.environ.get('GITHUB_SHA')}
    def save(): (output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    async with async_playwright() as pw:
        browser=await pw.chromium.launch(args=['--no-sandbox','--enable-unsafe-swiftshader'])
        try:
            for width,height in [(1280,900),(390,844)]:
                context,page,errors=await controls.context_for(browser,{
                    'viewport':{'width':width,'height':height},'cpu':1,'has_touch':width<600})
                item={'width':width,'height':height,'source':LINSOLVE_SOURCE,'passed':False}
                report['checks'].append(item)
                try:
                    await controls.bootstrap(page,args.url)
                    response=await context.request.get(urljoin(args.url.rstrip('/')+'/', 'build-info.json'))
                    assert response.ok,response.status
                    source=(await response.json())['source']
                    assert re.fullmatch(r'[0-9a-f]{40}',source),source
                    if args.expected_source: assert source==args.expected_source,source
                    if report.get('appSource'): assert report['appSource']==source
                    report['appSource']=item['appSource']=source
                    await real_click(page,page.get_by_role('button',name='Edit expression',exact=True))
                    editor=page.get_by_role('textbox',name='Expression',exact=True)
                    await real_click(page,editor)
                    await controls.next_frames(page)
                    await editor.fill(LINSOLVE_SOURCE)
                    await expect(editor).to_have_value(LINSOLVE_SOURCE)
                    item['inputReadBack']=await editor.input_value()
                    await controls.next_frames(page)
                    await editor.press('Enter')
                    await page.wait_for_function("""()=>{
                      const raw=localStorage.getItem('flutter.crisp.history');
                      if(!raw)return false;
                      try{return JSON.parse(JSON.parse(raw))[0]?.r?.includes('z =')}catch{return false}
                    }""",timeout=60000)
                    entry=await page.evaluate("()=>JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.history')))[0]")
                    item['historyEntry']=entry
                    assert re.sub(r'\s+','',entry['e']).replace('×','*').replace('·','*')==re.sub(r'\s+','',LINSOLVE_SOURCE),entry
                    validate_linsolve(entry['r'])
                    assert (entry.get('evidence')or{}).get('accuracy')=='exact',entry
                    # Flutter merges expression and result into the actual
                    # history row's semantic label, rather than a DOM Text.
                    label=entry['e']+'\n= '+entry['r']
                    result=page.get_by_label(label,exact=True)
                    await result.wait_for(state='attached')
                    assert await result.count()==1,label
                    box=await result.bounding_box()
                    assert box and box['width']>0 and box['height']>0 and box['x']>=0 and box['x']+box['width']<=width and box['y']>=0 and box['y']+box['height']<=height,box
                    item['resultGeometry']=box
                    item['visibleHistoryLabel']=await result.get_attribute('aria-label')
                    assert item['visibleHistoryLabel']==label,item
                    item['visibleResult']=item['visibleHistoryLabel'].split('\n= ')[1]
                    validate_linsolve(item['visibleResult'])
                    await page.reload(wait_until='domcontentloaded')
                    await page.locator('canvas').first.wait_for()
                    await page.locator('flt-semantics-placeholder').evaluate('(element)=>element.click()')
                    restored=await page.evaluate("()=>JSON.parse(JSON.parse(localStorage.getItem('flutter.crisp.history')))[0]")
                    assert restored==entry,(entry,restored)
                    item['reload']=True
                    result=page.get_by_label(label,exact=True)
                    await result.wait_for(state='attached')
                    assert await result.count()==1,label
                    item['restoredHistoryLabel']=await result.get_attribute('aria-label')
                    assert item['restoredHistoryLabel']==label,item
                    validate_linsolve(item['restoredHistoryLabel'].split('\n= ')[1])
                    await page.screenshot(path=str(output/f'linsolve-{width}.png'))
                    assert not errors,errors
                    item['passed']=True
                except Exception as error:
                    item['error']=repr(error);item['pageErrors']=errors
                    item['semanticLabels']=await page.locator('[aria-label]').evaluate_all("els=>els.map(el=>el.getAttribute('aria-label'))")
                    await page.screenshot(path=str(output/f'failure-linsolve-{width}.png'))
                    save();raise
                finally:
                    save();await context.close()
            report['passed']=True;save()
        finally:
            await browser.close()


async def check(args):
    if not args.constraint_only: await controls.check(args)
    await check_modules(args)
    if not args.constraint_only: await check_calculator(args)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--constraint-only',action='store_true',help='Diagnostic only: inspect the real constraint result DOM; skips worksheet/statistics checks')
    parser.add_argument('--url',default='http://127.0.0.1:8766/')
    parser.add_argument('--output',default='browser-results/round10-math-ui')
    parser.add_argument('--expected-source',default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
