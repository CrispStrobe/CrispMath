"""Live candidate checks for clean install, legacy upgrade, edit and restoration."""
import argparse
import asyncio
import json
from pathlib import Path
import re
from urllib.parse import quote
from playwright.async_api import async_playwright, expect
from check_feature_browser import labels, type_text

DOCUMENT = {'i': 'release-doc', 'n': 'Release restoration',
            'c': '2026-10-01T00:00:00Z', 'u': '2026-10-01T00:00:00Z',
            'l': [{'i': 'amount', 's': 'a = 5', 'r': '5'},
                  {'i': 'result', 's': 'a + 7', 'r': '12'}]}


async def check(args):
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        try:
            for scenario in ['clean', 'legacy', 'damaged-index']:
                context = await browser.new_context(viewport={'width': 1200, 'height': 900})
                page = await context.new_page()
                page.set_default_timeout(60000)
                errors = []
                page.on('pageerror', lambda error: errors.append(str(error)))
                preferences = {'crisp.onboardingDismissed': True, 'crisp.locale': 'en'}
                if scenario != 'clean':
                    preferences['crisp.currentNotepadDoc'] = DOCUMENT['i']
                    if scenario == 'legacy':
                        preferences['crisp.notepadDocs'] = json.dumps([DOCUMENT])
                    else:
                        preferences['crisp.notepadIndex'] = 'damaged index'
                        preferences['crisp.notepadDoc.' + quote(DOCUMENT['i'], safe='')] = json.dumps(DOCUMENT)
                await page.add_init_script('''if (!localStorage.getItem('releaseSeeded')) {
                    for (const [key,value] of Object.entries(''' + json.dumps(preferences) + '''))
                      localStorage.setItem('flutter.'+key, JSON.stringify(value));
                    localStorage.setItem('releaseSeeded','true');
                }''')

                async def open_notepad():
                    await page.locator('canvas').first.wait_for(timeout=300000)
                    await page.locator('flt-semantics-placeholder').evaluate('(element)=>element.click()')
                    await page.get_by_role('button', name=re.compile('^Notepad')).click()
                    await page.get_by_role('button', name='Link line to graph', exact=True).first.wait_for()

                await page.goto(args.url, wait_until='domcontentloaded')
                await open_notepad()
                field = page.get_by_role('textbox').first
                expected = '5 + 7' if scenario == 'clean' else 'a = 6'
                await type_text(page, field, expected)
                # Observe a durable save, rather than sleeping and hoping it flushed.
                await page.wait_for_function('''expected => Object.entries(localStorage)
                    .filter(([key])=>key.startsWith('flutter.crisp.notepadDoc.'))
                    .some(([,raw])=>{try{return JSON.parse(JSON.parse(raw)).l.some(line=>line.s===expected)}catch{return false}})''', arg=expected)
                if scenario == 'legacy':
                    assert await page.evaluate("localStorage.getItem('flutter.crisp.notepadDocs')") is None
                await page.reload(wait_until='domcontentloaded')
                await open_notepad()
                field = page.get_by_role('textbox').first
                await field.click()
                await expect(field).to_have_value(expected)
                if scenario != 'clean':
                    assert DOCUMENT['n'] in await labels(page)
                assert not errors, errors
                Path(args.results).mkdir(parents=True, exist_ok=True)
                await page.screenshot(path=str(Path(args.results) / f'release-{scenario}.png'))
                print(json.dumps({'scenario': scenario, 'editRestored': True, 'pageErrors': errors}), flush=True)
                await context.close()
        finally:
            await browser.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--results', default='browser-results/release')
    asyncio.run(check(parser.parse_args()))
