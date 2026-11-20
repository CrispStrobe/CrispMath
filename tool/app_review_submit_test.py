import unittest

from app_review_submit import EDITABLE, IN_FLIGHT, REVIEW_NOTES, resubmit_submission

VERSION = 'b102da1f-ea3c-4e75-84cf-9e54a21fad3b'


def submission(identifier, state, versions):
    return {'id': identifier, 'state': state,
            'items': [{'appStoreVersion': v} for v in versions]}


class ResubmitSubmissionTest(unittest.TestCase):
    def test_rejected_version_reuses_its_own_submission(self):
        submissions = [submission('old', 'COMPLETE', [VERSION]),
                       submission('rejected', 'UNRESOLVED_ISSUES', [VERSION]),
                       submission('draft', 'READY_FOR_REVIEW', [])]
        self.assertEqual(resubmit_submission(submissions, VERSION), 'rejected')

    def test_other_versions_and_states_are_ignored(self):
        submissions = [submission('other', 'UNRESOLVED_ISSUES', ['someone-else']),
                       submission('draft', 'READY_FOR_REVIEW', [VERSION])]
        self.assertIsNone(resubmit_submission(submissions, VERSION))

    def test_first_submission_has_nothing_to_reuse(self):
        self.assertIsNone(resubmit_submission([], VERSION))


class ReviewNotesTest(unittest.TestCase):
    def test_notes_fit_the_field(self):
        self.assertLess(len(REVIEW_NOTES), 4000)

    def test_notes_drop_unadvertised_recognition(self):
        self.assertNotIn('handwrit', REVIEW_NOTES.lower())
        self.assertIn('https://github.com/CrispStrobe/CrispMath', REVIEW_NOTES)

    def test_states_do_not_overlap(self):
        self.assertFalse(EDITABLE & IN_FLIGHT)


if __name__ == '__main__':
    unittest.main()


class WhatsNewTest(unittest.TestCase):
    def test_every_locale_fits_and_falls_back_to_english(self):
        from app_review_submit import WHATS_NEW, whats_new
        for text in WHATS_NEW.values():
            self.assertLess(len(text), 4000)
        self.assertTrue(whats_new('de-DE').startswith(WHATS_NEW['de']))
        self.assertTrue(whats_new('it').startswith(WHATS_NEW['en']))
        for locale in ['en-US', 'de-DE', 'fr-FR', 'es-ES']:
            self.assertLess(len(whats_new(locale)), 4000)


class PlatformNotesTest(unittest.TestCase):
    def test_mac_notes_replace_the_ios_update_intro(self):
        from app_review_submit import review_notes
        self.assertEqual(review_notes('IOS'), REVIEW_NOTES)
        mac = review_notes('MAC_OS')
        self.assertIn('first macOS release', mac)
        self.assertNotIn('update to the approved 1.2.0', mac)
        self.assertIn('https://github.com/CrispStrobe/CrispMath', mac)
        self.assertLess(len(mac), 4000)
