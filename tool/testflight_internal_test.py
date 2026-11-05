"""Upload preflight: an existing build number must be refused before signing."""
import importlib.util
from pathlib import Path
import unittest

MODULE = Path(__file__).resolve().parent / 'testflight_internal.py'
spec = importlib.util.spec_from_file_location('testflight_internal', MODULE)
testflight = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(testflight)

APP = '6789536359'


class FakeApi:
    def __init__(self, builds=(), bundle_id='com.crispstrobe.crispmath'):
        self.builds = list(builds)
        self.bundle_id = bundle_id
        self.requests = []

    def request(self, path, data=None, method=None):
        self.requests.append(path)
        if path == f'/v1/apps/{APP}':
            return {'data': {'attributes': {'bundleId': self.bundle_id}}}
        if path.startswith('/v1/builds?'):
            return {'data': self.builds}
        if path.startswith('/v1/builds/') and path.endswith('/preReleaseVersion'):
            build_id = path.split('/')[3]
            build = next(item for item in self.builds if item['id'] == build_id)
            return {'data': {'attributes': {'version': build['version'],
                                            'platform': build['platform']}}}
        raise AssertionError(f'unexpected request: {path}')


def build(identifier, number, version='1.2.0', platform='IOS',
          state='VALID'):
    return {'id': identifier,
            'version': version,
            'platform': platform,
            'attributes': {'version': number, 'processingState': state}}


class AssertUnusedTest(unittest.TestCase):
    def test_unused_build_number_passes(self):
        api = FakeApi([build('a', '26')])
        self.assertEqual(testflight.assert_unused(api, APP, '27', '1.2.0'),
                         {'version': '1.2.0', 'build': '27', 'alreadyUploaded': False})

    def test_existing_build_number_is_refused_with_its_state(self):
        api = FakeApi([build('a', '26')])
        with self.assertRaisesRegex(ValueError,
                                    r'1\.2\.0 \(26\) is already in App Store Connect '
                                    r'\(processingState=VALID\)'):
            testflight.assert_unused(api, APP, '26', '1.2.0')

    def test_other_version_or_platform_does_not_block(self):
        api = FakeApi([build('a', '27', version='1.1.9'),
                       build('b', '27', platform='MAC_OS')])
        self.assertFalse(testflight.assert_unused(api, APP, '27', '1.2.0')['alreadyUploaded'])

    def test_wrong_app_is_refused_before_any_build_query(self):
        api = FakeApi(bundle_id='com.example.other')
        with self.assertRaisesRegex(ValueError, 'does not identify CrispMath'):
            testflight.assert_unused(api, APP, '27', '1.2.0')
        self.assertEqual(api.requests, [f'/v1/apps/{APP}'])


if __name__ == '__main__':
    unittest.main()
