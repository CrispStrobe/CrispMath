import unittest
from copy import deepcopy
from unittest.mock import patch

from testflight_external import inspect, submit


class InspectionFixture:
    def __init__(self, bundle='com.crispstrobe.crispmath', state='VALID'):
        self.bundle, self.state = bundle, state
        self.writes = []

    def request(self, path, data=None):
        if data is not None:
            self.writes.append((path, data))
            raise AssertionError('Inspection must not write')
        if path == '/v1/apps/app':
            return {'data': {'attributes': {'bundleId': self.bundle}}}
        if path.startswith('/v1/builds?'):
            return {'data': [{'id': 'build', 'attributes': {'version': '13', 'processingState': self.state}}]}
        if path.endswith('/preReleaseVersion'):
            return {'data': {'attributes': {'version': '1.2.0', 'platform': 'IOS'}}}
        if path.endswith('/buildBetaDetail'):
            return {'data': {'id': 'detail', 'attributes': {'externalBuildState': 'READY_FOR_BETA_SUBMISSION'}}}
        if path.endswith('/betaAppReviewDetail'):
            return {'data': {'id': 'review', 'attributes': {'contactEmail': 'private@example.com'}}}
        return {'data': []}


class ExternalInspectionTests(unittest.TestCase):
    def test_inspection_is_read_only_and_redacts_review_contact(self):
        api = InspectionFixture()
        result = inspect(api, 'app', '13', '1.2.0')
        self.assertTrue(result['reviewFieldsPresent']['contactEmail'])
        self.assertNotIn('private@example.com', str(result))
        self.assertEqual(api.writes, [])

    def test_wrong_app_or_invalid_build_aborts(self):
        for api in [InspectionFixture(bundle='other.app'), InspectionFixture(state='INVALID')]:
            with self.assertRaises(ValueError):
                inspect(api, 'app', '13', '1.2.0')
            self.assertEqual(api.writes, [])


class SubmissionFixture:
    def __init__(self, assigned=False):
        self.assigned = assigned
        self.writes = []

    def request(self, path, data=None, method=None):
        if data is not None:
            self.writes.append((path, data, method))
            if path.endswith('/relationships/builds'):
                self.assigned = True
            return {}
        if path.endswith('/builds?limit=200'):
            return {'data': [{'id': 'build'}] if self.assigned else []}
        raise AssertionError(path)


def submission_evidence():
    return {'version': '1.2.0', 'build': '13', 'buildId': 'build',
            'reviewFieldsPresent': {k: True for k in ['contactFirstName', 'contactLastName', 'contactPhone', 'contactEmail']},
            'appLocalizations': [{'description': 'Calculator and worksheets'}],
            'buildLocalizations': [{'id': 'locale', 'whatsNew': 'Test calculations'}],
            'groups': [{'id': 'group', 'name': 'External Testers', 'isInternalGroup': False}],
            'betaDetail': {'externalBuildState': 'READY_FOR_BETA_SUBMISSION'}, 'submissions': []}


class ExternalSubmissionTests(unittest.TestCase):
    def test_submission_targets_only_the_verified_build_and_external_group(self):
        evidence = submission_evidence()
        verified = deepcopy(evidence)
        verified['submissions'] = [{'id': 'submission', 'betaReviewState': 'WAITING_FOR_REVIEW'}]
        api = SubmissionFixture()
        with patch('testflight_external.inspect', return_value=verified):
            result = submit(api, 'app', evidence)
        self.assertTrue(result['betaReviewSubmitted'])
        self.assertTrue(result['externalGroupAssigned'])
        self.assertEqual(api.writes, [('/v1/betaAppReviewSubmissions', {'data': {
            'type': 'betaAppReviewSubmissions', 'relationships': {'build': {'data': {'type': 'builds', 'id': 'build'}}}}}, None),
            ('/v1/betaGroups/group/relationships/builds', {'data': [{'type': 'builds', 'id': 'build'}]}, None)])

    def test_retry_does_not_submit_or_assign_again(self):
        evidence = submission_evidence()
        evidence['submissions'] = [{'id': 'submission', 'betaReviewState': 'WAITING_FOR_REVIEW'}]
        evidence['betaDetail']['externalBuildState'] = 'WAITING_FOR_BETA_REVIEW'
        api = SubmissionFixture(assigned=True)
        with patch('testflight_external.inspect', return_value=deepcopy(evidence)):
            submit(api, 'app', evidence)
        self.assertEqual(api.writes, [])

    def test_missing_metadata_internal_only_or_ambiguous_groups_prevent_writes(self):
        for kind in ['contact', 'internal', 'description', 'groups', 'state']:
            evidence = submission_evidence()
            if kind == 'contact': evidence['reviewFieldsPresent']['contactEmail'] = False
            if kind == 'internal': evidence['buildAudienceType'] = 'INTERNAL_ONLY'
            if kind == 'description': evidence['appLocalizations'][0]['description'] = None
            if kind == 'groups': evidence['groups'] = [{'id': 'a', 'name': 'A', 'isInternalGroup': False}, {'id': 'b', 'name': 'B', 'isInternalGroup': False}]
            if kind == 'state': evidence['betaDetail']['externalBuildState'] = 'BETA_REJECTED'
            api = SubmissionFixture()
            with self.assertRaises(ValueError): submit(api, 'app', evidence)
            self.assertEqual(api.writes, [])
