import unittest
from unittest.mock import patch
from testflight_internal import prepare


class ApiFixture:
    def __init__(self, *, bundle='com.crispstrobe.crispmath', platform='IOS', version='1.2.0', internal=True, state='VALID'):
        self.bundle, self.platform, self.version = bundle, platform, version
        self.internal, self.state = internal, state
        self.assigned = False
        self.writes = []

    def request(self, path, data=None):
        if data is not None:
            self.writes.append((path, data))
            self.assigned = True
            return {}
        if path == '/v1/apps/app':
            return {'data': {'attributes': {'bundleId': self.bundle}}}
        if path.startswith('/v1/builds?'):
            return {'data': [{'id': 'build', 'attributes': {'version': '12', 'processingState': self.state}}]}
        if path.endswith('/preReleaseVersion'):
            return {'data': {'attributes': {'version': self.version, 'platform': self.platform}}}
        if 'betaGroups?' in path:
            return {'data': [{'id': 'group', 'attributes': {'name': 'Internal Testers', 'isInternalGroup': self.internal}}]}
        if path == '/v1/betaGroups/group/builds?limit=200':
            return {'data': [{'id': 'build'}] if self.assigned else []}
        raise AssertionError(path)


class InternalTestFlightTests(unittest.TestCase):
    def test_valid_build_is_assigned_and_reverified_without_review(self):
        api = ApiFixture()
        result = prepare(api, 'app', '12', '1.2.0', wait_seconds=0)
        self.assertTrue(result['internalGroupAssigned'])
        self.assertFalse(result['appReviewSubmitted'])
        self.assertEqual(api.writes, [('/v1/betaGroups/group/relationships/builds',
                                      {'data': [{'type': 'builds', 'id': 'build'}]})])

    def test_wrong_app_or_external_group_never_receives_a_write(self):
        for options in [{'bundle': 'other.app'}, {'internal': False}]:
            api = ApiFixture(**options)
            with self.assertRaises(ValueError):
                prepare(api, 'app', '12', '1.2.0', wait_seconds=0)
            self.assertEqual(api.writes, [])

    def test_wrong_platform_or_marketing_version_is_not_assigned(self):
        for options in [{'platform': 'MAC_OS'}, {'version': '1.0.3'}]:
            api = ApiFixture(**options)
            with self.assertRaises(TimeoutError):
                prepare(api, 'app', '12', '1.2.0', wait_seconds=0)
            self.assertEqual(api.writes, [])

    def test_failed_or_unprocessed_build_is_not_assigned(self):
        for state in ['INVALID', 'FAILED', 'PROCESSING']:
            api = ApiFixture(state=state)
            with self.assertRaises((ValueError, TimeoutError)):
                prepare(api, 'app', '12', '1.2.0', wait_seconds=0)
            self.assertEqual(api.writes, [])

    def test_assignment_is_idempotent(self):
        api = ApiFixture()
        api.assigned = True
        with patch.dict('os.environ', {'GITHUB_SHA': 'tested-source'}):
            result = prepare(api, 'app', '12', '1.2.0', wait_seconds=0)
        self.assertEqual(result['source'], 'tested-source')
        self.assertEqual(api.writes, [])
