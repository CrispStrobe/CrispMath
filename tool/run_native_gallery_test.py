"""Hosted controls for launch budgets and streamed failure evidence."""
from pathlib import Path
import sys
import tempfile
import unittest
from run_native_gallery import run_phase, capture


class NativeGalleryPhaseTest(unittest.TestCase):
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
