"""Fill CrispMath's editable macOS App Store version listing.

Copies each locale's description, keywords, URLs and promotional text from
the newest iOS version, then replaces the primary locale's APP_DESKTOP
screenshots with the given native 2560x1600 PNGs (in order). It does not
submit anything for review.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from testflight_internal import AppleApi

COPIED = ('description', 'keywords', 'marketingUrl', 'supportUrl', 'promotionalText')
EDITABLE = {'PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED',
            'METADATA_REJECTED', 'INVALID_BINARY'}
MAX_SCREENSHOTS = 10


def state(v):
    a = v['attributes']
    return a.get('appVersionState') or a.get('appStoreState')


def versions(api, app, platform):
    return api.request(f'/v1/apps/{app}/appStoreVersions?' + urlencode(
        {'filter[platform]': platform, 'limit': '50'}))['data']


def localizations(api, vid):
    return api.request(f'/v1/appStoreVersions/{vid}/appStoreVersionLocalizations?limit=50')['data']


def copy_text(api, ios_vid, mac_vid):
    mac = {l['attributes']['locale']: l for l in localizations(api, mac_vid)}
    done = []
    for loc in localizations(api, ios_vid):
        locale = loc['attributes']['locale']
        attrs = {k: loc['attributes'].get(k) for k in COPIED if loc['attributes'].get(k)}
        if locale in mac:
            api.request(f'/v1/appStoreVersionLocalizations/{mac[locale]["id"]}', {'data': {
                'type': 'appStoreVersionLocalizations', 'id': mac[locale]['id'],
                'attributes': attrs}}, method='PATCH')
        else:
            api.request('/v1/appStoreVersionLocalizations', {'data': {
                'type': 'appStoreVersionLocalizations',
                'attributes': dict(attrs, locale=locale),
                'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': mac_vid}}}}})
        done.append(locale)
    return done


def upload_screenshot(api, set_id, path):
    data = path.read_bytes()
    shot = api.request('/v1/appScreenshots', {'data': {'type': 'appScreenshots',
        'attributes': {'fileName': path.name, 'fileSize': len(data)},
        'relationships': {'appScreenshotSet': {'data': {'type': 'appScreenshotSets', 'id': set_id}}}}})['data']
    for op in shot['attributes']['uploadOperations']:
        chunk = data[op['offset']:op['offset'] + op['length']]
        headers = {h['name']: h['value'] for h in op['requestHeaders']}
        with urlopen(Request(op['url'], data=chunk, method=op['method'], headers=headers), timeout=120):
            pass
    api.request(f'/v1/appScreenshots/{shot["id"]}', {'data': {'type': 'appScreenshots', 'id': shot['id'],
        'attributes': {'uploaded': True, 'sourceFileChecksum': hashlib.md5(data).hexdigest()}}},
        method='PATCH')
    return shot['id']


def replace_screenshots(api, localization_id, paths):
    sets = api.request(f'/v1/appStoreVersionLocalizations/{localization_id}/appScreenshotSets')['data']
    desktop = next((s for s in sets if s['attributes']['screenshotDisplayType'] == 'APP_DESKTOP'), None)
    if desktop:
        for shot in api.request(f'/v1/appScreenshotSets/{desktop["id"]}/appScreenshots?limit=50')['data']:
            api.request(f'/v1/appScreenshots/{shot["id"]}', method='DELETE')
        set_id = desktop['id']
    else:
        set_id = api.request('/v1/appScreenshotSets', {'data': {'type': 'appScreenshotSets',
            'attributes': {'screenshotDisplayType': 'APP_DESKTOP'},
            'relationships': {'appStoreVersionLocalization': {'data': {
                'type': 'appStoreVersionLocalizations', 'id': localization_id}}}}})['data']['id']
    return [upload_screenshot(api, set_id, p) for p in paths]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key-file', type=Path, required=True)
    parser.add_argument('--screenshots', type=Path, nargs='+', required=True)
    parser.add_argument('--locale', default='en-US')
    args = parser.parse_args()
    if len(args.screenshots) > MAX_SCREENSHOTS:
        raise SystemExit(f'At most {MAX_SCREENSHOTS} Mac screenshots are accepted')
    for path in args.screenshots:
        if not path.is_file():
            raise SystemExit(f'Missing screenshot {path}')
    api = AppleApi(args.key_file)
    app = os.environ['ASC_APP_ID']
    try:
        mac = [v for v in versions(api, app, 'MAC_OS') if state(v) in EDITABLE]
        if len(mac) != 1:
            raise SystemExit('Expected exactly one editable macOS version')
        ios = versions(api, app, 'IOS')
        ios.sort(key=lambda v: v['attributes'].get('createdDate') or '', reverse=True)
        locales = copy_text(api, ios[0]['id'], mac[0]['id'])
        primary = next(l for l in localizations(api, mac[0]['id'])
                       if l['attributes']['locale'] == args.locale)
        shots = replace_screenshots(api, primary['id'], args.screenshots)
    except HTTPError as error:
        print(error.read().decode(errors='replace'))
        raise
    print(json.dumps({'macosVersion': mac[0]['attributes']['versionString'],
                      'textCopiedFrom': ios[0]['attributes']['versionString'],
                      'locales': locales, 'screenshots': len(shots)}, indent=2))
