"""Create connected worksheets through real controls; edit, restore, export and reload.

Onboarding is dismissed by its real Skip button. No preferences, documents,
graphs, caches or results are injected. Storage is read-only evidence.
"""
import argparse
import asyncio
import json
import re
import time
from pathlib import Path

from playwright.async_api import async_playwright, expect
from benchmark_workflows import next_frames
from check_feature_browser import labels
from check_round6_statistics_browser import real_click
from guided_popup_geometry import stable_popup_window


async def snapshot(page):
    return await page.evaluate('''() => {
      const read=key=>{const raw=localStorage.getItem('flutter.crisp.'+key);
        if(raw===null)return null;const value=JSON.parse(raw);
        return typeof value==='string'&&/^[\\[{]/.test(value)?JSON.parse(value):value;};
      const ids=read('notepadIndex')||[];
      return {current:read('currentNotepadDoc'),
        documents:ids.map(id=>read('notepadDoc.'+encodeURIComponent(id))).filter(Boolean),
        links:read('graphLinks')||{}, functions:read('functions')||[]};
    }''')


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'passed': False, 'injectedDocuments': False,
              'injectedResults': False, 'injectedPreferences': False, 'checks': []}
    async with async_playwright() as pw:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await pw.chromium.launch(**options)
        for profile, width, height in [('desktop', 1280, 900), ('phone', 390, 844), ('tablet', 1032, 1376)]:
            context = await browser.new_context(
                viewport={'width': width, 'height': height},
                has_touch=profile != 'desktop',
                permissions=['clipboard-read', 'clipboard-write'])
            page = await context.new_page()
            page.set_default_timeout(120000)
            errors = []
            page.on('pageerror', lambda error: errors.append(str(error)))
            def console(message):
                if message.type == 'error' and any(token in message.text for token in
                        ['EXCEPTION CAUGHT', 'setState()', 'RenderFlex', 'Unhandled']):
                    errors.append(message.text)
            page.on('console', console)
            item = {'profile': profile, 'width': width, 'height': height, 'passed': False}
            report['checks'].append(item)
            async def button(name):
                await real_click(page, page.get_by_role('button', name=name, exact=True))
                await next_frames(page)
            async def menu(name):
                item['stage'] = 'menu: ' + name
                await button('Document menu')
                target = page.locator('[aria-label='+json.dumps(name)+']')
                await target.wait_for(state='attached')
                samples = []
                item.setdefault('menuGeometry', []).append({'action': name, 'samples': samples})
                for _ in range(120):
                    count = await target.count()
                    sample = {'count': count, 'ready': False, 'timeMs': time.monotonic()*1000}
                    if count == 1:
                        sample.update(await target.evaluate('''el=>{
                          const r=el.getBoundingClientRect(),hit=document.elementFromPoint(r.x+r.width/2,r.y+r.height/2);
                          return {x:r.x,y:r.y,width:r.width,height:r.height,
                            ready:r.width>0&&r.height>0&&r.x>=0&&r.right<=innerWidth&&r.y>=0&&r.bottom<=innerHeight&&
                              !!hit&&(hit===el||el.contains(hit))};
                        }'''))
                    samples.append(sample)
                    if stable_popup_window(samples):
                        break
                    await next_frames(page)
                else:
                    raise AssertionError('Popup item never became unique, unobscured and stable for 250ms')
                await real_click(page, target)
                await next_frames(page)
                await target.wait_for(state='hidden')
            async def edit(value):
                field = page.get_by_role('textbox').first
                await real_click(page, field)
                await next_frames(page)
                await field.fill(value)
                await expect(field).to_have_value(value)
                await next_frames(page)
                await expect(field).to_have_value(value)
            async def result(doc_id, value):
                await page.wait_for_function('''({id,value})=>{
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  if(!raw)return false;const doc=JSON.parse(JSON.parse(raw));
                  return doc.l.length===3&&doc.l[2].r===value&&!doc.l.some(row=>row.e);
                }''', arg={'id': doc_id, 'value': value})
                await page.wait_for_function('''value=>[...document.querySelectorAll('[aria-label]')]
                    .some(el=>el.getAttribute('aria-label').split('\\n').includes(value))||
                    document.body.innerText.split('\\n').includes(value)''', arg=value)
            async def create():
                before = await snapshot(page)
                await menu('Explore a linked worksheet')
                item['stage'] = 'fresh linked worksheet creation'
                await page.wait_for_function('''previous=>{
                  const raw=localStorage.getItem('flutter.crisp.currentNotepadDoc');
                  return raw&&JSON.parse(raw)!==previous;
                }''', arg=before['current'])
                after = await snapshot(page)
                doc_id = after['current']
                await result(doc_id, '19')
                await page.wait_for_function('''id=>{
                  const raw=localStorage.getItem('flutter.crisp.graphLinks');
                  return raw&&Object.values(JSON.parse(JSON.parse(raw))).some(link=>link.document===id);
                }''', arg=doc_id)
                await page.get_by_role('button', name='View linked graph', exact=True).wait_for()
                after = await snapshot(page)
                doc = next(doc for doc in after['documents'] if doc['i'] == doc_id)
                assert [row['s'] for row in doc['l']] == ['a=3', 'f(x)=x^2+a', 'f(4)'], doc
                assert doc_id not in {doc['i'] for doc in before['documents']}
                for previous in before['documents']:
                    preserved = next(doc for doc in after['documents'] if doc['i'] == previous['i'])
                    assert [(row['i'], row['s']) for row in preserved['l']] == [
                        (row['i'], row['s']) for row in previous['l']], (previous, preserved)
                assert all(after['links'].get(slot) == link for slot, link in before['links'].items())
                return doc_id
            try:
                await page.goto(args.url, wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for(timeout=300000)
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                await button('Skip')
                await page.get_by_role('button', name='Evaluate', exact=True).wait_for()
                await page.keyboard.press('Control+2')
                await page.get_by_role('textbox').first.wait_for()
                original = (await snapshot(page))['current']
                await edit('sentinel=37')
                await page.wait_for_function('''id=>{
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  if(!raw)return false;const row=JSON.parse(JSON.parse(raw)).l[0];
                  return row.s==='sentinel=37'&&row.r==='37'&&!row.e;
                }''', arg=original)
                await page.wait_for_function('''()=>[...document.querySelectorAll('[aria-label]')]
                    .some(el=>el.getAttribute('aria-label').split('\\n').includes('37'))||
                    document.body.innerText.split('\\n').includes('37')''')
                first = await create()
                second = await create()
                assert first != second
                await page.screenshot(path=str(output/f'{profile}-created.png'))
                await button('Document history')
                await button('Save checkpoint')
                await page.get_by_role('button', name='Compare', exact=True).wait_for()
                await button('Close')
                await edit('a=5')
                await result(second, '21')
                updated = await snapshot(page)
                slot = next(slot for slot, link in updated['links'].items() if link['document'] == second)
                assert '(5)' in updated['functions'][int(slot)], updated
                await button('View linked graph')
                linked = page.get_by_role('button', name=f'Linked Y{int(slot)+1}: Explore a function', exact=True)
                await real_click(page, linked)
                await page.get_by_role('button', name='Edit a', exact=True).wait_for()
                assert re.search(r'a = 5(?:\.0)?(?:\n|$)', await labels(page))
                await button('Open source')
                await page.get_by_role('textbox').first.wait_for()
                await result(second, '21')
                await button('Document history')
                await real_click(page, page.get_by_role('button', name='Compare', exact=True).first)
                await page.get_by_role('button', name='Restore checkpoint', exact=True).wait_for()
                assert 'a=3' in await labels(page) and 'a=5' in await labels(page)
                await button('Restore checkpoint')
                await result(second, '19')
                restored = await snapshot(page)
                assert '(3)' in restored['functions'][int(slot)], restored
                await button('Worksheet export preview')
                await page.get_by_role('button', name='Save MD', exact=True).wait_for()
                assert 'f(4)' in await labels(page) and '19' in await labels(page)
                async with page.expect_download() as info:
                    await button('Save MD')
                download = await info.value
                target = output/f'{profile}-worksheet.md'
                await download.save_as(target)
                exported = target.read_text()
                assert 'a=3' in exported and 'f(4)' in exported and '19' in exported, exported
                assert restored['functions'][int(slot)] in exported, exported
                await page.screenshot(path=str(output/f'{profile}-export.png'))
                await button('Close')
                await page.reload(wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for(timeout=300000)
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                await page.keyboard.press('Control+2')
                await page.get_by_role('textbox').first.wait_for()
                await result(second, '19')
                saved = await snapshot(page)
                assert saved['links'][slot] == restored['links'][slot]
                assert next(doc for doc in saved['documents'] if doc['i'] == original)['l'][0]['s'] == 'sentinel=37'
                assert next(doc for doc in saved['documents'] if doc['i'] == first)['l'][2]['r'] == '19'
                assert not errors, errors
                item.update(passed=True, createdIds=[first, second], existingWorkPreserved=True,
                    linkedSlot=int(slot), resultSequence=['19','21','19'], sourceNavigation=True,
                    checkpointRestore=True, downloadedMarkdown=True, reload=True, pageErrors=errors)
            except Exception as error:
                item.update(error=str(error), state=await snapshot(page), pageErrors=errors)
                await page.screenshot(path=str(output/f'{profile}-failure.png'))
                raise
            finally:
                (output/'report.json').write_text(json.dumps(report, indent=2)+'\n')
                await context.close()
        report['passed'] = True
        (output/'report.json').write_text(json.dumps(report, indent=2)+'\n')
        await browser.close()
    print(json.dumps(report), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/guided-worksheet')
    parser.add_argument('--chromium')
    asyncio.run(check(parser.parse_args()))
