"""Enter fresh math regressions through the real desktop and phone worksheet UI."""
import argparse
import asyncio
from fractions import Fraction
import json
import os
from pathlib import Path
import re
from urllib.parse import urljoin

from playwright.async_api import async_playwright

from benchmark_workflows import bootstrap, context_for, next_frames
from check_notepad_batch_browser import read_document


CASES = [
    ('exact-binary-cancellation', '(2^80+1)-2^80', '1'),
    ('exact-rational-sum', '1/6+1/10+1/15', '1/3'),
    ('negative-powers', '2^(-3)+4^(-2)', '3/16'),
    ('absolute-rational-quotient', 'abs(-3/7)/(9/14)', '2/3'),
    ('exact-decimal-cancellation', '10^30+7-10^30', '7'),
    ('cosine-removable-limit', 'limit((1-cos(x))/x^2,x,0)', None),
    ('rational-equation', 'solve((x-1)/(x+2)-2,x)', None),
    ('negative-temperature', '-40 °C in °F', '-40 °F'),
    ('additive-constant-domain', 'simplify(x^3/3+C)', None),
]


def validate_result(case, line):
    """Accept only the independently known value, with bounded notation variants."""
    case_id, source, expected = case
    assert line.get('s') == source, (case_id, line)
    assert not line.get('e'), (case_id, line)
    result = line.get('r')
    assert isinstance(result, str) and result, (case_id, line)
    assert not result.startswith('Error'), (case_id, line)
    if expected is not None:
        assert result == expected, (case_id, result, expected)
    elif case_id == 'cosine-removable-limit':
        assert abs(float(Fraction(result.strip())) - 0.5) < 1e-9, (case_id, result)
    elif case_id == 'rational-equation':
        root = re.fullmatch(
            r'x\s*=\s*\{?\s*(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)\s*\}?',
            result.strip())
        assert root is not None and float(root[1]) == -5, (case_id, result)
    elif case_id == 'additive-constant-domain':
        expression = re.sub(r'\s+', '', result).replace('**', '^').replace('³', '^3')
        # Accept parentheses only around the known coefficient/monomial;
        # stripping arbitrary parentheses could accept x^3/(3+C) incorrectly.
        # No general expression is eval'd.
        term = r'(?:(?:x\^3|\(x\^3\))/3|(?:1/3|\(1/3\))\*x\^3)'
        assert re.fullmatch(rf'(?:{term}\+C|C\+{term})', expression), (case_id, result)
        assert not (line.get('evidence') or {}).get('sourceDomain'), (case_id, line)
    else:
        raise AssertionError(f'Missing independent assertion for {case_id}')


async def check(args):
    output = Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    report = {'url': args.url, 'toolSource': os.environ.get('GITHUB_SHA'),
              'passed': False, 'checks': []}

    def save():
        (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    async with async_playwright() as pw:
        browser = await pw.chromium.launch(
            args=['--no-sandbox', '--enable-unsafe-swiftshader'])
        try:
            for width, height in [(1280, 900), (390, 844)]:
                for batch_start in range(0, len(CASES), 3):
                    batch = CASES[batch_start:batch_start + 3]
                    batch_number = batch_start // 3 + 1
                    doc_id = f'new-math-{width}-{batch_number}'
                    doc = {'i': doc_id, 'n': 'Fresh mathematical regressions',
                           'c': '2026-10-02T00:00:00Z', 'u': '2026-10-02T00:00:00Z',
                           'l': [{'i': str(i), 's': ''} for i in range(len(batch))]}
                    context, page, errors = await context_for(browser, {
                        'viewport': {'width': width, 'height': height},
                        'cpu': 1, 'has_touch': width < 600}, doc)
                    item = {'width': width, 'height': height, 'batch': batch_number,
                            'cases': [case[0] for case in batch], 'passed': False}
                    report['checks'].append(item)
                    try:
                        await bootstrap(page, args.url)
                        if 'appSource' not in report:
                            response = await context.request.get(
                                urljoin(args.url.rstrip('/') + '/', 'build-info.json'))
                            assert response.ok, f'Build provenance HTTP {response.status}'
                            source = (await response.json())['source']
                            assert re.fullmatch(r'[0-9a-f]{40}', source), source
                            if args.expected_source:
                                assert source == args.expected_source, (source, args.expected_source)
                            report['appSource'] = source
                        await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                        for index, case in enumerate(batch):
                            field = page.get_by_role('textbox').nth(index)
                            await field.click()
                            await next_frames(page)
                            await field.fill(case[1])
                            await page.wait_for_function('''item => {
                              const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+item.id);
                              if(!raw)return false;
                              const line=JSON.parse(JSON.parse(raw)).l[item.index];
                              return line.s===item.source && (line.r || line.e);
                            }''', arg={'id': doc_id, 'index': index, 'source': case[1]})
                        saved = await read_document(page, doc_id)
                        assert len(saved['l']) == len(batch), saved
                        for case, line in zip(batch, saved['l']):
                            validate_result(case, line)
                        item['beforeReload'] = saved
                        await page.screenshot(
                            path=str(output / f'math-{width}-batch-{batch_number}.png'))
                        await page.reload(wait_until='domcontentloaded')
                        await page.locator('canvas').first.wait_for()
                        await page.locator('flt-semantics-placeholder').evaluate(
                            '(element)=>element.click()')
                        await page.get_by_role('button', name=re.compile(r'^Notepad')).click()
                        restored = await read_document(page, doc_id)
                        assert len(restored['l']) == len(batch), restored
                        for case, line in zip(batch, restored['l']):
                            validate_result(case, line)
                        assert [line['s'] for line in restored['l']] == [case[1] for case in batch]
                        assert [line['r'] for line in restored['l']] == [line['r'] for line in saved['l']]
                        assert not errors, errors
                        item.update({'passed': True, 'reload': True, 'afterReload': restored})
                    except Exception as error:
                        item['error'] = repr(error)
                        item['pageErrors'] = errors
                        try:
                            item['document'] = await read_document(page, doc_id)
                            await page.screenshot(path=str(
                                output / f'failure-{width}-batch-{batch_number}.png'))
                        except Exception as evidence_error:
                            item['evidenceError'] = repr(evidence_error)
                        save()
                        raise
                    finally:
                        save()
                        await context.close()
            report['passed'] = True
            save()
            print(json.dumps(report), flush=True)
        finally:
            await browser.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/new-math')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(check(parser.parse_args()))
