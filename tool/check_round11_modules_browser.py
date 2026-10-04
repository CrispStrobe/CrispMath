"""Complete remaining frozen module references through visible real controls.

Compact statistics rows use the documented six-decimal/four-place scientific
display. Full-precision descriptive values and all enumerated CSP assignments
are read from real result controls; no engine API or result injection is used.
"""
import json
import math
import os
from pathlib import Path
import re
from urllib.parse import urljoin

from playwright.async_api import async_playwright, expect
import check_new_math_browser as controls
from check_round6_statistics_browser import real_click, check_hypothesis
from check_round10_math_browser import reveal_tab

from round11_module_reference_checks import STATISTICS, ENUMERATIONS, NUMBER, validate_enumeration


async def fill_fields(page,inputs):
    for label,value in inputs.items():
        field=page.get_by_role('textbox',name=re.compile('^'+re.escape(label)))
        await real_click(page,field);await controls.next_frames(page)
        await field.fill(value);await expect(field).to_have_value(value)
        await controls.next_frames(page);await expect(field).to_have_value(value)
    readback={}
    for label,value in inputs.items():
        field=page.get_by_role('textbox',name=re.compile('^'+re.escape(label)))
        readback[label]=await field.input_value()
        assert readback[label]==value,(label,value,readback)
    return readback


async def visible_row(page,label,expected):
    for _ in range(16):
        nodes=await page.locator('flt-semantics').evaluate_all("""els=>els.flatMap(el=>{
          const r=el.getBoundingClientRect();return [el.getAttribute('aria-label'),el.innerText].filter(Boolean)
            .map(text=>({text:text.trim().replace(/\\s+/g,' '),box:{x:r.x,y:r.y,width:r.width,height:r.height}}));})""")
        pattern=rf'(?:^|\s){re.escape(label)}\s+({NUMBER})(?=\s|$)'
        candidates=[]
        for node in nodes:
            box=node['box'];matches=re.findall(pattern,node['text'])
            if len(matches)==1 and box['width']>0 and box['height']>0 and box['x']>=0 and box['x']+box['width']<=page.viewport_size['width']+1 and box['y']>=140 and box['y']+box['height']<=page.viewport_size['height']+1:
                assert matches[0]==expected,(label,expected,node)
                assert math.isfinite(float(matches[0])),node
                if float(expected)>0:assert float(matches[0])>0,node
                candidates.append(node)
        if candidates:return {'value':expected,'node':min(candidates,key=lambda n:n['box']['height'])}
        await page.mouse.move(page.viewport_size['width']*.8,page.viewport_size['height']*.65)
        await page.mouse.wheel(0,150);await controls.next_frames(page)
    raise AssertionError(('Expected complete visible result row',label,expected,nodes))


async def enumeration_result(page,header,expected):
    await header.wait_for(state='attached')
    header_box=await header.bounding_box();assert header_box
    roles=await page.get_by_role('textbox').evaluate_all("""els=>els.map((el,index)=>{
      const r=el.getBoundingClientRect();return {index,disabled:el.disabled===true,box:{x:r.x,y:r.y,width:r.width,height:r.height}};})""")
    candidates=[node for node in roles if node['disabled'] and node['box']['width']>0 and node['box']['height']>0 and node['box']['y']>=header_box['y']+header_box['height']]
    assert len(candidates)==1,('Unique rendered result control',roles,header_box)
    result=page.get_by_role('textbox').nth(candidates[0]['index'])
    parent=result.locator('..')
    assert await parent.evaluate("el=>el.tagName==='FLT-SEMANTICS'"),'Actual semantic result parent'
    await real_click(page,parent);await controls.next_frames(page)
    await expect(result).to_have_value(re.compile(r'.+'))
    text=await result.input_value();rows=validate_enumeration(text,expected)
    fields=await page.locator('input,textarea').evaluate_all("els=>els.map(el=>({tag:el.tagName,value:el.value,readOnly:el.readOnly}))")
    assert any(field['readOnly']and field['value']==text for field in fields),fields
    await page.context.grant_permissions(['clipboard-read','clipboard-write'])
    await real_click(page,page.get_by_role('button',name='Copy solutions',exact=True))
    clipboard=await page.evaluate('()=>navigator.clipboard.readText()')
    assert clipboard==text,(clipboard,text)
    validate_enumeration(clipboard,expected)
    return {'assignment':text,'rows':rows,'clipboard':clipboard,'nativeFields':fields,'geometry':await parent.bounding_box()}


async def check_modules(args):
    output=Path(args.output)/'additional-modules';output.mkdir(parents=True,exist_ok=True)
    report={'passed':False,'toolSource':os.environ.get('GITHUB_SHA'),'checks':[],
            'coverage':'five frozen distribution/regression cases, two full-precision descriptive cases, three complete CSP enumerations',
            'injectedResults':False,'displayNote':'Compact statistics use six decimals or four fractional scientific digits; descriptive dialog retains complete double values.'}
    def save():(output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    async with async_playwright() as pw:
        browser=await pw.chromium.launch(args=['--no-sandbox','--enable-unsafe-swiftshader'])
        try:
            for width,height in [(1280,900),(390,844)]:
                for name,tab,inputs,refs in STATISTICS+[(name,'Constraint',{'Constraint program':source},refs)for name,source,refs in ENUMERATIONS]:
                    context,page,errors=await controls.context_for(browser,{'viewport':{'width':width,'height':height},'cpu':1,'has_touch':width<600})
                    item={'case':name,'width':width,'height':height,'passed':False};report['checks'].append(item)
                    try:
                        await controls.bootstrap(page,args.url)
                        response=await context.request.get(urljoin(args.url.rstrip('/')+'/', 'build-info.json'))
                        assert response.ok,response.status
                        source=(await response.json())['source'];assert re.fullmatch(r'[0-9a-f]{40}',source),source
                        if args.expected_source:assert source==args.expected_source,source
                        item['appSource']=source
                        await page.get_by_role('button',name=re.compile(r'^Analysis')).click()
                        card=page.get_by_text(re.compile(r'^Constraint problems\s+Diophantine equations and cryptarithms'if tab=='Constraint'else r'^Statistics\s+Descriptive stats, linear regression, normal & binomial distributions'))
                        await real_click(page,card)
                        if tab=='Constraint':
                            await reveal_tab(page,'Free-form')
                            item['inputsReadBack']=await fill_fields(page,inputs)
                            await real_click(page,page.get_by_role('button',name='Solve',exact=True))
                            count=len(refs);label='1 solution'if count==1 else f'{count} solutions'
                            header=page.get_by_text(label,exact=True).first
                            item['header']=label
                            item['result']=await enumeration_result(page,header,refs)
                        elif tab=='Tests':
                            await check_hypothesis(page,'chi-square-empty-bin',inputs,refs,item,output,width)
                        else:
                            await real_click(page,page.get_by_label(tab,exact=True),horizontal=True)
                            item['inputsReadBack']=await fill_fields(page,inputs)
                            if tab=='Descriptive':
                                await real_click(page,page.get_by_role('button',name='Full precision',exact=True))
                                content=page.get_by_text(re.compile(r'^Mean:')).first
                                await content.wait_for(state='attached')
                                text=await content.inner_text();item['fullPrecisionText']=text
                                values={}
                                for label,expected in refs.items():
                                    matches=re.findall(rf'(?:^|\n){re.escape(label)}:\s*({NUMBER})(?=\n|$)',text)
                                    assert len(matches)==1 and float(matches[0])==expected,(name,label,text,expected)
                                    values[label]=matches[0]
                                item['fullPrecisionValues']=values
                            else:item['rows']={label:await visible_row(page,label,value)for label,value in refs.items()}
                        assert not errors,errors
                        await page.screenshot(path=str(output/f'{name}-{width}.png'));item['passed']=True
                    except Exception as error:
                        item['error']=repr(error);item['pageErrors']=errors
                        item['labels']=await page.locator('[aria-label]').evaluate_all("els=>els.map(el=>el.getAttribute('aria-label'))")
                        await page.screenshot(path=str(output/f'failure-{name}-{width}.png'));save();raise
                    finally:save();await context.close()
            report['passed']=True;save()
        finally:await browser.close()
