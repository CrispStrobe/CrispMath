"""Exercise inline plots and both worksheet/graph directions through real UI.

Fresh browser profiles dismiss onboarding and enter every expression through
visible controls. Storage is read-only evidence for persistence and link IDs;
no documents, preferences, outputs or app state are injected. Run on hosted CI
against the exact built feature commit, on both wide and narrow layouts.
"""
import argparse
import asyncio
import json
import math
import os
import re
import time
from pathlib import Path

from playwright.async_api import async_playwright, expect

from benchmark_workflows import next_frames
from check_feature_browser import labels
from check_guided_worksheet_browser import snapshot
from check_round6_statistics_browser import real_click
from guided_popup_geometry import stable_popup_window


async def wait_document(page, document_id, sources):
    """Wait for the actual UI edits and their persisted, error-free outputs."""
    await page.wait_for_function(
        """({id,sources})=>{
          const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
          if(!raw)return false;const doc=JSON.parse(JSON.parse(raw));
          return doc.l.length===sources.length && doc.l.every((row,i)=>
            row.s===sources[i]&&!row.e&&row.r!==null&&row.r!==undefined);
        }""", arg={'id': document_id, 'sources': sources})


async def fill_field(page, field, value):
    await real_click(page, field)
    await next_frames(page)
    await field.fill(value)
    await expect(field).to_have_value(value)
    await next_frames(page)
    await expect(field).to_have_value(value)


async def button(page, name):
    await real_click(page, page.get_by_role('button', name=name, exact=True))
    await next_frames(page)


async def popup_item(page, name, *, reveal=False):
    """Wait for actual popup layout/hit testing before a real pointer click."""
    # Accessible names preserve Unicode; JSON escapes are not CSS escapes.
    # Include clipped menu items so real scrolling can reveal them below.
    target = page.get_by_role('menuitem', name=name, exact=True, include_hidden=True)
    await target.wait_for(state='attached')
    samples = []
    for _ in range(180):
        sample = {'count': await target.count(), 'ready': False,
                  'timeMs': time.monotonic() * 1000}
        if sample['count'] == 1:
            sample.update(await target.evaluate("""el=>{
              const r=el.getBoundingClientRect();
              const hit=document.elementFromPoint(r.x+r.width/2,r.y+r.height/2);
              return {x:r.x,y:r.y,width:r.width,height:r.height,
                ready:r.width>0&&r.height>0&&r.x>=0&&r.right<=innerWidth&&
                  r.y>=0&&r.bottom<=innerHeight&&!!hit&&(hit===el||el.contains(hit))};
            }"""))
        samples.append(sample)
        if stable_popup_window(samples):
            await real_click(page, target)
            await target.wait_for(state='hidden')
            await next_frames(page)
            return
        if reveal and sample['count'] == 1 and not sample['ready']:
            # The document menu's Copy action can be below its visible fold.
            # Scroll over its measured horizontal position, never force-click
            # a clipped semantic node or mutate the DOM scroll position.
            width, height = page.viewport_size['width'], page.viewport_size['height']
            x = min(width - 20, max(20, sample['x'] + sample['width'] / 2))
            await page.mouse.move(x, height * 0.65)
            await page.mouse.wheel(0, -180 if sample['y'] < 0 else 180)
        await next_frames(page)
    raise AssertionError(f'Popup item did not settle: {name}; {samples[-4:]}')


async def function_menu(page, slot):
    """Reveal one named slot in the horizontal list using real wheel input."""
    target = page.get_by_role('button', name=f'Y{slot + 1}: Function actions', exact=True)
    menus = page.get_by_role('button', name=re.compile(r'^Y\d+: Function actions$'))
    await menus.first.wait_for(state='attached')
    for _ in range(20):
        position = None
        if await target.count() == 1:
            position = await target.evaluate("""el=>{
              const r=el.getBoundingClientRect(),x=r.x+r.width/2,y=r.y+r.height/2;
              const hit=document.elementFromPoint(x,y);
              return {x,y,ready:r.width>0&&r.height>0&&x>0&&x<innerWidth&&
                y>0&&y<innerHeight&&!!hit&&(hit===el||el.contains(hit))};
            }""")
            if position['ready']:
                await page.mouse.click(position['x'], position['y'])
                await next_frames(page)
                return
        visible = await menus.evaluate_all("""els=>els.map(el=>{
          const r=el.getBoundingClientRect();return {
            label:(el.getAttribute('aria-label')||el.textContent||'').trim(),
            x:r.x+r.width/2,y:r.y+r.height/2};
        }).filter(r=>r.x>0&&r.x<innerWidth&&r.y>0&&r.y<innerHeight)""")
        assert visible, 'No graph function menu has visible scroll geometry'
        # Flutter can expose this button's accessible name through its child
        # text instead of aria-label. Require the same complete name that the
        # role locator matched before using it to choose a scroll direction.
        first_name = re.fullmatch(r'Y(\d+): Function actions', visible[0]['label'])
        assert first_name, f"Unexpected graph function action name: {visible[0]['label']!r}"
        first_slot = int(first_name.group(1)) - 1
        direction = -1 if (position and position['x'] < 0) or first_slot > slot else 1
        await page.mouse.move(page.viewport_size['width'] * 0.5, visible[0]['y'])
        await page.mouse.wheel(direction * 220, 0)
        await next_frames(page)
    raise AssertionError(f'Could not reveal function menu Y{slot + 1}')


# The chart owns an image semantics node, distinct from its range caption and
# graph-opening button. Retain full label matching and real on-screen geometry
# without depending on one browser's mapping of Flutter's image role.
PLOT_LABEL_JS = r"""({pattern})=>{
  const re=new RegExp(pattern);
  for(const el of document.querySelectorAll('[aria-label^="Graphing: "]')){
    const label=el.getAttribute('aria-label');
    const r=el.getBoundingClientRect();
    if(re.test(label)&&r.width>0&&r.height>0&&r.right>0&&r.bottom>0&&
       r.left<innerWidth&&r.top<innerHeight)return label;
  }return false;
}"""


async def wait_plot_label(page, pattern):
    handle = await page.wait_for_function(
        PLOT_LABEL_JS, arg={'pattern': pattern}, timeout=90000)
    text = await handle.json_value()
    await handle.dispose()
    return text


async def plot_semantics_evidence(page):
    """Read actual semantic DOM geometry when a browser assertion fails."""
    return await page.evaluate(r"""()=>{
      const describe=el=>{
        const r=el.getBoundingClientRect(),s=getComputedStyle(el);
        return {tag:el.tagName,role:el.getAttribute('role'),
          label:el.getAttribute('aria-label'),hidden:el.getAttribute('aria-hidden'),
          rect:{x:r.x,y:r.y,width:r.width,height:r.height},
          display:s.display,visibility:s.visibility,
          outerHTML:el.outerHTML.slice(0,3000)};
      };
      return {viewport:{width:innerWidth,height:innerHeight},
        plots:[...document.querySelectorAll('[aria-label^="Graphing: "]')]
          .slice(0,20).map(el=>{
            const ancestors=[];let parent=el.parentElement;
            for(let i=0;parent&&i<4;i++,parent=parent.parentElement)
              ancestors.push(describe(parent));
            return {...describe(el),ancestors};
          })};
    }""")


async def inline_plot(page, coefficient, lo, hi):
    # This is the image semantics attached only after sampling succeeds. Its
    # label exposes the same bound expression/range painted in the widget.
    pattern = (r'^Graphing: (?=[^;]*\b' + re.escape(str(coefficient)) +
               r'(?:\.0)?\b)[^;]+; ' + re.escape(f'{lo} ≤ x ≤ {hi}') + r'$')
    text = await wait_plot_label(page, pattern)
    count = await page.locator('[aria-label^="Graphing: "]').evaluate_all(
        "(els,p)=>els.filter(e=>new RegExp(p).test(e.getAttribute('aria-label'))).length",
        pattern)
    assert count == 1, f'expected one inline plot, found {count}: {text}'
    expression = text.removeprefix('Graphing: ').rsplit('; ', 1)[0]
    assert not re.search(r'\b[af]\b', expression), expression
    return text


async def inline_range(page, lo, hi):
    # Capturing a viewport can introduce harmless double roundoff. Read the
    # rendered interval numerically instead of assuming one decimal spelling.
    handle = await page.wait_for_function(r"""({lo,hi})=>{
      for(const el of document.querySelectorAll('[aria-label^="Graphing: "]')){
        const label=el.getAttribute('aria-label');
        const m=/^Graphing: .+; ([^;]+) ≤ x ≤ ([^;]+)$/.exec(label);
        const r=el.getBoundingClientRect();
        if(m&&r.width>0&&r.height>0&&r.right>0&&r.bottom>0&&
           r.left<innerWidth&&r.top<innerHeight&&Math.abs(Number(m[1])-lo)<1e-6&&
           Math.abs(Number(m[2])-hi)<1e-6)
          return label;
      }return false;
    }""", arg={'lo': lo, 'hi': hi}, timeout=90000)
    text = await handle.json_value()
    await handle.dispose()
    return text


async def graph_bounds(page, *, change=None):
    await button(page, 'Graph bounds')
    result = {}
    for name in ['x minimum', 'x maximum', 'y minimum', 'y maximum']:
        field = page.get_by_role('textbox', name=name, exact=True)
        await real_click(page, field)
        await next_frames(page)
        await expect(field).to_have_value(re.compile(r'.+'))
        result[name] = float(await field.input_value())
        if change and name in change:
            await fill_field(page, field, str(change[name]))
    await button(page, 'Apply bounds' if change else 'Cancel')
    await page.get_by_role('textbox', name='x minimum', exact=True).wait_for(state='hidden')
    await next_frames(page)
    return result


async def enable_semantics(page):
    await page.locator('canvas').first.wait_for(timeout=300000)
    placeholder = page.locator('flt-semantics-placeholder')
    await placeholder.wait_for(state='attached')
    # Flutter's accessibility opt-in, not an application state mutation.
    await placeholder.evaluate('(el)=>el.click()')


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'toolSource': os.environ.get('GITHUB_SHA'),
              'passed': False, 'injectedDocuments': False, 'injectedResults': False,
              'injectedPreferences': False, 'checks': []}
    async with async_playwright() as pw:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await pw.chromium.launch(**options)
        for profile, width, height in [('desktop', 1280, 900), ('phone', 390, 844)]:
            context = await browser.new_context(
                viewport={'width': width, 'height': height}, locale='en-US',
                has_touch=profile == 'phone',
                permissions=['clipboard-read', 'clipboard-write'])
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
                item['stage'] = 'enter worksheet through real controls'
                await page.goto(args.url, wait_until='domcontentloaded')
                await enable_semantics(page)
                await button(page, 'Skip')
                await page.get_by_role('button', name='Evaluate', exact=True).wait_for()
                await page.keyboard.press('Control+2')
                await page.get_by_role('textbox').first.wait_for()
                before = await snapshot(page)
                original_id = before['current']
                sources = ['a=2', 'f(t)=a*t^2', 'plot(f(x),x,-2,2)']
                for index, source in enumerate(sources):
                    if index:
                        await button(page, 'Add line')
                    await fill_field(page, page.get_by_role('textbox').nth(index), source)
                await wait_document(page, original_id, sources)
                initial_label = await inline_plot(page, 2, -2, 2)
                await page.screenshot(path=str(output / f'{profile}-inline-initial.png'))

                item['stage'] = 'copy plot through the actual document Markdown menu'
                await button(page, 'Document menu')
                await popup_item(page, 'Copy as Markdown', reveal=True)
                await page.wait_for_function("""async()=>
                  (await navigator.clipboard.readText()).includes('plot(f(x),x,-2,2)')""")
                copied = await page.evaluate('navigator.clipboard.readText()')
                assert '`plot(f(x),x,-2,2)`' in copied, copied
                assert 'Plot of ' in copied and 'x in [-2, 2]' in copied, copied
                assert '__plot__' not in copied, copied
                item['clipboardPlotMetadata'] = True

                item['stage'] = 'edit captured parameter and observe new inline plot'
                sources[0] = 'a=3'
                await fill_field(page, page.get_by_role('textbox').first, sources[0])
                await wait_document(page, original_id, sources)
                updated_label = await inline_plot(page, 3, -2, 2)
                assert initial_label != updated_label, (initial_label, updated_label)
                await page.screenshot(path=str(output / f'{profile}-inline-updated.png'))
                item['inlineLabels'] = [initial_label, updated_label]

                item['stage'] = 'open inline graph with its declared interval'
                # This is the inline action before any graph link exists, so
                # there is no duplicate worksheet-level toolbar button.
                await button(page, 'View linked graph')
                await page.get_by_role('button', name='Graph bounds', exact=True).wait_for()
                await page.wait_for_function("""id=>{
                  const raw=localStorage.getItem('flutter.crisp.graphLinks');
                  return raw&&Object.values(JSON.parse(JSON.parse(raw)))
                    .some(link=>link.document===id);
                }""", arg=original_id)
                linked_state = await snapshot(page)
                slot = next(int(slot) for slot, link in linked_state['links'].items()
                            if link['document'] == original_id)
                bounds = await graph_bounds(page)
                assert math.isclose(bounds['x minimum'], -2, abs_tol=1e-6), bounds
                assert math.isclose(bounds['x maximum'], 2, abs_tol=1e-6), bounds
                item['linkedSlot'] = slot
                item['openedBounds'] = bounds
                await page.screenshot(path=str(output / f'{profile}-linked-graph.png'))

                item['stage'] = 'return through the linked function source action'
                await function_menu(page, slot)
                await popup_item(page, 'Open worksheet source')
                await page.get_by_role('textbox').first.wait_for()
                await wait_document(page, original_id, sources)
                await inline_plot(page, 3, -2, 2)
                assert (await snapshot(page))['current'] == original_id

                item['stage'] = 'edit an independent graph and its slider'
                await page.keyboard.press('Control+3')
                await function_menu(page, 0)
                await popup_item(page, 'Edit')
                # Graph uses its visible custom math editor and real keyboard
                # events; Escape is its documented Clear command.
                await page.keyboard.press('Escape')
                await page.keyboard.type('b*x', delay=40)
                await page.keyboard.press('Enter')
                await page.wait_for_function(r"""()=>{
                  const raw=localStorage.getItem('flutter.crisp.functions');
                  return raw&&JSON.parse(JSON.parse(raw))[0].replace(/\s/g,'')==='b*x';
                }""")
                slider = page.get_by_role('slider')
                await expect(slider).to_have_count(1)
                await real_click(page, slider)
                await next_frames(page)
                box = await slider.bounding_box()
                assert box and box['width'] > 0, 'Parameter slider has no visible track'
                await page.mouse.click(box['x'] + box['width'] * 0.72,
                                       box['y'] + box['height'] / 2)
                await next_frames(page)
                await page.wait_for_function("""()=>{
                  const raw=localStorage.getItem('flutter.crisp.parameters');
                  if(!raw)return false;const params=JSON.parse(JSON.parse(raw));
                  return params['0']&&Number.isFinite(params['0'].b)&&params['0'].b!==1;
                }""")
                parameter = await page.evaluate("""()=>JSON.parse(JSON.parse(
                  localStorage.getItem('flutter.crisp.parameters')))['0'].b""")
                assert math.isfinite(parameter) and parameter != 1, parameter
                await graph_bounds(page, change={'x minimum': -3, 'x maximum': 4})

                item['stage'] = 'create a source-owned worksheet from the graph'
                before_create = await snapshot(page)
                await function_menu(page, 0)
                await popup_item(page, 'Create worksheet')
                await page.get_by_role('textbox').first.wait_for()
                await page.wait_for_function("""previous=>{
                  const raw=localStorage.getItem('flutter.crisp.currentNotepadDoc');
                  return raw&&JSON.parse(raw)!==previous;
                }""", arg=original_id)
                created_state = await snapshot(page)
                created_id = created_state['current']
                created = next(doc for doc in created_state['documents'] if doc['i'] == created_id)
                assert created_id not in {doc['i'] for doc in before_create['documents']}
                assert len(created['l']) == 2, created
                binding = re.fullmatch(r'b\s*=\s*(.+)', created['l'][0]['s'])
                assert binding and math.isclose(float(binding.group(1)), parameter,
                                                rel_tol=1e-12, abs_tol=1e-12), created
                plot_source = created['l'][1]['s']
                interval = re.fullmatch(r'plot\(b\s*\*\s*x,\s*x,\s*([^,]+),\s*([^,]+)\)', plot_source)
                assert interval and math.isclose(float(interval.group(1)), -3, abs_tol=1e-6) and math.isclose(
                    float(interval.group(2)), 4, abs_tol=1e-6), plot_source
                await wait_document(page, created_id, [row['s'] for row in created['l']])
                imported_label = await inline_range(page, -3, 4)
                assert not re.search(r'\bb\b', imported_label), imported_label
                created_state = await snapshot(page)
                assert created_state['links']['0'] == {'document': created_id, 'line': created['l'][1]['i']}
                for previous in before_create['documents']:
                    retained = next(doc for doc in created_state['documents'] if doc['i'] == previous['i'])
                    assert [(row['i'], row['s']) for row in retained['l']] == [
                        (row['i'], row['s']) for row in previous['l']], (previous, retained)
                assert created_state['links'][str(slot)] == before_create['links'][str(slot)]
                await page.screenshot(path=str(output / f'{profile}-graph-worksheet.png'))

                item['stage'] = 'reload and verify source identity and graph ownership'
                await page.reload(wait_until='domcontentloaded')
                await enable_semantics(page)
                await page.keyboard.press('Control+2')
                await page.get_by_role('textbox').first.wait_for()
                await wait_document(page, created_id, [row['s'] for row in created['l']])
                reloaded_label = await inline_range(page, -3, 4)
                assert not re.search(r'\bb\b', reloaded_label), reloaded_label
                saved = await snapshot(page)
                assert saved['current'] == created_id
                assert saved['links']['0'] == created_state['links']['0']
                assert saved['links'][str(slot)] == created_state['links'][str(slot)]
                original = next(doc for doc in saved['documents'] if doc['i'] == original_id)
                assert [row['s'] for row in original['l']] == sources, original
                assert not errors, errors
                item.update(passed=True, sourceNavigation=True, originalDocument=original_id,
                            graphWorksheet=created_id, capturedParameter=parameter,
                            importedInterval=[-3, 4], importedLabel=imported_label,
                            reloadedLabel=reloaded_label, existingWorkPreserved=True,
                            reload=True, pageErrors=errors)
            except Exception as error:
                item.update(error=str(error), pageErrors=errors)
                try:
                    item['state'] = await snapshot(page)
                    (output / f'{profile}-failure-labels.txt').write_text(await labels(page))
                    semantics = await plot_semantics_evidence(page)
                    (output / f'{profile}-failure-semantics.json').write_text(
                        json.dumps(semantics, indent=2) + '\n')
                    item['plotSemanticNodes'] = len(semantics['plots'])
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
    parser.add_argument('--output', default='browser-results/connected-notepad')
    parser.add_argument('--chromium')
    asyncio.run(check(parser.parse_args()))
