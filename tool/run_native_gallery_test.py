"""Hosted controls for launch budgets and streamed failure evidence."""
from pathlib import Path
import sys
import tempfile
import unittest
from run_native_gallery import run_phase, capture, pre_vm_discovery_failure, allow_discovery_recovery
from verify_native_gallery import verify_connected_worksheet


class ConnectedGalleryEvidenceTest(unittest.TestCase):
    def document(self):
        return {'l': [{'s': 'a=3', 'r': '3'},
                      {'s': 'f(x)=x^2+a', 'r': 'x^2+(3)'},
                      {'s': 'f(4)', 'r': '19', 'evidence': {'accuracy': 'exact'}}]}

    def test_actual_three_row_guide_is_accepted(self):
        verify_connected_worksheet(self.document())

    def test_wrong_source_or_missing_row_is_rejected(self):
        for kind in ['source', 'missing']:
            with self.subTest(kind=kind):
                document = self.document()
                if kind == 'source':
                    document['l'][0]['s'] = 'a=5'
                else:
                    document['l'].pop()
                with self.assertRaises(AssertionError):
                    verify_connected_worksheet(document)

    def test_wrong_result_error_or_inexact_evidence_is_rejected(self):
        for key, value in [('r', '21'), ('e', 'Evaluation failed'),
                           ('evidence', {'accuracy': 'approximate'})]:
            with self.subTest(key=key):
                document = self.document()
                document['l'][2][key] = value
                with self.assertRaises(AssertionError):
                    verify_connected_worksheet(document)

    def test_function_variable_loss_is_rejected(self):
        document = self.document()
        document['l'][1]['r'] = '3'
        with self.assertRaises(AssertionError):
            verify_connected_worksheet(document)


class NativeGalleryPhaseTest(unittest.TestCase):
    def test_missing_vm_discovery_is_bounded_and_collects_health_before_stop(self):
        diagnostics=[]
        with tempfile.TemporaryDirectory() as directory:
            result=run_phase([sys.executable,'-c','import time; print("Waiting for VM Service port to be available...",flush=True); time.sleep(30)'],
                timeout=5,log=Path(directory)/'discovery.log',discovery_timeout=.2,
                before_discovery_stop=lambda:diagnostics.append('health before stop'))
            self.assertTrue(result['discoveryTimedOut'])
            self.assertEqual(diagnostics,['health before stop'])
            self.assertLess(result['elapsedSeconds'],4)

    def test_observed_vm_disables_only_discovery_watchdog(self):
        with tempfile.TemporaryDirectory() as directory:
            result=run_phase([sys.executable,'-c','import time; print("Waiting for VM Service port to be available...\\nConnecting to VM Service",flush=True); time.sleep(.3)'],
                timeout=5,log=Path(directory)/'ready.log',discovery_timeout=.1)
            self.assertTrue(result['vmServiceObserved'])
            self.assertFalse(result['timedOut'])

    def test_recovery_requires_first_pre_vm_attempt_alive_without_crash_or_assertion(self):
        waiting='Waiting for VM Service port to be available...'
        self.assertTrue(allow_discovery_recovery(1,{'discoveryTimedOut':True},{'alive':True,'crashReports':[]},waiting))
        self.assertFalse(allow_discovery_recovery(2,{'discoveryTimedOut':True},{'alive':True},waiting))
        for health in [{'alive':False},{'alive':True,'crashReports':['Runner.ips']}]:
            self.assertFalse(allow_discovery_recovery(1,{'discoveryTimedOut':True},health,waiting))
        for progress in ['Connecting to VM Service','00:00 +0: actual test','EXCEPTION CAUGHT','Some tests failed','[E]']:
            self.assertFalse(pre_vm_discovery_failure(waiting+'\n'+progress))

    def test_streamed_output_and_success(self):
        with tempfile.TemporaryDirectory() as directory:
            log=Path(directory)/'output.log'
            result=run_phase([sys.executable,'-c','print("VM service and test progress",flush=True)'],timeout=5,log=log)
            self.assertEqual(result['returnCode'],0)
            self.assertFalse(result['timedOut'])
            self.assertIn('VM service and test progress',log.read_text())

    def test_failure_code_and_diagnostics_are_retained(self):
        with tempfile.TemporaryDirectory() as directory:
            log=Path(directory)/'failure.log'
            result=run_phase([sys.executable,'-c','import sys; print("launch failed",flush=True); sys.exit(7)'],timeout=5,log=log)
            self.assertEqual(result['returnCode'],7)
            self.assertFalse(result['timedOut'])
            self.assertIn('launch failed',log.read_text())

    def test_pre_vm_stall_has_outer_budget(self):
        with tempfile.TemporaryDirectory() as directory:
            log=Path(directory)/'timeout.log'
            result=run_phase([sys.executable,'-c','import time; print("before VM discovery",flush=True); time.sleep(30)'],timeout=.3,log=log)
            self.assertTrue(result['timedOut'])
            self.assertNotEqual(result['returnCode'],0)
            self.assertLess(result['elapsedSeconds'],10)
            self.assertIn('before VM discovery',log.read_text())

    def test_timeout_also_closes_pipe_held_by_owned_descendant(self):
        with tempfile.TemporaryDirectory() as directory:
            log=Path(directory)/'descendant.log'
            child='import signal,time; signal.signal(signal.SIGTERM,signal.SIG_IGN); print("child ready",flush=True); time.sleep(30)'
            parent='import subprocess,sys,time; subprocess.Popen([sys.executable,"-c",'+repr(child)+']); time.sleep(30)'
            result=run_phase([sys.executable,'-c',parent],timeout=.5,log=log)
            self.assertTrue(result['timedOut'])
            self.assertLess(result['elapsedSeconds'],12)
            self.assertIn('child ready',log.read_text())

    def test_early_exit_also_closes_owned_descendant_pipe(self):
        with tempfile.TemporaryDirectory() as directory:
            log=Path(directory)/'early-exit.log'
            child='import time; print("retained child pipe",flush=True); time.sleep(30)'
            parent='import subprocess,sys,time; subprocess.Popen([sys.executable,"-c",'+repr(child)+']); time.sleep(.1); sys.exit(7)'
            result=run_phase([sys.executable,'-c',parent],timeout=5,log=log)
            self.assertFalse(result['timedOut'])
            self.assertEqual(result['returnCode'],7)
            self.assertLess(result['elapsedSeconds'],12)
            self.assertIn('retained child pipe',log.read_text())

    def test_invalid_device_rejected_before_command(self):
        with self.assertRaises(AssertionError):capture('iphone','--bad-device','unused')


if __name__=='__main__':unittest.main()
