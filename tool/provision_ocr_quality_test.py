import unittest
from provision_ocr_quality import parse_ink, normalize_strokes, verified_archive
from pathlib import Path
import tempfile


class OcrCorpusTest(unittest.TestCase):
    def test_ink_metadata_and_spatial_coordinates_preserve_ground_truth(self):
        annotations, strokes = parse_ink(b'''<ink xmlns="http://www.w3.org/2003/InkML">
          <annotation type="normalizedLabel">x+1</annotation>
          <trace>10 20 0, 30 40 5</trace><trace>50 60 6</trace></ink>''')
        self.assertEqual(annotations['normalizedLabel'], 'x+1')
        self.assertEqual(strokes, [[(10., 20.), (30., 40.)], [(50., 60.)]])

    def test_normalization_is_translation_invariant_and_bounds_every_point(self):
        first, size = normalize_strokes([[(10, 20), (30, 40)]])
        shifted, other_size = normalize_strokes([[(100, 200), (120, 220)]])
        self.assertEqual((first, size), (shifted, other_size))
        for x, y in first[0]:
            self.assertTrue(0 <= x < size[0] and 0 <= y < size[1])

    def test_degenerate_strokes_are_bounded_and_empty_or_nonfinite_inks_fail(self):
        points, size = normalize_strokes([[(1, 1), (1000000, 1)]])
        self.assertLessEqual(size[0], 1624)
        self.assertGreater(size[1], 0)
        for xml in [b'<ink/>', b'<ink><trace>nan 1</trace></ink>', b'<ink><trace>1</trace></ink>']:
            with self.subTest(xml=xml), self.assertRaises(ValueError):
                parse_ink(xml)

    def test_archive_hash_is_checked_before_extracting_any_dataset_content(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory)/'bad.tgz'
            archive.write_bytes(b'not the official dataset')
            with self.assertRaisesRegex(ValueError, 'checksum'):
                verified_archive(archive)


if __name__ == '__main__':
    unittest.main()
