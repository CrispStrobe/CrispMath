"""Ensure CrispMath's Mac App Store profile and macOS version exist.

Reuses an active MAC_APP_STORE profile bound to the Apple Distribution
certificate whose SHA-1 matches --cert-sha1, or creates one, and writes it to
--profile-out. Creates the macOS App Store version when none is editable.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlencode

from testflight_internal import AppleApi

BUNDLE = 'com.crispstrobe.crispmath'
PROFILE_NAME = 'CrispMath MacAppStore CI'
EDITABLE = {'PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED',
            'METADATA_REJECTED', 'INVALID_BINARY'}


def certificate_id(api, sha1):
    certs = api.request('/v1/certificates?' + urlencode(
        {'filter[certificateType]': 'DISTRIBUTION', 'limit': '50'}))['data']
    for c in certs:
        der = base64.b64decode(c['attributes']['certificateContent'])
        if hashlib.sha1(der).hexdigest().upper() == sha1.upper():
            return c['id']
    raise ValueError('No Apple Distribution certificate matches the signing identity')


def ensure_profile(api, bundle_id, cert):
    for p in api.request(f'/v1/bundleIds/{bundle_id}/profiles?limit=50')['data']:
        a = p['attributes']
        if a['name'] == PROFILE_NAME and a['profileType'] == 'MAC_APP_STORE' and a['profileState'] == 'ACTIVE':
            certs = api.request(f'/v1/profiles/{p["id"]}/certificates')['data']
            if any(c['id'] == cert for c in certs):
                return p['id'], a['profileContent'], False
    created = api.request('/v1/profiles', {'data': {'type': 'profiles',
        'attributes': {'name': PROFILE_NAME, 'profileType': 'MAC_APP_STORE'},
        'relationships': {'bundleId': {'data': {'type': 'bundleIds', 'id': bundle_id}},
                          'certificates': {'data': [{'type': 'certificates', 'id': cert}]}}}})['data']
    return created['id'], created['attributes']['profileContent'], True


def ensure_version(api, app, version):
    versions = api.request(f'/v1/apps/{app}/appStoreVersions?' + urlencode(
        {'filter[platform]': 'MAC_OS', 'limit': '50'}))['data']
    for v in versions:
        state = v['attributes'].get('appVersionState') or v['attributes'].get('appStoreState')
        if state in EDITABLE:
            return {'id': v['id'], 'version': v['attributes']['versionString'], 'created': False}
    created = api.request('/v1/appStoreVersions', {'data': {'type': 'appStoreVersions',
        'attributes': {'platform': 'MAC_OS', 'versionString': version},
        'relationships': {'app': {'data': {'type': 'apps', 'id': app}}}}})['data']
    return {'id': created['id'], 'version': version, 'created': True}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key-file', type=Path, required=True)
    parser.add_argument('--cert-sha1', required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--profile-out', type=Path, required=True)
    args = parser.parse_args()
    api = AppleApi(args.key_file)
    app = os.environ['ASC_APP_ID']
    try:
        bundles = [b for b in api.request('/v1/bundleIds?' + urlencode({'filter[identifier]': BUNDLE}))['data']
                   if b['attributes']['identifier'] == BUNDLE]
        if len(bundles) != 1 or bundles[0]['attributes']['platform'] not in {'UNIVERSAL', 'MAC_OS'}:
            raise ValueError('Bundle ID is not registered for macOS')
        cert = certificate_id(api, args.cert_sha1)
        profile_id, content, made = ensure_profile(api, bundles[0]['id'], cert)
        args.profile_out.write_bytes(base64.b64decode(content))
        version = ensure_version(api, app, args.version)
    except HTTPError as error:
        print(error.read().decode(errors='replace'))
        raise
    print(json.dumps({'profile': profile_id, 'profileCreated': made, 'certificate': cert,
                      'macosVersion': version}, indent=2))
