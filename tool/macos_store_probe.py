"""Read-only inspection of CrispMath's Mac App Store prerequisites.

Reports the bundle ID platform and capabilities, distribution/installer
certificates, Mac App Store profiles and macOS App Store versions. It makes no
changes to App Store Connect.
"""
import argparse
import json
import os
from pathlib import Path
from urllib.parse import urlencode

from testflight_internal import AppleApi

BUNDLE = 'com.crispstrobe.crispmath'


def probe(api, app):
    bundles = api.request('/v1/bundleIds?' + urlencode({'filter[identifier]': BUNDLE}))['data']
    bundles = [b for b in bundles if b['attributes']['identifier'] == BUNDLE]
    certs = api.request('/v1/certificates?' + urlencode(
        {'filter[certificateType]': 'DISTRIBUTION,MAC_INSTALLER_DISTRIBUTION,MAC_APP_DISTRIBUTION',
         'limit': '50'}))['data']
    profiles = []
    for b in bundles:
        for p in api.request(f'/v1/bundleIds/{b["id"]}/profiles?limit=50')['data']:
            a = p['attributes']
            profiles.append({'id': p['id'], 'name': a['name'], 'type': a['profileType'],
                             'state': a['profileState'], 'expires': a['expirationDate']})
    versions = api.request(f'/v1/apps/{app}/appStoreVersions?limit=50')['data']
    return {
        'bundleIds': [{'id': b['id'], 'platform': b['attributes']['platform']} for b in bundles],
        'certificates': [{'id': c['id'], 'type': c['attributes']['certificateType'],
                          'name': c['attributes']['name'],
                          'serial': c['attributes']['serialNumber'],
                          'expires': c['attributes']['expirationDate']} for c in certs],
        'profiles': profiles,
        'versions': [{'platform': v['attributes']['platform'],
                      'version': v['attributes']['versionString'],
                      'state': v['attributes'].get('appVersionState') or v['attributes'].get('appStoreState')}
                     for v in versions],
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key-file', type=Path, required=True)
    parser.add_argument('--output', type=Path, default=Path('macos-store-probe.json'))
    args = parser.parse_args()
    result = probe(AppleApi(args.key_file), os.environ['ASC_APP_ID'])
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
