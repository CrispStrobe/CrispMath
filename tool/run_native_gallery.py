"""Bound simulator boot and verbose Flutter drive, retaining phase diagnostics.

Flutter drive's own test timeout starts after app launch. The outer process
budget also covers VM-service discovery, which previously stalled silently.
"""
import argparse
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import threading
import time


def run_phase(command, *, timeout, log, env=None):
    """Stream output and stop only this invocation's process group on timeout."""
    assert timeout > 0
    started = time.monotonic()
    print(f'BEGIN phase command={command[0]} budget={timeout}s',flush=True)
    process = subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                               env=env,start_new_session=True)
    def stream():
        with Path(log).open('wb') as handle:
            while True:
                chunk = os.read(process.stdout.fileno(),4096)
                if not chunk: break
                handle.write(chunk)
                handle.flush()
                print(chunk.decode('utf-8',errors='replace'),end='',flush=True)
    reader = threading.Thread(target=stream,daemon=True)
    reader.start()
    timed_out = False
    try:
        process.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        print(f'TIMEOUT after {timeout}s; terminating owned process group {process.pid}',flush=True)
        try: os.killpg(process.pid,signal.SIGTERM)
        except ProcessLookupError: pass
        try: process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            try: os.killpg(process.pid,signal.SIGKILL)
            except ProcessLookupError: pass
            process.wait(timeout=5)
    reader.join(timeout=5)
    if reader.is_alive():
        # A child can retain the pipe after any leader exit, including success.
        # Its session belongs to this invocation, so terminate that group too.
        try: os.killpg(process.pid,signal.SIGKILL)
        except ProcessLookupError: pass
        reader.join(timeout=5)
    result = {'command':command,'returnCode':process.returncode,'timedOut':timed_out,
              'elapsedSeconds':round(time.monotonic()-started,3),'budgetSeconds':timeout,
              'log':str(log)}
    print('END phase '+json.dumps(result),flush=True)
    return result


def capture(profile,simulator,output):
    assert profile in {'iphone','ipad'}
    assert re.fullmatch(r'[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}',simulator),simulator
    diagnostics=Path(output)/'diagnostics'/profile
    diagnostics.mkdir(parents=True,exist_ok=True)
    report={'source':os.environ.get('GITHUB_SHA'),'profile':profile,'simulator':simulator,
            'physicalDeviceTest':False,'passed':False,'phases':[]}
    def phase(name,command,budget,env=None):
        result=run_phase(command,timeout=budget,log=diagnostics/(name+'.log'),env=env)
        result['phase']=name
        report['phases'].append(result)
        (diagnostics/'phases.json').write_text(json.dumps(report,indent=2)+'\n')
        return result
    try:
        # Boot can return already-booted; readiness is determined independently.
        phase('boot-request',['xcrun','simctl','boot',simulator],30)
        readiness=phase('boot-readiness',['xcrun','simctl','bootstatus',simulator,'-b'],120)
        assert readiness['returnCode']==0 and not readiness['timedOut'],'Simulator boot readiness failed'
        status=phase('status-bar',['xcrun','simctl','status_bar',simulator,'override','--time','9:41',
                                  '--batteryState','charged','--batteryLevel','100','--wifiBars','3'],30)
        assert status['returnCode']==0 and not status['timedOut'],'Status bar setup failed'
        env=dict(os.environ,CRISPMATH_GALLERY_OUTPUT=str(Path(output)/profile))
        drive=phase('flutter-drive',['flutter','drive','--verbose',
                    '--driver=test_driver/product_gallery_driver.dart',
                    '--target=integration_test/product_gallery_test.dart','-d',simulator],900,env)
        assert drive['returnCode']==0 and not drive['timedOut'],'Native capture or VM discovery failed'
        report['passed']=True
    finally:
        if not report['passed']:
            phase('failure-devices',['xcrun','simctl','list','devices','--json'],15)
            phase('failure-screenshot',['xcrun','simctl','io',simulator,'screenshot',
                                        str(diagnostics/'failure.png')],15)
        phase('shutdown',['xcrun','simctl','shutdown',simulator],30)
        (diagnostics/'phases.json').write_text(json.dumps(report,indent=2)+'\n')
    return report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile',required=True,choices=['iphone','ipad'])
    parser.add_argument('--simulator',required=True)
    parser.add_argument('--output',default='native-gallery')
    args=parser.parse_args()
    capture(args.profile,args.simulator,args.output)
