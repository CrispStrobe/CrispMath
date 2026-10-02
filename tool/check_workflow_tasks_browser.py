"""Run the same 50-task CLI corpus in the deployed app's real math worker."""
import argparse
import asyncio
import json
from pathlib import Path
from urllib.parse import urljoin
from playwright.async_api import Error as PlaywrightError, async_playwright


async def ready_worker_page(page, base_url):
    """Wait for the actual HTTP server, without waiting for the app UI to boot."""
    url = urljoin(base_url.rstrip('/') + '/', 'privacy.html')
    # CI starts its HTTP server in the background immediately before this
    # script. A successful HTTP response is the readiness condition; elapsed
    # startup time alone is not evidence that it is listening.
    for attempt in range(6):
        try:
            response = await page.context.request.get(url, timeout=3000)
        except PlaywrightError:
            if attempt == 5:
                raise
            await asyncio.sleep(0.5)
            continue
        assert response.ok, f'Audit bootstrap HTTP {response.status}: {url}'
        break
    response = await page.goto(url, wait_until='domcontentloaded', timeout=30000)
    assert response is not None and response.ok, f'Audit navigation failed: {url}'

async def check(args):
    tasks = json.loads(Path(args.tasks).read_text())['tasks']
    path = Path(args.output)
    path.parent.mkdir(parents=True, exist_ok=True)
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        page = await browser.new_page()
        phase = 'http-bootstrap'
        try:
            await ready_worker_page(page, args.url)
            phase = 'math-worker'
            result = await page.evaluate('''({url, tasks}) => new Promise((resolve, reject) => {
          const worker = new Worker(url);
          const timer = setTimeout(() => {worker.terminate(); reject(Error('Batch timed out'));}, 90000);
          worker.onerror = e => {clearTimeout(timer); worker.terminate(); reject(Error(e.message));};
          worker.onmessage = ({data}) => {
            clearTimeout(timer); worker.terminate();
            data.error ? reject(Error(data.error)) : resolve(data.result);
          };
          worker.postMessage({id: 1, type: 'workflowTasks', payload: {tasks}});
        })''', {'url': urljoin(args.url.rstrip('/') + '/', 'workflow_tasks_worker.js'), 'tasks': tasks})
        except Exception as error:
            path.write_text(json.dumps({
                'url': args.url, 'route': 'app-engine-diagnostic-worker',
                'phase': phase, 'error': str(error), 'passed': False,
                'resultsAvailable': False,
            }, indent=2) + '\n')
            raise
        finally:
            await browser.close()
        result['url'] = args.url
        result['route'] = 'app-engine-diagnostic-worker'
        path.write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps({k: v for k, v in result.items() if k != 'results'}, indent=2))
        for task in result['results']:
            if task['status'] != 'passed':
                print(task['id'], task['status'], task.get('error', task.get('actual')))
        assert result['schemaVersion'] == 2, 'Deployed audit runner is stale; result-form checks require version 2'
        assert result['nativeBridge'], 'WASM CAS unavailable'
        assert result['failed'] == 0 and result['unsupported'] == 0, 'See task report for gaps'

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--tasks', default='test/fixtures/workflow_tasks.json')
    parser.add_argument('--output', default='browser-results/workflow-tasks.json')
    parser.add_argument('--chromium')
    asyncio.run(check(parser.parse_args()))
