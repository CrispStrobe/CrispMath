"""Playwright UI checks against a built CrispMath bundle (local or Pages).
Run with --url http://127.0.0.1:8766/ --stage 1 [--chromium PATH].
"""
import argparse
import asyncio
import json
import math
import re
import urllib.request
from pathlib import Path
from playwright.async_api import async_playwright

async def labels(page):
    return await page.locator('body').inner_text() + '\n' + await page.locator('[aria-label]').evaluate_all("els=>els.map(e=>e.getAttribute('aria-label')).join('\\n')")

async def check(args):
    async with async_playwright() as p:
        opts = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            opts['executable_path'] = args.chromium
        browser = await p.chromium.launch(**opts)
        context = await browser.new_context(viewport={'width': 1200, 'height': 900}, permissions=['clipboard-read', 'clipboard-write'])
        page = await context.new_page()
        errors = []
        page.on('pageerror', lambda e: (errors.append(str(e)), print('page error:', e, flush=True)))
        def console(message):
            if message.type == 'error':
                print('console:', message.text, flush=True)
                if any(s in message.text for s in ['EXCEPTION CAUGHT', 'setState()', 'RenderFlex', 'Unhandled']):
                    errors.append(message.text)
        page.on('console', console)
        await page.add_init_script("localStorage.setItem('flutter.crisp.onboardingDismissed','true')")
        if args.stage >= 2:
            await page.add_init_script("""
              if (!localStorage.getItem('featureTestSeeded')) {
                const doc={i:'live-model',n:'Live model',c:'2026-09-30T00:00:00Z',u:'2026-09-30T00:00:00Z',
                  l:[{i:'parameter-line',s:'a = 2',r:'2'},{i:'function-line',s:'f = a*sin(x)'}]};
                localStorage.setItem('flutter.crisp.notepadIndex',JSON.stringify(JSON.stringify(['live-model'])));
                localStorage.setItem('flutter.crisp.notepadDoc.live-model',JSON.stringify(JSON.stringify(doc)));
                localStorage.setItem('flutter.crisp.currentNotepadDoc',JSON.stringify('live-model'));
                localStorage.setItem('featureTestSeeded','true');
              }
            """)
        if args.stage >= 5:
            settings = {'crisp.copilot.apiUrl': args.ai_fixture_url + '/v1/chat/completions', 'crisp.copilot.model': 'browser-contract-fixture', 'crisp.copilot.apiKey': 'fixture-key'}
            await page.add_init_script('for (const [k,v] of Object.entries(' + json.dumps(settings) + ')) localStorage.setItem("flutter."+k,JSON.stringify(v))')
        await page.goto(args.url, wait_until="domcontentloaded", timeout=90000)
        print('Page loaded', flush=True)
        await page.locator('canvas').first.wait_for(timeout=300000)
        await page.locator('flt-semantics-placeholder').wait_for(state='attached', timeout=90000)
        await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
        await page.wait_for_function("document.body.innerText.includes('Notepad')", timeout=60000)
        await page.keyboard.press('Control+3')
        print('Graph selected', flush=True)
        await page.get_by_role('button', name='Value table', exact=True).click(timeout=60000)
        print('Value table open', flush=True)
        await page.get_by_role('button', name='Generate table', exact=True).click()
        await page.get_by_role('button', name='Copy CSV', exact=True).click(timeout=90000)
        csv = await page.evaluate('navigator.clipboard.readText()')
        assert csv.startswith('x,y\n'), csv
        rows = [tuple(map(float, r.split(','))) for r in csv.strip().splitlines()[1:]]
        assert rows[0][0] == -5 and rows[-1][0] == 5, rows
        assert all(math.isclose(y, math.sin(x), abs_tol=1e-12) for x,y in rows), rows
        assert len(csv.strip().splitlines()) == 12, csv
        print('CSV copied and verified', flush=True)
        await page.get_by_role('button', name='Close', exact=True).evaluate('(el)=>el.click()')
        await page.get_by_role('button', name='Trace curve', exact=True).click()
        await page.wait_for_function("document.body.innerText.includes('x = ') || [...document.querySelectorAll('[aria-label]')].some(e=>e.getAttribute('aria-label').includes('x = '))", timeout=90000)
        await page.mouse.click(850, 400)
        before = await labels(page)
        await page.keyboard.press('ArrowRight')
        await page.wait_for_timeout(200)
        after = await labels(page)
        before_x = float(re.search(r'x = ([^,]+), y = ', before).group(1))
        after_x = float(re.search(r'x = ([^,]+), y = ', after).group(1))
        assert after_x > before_x, 'Keyboard tracing did not advance'
        Path(args.screenshots).mkdir(parents=True, exist_ok=True)
        await page.screenshot(path=str(Path(args.screenshots) / 'graph-trace.png'))
        if args.stage >= 2:
            await page.keyboard.press('Control+2')
            await page.get_by_role('button', name='Link line to graph', exact=True).last.click(timeout=60000)
            await page.get_by_role('button', name='Linked Y3: Live model', exact=True).click(timeout=60000)
            await page.get_by_role('button', name='Open source', exact=True).wait_for(timeout=60000)
            assert re.search(r'a = 2(?:\.0)?(?:\n|$)', await labels(page)), await labels(page)
            await page.get_by_role('button', name='Open source', exact=True).click()
            await page.get_by_role('button', name='Link line to graph', exact=True).first.wait_for(timeout=60000)
            boxes = page.get_by_role('textbox')
            assert await boxes.count() >= 2
            await boxes.first.click()
            await page.keyboard.press('Control+A')
            await page.keyboard.type('a = 4')
            await page.wait_for_function(r"(localStorage.getItem('flutter.crisp.functions')||'').match(/\(4(?:\.0)?\)/)", timeout=60000)
            await page.get_by_label(re.compile(r'^Graphing')).first.evaluate('(el)=>el.click()')
            await page.get_by_role('button', name='Linked Y3: Live model', exact=True).click()
            await page.get_by_role('button', name='Open source', exact=True).wait_for(timeout=60000)
            assert re.search(r'a = 4(?:\.0)?(?:\n|$)', await labels(page)), await labels(page)
            await page.get_by_role('button', name='Close', exact=True).evaluate('(el)=>el.click()')
            await page.screenshot(path=str(Path(args.screenshots) / 'linked-graph.png'))
        if args.stage >= 3:
            await page.keyboard.press('Control+k')
            await page.get_by_role('textbox', name='Find a command').fill('unit converter')
            await page.keyboard.press('Enter')
            await page.get_by_text('Length', exact=True).first.wait_for(timeout=60000)
            await page.keyboard.press('Escape')
            await page.get_by_role('button', name='Search commands', exact=True).click()
            await page.get_by_role('textbox', name='Find a command').fill('notepad')
            await page.keyboard.press('Enter')
            await page.get_by_role('button', name='Link line to graph', exact=True).first.wait_for(timeout=60000)
            await page.screenshot(path=str(Path(args.screenshots) / 'command-navigation.png'))
        if args.stage >= 4:
            await page.get_by_label(re.compile(r'^Graphing')).first.evaluate('(el)=>el.click()')
            await page.get_by_role('button', name='Graph bounds', exact=True).click()
            await page.get_by_role('textbox', name='x minimum', exact=True).fill('10')
            await page.get_by_role('textbox', name='x maximum', exact=True).fill('-10')
            await page.get_by_role('button', name='Apply bounds', exact=True).click()
            await page.get_by_text('Enter finite, increasing x and y bounds.', exact=True).wait_for()
            for label, value in [('x minimum','-5'),('x maximum','5'),('y minimum','-100'),('y maximum','100')]:
                await page.get_by_role('textbox', name=label, exact=True).fill(value)
            await page.get_by_role('button', name='Apply bounds', exact=True).click()
            await page.get_by_role('button', name='Fit graph', exact=True).click()
            await page.wait_for_timeout(1000)
            await page.get_by_role('button', name='Graph bounds', exact=True).click()
            assert float(await page.get_by_role('textbox', name='y maximum', exact=True).input_value()) < 10
            await page.get_by_role('button', name='Cancel', exact=True).click()
            await page.get_by_role('button', name='Undo graph change', exact=True).click()
            await page.get_by_role('button', name='Graph bounds', exact=True).click()
            assert float(await page.get_by_role('textbox', name='y maximum', exact=True).input_value()) == 100
            await page.get_by_role('button', name='Cancel', exact=True).click()
            await page.screenshot(path=str(Path(args.screenshots) / 'graph-navigation.png'))
        if args.stage >= 5:
            await page.get_by_label(re.compile(r'^Settings')).first.click()
            await page.get_by_role('button', name='Open assistant', exact=True).click()
            question = page.get_by_role('textbox', name='Math question', exact=True)
            await question.fill('simulate failure')
            await page.get_by_role('button', name='Translate', exact=True).click()
            await page.get_by_text(re.compile('HTTP 503')).wait_for(timeout=60000)
            await question.fill('slow request')
            await page.get_by_role('button', name='Retry', exact=True).click()
            await page.get_by_role('button', name='Cancel request', exact=True).click()
            await page.get_by_text('Request cancelled. You can retry.', exact=True).wait_for()
            await question.fill('two plus two')
            await page.get_by_role('button', name='Retry', exact=True).click()
            expression = page.get_by_role('textbox', name='Translated expression', exact=True)
            await expression.wait_for(timeout=60000)
            assert await expression.input_value() == '2+2'
            await question.fill('five plus seven')
            await page.get_by_role('button', name='Translate', exact=True).click()
            await expression.wait_for(timeout=60000)
            assert await expression.input_value() == '5+7'
            await page.screenshot(path=str(Path(args.screenshots) / 'math-assistance.png'))
            await page.get_by_role('button', name='Use in calculator', exact=True).click()
            await page.keyboard.press('Enter')
            await page.wait_for_function("[...document.querySelectorAll('[aria-label]')].some(e=>/\\b12\\b/.test(e.getAttribute('aria-label'))) || /\\b12\\b/.test(document.body.innerText)", timeout=60000)
            with urllib.request.urlopen(args.ai_fixture_url + '/requests') as response:
                provider_requests = json.load(response)
            assert any(r['messages'][-1]['content'] == 'two plus two' for r in provider_requests)
            assert any(r['messages'][-1]['content'] == 'five plus seven' for r in provider_requests)
            print('AI provider HTTP contract fixture and calculator result verified; model quality was not tested', flush=True)
        assert not errors, errors
        print(json.dumps({'stage': args.stage, 'csvRows': 11, 'keyboardTrace': True, 'pageErrors': errors}, indent=2))
        await browser.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--stage', type=int, default=1)
    parser.add_argument('--chromium')
    parser.add_argument('--ai-fixture-url', default='http://127.0.0.1:8769')
    parser.add_argument('--screenshots', default='/tmp/crispmath-feature-screenshots')
    asyncio.run(check(parser.parse_args()))
