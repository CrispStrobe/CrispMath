"""Export only disposable local-stack connection fields into hosted CI."""
import json
import os
from pathlib import Path
import sys
from urllib.parse import urlparse


def export(status_path, environment_path):
    status = json.loads(Path(status_path).read_text())
    url = status.get('API_URL')
    parsed = urlparse(url or '')
    if (parsed.scheme != 'http' or parsed.hostname not in {'localhost', '127.0.0.1'}
            or parsed.username or parsed.password or parsed.query or parsed.fragment
            or parsed.path not in {'', '/'}):
        raise ValueError('Expected a disposable loopback Supabase API')
    fields = {
        'CRISPMATH_SYNC_API_URL': url,
        'CRISPMATH_SYNC_PUBLIC_KEY': status.get('ANON_KEY') or status.get('PUBLISHABLE_KEY'),
        'CRISPMATH_SYNC_FIXTURE_ADMIN_KEY': status.get('SERVICE_ROLE_KEY') or status.get('SECRET_KEY'),
        'CRISPMATH_SYNC_LIVE': 'disposable',
    }
    if any(not isinstance(value, str) or not value or '\n' in value or '\r' in value
           for value in fields.values()):
        raise ValueError('Missing or malformed local-stack connection fields')
    # These keys administer only the runner's throwaway stack. Mask them before
    # exporting; never include credentials or status.json in test artifacts.
    for name, value in status.items():
        if any(part in name for part in ('KEY', 'SECRET', 'PASSWORD', 'DB_URL')):
            if isinstance(value, str) and value:
                print('::add-mask::' + value)
    with Path(environment_path).open('a') as stream:
        for name, value in fields.items():
            stream.write(f'{name}={value}\n')


if __name__ == '__main__':
    export(sys.argv[1], os.environ['GITHUB_ENV'])
