"""Live regressions for localized worked examples and duplicate search results."""
import argparse
import asyncio
import json
import re
from pathlib import Path
from playwright.async_api import async_playwright, expect
from check_feature_browser import labels, type_text

LOCALES = {
    'de': ('Beispielaufgaben', 'Beispiele suchen…', 'Bestimmtes Integral von sin(x)',
           'Fläche unter sin(x) von 0 bis π.', 'Ausdruck kopieren'),
    'fr': ('Exemples résolus', 'Rechercher des exemples…', 'Intégrale définie de sin(x)',
           'Aire sous sin(x) de 0 à π.', "Copier l'expression"),
    'es': ('Ejemplos resueltos', 'Buscar ejemplos…', 'Integral definida de sin(x)',
           'Área bajo sin(x) de 0 a π.', 'Copiar expresión'),
}

async def wait_for_catalog_content(page, expected, failure_prefix):
    # Textbox values and result counts can update before Flutter's next semantics
    # frame. A one-result-to-one-result search needs actual new content readiness.
    try:
        await page.wait_for_function(
            """expected => {
              const labels = document.body.innerText + '\\n' +
                Array.from(document.querySelectorAll('[aria-label]'))
                  .map(el => el.getAttribute('aria-label')).join('\\n');
              return expected.every(value => labels.includes(value));
            }""", arg=expected)
    except Exception:
        failure_prefix.parent.mkdir(parents=True, exist_ok=True)
        failure_prefix.with_suffix('.json').write_text(json.dumps({
            'expected': expected, 'actualLabels': await labels(page)
        }, ensure_ascii=False, indent=2))
        await page.screenshot(path=str(failure_prefix.with_suffix('.png')))
        raise


async def check(args):
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox', '--enable-unsafe-swiftshader']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        try:
            for locale, (catalog, hint, title, description, copy) in LOCALES.items():
                context = await browser.new_context(viewport={'width': 1200, 'height': 900})
                page = await context.new_page()
                page.set_default_timeout(60000)
                errors = []
                page.on('pageerror', lambda e: errors.append(str(e)))
                def console(message):
                    if message.type == 'error' and any(s in message.text for s in ['EXCEPTION CAUGHT', 'setState()', 'RenderFlex', 'Unhandled']):
                        errors.append(message.text)
                page.on('console', console)
                await page.add_init_script("localStorage.setItem('flutter.crisp.onboardingDismissed', 'true'); localStorage.setItem('flutter.crisp.locale', " + json.dumps(json.dumps(locale)) + ");")
                await page.goto(args.url, wait_until='domcontentloaded')
                await page.locator('canvas').first.wait_for(timeout=300000)
                await page.locator('flt-semantics-placeholder').evaluate('(el)=>el.click()')
                await page.get_by_role('button', name=re.compile('^' + re.escape(catalog))).click()
                search = page.get_by_role('textbox', name=hint, exact=True)
                await type_text(page, search, title)
                buttons = page.get_by_role('button', name=re.compile('^' + re.escape(copy)))
                await expect(buttons).to_have_count(1)
                await wait_for_catalog_content(
                    page, [title, description],
                    Path(args.screenshots) / f'catalog-{locale}-title-failure')
                visible = await labels(page)
                assert title in visible and description in visible, visible
                await type_text(page, search, 'alg8')
                await expect(buttons).to_have_count(1)
                await expect(search).to_have_value('alg8')
                await wait_for_catalog_content(
                    page, ['solve(a*x^2 + b*x + c = 0, x)'],
                    Path(args.screenshots) / f'catalog-{locale}-id-failure')
                await expect(buttons).to_have_count(1)
                # Both translated prose and stable IDs find a single catalog entry.
                assert 'solve(a*x^2 + b*x + c = 0, x)' in await labels(page)
                assert not errors, errors
                Path(args.screenshots).mkdir(parents=True, exist_ok=True)
                await page.screenshot(path=str(Path(args.screenshots) / f'catalog-{locale}.png'))
                print({'locale': locale, 'translatedTitle': title, 'translatedDescription': description,
                       'uniqueTitleSearch': True, 'uniqueIdSearch': True, 'pageErrors': errors}, flush=True)
                await context.close()
        finally:
            await browser.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--chromium')
    parser.add_argument('--screenshots', default='/tmp/crispmath-feature-screenshots')
    asyncio.run(check(parser.parse_args()))
