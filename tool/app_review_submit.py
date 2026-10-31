"""Inspect, or submit, a verified CrispMath build for App Store review.

Inspection makes no changes. Submission reuses the editable iOS App Store
version (keeping its screenshots and metadata), renames it to the build's
version, attaches the build, writes the App Review notes and submits through
the reviewSubmissions API. It refuses when a version is already in review.
"""
import argparse
import json
import os
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlencode

from testflight_internal import AppleApi, matching_build

REVIEW_NOTES = """\
This resubmission responds to the 4.3(a) finding on CrispMath 1.0.3 (submission e4eafc90-b0a1-4e16-890a-11dbf5919165). The same finding was recorded against nine other apps of ours in the same period, which makes us suspect an automated similarity check rather than a judgement about this app. CrispMath shares practically no relevant source files with our other titles, some of which are learning games; this is a scientific and graphing calculator with a computer algebra system in it.

The algebra is not string rewriting or a stored table of worked examples. The app embeds SymEngine, a C++ computer algebra library, through dart:ffi. On device and offline it provides:
- symbolic factoring, expansion and simplification with rational cancellation
- symbolic differentiation, Taylor and Maclaurin series, and limits computed by the Gruntz algorithm rather than by pattern matching
- equation and linear-system solving; matrices with determinant, inverse, reduced row echelon form and eigenvalues
- curve sketching that annotates roots and extrema, with parameter sliders
- statistics: one-, two-sample and paired t-tests, one-way ANOVA, chi-square goodness-of-fit and independence, Wilcoxon rank-sum
- unit conversion with SI prefixes and composite-dimension arithmetic
- a FlatZinc constraint solver with a step-by-step propagation view, and a Sudoku solver that explains each deduction (singles, locked candidates, subsets, Killer cage sums) and draws its search tree

Suggested path: the app opens on a worksheet. Enter a=3, then f(t)=t^2+a, then f(4); the result is 19, and changing a recalculates the sheet. Analysis > Labs > Sudoku solver > AI Escargot > Solve, then Next, steps through the explained deductions.

It is about 99,000 lines of Dart with more than 3,400 automated tests, localised in English, German, French and Spanish, and exports LaTeX. No account is needed. The source is public, so none of this has to be taken on trust: https://github.com/CrispStrobe/CrispMath
"""

EDITABLE = {'PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED',
            'METADATA_REJECTED', 'INVALID_BINARY'}
IN_FLIGHT = {'WAITING_FOR_REVIEW', 'IN_REVIEW', 'PENDING_DEVELOPER_RELEASE',
             'PROCESSING_FOR_APP_STORE'}


def version_state(v):
    a = v['attributes']
    return a.get('appVersionState') or a.get('appStoreState')


def find_build(api, app, number, version):
    query = urlencode({'filter[app]': app, 'filter[version]': number, 'limit': '200'})
    matches = [b for b in api.request('/v1/builds?' + query)['data']
               if matching_build(b, api.request(f'/v1/builds/{b["id"]}/preReleaseVersion')['data'], number, version)]
    if len(matches) != 1:
        raise ValueError('Expected exactly one matching iOS build')
    build = matches[0]
    if build['attributes']['processingState'] != 'VALID' or build['attributes'].get('expired'):
        raise ValueError('Build is not valid and current')
    return build


def inspect(api, app, number, version):
    if api.request(f'/v1/apps/{app}')['data']['attributes']['bundleId'] != 'com.crispstrobe.crispmath':
        raise ValueError('App ID does not identify CrispMath')
    build = find_build(api, app, number, version)
    versions = api.request(f'/v1/apps/{app}/appStoreVersions?' + urlencode(
        {'filter[platform]': 'IOS', 'limit': '50'}))['data']
    submissions = api.request('/v1/reviewSubmissions?' + urlencode(
        {'filter[app]': app, 'filter[platform]': 'IOS', 'limit': '50'}))['data']
    subs = []
    for s in submissions:
        items = api.request(f'/v1/reviewSubmissions/{s["id"]}/items?include=appStoreVersion&limit=50')['data']
        subs.append({'id': s['id'], 'state': s['attributes'].get('state'),
                     'items': [{'id': i['id'], 'state': i['attributes'].get('state'),
                                'appStoreVersion': ((i.get('relationships', {}).get('appStoreVersion') or {}).get('data') or {}).get('id')}
                               for i in items]})
    vs = []
    for v in versions:
        detail = api.request(f'/v1/appStoreVersions/{v["id"]}/appStoreReviewDetail')
        attached = api.request(f'/v1/appStoreVersions/{v["id"]}/build').get('data')
        vs.append({'id': v['id'], 'versionString': v['attributes']['versionString'],
                   'state': version_state(v), 'buildId': attached and attached['id'],
                   'reviewDetailId': (detail.get('data') or {}).get('id'),
                   'reviewFieldsPresent': {k: bool(x) for k, x in ((detail.get('data') or {}).get('attributes') or {}).items()}})
    return {'source': os.environ.get('BUILD_SOURCE'), 'version': version, 'build': number,
            'buildId': build['id'], 'usesNonExemptEncryption': build['attributes'].get('usesNonExemptEncryption'),
            'versions': vs, 'reviewSubmissions': subs, 'appReviewSubmitted': False}


def submit(api, app, evidence):
    if any(v['state'] in IN_FLIGHT for v in evidence['versions']):
        raise ValueError('A version is already waiting for or in review')
    editable = [v for v in evidence['versions'] if v['state'] in EDITABLE]
    if len(editable) > 1:
        raise ValueError('More than one editable iOS version; resolve manually')
    bid, version = evidence['buildId'], evidence['version']
    if editable:
        vid = editable[0]['id']
        if editable[0]['versionString'] != version:
            api.request(f'/v1/appStoreVersions/{vid}', {'data': {'type': 'appStoreVersions', 'id': vid,
                'attributes': {'versionString': version}}}, method='PATCH')
    else:
        vid = api.request('/v1/appStoreVersions', {'data': {'type': 'appStoreVersions',
            'attributes': {'platform': 'IOS', 'versionString': version},
            'relationships': {'app': {'data': {'type': 'apps', 'id': app}}}}})['data']['id']
    api.request(f'/v1/appStoreVersions/{vid}/relationships/build',
                {'data': {'type': 'builds', 'id': bid}}, method='PATCH')

    detail = api.request(f'/v1/appStoreVersions/{vid}/appStoreReviewDetail').get('data')
    if detail:
        api.request(f'/v1/appStoreReviewDetails/{detail["id"]}', {'data': {'type': 'appStoreReviewDetails',
            'id': detail['id'], 'attributes': {'notes': REVIEW_NOTES}}}, method='PATCH')
    else:
        # A new version has no review detail; carry the contact fields over
        # from the most recent version that has them.
        source = next((v for v in evidence['versions'] if v['reviewDetailId']), None)
        if not source:
            raise ValueError('No existing App Review contact details to carry over')
        old = api.request(f'/v1/appStoreReviewDetails/{source["reviewDetailId"]}')['data']['attributes']
        keep = {k: old.get(k) for k in ['contactFirstName', 'contactLastName', 'contactPhone',
                                        'contactEmail', 'demoAccountRequired'] if old.get(k) is not None}
        api.request('/v1/appStoreReviewDetails', {'data': {'type': 'appStoreReviewDetails',
            'attributes': dict(keep, notes=REVIEW_NOTES),
            'relationships': {'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': vid}}}}})

    # Reuse an open draft submission instead of leaving another one behind.
    drafts = [s for s in evidence['reviewSubmissions'] if s['state'] == 'READY_FOR_REVIEW']
    draft = next((s for s in drafts if any(i['appStoreVersion'] == vid for i in s['items'])), None) \
        or next((s for s in drafts if not s['items']), None)
    if draft:
        sid = draft['id']
    else:
        sid = api.request('/v1/reviewSubmissions', {'data': {'type': 'reviewSubmissions',
            'attributes': {'platform': 'IOS'},
            'relationships': {'app': {'data': {'type': 'apps', 'id': app}}}}})['data']['id']
    if not (draft and any(i['appStoreVersion'] == vid for i in draft['items'])):
        api.request('/v1/reviewSubmissionItems', {'data': {'type': 'reviewSubmissionItems',
            'relationships': {'reviewSubmission': {'data': {'type': 'reviewSubmissions', 'id': sid}},
                              'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': vid}}}}})
    api.request(f'/v1/reviewSubmissions/{sid}', {'data': {'type': 'reviewSubmissions', 'id': sid,
        'attributes': {'submitted': True}}}, method='PATCH')

    verified = inspect(api, app, evidence['build'], version)
    mine = next(v for v in verified['versions'] if v['id'] == vid)
    if mine['buildId'] != bid or mine['versionString'] != version:
        raise ValueError('Version rename or build attachment was not confirmed')
    sub = next((s for s in verified['reviewSubmissions'] if s['id'] == sid), None)
    if not sub or sub['state'] not in {'WAITING_FOR_REVIEW', 'IN_REVIEW'}:
        raise ValueError('Review submission was not confirmed: ' + str(sub and sub['state']))
    verified['submissionId'] = sid
    verified['appStoreVersionId'] = vid
    verified['appReviewSubmitted'] = True
    return verified


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--key-file', type=Path, required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--build', required=True)
    parser.add_argument('--submit', action='store_true')
    parser.add_argument('--output', type=Path, default=Path('app-review-evidence.json'))
    args = parser.parse_args()
    api = AppleApi(args.key_file)
    app = os.environ['ASC_APP_ID']
    evidence = inspect(api, app, args.build, args.version)
    if args.submit:
        try:
            evidence = submit(api, app, evidence)
        except HTTPError as error:
            # Apple explains a refused submission in the response body.
            print(error.read().decode(errors='replace'))
            raise
    args.output.write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps(evidence, indent=2))
