#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Locate the pinned bridge through Dart's resolved package configuration.
bridge_library=$(python3 - <<'PY'
import json
from pathlib import Path
from urllib.parse import urljoin, urlparse, unquote
config = Path('.dart_tool/package_config.json').resolve()
packages = json.loads(config.read_text())['packages']
package = next(p for p in packages if p['name'] == 'symbolic_math_bridge')
root = Path(unquote(urlparse(urljoin(config.as_uri(), package['rootUri'])).path))
print(root / 'linux' / 'Libraries')
PY
)
exec env LD_LIBRARY_PATH="$bridge_library${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" dart run tool/crispmath_cli.dart "$@"
