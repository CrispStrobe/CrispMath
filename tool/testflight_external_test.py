import unittest
from copy import deepcopy
from unittest.mock import patch

from testflight_external import (ENGLISH_BETA_DESCRIPTION, inspect, submit,
                                 update_english_description)


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


class BetaDescriptionFixture:
    def __init__(self, evidence, apply=True):
        self.evidence = deepcopy(evidence)
        self.writes = []
        self.apply = apply

    def request(self, path, data=None, method=None):
        self.writes.append((path, deepcopy(data), method))
        if path != '/v1/betaAppLocalizations/english' or method != 'PATCH':
            raise AssertionError('Metadata update must write only the English beta localization')
        if set(data['data']['attributes']) != {'description'}:
            raise AssertionError('Other metadata must be preserved')
        if self.apply:
            self.evidence['appLocalizations'][0]['description'] = data['data']['attributes']['description']
        return {}


def description_evidence():
    return {'version': '1.2.0', 'build': '15', 'buildId': 'build15',
            'appLocalizations': [
                {'id': 'english', 'locale': 'en-US', 'description': 'All computation runs on-device.',
                 'feedbackEmail': 'feedback@example.com', 'privacyPolicyUrl': 'https://example.com/privacy'},
                {'id': 'german', 'locale': 'de-DE', 'description': 'Individuelle Beschreibung'}],
            'buildLocalizations': [
                {'id': 'notes-en', 'locale': 'en-US', 'whatsNew': 'Custom build 15 test notes'},
                {'id': 'notes-de', 'locale': 'de-DE', 'whatsNew': 'Eigene Testhinweise'}]}


class BetaDescriptionTests(unittest.TestCase):
    def test_updates_only_english_beta_description_and_preserves_custom_notes(self):
        evidence = description_evidence()
        api = BetaDescriptionFixture(evidence)
        with patch('testflight_external.inspect', side_effect=lambda *args: deepcopy(api.evidence)) as verify:
            result = update_english_description(api, 'app', evidence)
        verify.assert_called_once_with(api, 'app', '15', '1.2.0')
        self.assertEqual(api.writes, [('/v1/betaAppLocalizations/english', {'data': {
            'type': 'betaAppLocalizations', 'id': 'english',
            'attributes': {'description': ENGLISH_BETA_DESCRIPTION}}}, 'PATCH')])
        self.assertEqual(result['buildLocalizations'], evidence['buildLocalizations'])
        self.assertEqual(result['appLocalizations'][1], evidence['appLocalizations'][1])
        self.assertTrue(result['metadataOnly'])
        self.assertTrue(result['betaDescriptionChanged'])
        self.assertTrue(result['betaDescriptionUpdateVerified'])
        self.assertIn('Optional AI assistance', ENGLISH_BETA_DESCRIPTION)
        self.assertIn('optional cloud sync', ENGLISH_BETA_DESCRIPTION)
        self.assertNotIn('All computation runs on-device', ENGLISH_BETA_DESCRIPTION)

    def test_retry_is_read_only_when_description_is_already_correct(self):
        evidence = description_evidence()
        evidence['appLocalizations'][0]['description'] = ENGLISH_BETA_DESCRIPTION
        api = BetaDescriptionFixture(evidence)
        with patch('testflight_external.inspect', return_value=deepcopy(evidence)):
            result = update_english_description(api, 'app', evidence)
        self.assertFalse(result['betaDescriptionChanged'])
        self.assertTrue(result['betaDescriptionUpdateVerified'])
        self.assertEqual(api.writes, [])

    def test_missing_or_ambiguous_english_localization_prevents_writes(self):
        for duplicate in (False, True):
            evidence = description_evidence()
            english = evidence['appLocalizations'][0]
            evidence['appLocalizations'] = [english, deepcopy(english)] if duplicate else [evidence['appLocalizations'][1]]
            api = BetaDescriptionFixture(evidence)
            with self.subTest(duplicate=duplicate), self.assertRaises(ValueError):
                update_english_description(api, 'app', evidence)
            self.assertEqual(api.writes, [])

    def test_unapplied_patch_changed_build_or_changed_custom_metadata_is_rejected(self):
        for kind in ('unapplied', 'build', 'notes', 'other-locale', 'privacy'):
            evidence = description_evidence()
            api = BetaDescriptionFixture(evidence, apply=kind != 'unapplied')
            def response(*args):
                verified = deepcopy(api.evidence)
                if kind == 'build': verified['buildId'] = 'different'
                if kind == 'notes': verified['buildLocalizations'][0]['whatsNew'] = 'overwritten'
                if kind == 'other-locale': verified['appLocalizations'][1]['description'] = 'overwritten'
                if kind == 'privacy': verified['appLocalizations'][0]['privacyPolicyUrl'] = None
                return verified
            with self.subTest(kind=kind), patch('testflight_external.inspect', side_effect=response), self.assertRaises(ValueError):
                update_english_description(api, 'app', evidence)


if __name__ == '__main__':
    unittest.main()
