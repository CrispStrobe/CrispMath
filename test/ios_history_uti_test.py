"""Validate the iOS document type used by file_picker's extension lookup."""

import pathlib
import plistlib
import unittest


class HistoryUtiTest(unittest.TestCase):
    def test_history_extension_has_exported_json_uti(self):
        plist_path = pathlib.Path(__file__).resolve().parents[1] / 'ios/Runner/Info.plist'
        with plist_path.open('rb') as source:
            info = plistlib.load(source)
        uti = 'com.crispstrobe.crispmath.calculator-history'
        declarations = [
            item for item in info['UTExportedTypeDeclarations']
            if item['UTTypeIdentifier'] == uti
        ]
        self.assertEqual(len(declarations), 1)
        declaration = declarations[0]
        self.assertIn('public.json', declaration['UTTypeConformsTo'])
        self.assertIn('crisphistory', declaration['UTTypeTagSpecification']['public.filename-extension'])
        # Direct document opening currently routes files to the worksheet flow;
        # declaring a history handler would falsely advertise that it can open it.
        for item in info['CFBundleDocumentTypes']:
            self.assertNotIn(uti, item.get('LSItemContentTypes', []))


if __name__ == '__main__':
    unittest.main()
