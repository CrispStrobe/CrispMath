"""Inspect or submit a verified CrispMath build to TestFlight beta review."""
import argparse
import json
import os
from pathlib import Path
from urllib.parse import urlencode

from testflight_internal import AppleApi, matching_build

TEST_NOTES = ('Please test worksheet calculations: a=3, f(t)=t^2+a, f(4) should give 19. '
              'Change a and recalculate, link a graph, preview/export results, save and restore '
              'a checkpoint, and import a worksheet through Files. Test formula photo import '
              'and camera permission prompts. Handwriting transcription is experimental; '
              'review and correct recognized formulas before inserting them.')


ENGLISH_BETA_DESCRIPTION = (
    'CrispMath is a scientific calculator with a Computer Algebra System '
    '(SymEngine), 2D/3D graphing, formula photo import, and a live-formula notepad. '
    'Core calculations run on your device. Optional AI assistance sends the math '
    'you request help with to your configured provider; optional cloud sync '
    'transfers your workspace through a configured backend.')


def update_english_description(api, app, evidence):
    """Change only the existing en-US beta description, then verify preservation."""
    english = [loc for loc in evidence['appLocalizations'] if loc.get('locale') == 'en-US']
    if len(english) != 1 or not english[0].get('id'):
        raise ValueError('Expected exactly one existing en-US beta localization')
    before = english[0]
    changed = before.get('description') != ENGLISH_BETA_DESCRIPTION
    if changed:
        api.request('/v1/betaAppLocalizations/' + before['id'], {'data': {
            'type': 'betaAppLocalizations', 'id': before['id'],
            'attributes': {'description': ENGLISH_BETA_DESCRIPTION}}}, method='PATCH')
    verified = inspect(api, app, evidence['build'], evidence['version'])
    if verified['buildId'] != evidence['buildId']:
        raise ValueError('Verified beta build changed during metadata update')
    expected = [dict(loc, description=ENGLISH_BETA_DESCRIPTION)
                if loc['id'] == before['id'] else loc for loc in evidence['appLocalizations']]
    by_id = lambda locales: {loc['id']: loc for loc in locales}
    if by_id(verified['appLocalizations']) != by_id(expected):
        raise ValueError('Beta description update or localization preservation was not confirmed')
    if by_id(verified['buildLocalizations']) != by_id(evidence['buildLocalizations']):
        raise ValueError('Existing beta release notes changed during metadata update')
    verified['metadataOnly'] = True
    verified['betaDescriptionChanged'] = changed
    verified['betaDescriptionUpdateVerified'] = True
    return verified


def submit(api, app, evidence):
    if evidence.get('buildAudienceType') == 'INTERNAL_ONLY':
        raise ValueError('Build was restricted to internal testing')
    fields = evidence['reviewFieldsPresent']
    missing = [k for k in ['contactFirstName', 'contactLastName', 'contactPhone', 'contactEmail']
               if not fields.get(k)]
    if missing:
        raise ValueError('Missing existing beta-review contact fields: ' + ', '.join(missing))
    if fields.get('demoAccountRequired') and not all(fields.get(k) for k in ['demoAccountName', 'demoAccountPassword']):
        raise ValueError('Required existing review account credentials are missing')
    if not evidence['appLocalizations'] or any(not (loc.get('description') or '').strip() for loc in evidence['appLocalizations']):
        raise ValueError('A beta description is required for every existing app localization')
    groups = [g for g in evidence['groups'] if g.get('isInternalGroup') is False]
    named = [g for g in groups if g['name'] == 'External Testers']
    if len(groups) > 1 and len(named) != 1:
        raise ValueError('Multiple external groups; target must be specified')
    state = evidence['betaDetail'].get('externalBuildState')
    if state not in ['READY_FOR_BETA_SUBMISSION', 'WAITING_FOR_BETA_REVIEW', 'IN_BETA_REVIEW',
                     'BETA_APPROVED', 'READY_FOR_BETA_TESTING', 'IN_BETA_TESTING']:
        raise ValueError('Build is not eligible for external submission: ' + str(state))
    if not evidence['buildLocalizations']:
        api.request('/v1/betaBuildLocalizations', {'data': {'type': 'betaBuildLocalizations',
            'attributes': {'locale': 'en-US', 'whatsNew': TEST_NOTES},
            'relationships': {'build': {'data': {'type': 'builds', 'id': evidence['buildId']}}}}})
    for loc in evidence['buildLocalizations']:
        if not (loc.get('whatsNew') or '').strip():
            api.request('/v1/betaBuildLocalizations/' + loc['id'], {'data': {
                'type': 'betaBuildLocalizations', 'id': loc['id'], 'attributes': {'whatsNew': TEST_NOTES}}}, method='PATCH')
    if state == 'READY_FOR_BETA_SUBMISSION' and not evidence['submissions']:
        api.request('/v1/betaAppReviewSubmissions', {'data': {'type': 'betaAppReviewSubmissions',
            'relationships': {'build': {'data': {'type': 'builds', 'id': evidence['buildId']}}}}})
    if groups:
        group = named[0] if named else groups[0]
    else:
        group = api.request('/v1/betaGroups', {'data': {'type': 'betaGroups',
            'attributes': {'name': 'External Testers', 'isInternalGroup': False},
            'relationships': {'app': {'data': {'type': 'apps', 'id': app}}}}})['data']
    path = '/v1/betaGroups/' + group['id']
    if not any(b['id'] == evidence['buildId'] for b in api.request(path + '/builds?limit=200')['data']):
        api.request(path + '/relationships/builds', {'data': [{'type': 'builds', 'id': evidence['buildId']}]})
    verified = inspect(api, app, evidence['build'], evidence['version'])
    verified['externalGroup'] = group['attributes']['name'] if 'attributes' in group else group['name']
    verified['externalGroupAssigned'] = any(b['id'] == evidence['buildId'] for b in api.request(path + '/builds?limit=200')['data'])
    verified['betaReviewSubmitted'] = bool(verified['submissions'])
    if not verified['externalGroupAssigned'] or not verified['betaReviewSubmitted']:
        raise ValueError('External assignment or beta submission was not confirmed')
    return verified

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
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--submit', action='store_true')
    action.add_argument('--update-english-description', action='store_true')
    args = parser.parse_args()
    api = AppleApi(args.key_file)
    evidence = inspect(api, os.environ['ASC_APP_ID'], args.build, args.version)
    output = Path('external-testflight-evidence.json')
    output.write_text(json.dumps(evidence, indent=2) + '\n')
    if args.update_english_description:
        evidence = update_english_description(api, os.environ['ASC_APP_ID'], evidence)
    if args.submit:
        evidence = submit(api, os.environ['ASC_APP_ID'], evidence)
    Path('external-testflight-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps(evidence), flush=True)
