"""Run the same 50-task CLI corpus in the deployed app's real math worker."""
import argparse
import asyncio
import json
from pathlib import Path
from urllib.parse import urljoin
from playwright.async_api import async_playwright

async def check(args):
    tasks = json.loads(Path(args.tasks).read_text())['tasks']
    async with async_playwright() as p:
        options = {'args': ['--no-sandbox']}
        if args.chromium:
            options['executable_path'] = args.chromium
        browser = await p.chromium.launch(**options)
        page = await browser.new_page()
        await page.goto(urljoin(args.url, 'privacy.html'))
        result = await page.evaluate('''({url, tasks}) => new Promise((resolve, reject) => {
          const worker = new Worker(url);
          const timer = setTimeout(() => {worker.terminate(); reject(Error('Batch timed out'));}, 90000);
          worker.onerror = e => {clearTimeout(timer); worker.terminate(); reject(Error(e.message));};
          worker.onmessage = ({data}) => {
            clearTimeout(timer); worker.terminate();
            data.error ? reject(Error(data.error)) : resolve(data.result);
          };
          worker.postMessage({id: 1, type: 'workflowTasks', payload: {tasks}});
        })''', {'url': urljoin(args.url, 'workflow_tasks_worker.js'), 'tasks': tasks})
        result['url'] = args.url
        result['route'] = 'app-engine-diagnostic-worker'
        path = Path(args.output)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps({k: v for k, v in result.items() if k != 'results'}, indent=2))
        for task in result['results']:
            if task['status'] != 'passed':
                print(task['id'], task['status'], task.get('error', task.get('actual')))
        await browser.close()
        assert result['nativeBridge'], 'WASM CAS unavailable'
        assert result['failed'] == 0 and result['unsupported'] == 0, 'See task report for gaps'

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://localhost:8766/')
    parser.add_argument('--tasks', default='test/fixtures/workflow_tasks.json')
    parser.add_argument('--output', default='browser-results/workflow-tasks.json')
    parser.add_argument('--chromium')
    asyncio.run(check(parser.parse_args()))
