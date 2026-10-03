"""Frozen seventh-audit references entered in real desktop and phone worksheets.

Answers are independent identities frozen in ffa36677 before app outputs.
Only blank documents are seeded; all sources and edits use actual textboxes.
"""
import argparse
import asyncio
import os

import check_new_math_browser as controls

from round7_reference_checks import CASES, validate_result

controls.CASES = CASES

async def check_reactive_taylor(page, doc_id, batch, saved, changes):
    if batch[0][0] != 'reactive-parameter':
        return
    field = page.get_by_role('textbox').first
    for parameter in [4, 1]:
        source = f'p={parameter}'
        await field.click()
        await controls.next_frames(page)
        await field.fill(source)
        await page.wait_for_function("""item => {
          const raw=localStorage.getItem('flutter.crisp.notepadDoc.'+item.id);
          if(!raw)return false;
          const lines=JSON.parse(JSON.parse(raw)).l;
          return lines[0].s===item.source && lines[0].r===String(item.value) &&
            lines[1].r==='9' && !lines.some(line=>line.e || (line.f||[]).length) &&
            lines[2].r && lines[2].r!==item.previous;
        }""", arg={'id': doc_id, 'source': source, 'value': parameter,
                   'previous': saved['l'][2]['r'] if parameter == 4 else changes[-1]['document']['l'][2]['r']})
        actual = await controls.read_document(page, doc_id)
        for index, line in enumerate(actual['l']):
            expected_case = batch[index]
            if index == 0:
                expected_case = (batch[index][0], source, str(parameter))
            elif index == 2:
                expected_case = (batch[index][0], batch[index][1], [parameter, 0, -1])
            validate_result(expected_case, line)
        changes.append({'source': source, 'expectedCoefficients': [parameter, 0, -1], 'document': actual})


controls.AFTER_ENTRY = check_reactive_taylor
controls.validate_result = validate_result

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766/')
    parser.add_argument('--output', default='browser-results/round7-math-ui')
    parser.add_argument('--expected-source', default=os.environ.get('EXPECTED_SOURCE'))
    asyncio.run(controls.check(parser.parse_args()))
