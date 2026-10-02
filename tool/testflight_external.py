"""Inspect or submit a verified CrispMath build to TestFlight beta review."""
import argparse
import json
import os
from pathlib import Path
from urllib.parse import urlencode

from testflight_internal import AppleApi, matching_build


def inspect(api, app, number, version):
    if api.request(f'/v1/apps/{app}')['data']['attributes']['bundleId'] != 'com.crispstrobe.crispmath':
        raise ValueError('App ID does not identify CrispMath')
    query = urlencode({'filter[app]': app, 'filter[version]': number, 'limit': '200'})
    matches = [b for b in api.request('/v1/builds?' + query)['data']
               if matching_build(b, api.request(f'/v1/builds/{b["id"]}/preReleaseVersion')['data'], number, version)]
    if len(matches) != 1:
        raise ValueError('Expected exactly one matching iOS build')
    build = matches[0]
    if build['attributes']['processingState'] != 'VALID' or build['attributes'].get('expired'):
        raise ValueError('Build is not valid and current')
    bid = build['id']
    groups = api.request(f'/v1/apps/{app}/betaGroups?limit=200')['data']
    detail = api.request(f'/v1/builds/{bid}/buildBetaDetail')['data']
    review = api.request(f'/v1/apps/{app}/betaAppReviewDetail')['data']
    localizations = api.request(f'/v1/apps/{app}/betaAppLocalizations?limit=200')['data']
    build_localizations = api.request(f'/v1/builds/{bid}/betaBuildLocalizations?limit=200')['data']
    submissions = api.request('/v1/betaAppReviewSubmissions?' + urlencode({'filter[build]': bid}))['data']
    return {'source': os.environ.get('BUILD_SOURCE'), 'verificationSource': os.environ.get('GITHUB_SHA'),
            'version': version, 'build': number, 'buildId': bid,
            'processingState': 'VALID', 'buildAudienceType': build['attributes'].get('buildAudienceType'),
            'betaDetail': detail['attributes'],
            'reviewFieldsPresent': {k: bool(v) for k, v in review['attributes'].items()},
            'appLocalizations': [{'id': item['id'], **item['attributes']} for item in localizations],
            'buildLocalizations': [{'id': item['id'], **item['attributes']} for item in build_localizations],
            'groups': [{'id': g['id'], **g['attributes']} for g in groups],
            'submissions': [{'id': item['id'], **item['attributes']} for item in submissions],
            'betaReviewSubmitted': False, 'appReviewSubmitted': False}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key-file', type=Path, required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--build', required=True)
    parser.add_argument('--submit', action='store_true')
    args = parser.parse_args()
    api = AppleApi(args.key_file)
    evidence = inspect(api, os.environ['ASC_APP_ID'], args.build, args.version)
    if args.submit:
        raise ValueError('Submission requires the inspected metadata to be validated first')
    Path('external-testflight-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps(evidence), flush=True)
