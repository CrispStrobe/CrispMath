from pathlib import Path
import plistlib
import unittest
from validate_ios_privacy import validate


class IosPrivacyTests(unittest.TestCase):
    def fixture(self):
        return {'NSPhotoLibraryUsageDescription': 'Import photos of formulas.',
                'NSCameraUsageDescription': 'Photograph formulas for recognition.',
                'CFBundleShortVersionString': '1.2.0', 'CFBundleVersion': '13'}

    def test_source_plist_explains_both_actual_image_entry_paths(self):
        with Path('ios/Runner/Info.plist').open('rb') as file:
            purposes = validate(plistlib.load(file))
        for value in purposes.values():
            self.assertIn('mathematical formulas', value)
            self.assertIn('calculator or worksheets', value)

    def test_missing_photo_purpose_reproduces_itms_90683(self):
        info = self.fixture()
        del info['NSPhotoLibraryUsageDescription']
        with self.assertRaisesRegex(ValueError, 'NSPhotoLibraryUsageDescription'):
            validate(info)

    def test_empty_or_unresolved_camera_purpose_is_rejected(self):
        for purpose in ['', '   ', '$(CAMERA_PURPOSE)', None]:
            info = self.fixture()
            info['NSCameraUsageDescription'] = purpose
            with self.assertRaisesRegex(ValueError, 'NSCameraUsageDescription'):
                validate(info)

    def test_packaged_version_and_build_must_match_delivery(self):
        validate(self.fixture(), '1.2.0', '13')
        for version, build in [('1.0.3', '13'), ('1.2.0', '12')]:
            with self.assertRaisesRegex(ValueError, 'differs from the intended delivery'):
                validate(self.fixture(), version, build)
