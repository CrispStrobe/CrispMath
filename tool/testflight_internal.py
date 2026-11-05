"""Verify an uploaded iOS build and assign only the existing internal group.

Uses Apple's builds and betaGroups API; never submits an App Review request.
Credentials are supplied by CI environment and a private key file.
"""
import argparse
import base64
import json
import os
from pathlib import Path
import time
from urllib.parse import urlencode
from urllib.request import Request, urlopen


def matching_build(build, prerelease, number, version):
    return (build['attributes']['version'] == number
            and prerelease['attributes']['version'] == version
            and prerelease['attributes']['platform'] == 'IOS')


def internal_group(groups):
    matches = [group for group in groups
               if group['attributes'].get('isInternalGroup') is True
               and group['attributes'].get('name') == 'Internal Testers']
    if len(matches) != 1:
        raise ValueError('Expected exactly one existing Internal Testers group')
    return matches[0]


class AppleApi:
    def __init__(self, key_file):
        from cryptography.hazmat.primitives import serialization
        self.key = serialization.load_pem_private_key(key_file.read_bytes(), password=None)

    def request(self, path, data=None, method=None):
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.primitives.asymmetric import ec
        from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature

        def encoded(value):
            return base64.urlsafe_b64encode(value).rstrip(b'=')

        now = int(time.time())
        header = encoded(json.dumps({'alg': 'ES256', 'kid': os.environ['ASC_KEY_ID'], 'typ': 'JWT'}).encode())
        claims = encoded(json.dumps({'iss': os.environ['ASC_ISSUER_ID'], 'iat': now,
                                     'exp': now + 600, 'aud': 'appstoreconnect-v1'}).encode())
        message = header + b'.' + claims
        r, s = decode_dss_signature(self.key.sign(message, ec.ECDSA(hashes.SHA256())))
        token = (message + b'.' + encoded(r.to_bytes(32, 'big') + s.to_bytes(32, 'big'))).decode()
        request = Request('https://api.appstoreconnect.apple.com' + path,
                          data=json.dumps(data).encode() if data is not None else None,
                          method=method,
                          headers={'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json'})
        with urlopen(request, timeout=40) as response:
            raw = response.read()
            return json.loads(raw) if raw else {}


def matching_builds(api, app, number, version):
    """Return every iOS build of [version] whose build number is [number]."""
    query = urlencode({'filter[app]': app, 'filter[version]': number, 'limit': '200'})
    found = []
    for build in api.request('/v1/builds?' + query)['data']:
        prerelease = api.request(f'/v1/builds/{build["id"]}/preReleaseVersion')['data']
        if matching_build(build, prerelease, number, version):
            found.append(build)
    return found


def assert_unused(api, app, number, version):
    """Fail closed when App Store Connect already holds this build number.

    Apple rejects a re-upload of an existing CFBundleVersion with a bare 409,
    after the bundle has been built and signed. Checking first turns that into
    a clear message and costs one API call.
    """
    if api.request(f'/v1/apps/{app}')['data']['attributes']['bundleId'] != 'com.crispstrobe.crispmath':
        raise ValueError('App ID does not identify CrispMath')
    existing = matching_builds(api, app, number, version)
    if not existing:
        return {'version': version, 'build': number, 'alreadyUploaded': False}
    states = [item['attributes']['processingState'] for item in existing]
    raise ValueError(
        f'{version} ({number}) is already in App Store Connect '
        f'(processingState={", ".join(states)}); bump the build number instead of re-uploading')


def prepare(api, app, number, version, wait_seconds=900):
    if api.request(f'/v1/apps/{app}')['data']['attributes']['bundleId'] != 'com.crispstrobe.crispmath':
        raise ValueError('App ID does not identify CrispMath')
    deadline = time.monotonic() + wait_seconds
    while True:
        candidates = matching_builds(api, app, number, version)
        if len(candidates) > 1:
            raise ValueError('Multiple matching iOS builds; assignment aborted')
        if candidates:
            build = candidates[0]
            state = build['attributes']['processingState']
            if state in ['FAILED', 'INVALID'] or build['attributes'].get('expired') is True:
                raise ValueError('Uploaded build failed processing or expired')
            if state == 'VALID':
                break
        if time.monotonic() >= deadline:
            raise TimeoutError('Uploaded build has not completed valid processing')
        print('Waiting for valid processing: ' + json.dumps(
            {'matchingBuilds': len(candidates),
             'states': [item['attributes']['processingState'] for item in candidates]}), flush=True)
        time.sleep(30)
    group = internal_group(api.request(f'/v1/apps/{app}/betaGroups?limit=200')['data'])
    path = f'/v1/betaGroups/{group["id"]}'
    existing = api.request(path + '/builds?limit=200')['data']
    if not any(item['id'] == build['id'] for item in existing):
        api.request(path + '/relationships/builds', {'data': [{'type': 'builds', 'id': build['id']}]})
    verified = api.request(path + '/builds?limit=200')['data']
    if not any(item['id'] == build['id'] for item in verified):
        raise ValueError('Internal TestFlight assignment was not confirmed')
    return {'source': os.environ.get('BUILD_SOURCE', os.environ.get('GITHUB_SHA')),
            'verificationSource': os.environ.get('GITHUB_SHA'), 'version': version, 'build': number,
            'processingState': 'VALID', 'internalGroup': group['attributes']['name'],
            'internalGroupAssigned': True, 'physicalDeviceTest': False,
            'appReviewSubmitted': False}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key-file', type=Path, required=True)
    parser.add_argument('--version')
    parser.add_argument('--build')
    parser.add_argument('--inspect-only', action='store_true')
    parser.add_argument('--assert-unused', action='store_true',
                        help='Fail when this version/build pair is already uploaded')
    parser.add_argument('--output', type=Path, default=Path('testflight-evidence.json'))
    args = parser.parse_args()
    api = AppleApi(args.key_file)
    app = os.environ['ASC_APP_ID']
    if args.assert_unused:
        if not args.version or not args.build:
            parser.error('--version and --build are required for --assert-unused')
        try:
            available = assert_unused(api, app, args.build, args.version)
        except ValueError as error:
            raise SystemExit(f'Upload refused: {error}')
        print(json.dumps(available), flush=True)
        raise SystemExit(0)
    if args.inspect_only:
        if api.request(f'/v1/apps/{app}')['data']['attributes']['bundleId'] != 'com.crispstrobe.crispmath':
            raise ValueError('App ID does not identify CrispMath')
        query = urlencode({'filter[app]': app, 'limit': '25', 'sort': '-uploadedDate'})
        evidence = {'builds': []}
        for build in api.request('/v1/builds?' + query)['data']:
            prerelease = api.request(f'/v1/builds/{build["id"]}/preReleaseVersion')['data']['attributes']
            evidence['builds'].append({'build': build['attributes']['version'],
                'version': prerelease['version'], 'platform': prerelease['platform'],
                'processingState': build['attributes']['processingState']})
    else:
        if not args.version or not args.build:
            parser.error('--version and --build are required for assignment')
        evidence = prepare(api, app, args.build, args.version)
    args.output.write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps(evidence), flush=True)
