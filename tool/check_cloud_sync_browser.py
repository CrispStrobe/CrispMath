"""Check actual app Cloud Sync between two browsers on a disposable backend.

Admin credentials create/delete only one throwaway account. All sign-in,
upload, pull, review/import, edit, reload and sign-out actions use the GUI.
No workspace, session or application state is injected into either browser.
"""
import argparse
import asyncio
import json
import os
from pathlib import Path
import re
import secrets
import urllib.error
import urllib.request
from urllib.parse import urlencode, urlparse, urljoin

from playwright.async_api import async_playwright, expect
from benchmark_workflows import next_frames
from check_round6_statistics_browser import real_click


def fixture_configuration(environment):
    api = environment.get('CRISPMATH_SYNC_API_URL', '')
    parsed = urlparse(api)
    if (environment.get('CRISPMATH_SYNC_LIVE') != 'disposable'
            or parsed.scheme != 'http'
            or parsed.hostname not in {'localhost', '127.0.0.1'}
            or parsed.username or parsed.password or parsed.query or parsed.fragment
            or parsed.path not in {'', '/'}):
        raise ValueError('Only the disposable loopback CI backend is permitted')
    keys = [environment.get(name, '') for name in
            ('CRISPMATH_SYNC_PUBLIC_KEY', 'CRISPMATH_SYNC_FIXTURE_ADMIN_KEY')]
    if any(not key or '\n' in key or '\r' in key for key in keys):
        raise ValueError('Disposable public/admin fixture fields are required')
    return api.rstrip('/'), keys[1]


def fixture_request(api, admin_key, method, path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    request = urllib.request.Request(api + '/auth/v1/admin/users' + path,
        data=data, method=method, headers={'apikey': admin_key,
        'Authorization': 'Bearer ' + admin_key, 'Content-Type': 'application/json'})
    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, *args, **kwargs):
            return None

    opener = urllib.request.build_opener(NoRedirect)
    with opener.open(request, timeout=30) as response:
        body = response.read()
        return json.loads(body) if body else None


async def documents(page):
    # Read-only persistence evidence, separate from actual visible result checks.
    return await page.evaluate("""() => {
      const raw=localStorage.getItem('flutter.crisp.notepadIndex');
      if (!raw) return [];
      return JSON.parse(JSON.parse(raw)).map(id=>{
        const value=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
        return value ? JSON.parse(JSON.parse(value)) : null;
      }).filter(Boolean);
    }""")


async def current_document(page):
    return await page.evaluate("""() => {
      const rawId=localStorage.getItem('flutter.crisp.currentNotepadDoc');
      if (!rawId) return null;
      const id=JSON.parse(rawId);
      const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(id));
      return raw ? JSON.parse(JSON.parse(raw)) : null;
    }""")


async def semantics(page):
    await page.locator('canvas').first.wait_for(timeout=300000)
    placeholder = page.locator('flt-semantics-placeholder')
    if await placeholder.count():
        # Enable Flutter's accessibility surface, not application state.
        await placeholder.evaluate('(el)=>el.click()')


async def menu(page, label):
    await real_click(page, page.get_by_role('button', name='Document menu', exact=True))
    await real_click(page, page.get_by_label(label, exact=True))
    await page.get_by_label('Popup menu', exact=True).wait_for(state='hidden')
    await next_frames(page)


async def notepad(page):
    await real_click(page, page.get_by_role('button', name=re.compile('^Notepad')))
    await page.get_by_role('button', name='Document menu', exact=True).wait_for()


async def worksheet_result(page, name, first, expected):
    await page.wait_for_function("""expected=>{
      const rawId=localStorage.getItem('flutter.crisp.currentNotepadDoc');
      if(!rawId)return false;
      const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+encodeURIComponent(JSON.parse(rawId)));
      if(!raw)return false;
      const doc=JSON.parse(JSON.parse(raw));
      return doc.n===expected.name && doc.l.length===3 &&
        doc.l[0].s===expected.first && doc.l[1].s==='f(t)=t^2+a' &&
        doc.l[2].s==='f(4)' && doc.l[2].r===expected.result;
    }""", arg={'name': name, 'first': first, 'result': expected})
    fields = page.get_by_role('textbox')
    # Imported source can be persisted before the popup route's accessibility
    # surface has closed and exposed the three worksheet editors.
    await expect(fields).to_have_count(3)
    for index, source in enumerate([first, 'f(t)=t^2+a', 'f(4)']):
        field = fields.nth(index)
        # Flutter fills its native editing element when the real controller
        # gains focus; unfocused semantic textareas intentionally have no value.
        await real_click(page, field)
        await next_frames(page)
        await expect(field).to_have_value(source)
    # Math.tex digits are separate semantic children merged with the row's
    # drag control, e.g. 'Drag to reorder\n1\n9'. Anchor the entire rendered
    # numeric sequence so adjacent or extra digits cannot pass.
    digits = r'\s*'.join(re.escape(char) for char in expected)
    result = page.get_by_label(re.compile(r'^Drag to reorder\s+' + digits + r'$'))
    await expect(result).to_have_count(1)
    await expect(result).to_be_visible()
    box = await result.bounding_box()
    viewport = page.viewport_size
    assert box and box['width'] > 0 and box['height'] > 0
    assert 0 <= box['x'] and box['x'] + box['width'] <= viewport['width']
    assert 0 <= box['y'] and box['y'] + box['height'] <= viewport['height']
    return await current_document(page)


async def edit(page, source):
    field = page.get_by_role('textbox').first
    await real_click(page, field)
    await next_frames(page)
    await field.fill(source)
    await expect(field).to_have_value(source)
    await next_frames(page)
    await expect(field).to_have_value(source)


async def open_sync(page):
    await real_click(page, page.get_by_role('button', name=re.compile('^Settings')))
    target = page.get_by_role('button', name=re.compile('Cloud Sync'))
    width, height = page.viewport_size['width'], page.viewport_size['height']
    for _ in range(16):
        assert await target.count() <= 1, 'Cloud Sync settings action is ambiguous'
        box = await target.bounding_box() if await target.count() else None
        if (box and box['width'] > 0 and box['height'] > 0
                and box['x'] >= 0 and box['x'] + box['width'] <= width
                and box['y'] > 88 and box['y'] + box['height'] < height - 60):
            await real_click(page, target)
            return
        await page.mouse.move(width * .6, height * .5)
        await page.mouse.wheel(0, -220 if box and box['y'] < 88 else 500)
        await next_frames(page)
    raise AssertionError('Cloud Sync action was not reachable by real scrolling')


def titled_dialog(page, title):
    return page.get_by_role('alertdialog').filter(
        has=page.locator('span').filter(has_text=re.compile('^' + re.escape(title) + '$')))


async def dismiss_sync(page):
    dialog = titled_dialog(page, 'Cloud Sync')
    await expect(dialog).to_have_count(1)
    close = dialog.get_by_role('button', name='Close', exact=True)
    await expect(close).to_have_count(1)
    await real_click(page, close)
    await dialog.wait_for(state='hidden')
    await page.get_by_role('button', name='Pull', exact=True).wait_for(state='hidden')
    await next_frames(page)
    await page.wait_for_timeout(500)


def inline_feedback(page, message):
    # Flutter also mirrors live-region text into an announcement transport.
    # Prove the actual active dialog content, without selecting that mirror.
    return page.get_by_role('alertdialog').locator('span').filter(
        has_text=re.compile('^' + re.escape(message) + '$'))


async def expect_inline_feedback(page, message):
    dialog = page.get_by_role('alertdialog')
    await expect(dialog).to_have_count(1)
    feedback = inline_feedback(page, message)
    await expect(feedback).to_have_count(1)
    await expect(feedback).to_be_visible()
    box = await feedback.bounding_box()
    viewport = page.viewport_size
    assert box and viewport and box['width'] > 0 and box['height'] > 0, 'Inline feedback has no visible geometry'
    assert (box['x'] >= 0 and box['y'] >= 0
            and box['x'] + box['width'] <= viewport['width']
            and box['y'] + box['height'] <= viewport['height']), 'Inline feedback is clipped outside the viewport'


async def login(page, email, password):
    await open_sync(page)
    async def fill(label, value):
        field = page.get_by_role('textbox', name=label, exact=True)
        await real_click(page, field)
        await next_frames(page)
        await field.fill(value)
        assert await field.input_value() == value, 'Auth field did not retain input'
    await fill('Email', email)
    await fill('Password', password + '-wrong')
    await real_click(page, page.get_by_role('button', name='Log In', exact=True))
    failure = inline_feedback(page, 'Sign in failed. Check your email and password, then try again.')
    await expect_inline_feedback(page, 'Sign in failed. Check your email and password, then try again.')
    await expect(page.get_by_role('button', name='Pull', exact=True)).to_have_count(0)
    await fill('Password', password)
    await real_click(page, page.get_by_role('button', name='Log In', exact=True))
    await page.get_by_role('button', name='Pull', exact=True).wait_for()
    await expect(failure).to_have_count(0)
    await expect_inline_feedback(page, 'Signed in. You can now pull or upload a cloud backup.')
    await expect(page.get_by_text('Logged in as ' + email, exact=True)).to_be_visible()
    await real_click(page, page.get_by_role('button', name='Pull', exact=True))
    await expect_inline_feedback(page, 'No cloud backup is available.')


async def push(page, first, revision):
    await real_click(page, page.get_by_role('button', name='Push', exact=True))
    api = urlparse(os.environ['CRISPMATH_SYNC_API_URL'])
    method = 'POST' if revision == 0 else 'PATCH'

    def actual_upload(response):
        target = urlparse(response.url)
        return (target.scheme == api.scheme and target.netloc == api.netloc
                and target.path == '/rest/v1/user_sync_data'
                and response.request.method == method)

    # Require the real GUI-triggered SDK write, inline accessible success and
    # persistence through the other browser's Pull/import.
    async with page.expect_response(actual_upload) as observed:
        await real_click(page, page.get_by_role('button', name='Upload backup', exact=True))
    response = await observed.value
    assert response.status == (201 if revision == 0 else 200), 'Cloud write did not succeed'
    data = response.request.post_data_json
    assert isinstance(data, dict) and data['revision'] == revision, 'Incorrect cloud write revision'
    state = json.loads(data['app_state'])
    doc = next(d for d in state['notepadDocuments'] if d['n'] == 'Cloud source')
    assert [row['s'] for row in doc['l']] == [first, 'f(t)=t^2+a', 'f(4)'], 'Wrong uploaded worksheet source'
    assert all('r' not in row for row in doc['l']), 'Cloud upload trusted computed cache'
    await expect_inline_feedback(page, 'Cloud backup uploaded.')
    await page.get_by_role('button', name='Pull', exact=True).wait_for()
    await expect(page.get_by_role('button', name='Pull', exact=True)).to_be_enabled()
    return {'responseStatus': response.status, 'revision': revision,
            'source': first, 'sourceVerified': True, 'cachedResultsExcluded': True}


async def pull_import(page, expected_name):
    await real_click(page, page.get_by_role('button', name='Pull', exact=True))
    review = titled_dialog(page, 'Workspace backups')
    await expect(review).to_have_count(1)
    await review.get_by_role('button', name='Import worksheets', exact=True).wait_for()
    await expect(review.get_by_text(expected_name + ': 3 rows', exact=True)).to_be_visible()
    await real_click(page, review.get_by_role('button', name='Import worksheets', exact=True))
    await expect(review.get_by_text('Worksheets imported; conflicting versions kept separately.', exact=True)).to_be_visible()
    await real_click(page, review.get_by_role('button', name='Close', exact=True))
    # Import removes its preview controls before the review route closes.
    # Wait for the actual titled route to leave accessibility, then require
    # the distinct underlying sync controls before closing that route.
    await review.wait_for(state='hidden')
    await page.get_by_role('button', name='Pull', exact=True).wait_for()
    await expect(page.get_by_role('button', name='Close', exact=True)).to_have_count(1)
    await dismiss_sync(page)


async def check(args):
    api, admin_key = fixture_configuration(os.environ)
    app = urlparse(args.url)
    if (app.scheme != 'http' or app.hostname not in {'localhost', '127.0.0.1'}
            or app.username or app.password or app.query or app.fragment):
        raise ValueError('The browser must use the isolated loopback CI application')
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'source': os.environ.get('GITHUB_SHA'), 'passed': False,
              'backend': 'disposable Supabase Auth/PostgREST/PostgreSQL',
              'physicalDeviceTest': False, 'deployedUserProjectTest': False,
              'stateInjected': False, 'checks': [], 'cleanupVerified': False}
    email = 'browser-' + secrets.token_hex(10) + '@example.test'
    password = secrets.token_urlsafe(24)
    user_id = None
    contexts = []
    page_errors = []
    stage = 'create disposable fixture'
    try:
        fixture = await asyncio.to_thread(fixture_request, api, admin_key, 'POST', '',
            {'email': email, 'password': password, 'email_confirm': True})
        user_id = fixture['id']
        async with async_playwright() as pw:
            browser = await pw.chromium.launch(args=['--no-sandbox', '--enable-unsafe-swiftshader'])
            try:
                pages = []
                for profile, width, height, name in [('desktop', 1280, 900, 'Cloud source'),
                                                     ('phone', 390, 844, 'Phone local work')]:
                    stage = 'create ' + profile + ' worksheet through workflow link'
                    context = await browser.new_context(viewport={'width': width, 'height': height}, locale='en-US')
                    contexts.append(context)
                    page = await context.new_page()
                    page.set_default_timeout(120000)
                    pages.append(page)
                    page.on('pageerror', lambda error: page_errors.append(type(error).__name__))
                    metadata = await context.request.get(urljoin(args.url, 'build-info.json'))
                    assert metadata.ok, 'Application source metadata unavailable'
                    app_source = (await metadata.json())['source']
                    assert re.fullmatch(r'[0-9a-f]{40}', app_source), 'Invalid application source'
                    assert args.expected_source and app_source == args.expected_source, 'Application source differs from expected CI revision'
                    if report.get('appSource'):
                        assert report['appSource'] == app_source, 'Profiles loaded different sources'
                    report['appSource'] = app_source
                    url = args.url.rstrip('/') + '/?' + urlencode({'action': 'worksheet',
                        'name': name, 'lines': 'a=3\nf(t)=t^2+a\nf(4)'})
                    await page.goto(url, wait_until='domcontentloaded')
                    await semantics(page)
                    await real_click(page, page.get_by_role('button', name='Skip', exact=True))
                    await page.get_by_role('button', name='Skip', exact=True).wait_for(state='hidden')
                    await notepad(page)
                    await worksheet_result(page, name, 'a=3', '19')
                    stage = 'GUI login ' + profile
                    await login(page, email, password)
                first, second = pages
                stage = 'GUI desktop push'
                upload = await push(first, 'a=3', 0)
                await dismiss_sync(first)
                stage = 'GUI phone pull and review/import'
                await pull_import(second, 'Cloud source')
                docs = await documents(second)
                original = next(d for d in docs if d['n'] == 'Cloud source')
                local = next(d for d in docs if d['n'] == 'Phone local work')
                assert [r['s'] for r in local['l']] == ['a=3', 'f(t)=t^2+a', 'f(4)']
                await notepad(second)
                await menu(second, 'Cloud source')
                await menu(second, 'Recalculate all')
                await worksheet_result(second, 'Cloud source', 'a=3', '19')
                report['checks'].append({'independentProfiles': ['desktop', 'phone'],
                    'guiSignInPushPullReviewImport': True,
                    'inlineWrongPasswordErrorBothProfiles': True,
                    'inlineSignInSuccessBothProfiles': True,
                    'inlineNoBackupBothProfiles': True,
                    'inlineUploadSuccess': True, 'importSourceRecalculated': True,
                    'unrelatedPhoneWorksheetPreserved': True, 'uploadResponse': upload})
                stage = 'conflicting independent edits'
                await edit(second, 'a=5')
                await worksheet_result(second, 'Cloud source', 'a=5', '21')
                await notepad(first)
                await edit(first, 'a=7')
                await worksheet_result(first, 'Cloud source', 'a=7', '23')
                await open_sync(first)
                upload = await push(first, 'a=7', 1)
                await dismiss_sync(first)
                await open_sync(second)
                await pull_import(second, 'Cloud source')
                docs = await documents(second)
                preserved = next(d for d in docs if d['i'] == original['i'])
                imported = next(d for d in docs if d['n'] == 'Cloud source (imported)')
                assert preserved['l'][0]['s'] == 'a=5'
                assert imported['i'] != original['i'] and imported['l'][0]['s'] == 'a=7'
                assert any(d['i'] == local['i'] for d in docs)
                await notepad(second)
                await menu(second, 'Cloud source (imported)')
                await menu(second, 'Recalculate all')
                await worksheet_result(second, 'Cloud source (imported)', 'a=7', '23')
                stage = 'reload persisted imported worksheet and authenticated session'
                # Remove the explicit create-action URL so reload cannot create a fresh document.
                await second.goto(args.url, wait_until='domcontentloaded')
                await semantics(second)
                await notepad(second)
                await worksheet_result(second, 'Cloud source (imported)', 'a=7', '23')
                docs = await documents(second)
                assert next(d for d in docs if d['i'] == original['i'])['l'][0]['s'] == 'a=5'
                report['checks'].append({'sameIdConflictPreserved': True,
                    'localSource': 'a=5', 'localResultBeforeImport': '21',
                    'importedSource': 'a=7', 'importedResult': '23',
                    'reloadPreservesBothVersions': True, 'uploadResponse': upload})
                stage = 'GUI sign-out in both independent profiles'
                for page in pages:
                    await open_sync(page)
                    await page.get_by_role('button', name='Sign Out', exact=True).wait_for()
                    await real_click(page, page.get_by_role('button', name='Sign Out', exact=True))
                    await page.get_by_role('button', name='Log In', exact=True).wait_for()
                    await expect_inline_feedback(page, 'Signed out. Your workspace remains saved on this device.')
                    await expect(page.get_by_role('button', name='Pull', exact=True)).to_have_count(0)
                    await real_click(page, page.get_by_role('button', name='Close', exact=True))
                    await page.get_by_role('button', name='Log In', exact=True).wait_for(state='hidden')
                assert not page_errors, 'Uncaught browser page errors occurred'
                report['checks'].append({'guiSignOutBothProfiles': True, 'inlineSignOutFeedbackBothProfiles': True,
                    'normalCloseBothProfiles': True,
                    'uncaughtPageErrors': 0,
                    'reloadRestoredAuthenticatedSession': True})
            except Exception:
                # Only bounded rendered accessibility labels: no DOM editing
                # values, cookies, network bodies or auth-storage snapshots.
                redactions = [email, password, admin_key,
                    os.environ['CRISPMATH_SYNC_PUBLIC_KEY']]
                views = []
                for page in pages:
                    try:
                        labels = await page.locator('[aria-label]').evaluate_all(
                            "els=>els.slice(0,400).map(el=>(el.getAttribute('aria-label')||''))")
                        clean = []
                        for label in labels:
                            for private in redactions:
                                label = label.replace(private, '[redacted]')
                            label = re.sub(r'eyJ[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+){1,2}',
                                           '[redacted token]', label)
                            clean.append(label[:1000])
                        views.append({'viewport': page.viewport_size, 'labels': clean})
                    except Exception:
                        views.append({'diagnosticUnavailable': True})
                report['failureViews'] = views
                raise
            finally:
                for context in contexts:
                    await context.close()
                await browser.close()
    except Exception as error:
        # Credentials/tokens and login screenshots never enter reports.
        report['failure'] = {'stage': stage, 'errorType': type(error).__name__}
        raise
    finally:
        try:
            if user_id:
                await asyncio.to_thread(fixture_request, api, admin_key, 'DELETE', '/' + user_id)
                try:
                    await asyncio.to_thread(fixture_request, api, admin_key, 'GET', '/' + user_id)
                except urllib.error.HTTPError as error:
                    if error.code != 404:
                        raise
                else:
                    raise AssertionError('Disposable account still exists after deletion')
                report['cleanupVerified'] = True
            report['passed'] = ('failure' not in report and len(report['checks']) == 3
                                and report['cleanupVerified'])
        finally:
            (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--expected-source', default=os.environ.get('GITHUB_SHA'))
    parser.add_argument('--output', default='browser-results/cloud-sync-live')
    asyncio.run(check(parser.parse_args()))
