"""Release publication must have live UI proof for the same app bytes."""
import copy
import unittest

from wait_release_validation import REPOSITORY, WORKFLOW, ValidationError, wait_for_validation

VALIDATED = 'a' * 40
PACKAGED = 'b' * 40
BLOB = 'c' * 40


def run():
    return {'id': 42, 'name': 'Feature validation', 'path': WORKFLOW,
            'repository': {'full_name': REPOSITORY},
            'head_repository': {'full_name': REPOSITORY},
            'head_sha': VALIDATED, 'status': 'completed', 'conclusion': 'success'}


def tree():
    return {'truncated': False, 'tree': [
        {'path': path, 'type': 'blob', 'mode': '100644', 'sha': BLOB}
        for path in ('lib/main.dart', 'pubspec.yaml', 'pubspec.lock',
                     'ios/Runner/Info.plist', 'assets/model.onnx',
                     'tool/stage_ocr_runtime.py', 'tool/ocr_runtime_checksums.json',
                     'tool/dependency_lock.json')]}


class FakeAPI:
    def __init__(self):
        self.run = run()
        self.runs = []
        self.jobs = [{'id': i, 'name': name, 'status': 'completed', 'conclusion': 'success'}
                     for i, name in enumerate(('browser', 'gallery'))]
        self.validated = tree()
        self.packaged = tree()
        self.calls = []
        self.pages = None

    def __call__(self, path):
        self.calls.append(path)
        if '/jobs?' in path:
            page = int(path.rsplit('=', 1)[1])
            entries = self.pages[page - 1] if self.pages else self.jobs
            return {'total_count': len(self.jobs), 'jobs': entries}
        if '/actions/runs/' in path:
            return self.runs.pop(0) if self.runs else self.run
        return self.validated if VALIDATED in path else self.packaged


class ReleaseValidationTest(unittest.TestCase):
    def setUp(self):
        self.api = FakeAPI()

    def check(self, **kwargs):
        return wait_for_validation(self.api, '42', PACKAGED, **kwargs)

    def test_success_records_sources_jobs_and_fingerprint(self):
        evidence = self.check()
        self.assertTrue(evidence['passed'])
        self.assertEqual(evidence['validationSource'], VALIDATED)
        self.assertEqual(evidence['packageSource'], PACKAGED)
        self.assertEqual(set(evidence['requiredJobs']), {'browser', 'gallery'})
        self.assertEqual(len(evidence['productionTreeSha256']), 64)

    def test_wrong_repository_workflow_or_run_is_rejected(self):
        for field, value in [('repository', {'full_name': 'other/repo'}),
                             ('head_repository', {'full_name': 'fork/repo'}),
                             ('path', '.github/workflows/checks-only.yml'),
                             ('name', 'Different workflow'), ('id', 43)]:
            with self.subTest(field=field):
                self.api.run = run()
                self.api.run[field] = value
                with self.assertRaises(ValidationError):
                    self.check()

    def test_invalid_run_ids_and_source_shas_are_rejected(self):
        for value in ('', '0', '-42', '42/other', ' 42', '４２'):
            with self.subTest(run_id=value), self.assertRaises(ValidationError):
                wait_for_validation(self.api, value, PACKAGED)
        for value in ('short', 'z' * 40, 'a' * 39, 'A' * 40):
            with self.subTest(sha=value), self.assertRaises(ValidationError):
                wait_for_validation(self.api, '42', value)
        self.api.run['head_sha'] = 'abc'
        with self.assertRaises(ValidationError):
            self.check()

    def test_completed_failure_cannot_publish(self):
        for conclusion in ('failure', 'cancelled', 'skipped', 'neutral', None):
            self.api.run['conclusion'] = conclusion
            with self.subTest(conclusion=conclusion), self.assertRaises(ValidationError):
                self.check()

    def test_checks_only_run_cannot_replace_browser_and_gallery(self):
        for missing in ('browser', 'gallery'):
            original = copy.deepcopy(self.api.jobs)
            self.api.jobs = [job for job in original if job['name'] != missing]
            with self.subTest(missing=missing), self.assertRaises(ValidationError):
                self.check()
            self.api.jobs = original
        for name in ('browser', 'gallery'):
            for conclusion in ('skipped', 'failure', None):
                self.api.jobs = FakeAPI().jobs
                next(job for job in self.api.jobs if job['name'] == name)['conclusion'] = conclusion
                with self.subTest(name=name, conclusion=conclusion), self.assertRaises(ValidationError):
                    self.check()

    def test_job_pagination_is_followed(self):
        self.api.pages = [[self.api.jobs[0]], [self.api.jobs[1]]]
        self.assertTrue(self.check()['passed'])
        self.assertTrue(any('page=2' in path for path in self.api.calls))

    def test_waits_for_completion_and_has_bounded_timeout(self):
        pending = run()
        pending.update(status='in_progress', conclusion=None)
        self.api.runs = [pending]
        sleeps = []
        self.assertTrue(self.check(clock=lambda: 0, sleep=sleeps.append)['passed'])
        self.assertEqual(sleeps, [30])
        self.api.run = pending
        times = iter((0, 0, 30))
        with self.assertRaisesRegex(ValidationError, 'Timed out'):
            self.check(timeout=30, clock=lambda: next(times), sleep=lambda _: None)
        with self.assertRaises(ValidationError):
            self.check(timeout=1801)

    def test_runtime_changes_additions_and_deletions_block_release(self):
        for path in ('lib/main.dart', 'pubspec.lock', 'ios/Runner/Info.plist',
                     'assets/model.onnx', 'tool/stage_ocr_runtime.py',
                     'tool/ocr_runtime_checksums.json'):
            self.api.packaged = tree()
            next(entry for entry in self.api.packaged['tree'] if entry['path'] == path)['sha'] = 'd' * 40
            with self.subTest(path=path), self.assertRaisesRegex(ValidationError, 'source differs'):
                self.check()
        self.api.packaged = tree()
        self.api.packaged['tree'].append({'path': 'new_runtime/data.bin', 'type': 'blob', 'mode': '100644', 'sha': BLOB})
        with self.assertRaises(ValidationError):
            self.check()
        self.api.packaged = tree()
        self.api.packaged['tree'].pop()
        with self.assertRaises(ValidationError):
            self.check()

    def test_dependency_lock_pin_change_blocks_even_with_green_browser(self):
        # A packaging pin can change native shipped code without lib/ changing.
        lock = next(entry for entry in self.api.packaged['tree']
                    if entry['path'] == 'tool/dependency_lock.json')
        lock['sha'] = 'e' * 40
        with self.assertRaisesRegex(ValidationError, 'tool/dependency_lock.json'):
            self.check()

    def test_ci_docs_and_test_only_changes_allow_same_app(self):
        for path in ('.github/workflows/ios-release.yml', 'docs/evidence.md',
                     'test/math_test.dart', 'integration_test/gallery.dart',
                     'tool/wait_release_validation.py', 'tool/check_mobile_trace.py'):
            self.api.packaged['tree'].append({'path': path, 'type': 'blob', 'mode': '100644', 'sha': 'd' * 40})
        self.assertTrue(self.check()['passed'])

    def test_truncated_or_incomplete_source_tree_is_rejected(self):
        self.api.packaged['truncated'] = True
        with self.assertRaises(ValidationError):
            self.check()
        self.api.packaged = {'truncated': False, 'tree': []}
        with self.assertRaises(ValidationError):
            self.check()


if __name__ == '__main__':
    unittest.main()
