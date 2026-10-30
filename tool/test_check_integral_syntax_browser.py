"""Small unit checks for the hosted integral browser diagnostic collector."""
import importlib.util
import json
from pathlib import Path
import sys
import types
import unittest
from unittest.mock import patch


def load_checker():
    playwright = types.ModuleType('playwright')
    playwright_api = types.ModuleType('playwright.async_api')
    setattr(playwright_api, 'async_playwright', None)
    setattr(playwright_api, 'expect', None)
    benchmark = types.ModuleType('benchmark_workflows')
    for name in ('bootstrap', 'context_for', 'next_frames'):
        setattr(benchmark, name, None)
    statistics = types.ModuleType('check_round6_statistics_browser')
    setattr(statistics, 'real_click', None)
    spec = importlib.util.spec_from_file_location(
        'integral_checker', Path(__file__).with_name('check_integral_syntax_browser.py'))
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    with patch.dict(sys.modules, {'playwright': playwright,
                                 'playwright.async_api': playwright_api,
                                 'benchmark_workflows': benchmark,
                                 'check_round6_statistics_browser': statistics}):
        spec.loader.exec_module(module)
    return module


checker = load_checker()


class IntegralDiagnosticsTest(unittest.TestCase):
    def test_opt_in_url_preserves_query_and_fragment(self):
        self.assertEqual(
            checker.diagnostic_url('https://example.test/app?x=2&crispInputTrace=0#/route'),
            'https://example.test/app?x=2&crispInputTrace=1#/route')

    def test_collector_filters_validates_and_bounds_events(self):
        report = {'flutterTrace': [], 'flutterTraceMalformed': 0,
                  'flutterTraceDropped': 0}
        checker.collect_trace('other console message', report)
        checker.collect_trace(checker.TRACE_PREFIX + 'not json', report)
        checker.collect_trace(checker.TRACE_PREFIX + '[]', report)
        event = {'stage': 'editor-submitted', 'editorIsTarget': True}
        for _ in range(checker.TRACE_LIMIT + 1):
            checker.collect_trace(checker.TRACE_PREFIX + json.dumps(event), report)
        self.assertEqual(len(report['flutterTrace']), checker.TRACE_LIMIT)
        self.assertEqual(report['flutterTrace'][0], event)
        self.assertEqual(report['flutterTraceMalformed'], 2)
        self.assertEqual(report['flutterTraceDropped'], 1)


class EditorSnapshotTest(unittest.IsolatedAsyncioTestCase):
    async def test_snapshot_records_trace_boundary_and_node_state(self):
        class Editor:
            async def evaluate(self, script):
                if 'isConnected' not in script:
                    raise AssertionError('missing connectivity check')
                return {'value': '2+2', 'nodeId': 1, 'connected': True}

        report = {'flutterTrace': [{'stage': 'editor-to-math'}], 'editorStates': []}
        await checker.editor_state(Editor(), 'before Enter', report)
        self.assertEqual(report['editorStates'], [{
            'value': '2+2', 'nodeId': 1, 'connected': True,
            'stage': 'before Enter', 'traceCount': 1}])


if __name__ == '__main__':
    unittest.main()
