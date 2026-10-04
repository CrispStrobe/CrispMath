"""Prove fresh cloud-off profiles retain local worksheet/history/backup workflows."""
import argparse
import asyncio
import json
from pathlib import Path
import re
from urllib.parse import urlencode, urlparse

from playwright.async_api import async_playwright, expect
from benchmark_workflows import next_frames
from check_cloud_sync_browser import (
    current_document, dismiss_sync, menu, notepad, open_sync, semantics,
    titled_dialog, worksheet_result,
)
from check_round6_statistics_browser import real_click

OFF_COPY = ('Cloud sync is off. Your work stays on this device. Local worksheets, '
            'checkpoints and backup files work without an account. Configure your own '
            'project only if you want cloud backups.')


async def close_dialog(page, dialog):
    await expect(dialog).to_have_count(1)
    await real_click(page, dialog.get_by_role('button', name='Close', exact=True))
    await dialog.wait_for(state='hidden')
    await next_frames(page)


async def off_dialog(page):
    await open_sync(page)
    dialog = titled_dialog(page, 'Cloud Sync')
    await expect(dialog).to_have_count(1)
    await expect(dialog.get_by_text(OFF_COPY, exact=True)).to_be_visible()
    for label in ['Log In', 'Sign Up', 'Push', 'Pull', 'Sign Out']:
        await expect(dialog.get_by_role('button', name=label, exact=True)).to_have_count(0)
    await expect(dialog.get_by_role('button', name='Workspace backups', exact=True)).to_be_visible()
    return dialog


async def check(args):
    assert args.expected_source and re.fullmatch(r'[0-9a-f]{40}', args.expected_source)
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'source': args.expected_source, 'passed': False, 'stateInjected': False,
              'cloudConfigured': False, 'checks': []}
    stage = 'startup'
    try:
        async with async_playwright() as pw:
            browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
            try:
                for profile, width, height in [('desktop', 1280, 900), ('phone', 390, 844), ('tablet', 1032, 1376)]:
                    context = await browser.new_context(viewport={'width': width, 'height': height},
                        has_touch=profile != 'desktop', locale='en-US')
                    requests, errors = [], []
                    def observe_url(url):
                        target = urlparse(url)
                        if (target.hostname == 'fixture.invalid' or 'supabase' in (target.hostname or '').lower()
                                or re.match(r'^/(auth|rest|storage|functions)/v1(?:/|$)', target.path)
                                or target.path.startswith('/realtime/v1')):
                            requests.append(target.path)
                    context.on('request', lambda request: observe_url(request.url))
                    page = await context.new_page()
                    page.set_default_timeout(120000)
                    page.on('pageerror', lambda error: errors.append(type(error).__name__))
                    page.on('websocket', lambda socket: observe_url(socket.url))
                    try:
                        stage = profile + ': fresh local worksheet'
                        metadata = await context.request.get(args.url.rstrip('/') + '/build-info.json')
                        assert metadata.ok and (await metadata.json())['source'] == args.expected_source
                        name = 'Cloud off ' + profile
                        await page.goto(args.url.rstrip('/') + '/?' + urlencode(
                            {'action': 'worksheet', 'name': name, 'lines': 'a=3\nf(t)=t^2+a\nf(4)'}), wait_until='domcontentloaded')
                        await semantics(page)
                        await real_click(page, page.get_by_role('button', name='Skip', exact=True))
                        await page.get_by_role('button', name='Skip', exact=True).wait_for(state='hidden')
                        await notepad(page)
                        await worksheet_result(page, name, 'a=3', '19')
                        original = await current_document(page)

                        stage = profile + ': local checkpoint and restore'
                        await menu(page, 'Document history')
                        history = titled_dialog(page, 'Document history')
                        await real_click(page, history.get_by_role('button', name='Save checkpoint', exact=True))
                        await history.get_by_role('button', name='Compare', exact=True).wait_for()
                        await close_dialog(page, history)
                        field = page.get_by_role('textbox').first
                        await real_click(page, field)
                        await next_frames(page)
                        await field.fill('a=5')
                        await worksheet_result(page, name, 'a=5', '21')
                        await menu(page, 'Document history')
                        await real_click(page, history.get_by_role('button', name='Compare', exact=True))
                        compare = titled_dialog(page, 'Compare checkpoint')
                        await real_click(page, compare.get_by_role('button', name='Restore checkpoint', exact=True))
                        await compare.wait_for(state='hidden')
                        await history.wait_for(state='hidden')
                        await worksheet_result(page, name, 'a=3', '19')

                        stage = profile + ': cloud off and rejected configuration'
                        dialog = await off_dialog(page)
                        # Check the actual settings subtitle before opening this
                        # modal on the second visit below; no configuration keys
                        # or auth sessions are inserted into browser storage.
                        fields = dialog.get_by_role('textbox')
                        await expect(fields).to_have_count(2)
                        for url in ['http://fixture.invalid', 'https://fixture.invalid']:
                            for field, value in [(fields.nth(0), url), (fields.nth(1), 'sb_secret_rejected_fixture')]:
                                await real_click(page, field)
                                await next_frames(page)
                                await field.fill(value)
                            await real_click(page, dialog.get_by_role('button', name='Configure cloud sync', exact=True))
                            await expect(dialog.locator('span').filter(has_text=re.compile(
                                '^Enter an HTTPS project URL and a public publishable or anon key\\.$'))).to_be_visible()
                            await expect(dialog.get_by_role('button', name='Log In', exact=True)).to_have_count(0)

                        stage = profile + ': portable local backup'
                        await real_click(page, dialog.get_by_role('button', name='Workspace backups', exact=True))
                        backups = titled_dialog(page, 'Workspace backups')
                        async with page.expect_download() as observed:
                            await real_click(page, backups.get_by_role('button', name='Save backup', exact=True))
                        download = await observed.value
                        target = output / (profile + '-backup.json')
                        await download.save_as(target)
                        payload = json.loads(target.read_text())
                        assert payload['format'] == 'crispmath.backup'
                        worksheet = next(doc for doc in payload['state']['notepadDocuments'] if doc['i'] == original['i'])
                        assert [row['s'] for row in worksheet['l']] == ['a=3', 'f(t)=t^2+a', 'f(4)']
                        assert all('r' not in row for row in worksheet['l']) and len(payload['checkpoints']) >= 2
                        await close_dialog(page, backups)
                        await dialog.get_by_role('button', name='Workspace backups', exact=True).wait_for()
                        await dismiss_sync(page)
                        await expect(page.get_by_text('Off · local work needs no account', exact=True)).to_be_visible()

                        stage = profile + ': fresh reload remains off'
                        await page.reload(wait_until='domcontentloaded')
                        await semantics(page)
                        await notepad(page)
                        await worksheet_result(page, name, 'a=3', '19')
                        restored = await current_document(page)
                        assert restored['i'] == original['i']
                        await off_dialog(page)
                        await dismiss_sync(page)
                        await page.wait_for_timeout(500)
                        assert await page.evaluate("() => localStorage.getItem('flutter.crisp.syncProjectUrl') === null && localStorage.getItem('flutter.crisp.syncPublicKey') === null"), 'Rejected configuration was persisted'
                        assert not requests, 'Cloud-off flow emitted backend requests'
                        assert not errors, 'Cloud-off flow emitted uncaught page errors'
                        report['checks'].append({'profile': profile, 'hasTouch': profile != 'desktop', 'backendRequests': 0,
                            'freshStartupAndReloadOff': True, 'invalidConfigurationRejected': True,
                            'worksheetRecalculated': True, 'checkpointRestored': True,
                            'backupDownloadedAndSourceVerified': True, 'localWorkspacePreserved': True,
                            'pageErrors': 0})
                    finally:
                        await context.close()
            finally:
                await browser.close()
        report['passed'] = True
    except Exception as error:
        report['failedStage'] = stage
        report['errorType'] = type(error).__name__
        raise
    finally:
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--expected-source', required=True)
    parser.add_argument('--output', default='browser-results/cloud-disabled')
    asyncio.run(check(parser.parse_args()))
