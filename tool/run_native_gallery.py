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
import socket
import subprocess
import threading
import time
import urllib.request


VM_READY = ('Dart VM service is listening', 'Connecting to VM Service',
            'Connected to VM Service', 'VM Service URL', 'Observatory listening')


def pre_vm_discovery_failure(text):
    return ('Waiting for VM Service port to be available' in text
            and not any(marker.lower() in text.lower() for marker in VM_READY)
            and not re.search(r'\d\d:\d\d\s+\+\d|EXCEPTION CAUGHT|Some tests failed|\[E\]', text))


def allow_discovery_recovery(number, drive, health, text):
    return (number == 1 and drive.get('discoveryTimedOut') is True
            and pre_vm_discovery_failure(text) and health.get('alive') is True
            and not health.get('crashReports'))


def run_phase(command, *, timeout, log, env=None, discovery_timeout=None,
              before_discovery_stop=None):
    """Stream output and stop only this invocation's process group on timeout."""
    assert timeout > 0
    started = time.monotonic()
    print(f'BEGIN phase command={command[0]} budget={timeout}s',flush=True)
    process = subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,
                               env=env,start_new_session=True)
    discovery_started = None
    vm_ready = False
    recent = ''
    def stream():
        nonlocal discovery_started, vm_ready, recent
        with Path(log).open('wb') as handle:
            while True:
                chunk = os.read(process.stdout.fileno(),4096)
                if not chunk: break
                handle.write(chunk)
                handle.flush()
                recent = (recent + chunk.decode('utf-8',errors='replace'))[-8192:]
                if 'Waiting for VM Service port to be available' in recent and discovery_started is None:
                    discovery_started = time.monotonic()
                if any(marker.lower() in recent.lower() for marker in VM_READY):
                    vm_ready = True
                print(chunk.decode('utf-8',errors='replace'),end='',flush=True)
    reader = threading.Thread(target=stream,daemon=True)
    reader.start()
    timed_out = False
    discovery_timed_out = False
    try:
        while process.poll() is None:
            if discovery_timeout and discovery_started and not vm_ready and time.monotonic()-discovery_started >= discovery_timeout:
                discovery_timed_out = True
                if before_discovery_stop:
                    before_discovery_stop()
                raise subprocess.TimeoutExpired(command,discovery_timeout)
            remaining = timeout-(time.monotonic()-started)
            if remaining <= 0:
                raise subprocess.TimeoutExpired(command,timeout)
            try:
                process.wait(timeout=min(.2,remaining))
            except subprocess.TimeoutExpired:
                pass
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
    result.update(discoveryTimedOut=discovery_timed_out, vmServiceObserved=vm_ready,
                  discoveryBudgetSeconds=discovery_timeout)
    print('END phase '+json.dumps(result),flush=True)
    return result


def capture(profile,simulator,output):
    assert profile in {'iphone','ipad'}
    assert re.fullmatch(r'[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}',simulator),simulator
    diagnostics=Path(output)/'diagnostics'/profile
    diagnostics.mkdir(parents=True,exist_ok=True)
    report={'source':os.environ.get('GITHUB_SHA'),'profile':profile,'templateSimulator':simulator,
            'physicalDeviceTest':False,'passed':False,'phases':[], 'attempts':[]}
    def phase(name,command,budget,env=None,**options):
        result=run_phase(command,timeout=budget,log=diagnostics/(name+'.log'),env=env,**options)
        result['phase']=name
        report['phases'].append(result)
        (diagnostics/'phases.json').write_text(json.dumps(report,indent=2)+'\n')
        return result
    owned = []
    try:
      for attempt_number in [1,2]:
        prefix = f'attempt-{attempt_number}-'
        clone=phase(prefix+'create',['xcrun','simctl','clone',simulator,
            f'CrispMath-{profile}-{os.environ.get("GITHUB_RUN_ID","ci")}-{attempt_number}'],45)
        assert clone['returnCode']==0 and not clone['timedOut'],'Fresh simulator clone failed'
        ids=re.findall(r'(?m)^([0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12})\s*$',Path(clone['log']).read_text())
        assert len(ids)==1,'Expected exactly one newly owned simulator UUID'
        device=ids[0]; owned.append(device)
        attempt={'number':attempt_number,'simulator':device,'health':{},'reason':'initial fresh simulator' if attempt_number==1 else 'one bounded pre-VM discovery recovery'}
        report['attempts'].append(attempt)
        # Boot can return already-booted; readiness is determined independently.
        phase(prefix+'boot-request',['xcrun','simctl','boot',device],30)
        readiness=phase(prefix+'boot-readiness',['xcrun','simctl','bootstatus',device,'-b'],120)
        assert readiness['returnCode']==0 and not readiness['timedOut'],'Simulator boot readiness failed'
        status=phase(prefix+'status-bar',['xcrun','simctl','status_bar',device,'override','--time','9:41',
                                  '--batteryState','charged','--batteryLevel','100','--wifiBars','3'],30)
        assert status['returnCode']==0 and not status['timedOut'],'Status bar setup failed'
        with socket.socket() as candidate:
            candidate.bind(('127.0.0.1',0))
            port=candidate.getsockname()[1]
        attempt['debugLoopbackPort']=port
        def diagnose():
            health=phase(prefix+'process-health',['xcrun','simctl','spawn',device,'launchctl','list'],15)
            text=Path(health['log']).read_text()
            attempt['health']['appProcesses']=[line for line in text.splitlines() if 'com.crispstrobe.crispmath' in line]
            attempt['health']['alive']=any(re.match(r'^\s*[1-9]\d*\s',line) for line in attempt['health']['appProcesses'])
            attempt['health']['pids']=[int(line.split()[0]) for line in attempt['health']['appProcesses'] if re.match(r'^\s*[1-9]\d*\s',line)]
            for pid in attempt['health']['pids']:
                phase(prefix+'sockets-'+str(pid),['lsof','-nP','-a','-p',str(pid),'-iTCP','-sTCP:LISTEN'],10)
            try:
                with urllib.request.urlopen(f'http://127.0.0.1:{port}/getVM',timeout=3) as response:
                    vm=json.loads(response.read(262144))
                result=vm.get('result',vm)
                attempt['health']['vm']={'healthy':result.get('type')=='VM' and isinstance(result.get('isolates'),list),'response':vm}
            except Exception as error:
                attempt['health']['vm']={'healthy':False,'error':type(error).__name__}
            phase(prefix+'system-log',['xcrun','simctl','spawn',device,'log','show','--last','3m','--style','compact',
                '--predicate','process == "Runner"'],20)
            phase(prefix+'failure-screenshot',['xcrun','simctl','io',device,'screenshot',str(diagnostics/(prefix+'failure.png'))],15)
            crashes=Path.home()/'Library/Developer/CoreSimulator/Devices'/device/'data/Library/Logs/CrashReporter'
            attempt['health']['crashReports']=[path.name for path in crashes.glob('Runner*') if path.is_file()]
            for path in list(crashes.glob('Runner*'))[:5]:
                if path.is_file() and path.stat().st_size <= 1_000_000:
                    (diagnostics/(prefix+path.name)).write_bytes(path.read_bytes())
        env=dict(os.environ,CRISPMATH_GALLERY_OUTPUT=str(Path(output)/profile))
        drive=phase(prefix+'flutter-drive',['flutter','drive','--verbose',
                    '--no-dds','--disable-service-auth-codes',f'--host-vmservice-port={port}',
                    '--driver=test_driver/product_gallery_driver.dart',
                    '--target=integration_test/product_gallery_test.dart','-d',device],900,env,
                    discovery_timeout=120,before_discovery_stop=diagnose)
        attempt['drive']=drive
        if drive['returnCode']==0 and not drive['timedOut']:
            report.update(passed=True,simulator=device)
            manifest_path=Path(output)/'manifest.json'
            manifest=json.loads(manifest_path.read_text())
            manifest[profile+'Capture']={'simulator':device,'templateSimulator':simulator,'attempt':attempt_number,
                'source':report['source'],'freshSimulator':True,'physicalDeviceTest':False}
            manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
            break
        if not drive['discoveryTimedOut']:
            diagnose()
        text=Path(drive['log']).read_text()
        attempt['recoveryAllowed']=allow_discovery_recovery(attempt_number,drive,attempt['health'],text)
        phase(prefix+'terminate-owned-app',['xcrun','simctl','terminate',device,'com.crispstrobe.crispmath'],15)
        phase(prefix+'shutdown',['xcrun','simctl','shutdown',device],30)
        assert attempt['recoveryAllowed'],'Native capture failed; no app-assertion or crash recovery is allowed'
      assert report['passed'],'Native gallery did not complete'
    finally:
        for device in owned:
            phase('cleanup-'+device,['xcrun','simctl','shutdown',device],30)
            phase('delete-'+device,['xcrun','simctl','delete',device],30)
        (diagnostics/'phases.json').write_text(json.dumps(report,indent=2)+'\n')
    return report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile',required=True,choices=['iphone','ipad'])
    parser.add_argument('--simulator',required=True)
    parser.add_argument('--output',default='native-gallery')
    args=parser.parse_args()
    capture(args.profile,args.simulator,args.output)
