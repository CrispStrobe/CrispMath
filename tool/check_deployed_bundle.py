"""Wait for the requested source to appear on a deployed site before live tests."""
import argparse
import json
import time
from urllib.request import urlopen
from urllib.parse import urljoin


def check(url, source, timeout=180):
    deadline = time.monotonic() + timeout
    last = 'no response'
    while time.monotonic() < deadline:
        try:
            path = urljoin(url.rstrip('/')+'/', 'build-info.json')+'?source='+source
            with urlopen(path, timeout=15) as response:
                result = json.load(response)
            if result.get('source') == source:
                print(json.dumps({'url': url, 'source': source, 'matched': True}))
                return
            last = result.get('source', 'missing source')
        except (OSError, ValueError) as error:
            last = str(error)
        time.sleep(5)
    raise RuntimeError(f'Deployed source did not match {source}: {last}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--url', required=True)
    parser.add_argument('--source', required=True)
    args = parser.parse_args()
    check(args.url, args.source)
