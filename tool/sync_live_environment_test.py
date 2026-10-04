import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest

from sync_contract.export_live_environment import export


class DisposableSyncEnvironmentTest(unittest.TestCase):
    def run_export(self, status):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'status.json'
            output = Path(directory) / 'environment'
            source.write_text(json.dumps(status))
            with contextlib.redirect_stdout(io.StringIO()) as captured:
                export(source, output)
            return output.read_text(), captured.getvalue()

    def test_exports_only_required_loopback_fields_and_masks_keys(self):
        environment, log = self.run_export({
            'API_URL': 'http://127.0.0.1:54321', 'ANON_KEY': 'fixture-public',
            'SERVICE_ROLE_KEY': 'fixture-admin', 'DB_URL': 'fixture-database-secret',
        })
        self.assertIn('CRISPMATH_SYNC_PUBLIC_KEY=fixture-public\n', environment)
        self.assertIn('CRISPMATH_SYNC_FIXTURE_ADMIN_KEY=fixture-admin\n', environment)
        self.assertIn('CRISPMATH_SYNC_LIVE=disposable\n', environment)
        self.assertNotIn('fixture-database-secret', environment)
        self.assertIn('::add-mask::fixture-admin\n', log)
        self.assertIn('::add-mask::fixture-database-secret\n', log)

    def test_accepts_current_publishable_and_secret_local_stack_fields(self):
        environment, _ = self.run_export({
            'API_URL': 'http://localhost:54321',
            'PUBLISHABLE_KEY': 'fixture-publishable', 'SECRET_KEY': 'fixture-secret',
        })
        self.assertIn('CRISPMATH_SYNC_PUBLIC_KEY=fixture-publishable\n', environment)
        self.assertIn('CRISPMATH_SYNC_FIXTURE_ADMIN_KEY=fixture-secret\n', environment)

    def test_rejects_production_urls_and_invalid_fields_without_partial_export(self):
        invalid = [
            {'API_URL': 'https://project.supabase.co'},
            {'API_URL': 'http://localhost.example:54321'},
            {'API_URL': 'http://user:password@localhost:54321'},
            {'API_URL': 'http://localhost:54321?key=secret'},
            {'API_URL': 'http://localhost:54321/rest/v1'},
            {'SERVICE_ROLE_KEY': None},
            {'ANON_KEY': 'fixture\nINJECTED=secret'},
        ]
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'status.json'
            output = Path(directory) / 'environment'
            for changed in invalid:
                with self.subTest(changed=changed):
                    source.write_text(json.dumps({
                        'API_URL': 'http://localhost:54321',
                        'ANON_KEY': 'fixture-public', 'SERVICE_ROLE_KEY': 'fixture-admin',
                        **changed,
                    }))
                    with self.assertRaises(ValueError):
                        export(source, output)
                    self.assertFalse(output.exists())


if __name__ == '__main__':
    unittest.main()
