#!/usr/bin/env bash
set -euo pipefail
# Run from the repository root. Flutter copies the compiled worker into the
# web bundle alongside the launcher and WASM assets.
dart compile js -O2 -Ddart.vm.product=true lib/services/math_worker_entry.dart -o web/math_worker.dart.js
flutter build web "$@"
# The browser probe is for development and must not ship in the app.
rm -f build/web/math_worker_probe.dart.js*
