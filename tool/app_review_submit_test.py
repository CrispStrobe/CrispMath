import unittest

from app_review_submit import EDITABLE, IN_FLIGHT, REVIEW_NOTES


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
