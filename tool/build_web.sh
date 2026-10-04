#!/usr/bin/env bash
set -euo pipefail
# Run from the repository root. Flutter copies the compiled worker into the
# web bundle alongside the launcher and WASM assets.
python3 tool/stage_ocr_wasm_runtime.py
dart compile js -O2 -Ddart.vm.product=true lib/services/math_worker_entry.dart -o web/math_worker.dart.js
dart compile js -O2 -Ddart.vm.product=true lib/diagnostics/workflow_tasks_worker.dart -o web/workflow_tasks_worker.dart.js
flutter build web "$@"
# The browser probe is for development and must not ship in the app.
rm -f build/web/math_worker_probe.dart.js*

# Identify the deployed bundle without exposing build-system details in the UI.
python3 - <<'PYTHON'
import json, os, subprocess
from pathlib import Path
source = os.environ.get('GITHUB_SHA') or subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
Path('build/web/build-info.json').write_text(json.dumps({'source': source}) + '\n')
PYTHON
