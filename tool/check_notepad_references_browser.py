"""Exercise stable worksheet result references through actual desktop/phone UI.

Every source and reference is entered through visible controls. Local storage
is read only to verify persisted identity and results; no source, result,
preference, or application state is injected. Run against the exact hosted CI
build. Engine tests separately cover reorder/cycle/import edge cases.
"""
import argparse
import asyncio
import json
import os
import re
from pathlib import Path
from urllib.parse import unquote

from playwright.async_api import async_playwright, expect

from benchmark_workflows import next_frames
from check_connected_notepad_browser import button, enable_semantics, fill_field, popup_item
from check_feature_browser import labels
from check_guided_worksheet_browser import snapshot
from check_round6_statistics_browser import real_click


async def current_document(page):
    state = await snapshot(page)
    return next(doc for doc in state['documents'] if doc['i'] == state['current'])


async def wait_rows(page, document_id, sources, results, *, timeout=90000):
    """Independent exact answers, after actual editing and persisted recalc."""
    handle = await page.wait_for_function("""({id,sources,results})=>{
      const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
      if(!raw)return false;const doc=JSON.parse(JSON.parse(raw));
      return doc.l.length===sources.length && doc.l.every((row,i)=>
        row.s===sources[i]&&!row.e&&String(row.r)===results[i]) ? doc : false;
    }""", arg={'id': document_id, 'sources': sources, 'results': results}, timeout=timeout)
    document = await handle.json_value()
    await handle.dispose()
    return document


def referenced_ids(source):
    return [unquote(value) for value in re.findall(r'@\{([^{}]+)\}', source)]


async def row_result(page, index, result):
    # Existing hosted worksheet checks establish that this semantic carrier
    # contains one row's actual editor and rendered result.
    rows = page.get_by_label('Drag to reorder', exact=True)
    row = rows.nth(index)
    await row.wait_for(state='attached')
    target = row.get_by_text(result, exact=True).or_(row.get_by_label(result, exact=True))
    await expect(target).to_have_count(1)
    await expect(target).to_be_visible()
    box = await target.bounding_box()
    viewport = page.viewport_size
    assert box and box['width'] > 0 and box['height'] > 0
    assert 0 <= box['x'] and box['x'] + box['width'] <= viewport['width']
    assert 0 <= box['y'] and box['y'] + box['height'] <= viewport['height']
    return target


async def result_actions(page, result, profile):
    # Static math can pass pointer hits to its own row. Require a measured,
    # unobscured target, then send genuine pointer input at that position.
    target = await row_result(page, 0, result)
    position = await target.evaluate("""el=>{
      const r=el.getBoundingClientRect(),x=r.x+r.width/2,y=r.y+r.height/2;
      const hit=document.elementFromPoint(x,y),row=el.closest('[aria-label="Drag to reorder"]');
      return {x,y,ready:r.width>0&&r.height>0&&x>0&&x<innerWidth&&y>0&&y<innerHeight&&
        !!hit&&(hit===el||el.contains(hit)||(!!row&&row.contains(hit)))};
    }""")
    assert position['ready'], 'Computed source result is not an unobscured pointer target'
    if profile == 'phone':
        await page.mouse.move(position['x'], position['y'])
        await page.mouse.down()
        await page.wait_for_timeout(650)
        await page.mouse.up()
    else:
        await page.mouse.click(position['x'], position['y'], button='right')
    await next_frames(page)
    await button(page, 'Use result')


async def document_menu(page, name):
    await button(page, 'Document menu')
    await popup_item(page, name, reveal=True)


async def reference_button(page, line_number, hint):
    # Flutter may expose the separate semantic hint as part of the accessible
    # name. Accept only the exact label or that label plus the expected hint,
    # never an arbitrary prefix that could select a different source.
    label = f'Result of line {line_number}'
    name = re.compile(r'^' + re.escape(label) + r'(?:\s+' + re.escape(hint) + r')?$')
    target = page.get_by_role('button', name=name)
    await expect(target).to_have_count(1)
    await real_click(page, target)
    await next_frames(page)


async def reference_dom(page):
    """Bounded read-only evidence for a failed real-control assertion."""
    return await page.evaluate("""()=>{
      const candidates=[...document.querySelectorAll('[aria-label]')].filter(el=>
        /Use result|References|Result of line|Missing result|Delete line|Undo/.test(
          el.getAttribute('aria-label')||''));
      return candidates.slice(0,30).map(el=>{
        const r=el.getBoundingClientRect();
        return {label:el.getAttribute('aria-label'),role:el.getAttribute('role'),
          rect:{x:r.x,y:r.y,width:r.width,height:r.height},outerHTML:el.outerHTML.slice(0,2000)};
      });
    }""")


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {
        'url': args.url, 'toolSource': os.environ.get('GITHUB_SHA'), 'passed': False,
        'injectedDocuments': False, 'injectedResults': False, 'injectedPreferences': False,
        'coverage': ['Use result', 'live dependency updates', 'picker selection replacement',
                     'source navigation', 'deletion and undo', 'duplicate identity', 'reload'],
        'notCovered': ['pointer-driven reordering', 'cross-document imports', 'physical devices'],
        'checks': [],
    }
    async with async_playwright() as pw:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await pw.chromium.launch(**options)
        for profile, width, height in [('desktop', 1280, 900), ('phone', 390, 844)]:
            context = await browser.new_context(viewport={'width': width, 'height': height},
                                               locale='en-US', has_touch=profile == 'phone')
            page = await context.new_page()
            page.set_default_timeout(90000)
            errors = []
            page.on('pageerror', lambda error: errors.append(str(error)))

            def console(message):
                if message.type == 'error' and any(token in message.text for token in
                        ['EXCEPTION CAUGHT', 'setState()', 'RenderFlex', 'Unhandled']):
                    errors.append(message.text)

            page.on('console', console)
            item = {'profile': profile, 'width': width, 'height': height, 'passed': False}
            report['checks'].append(item)
            try:
                item['stage'] = 'compute and use a result through its actual context menu'
                await page.goto(args.url, wait_until='domcontentloaded')
                await enable_semantics(page)
                await button(page, 'Skip')
                await page.get_by_role('button', name='Evaluate', exact=True).wait_for()
                await page.keyboard.press('Control+2')
                fields = page.get_by_role('textbox')
                await fields.first.wait_for()
                original = await current_document(page)
                document_id = original['i']
                await fill_field(page, fields.first, '3+4')
                original = await wait_rows(page, document_id, ['3+4'], ['7'])
                source_id = original['l'][0]['i']
                await result_actions(page, '7', profile)
                await expect(fields).to_have_count(2)
                await expect(fields.nth(1)).to_have_value(re.compile(r'^@\{[^{}]+\}$'))
                await expect(fields.nth(1)).to_be_focused()
                token = await fields.nth(1).input_value()
                assert referenced_ids(token) == [source_id], token
                await page.keyboard.press('End')
                await page.keyboard.type('*2')
                await expect(fields.nth(1)).to_have_value(token + '*2')
                linked = await wait_rows(page, document_id, ['3+4', token + '*2'], ['7', '14'])
                await row_result(page, 1, '14')
                dependent_id = linked['l'][1]['i']
                item['useResult'] = True

                item['stage'] = 'source edits recalculate the same dependent row'
                await fill_field(page, fields.first, '5+4')
                edited = await wait_rows(page, document_id, ['5+4', token + '*2'], ['9', '18'])
                assert [row['i'] for row in edited['l']] == [source_id, dependent_id]
                await row_result(page, 1, '18')
                item['liveResults'] = ['14', '18']
                await page.screenshot(path=str(output / f'{profile}-live-reference.png'))

                item['stage'] = 'References picker replaces the current editor selection'
                await fill_field(page, fields.nth(1), '10+0')
                await wait_rows(page, document_id, ['5+4', '10+0'], ['9', '10'])
                await page.keyboard.press('End')
                await page.keyboard.press('Shift+ArrowLeft')
                selected = await fields.nth(1).evaluate(
                    '(el)=>el.value.slice(el.selectionStart,el.selectionEnd)')
                assert selected == '0', selected
                await document_menu(page, 'References…')
                await reference_button(page, 1, '5+4 = 9')
                await expect(fields.nth(1)).to_have_value('10+' + token)
                picked = await wait_rows(page, document_id, ['5+4', '10+' + token], ['9', '19'])
                assert picked['l'][1]['i'] == dependent_id
                await row_result(page, 1, '19')
                item['selectionReplacement'] = True

                item['stage'] = 'reference chip returns focus to its source row'
                await reference_button(page, 1, 'Open source: 5+4')
                await expect(fields.first).to_have_value('5+4')
                await expect(fields.first).to_be_focused()
                item['sourceNavigation'] = True

                item['stage'] = 'deleting the source reports a missing reference and Undo recovers it'
                deletes = page.get_by_role('button', name=re.compile(r'^Delete line(?: Delete line)?$'))
                await expect(deletes).to_have_count(2)
                await real_click(page, deletes.first)
                await next_frames(page)
                missing = await page.wait_for_function("""id=>{
                  const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
                  if(!raw)return false;const doc=JSON.parse(JSON.parse(raw));
                  return doc.l.length===1&&doc.l[0].e&&!doc.l[0].r ? doc : false;
                }""", arg=document_id, timeout=3000)
                missing_doc = await missing.json_value()
                await missing.dispose()
                assert missing_doc['l'][0]['i'] == dependent_id
                assert referenced_ids(missing_doc['l'][0]['s']) == [source_id]
                await next_frames(page)
                assert 'Missing result' in await labels(page)
                await button(page, 'Undo')
                restored = await wait_rows(page, document_id, ['5+4', '10+' + token], ['9', '19'])
                assert [row['i'] for row in restored['l']] == [source_id, dependent_id]
                await row_result(page, 1, '19')
                item['missingReferenceError'] = missing_doc['l'][0]['e']
                item['undoRestoredIdentity'] = True

                item['stage'] = 'duplicate remaps references to the new worksheet source'
                await document_menu(page, 'Duplicate')
                await page.wait_for_function("""old=>{
                  const raw=localStorage.getItem('flutter.crisp.currentNotepadDoc');
                  return raw&&JSON.parse(raw)!==old;
                }""", arg=document_id)
                duplicate = await current_document(page)
                duplicate_id = duplicate['i']
                assert duplicate_id != document_id
                assert len(duplicate['l']) == 2
                assert duplicate['l'][0]['i'] != source_id
                assert duplicate['l'][1]['i'] != dependent_id
                duplicate_source = duplicate['l'][1]['s']
                assert duplicate_source.startswith('10+@{'), duplicate_source
                assert referenced_ids(duplicate_source) == [duplicate['l'][0]['i']]
                assert referenced_ids(duplicate_source) != [source_id]
                await wait_rows(page, duplicate_id, ['5+4', duplicate_source], ['9', '19'])
                await fill_field(page, fields.first, '10')
                await wait_rows(page, duplicate_id, ['10', duplicate_source], ['10', '20'])
                await row_result(page, 1, '20')
                retained = next(doc for doc in (await snapshot(page))['documents']
                                if doc['i'] == document_id)
                assert [(row['i'], row['s'], row['r']) for row in retained['l']] == [
                    (source_id, '5+4', '9'), (dependent_id, '10+' + token, '19')]
                item['duplicateRemapsReferences'] = True
                item['existingWorkPreserved'] = True

                item['stage'] = 'reload keeps duplicate identity and live references'
                await page.reload(wait_until='domcontentloaded')
                await enable_semantics(page)
                await page.keyboard.press('Control+2')
                await fields.first.wait_for()
                reloaded = await wait_rows(page, duplicate_id, ['10', duplicate_source], ['10', '20'])
                assert [row['i'] for row in reloaded['l']] == [row['i'] for row in duplicate['l']]
                assert (await snapshot(page))['current'] == duplicate_id
                await row_result(page, 1, '20')
                await page.screenshot(path=str(output / f'{profile}-reloaded-reference.png'))
                assert not errors, errors
                item.update(passed=True, reload=True, originalDocument=document_id,
                            duplicateDocument=duplicate_id, pageErrors=errors)
            except Exception as error:
                item.update(error=str(error), pageErrors=errors)
                try:
                    item['state'] = await snapshot(page)
                    (output / f'{profile}-failure-labels.txt').write_text(await labels(page))
                    (output / f'{profile}-failure-semantics.json').write_text(
                        json.dumps(await reference_dom(page), indent=2) + '\n')
                    await page.screenshot(path=str(output / f'{profile}-failure.png'), timeout=10000)
                except Exception as evidence_error:
                    item['evidenceError'] = str(evidence_error)
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
    parser.add_argument('--output', default='browser-results/notepad-references')
    parser.add_argument('--chromium')
    asyncio.run(check(parser.parse_args()))
