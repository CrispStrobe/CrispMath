"""Independent solve-scope controls entered through desktop/phone worksheets."""
import argparse
import asyncio
from fractions import Fraction
import math
import os
import re

import check_new_math_browser as controls

# Freeze scope references before execution: x²-1 has roots±1; the rational
# equation x-1=2(x+2) has root-5 (source excludes-2); 2x-6=0 has root3.
# Explicit solve variables are local even when a worksheet defines x=9.
controls.CASES = [
    ('quadratic-global-x', 'x=9', '9'),
    ('quadratic-local-solve', 'solve(x^2-1,x)', {-1, 1}),
    ('rational-local-solve', 'solve((x-1)/(x+2)-2,x)', {-5}),
    ('reactive-coefficient', 'a=2', '2'),
    ('linear-global-x', 'x=9', '9'),
    ('linear-local-solve', 'solve(a*x-6,x)', {3}),
    ('calculus-global-x', 'x=9', '9'),
    ('formal-derivative', 'diff(x^3,x)', '3*x^2'),
    ('formal-antiderivative', 'integrate(x^2,x)', 'x^3/3+C'),
]
NUMERIC = re.compile(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?(?:/\d+)?')


def validate_result(case, line, expected_free=()):
    case_id, source, expected = case
    assert line.get('s') == source and not line.get('e'), (case, line)
    result = line.get('r')
    assert isinstance(result, str) and result, (case, line)
    if case_id in {'formal-derivative', 'formal-antiderivative'}:
        expression = re.sub(r'\s+', '', result).replace('**', '^').replace('²', '^2').replace('³', '^3')
        if case_id == 'formal-derivative':
            assert re.fullmatch(r'3\*?x\^2', expression), (case, line)
        else:
            term = r'(?:(?:x\^3|\(x\^3\))/3|(?:1/3|\(1/3\))\*?x\^3)'
            assert re.fullmatch(rf'(?:{term}\+C|C\+{term})', expression), (case, line)
        assert line.get('f', []) == list(expected_free), (case, line)
        return
    if isinstance(expected, set):
        match = re.fullmatch(r'x\s*=\s*(\{[^{}]+\}|[^{}]+)', result.strip())
        assert match, (case, line)
        text = match[1].strip()
        if text.startswith('{'):
            text = text[1:-1]
        parts = [part.strip() for part in text.split(',')]
        assert all(NUMERIC.fullmatch(part) for part in parts), (case, line)
        values = {float(Fraction(part)) for part in parts}
        assert len(parts) == len(expected) == len(values), (case, line)
        assert all(any(abs(actual-ref) < 1e-10 for actual in values)
                   for ref in expected), (case, line)
        assert not line.get('f'), (case, line)
    else:
        assert result == expected, (case, line)


controls.validate_result = validate_result


async def check_incremental_badges(page, doc_id, batch, baseline, snapshots):
    if batch[0][0] != 'calculus-global-x':
        return
    formal_baseline = baseline['l'][1:]
    assert all(line.get('evidence') for line in formal_baseline), baseline
    edits = [
        ('rename-owner', 'y=9', ['x'], '9', False),
        ('incomplete-owner', 'x=1+', ['x'], None, False),
        ('invalidate-owner', 'x=diff(1)', ['x'], None, True),
        ('remove-owner', '', ['x'], None, False),
        ('restore-owner', 'x=9', [], '9', False),
        ('change-owner-value', 'x=12', [], '12', False),
        ('restore-before-reload', 'x=9', [], '9', False),
    ]
    for label, source, free_vars, owner_result, owner_error in edits:
        field = page.get_by_role('textbox').nth(0)
        await field.click()
        await controls.next_frames(page)
        await field.fill(source)
        # Observe persisted app state only. No direct cache mutation or
        # recalculate-all action may conceal an incremental refresh defect.
        await page.wait_for_function('''item => {
          const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+item.id);
          if(!raw)return false;
          const rows=JSON.parse(JSON.parse(raw)).l;
          if(rows.length!==3 || rows[0].s!==item.source)return false;
          if(Boolean(rows[0].e)!==item.ownerError)return false;
          if(item.ownerResult!==null && rows[0].r!==item.ownerResult)return false;
          if(item.ownerResult===null && rows[0].r)return false;
          return rows.slice(1).every((line,index) =>
            line.s===item.formal[index].s && !line.e &&
            line.r===item.formal[index].r &&
            JSON.stringify(line.f || [])===JSON.stringify(item.free));
        }''', arg={'id': doc_id, 'source': source, 'free': free_vars,
                  'ownerResult': owner_result, 'ownerError': owner_error,
                  'formal': formal_baseline})
        document = await controls.read_document(page, doc_id)
        # Keep evidence for every observed edit, even if a later assertion fails.
        snapshots.append({'edit': label, 'source': source,
                          'expectedFreeVariables': free_vars,
                          'document': document})
        owner = document['l'][0]
        assert owner['s'] == source and bool(owner.get('e')) == owner_error, owner
        if owner_result is not None:
            assert owner.get('r') == owner_result, owner
        else:
            assert not owner.get('r'), owner
        for case, line, original in zip(batch[1:], document['l'][1:],
                                        formal_baseline):
            validate_result(case, line, expected_free=free_vars)
            assert line['r'] == original['r'], (label, line, original)
            assert line.get('evidence') == original.get('evidence'), (
                label, line, original)


controls.AFTER_ENTRY = check_incremental_badges


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round5-solve-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
