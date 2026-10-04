"""Verify published OCR bytes and initialize their real WASM API without models."""
import argparse
import asyncio
import json
from pathlib import Path
from urllib.parse import urljoin

API_VERSION = 'crispembed-ocr-wasm-0.3.0'


def verify_report(report, source, revision, version, checksums):
    if report.get('source') != source or report.get('crispembedSource') != revision:
        raise ValueError('OCR runtime source provenance mismatch')
    if report.get('version') != version or report.get('checksumsVerified') is not True:
        raise ValueError('OCR runtime release provenance mismatch')
    for name in ('crispembed_ocr.js', 'crispembed_ocr.wasm'):
        if report.get('assets', {}).get(name, {}).get('sha256') != checksums[name]:
            raise ValueError('OCR runtime recorded asset checksum mismatch')


def verify_live(live, checksums):
    for name in ('crispembed_ocr.js', 'crispembed_ocr.wasm'):
        if live.get('assets', {}).get(name) != checksums[name]:
            raise ValueError('Actual browser OCR bytes differ from the release')
    if live.get('apiVersion') != API_VERSION:
        raise ValueError('Unexpected OCR WASM API version')
    if live.get('allocatedPointer', 0) <= 0 or live.get('pointerRoundTrip') is not True:
        raise ValueError('OCR WASM allocation/heap pointer guard failed')
    if live.get('missingModelPointer') != 0:
        raise ValueError('OCR WASM accepted a nonexistent model')


async def check(args):
    # Lazy browser import keeps negative controls dependency-light.
    from playwright.async_api import async_playwright
    lock = json.loads(Path('tool/dependency_lock.json').read_text())['crispembed']
    checksums = json.loads(Path('tool/ocr_runtime_checksums.json').read_text())[lock['version']]
    base = args.url.rstrip('/') + '/'
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    report = {'passed': False, 'source': args.expected_source, 'modelDownloaded': False,
              'url': base, 'version': lock['version'], 'crispembedSource': lock['revision']}
    try:
        async with async_playwright() as pw:
            browser = await pw.chromium.launch(args=['--no-sandbox'])
            try:
                page = await browser.new_page()
                await page.goto(urljoin(base, 'privacy.html'), wait_until='domcontentloaded')
                meta = await page.request.get(urljoin(base, 'crispembed-ocr-runtime.json'))
                if not meta.ok:
                    raise ValueError('OCR runtime provenance is missing')
                verify_report(await meta.json(), args.expected_source, lock['revision'], lock['version'], checksums)
                live = await page.evaluate('''async ({base, expected}) => {
                  const assets = {};
                  const bytes = {};
                  for (const name of ['crispembed_ocr.js', 'crispembed_ocr.wasm']) {
                    const response = await fetch(new URL(name, base), {cache: 'no-store'});
                    if (!response.ok) throw Error('OCR asset unavailable: ' + name);
                    bytes[name] = new Uint8Array(await response.arrayBuffer());
                    const digest = await crypto.subtle.digest('SHA-256', bytes[name]);
                    assets[name] = Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2,'0')).join('');
                    if (assets[name] !== expected[name]) throw Error('Actual OCR byte checksum mismatch: ' + name);
                  }
                  // Execute and instantiate precisely the fetched, verified pair.
                  (0, eval)(new TextDecoder().decode(bytes['crispembed_ocr.js']));
                  if (typeof CrispEmbedOCR !== 'function') throw Error('Missing app-compatible factory');
                  const m = await CrispEmbedOCR({wasmBinary: bytes['crispembed_ocr.wasm'],
                    locateFile: name => new URL(name, base).href});
                  for (const name of ['ccall','UTF8ToString','_malloc','_free']) {
                    if (typeof m[name] !== 'function') throw Error('Missing runtime export: ' + name);
                  }
                  if (!(m.HEAPF32 instanceof Float32Array) || !(m.HEAPU8 instanceof Uint8Array) || !m.FS) {
                    throw Error('Missing native heap/FS exports');
                  }
                  const apiVersion = m.ccall('wasm_ocr_version','string',[],[]);
                  const ptr = m._malloc(16);
                  if (!ptr || ptr + 16 > m.HEAPU8.length) throw Error('Invalid allocated pointer');
                  m.HEAPU8[ptr] = 123;
                  const pointerRoundTrip = m.HEAPU8[ptr] === 123;
                  m._free(ptr);
                  const missingModelPointer = m.ccall('wasm_ocr_init','number',
                    ['string','number'], ['/__crispmath_missing_model__.gguf',1]);
                  if (missingModelPointer) m.ccall('wasm_ocr_free',null,['number'],[missingModelPointer]);
                  return {assets,apiVersion,allocatedPointer:ptr,pointerRoundTrip,missingModelPointer};
                }''', {'base': base, 'expected': {name: checksums[name] for name in ('crispembed_ocr.js','crispembed_ocr.wasm')}})
                verify_live(live, checksums)
                report.update(passed=True, live=live)
            finally:
                await browser.close()
    finally:
        output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', default='http://127.0.0.1:8766')
    parser.add_argument('--expected-source', required=True)
    parser.add_argument('--output', default='browser-results/ocr-runtime.json')
    asyncio.run(check(parser.parse_args()))
