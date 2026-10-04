# CrispMath 1.2.0 release candidate

This candidate improves calculation and graph responsiveness and connects the
notepad and graph workspace. Compiled expression caching, persistent workers,
lazy tabs and document-level storage reduce repeated work.

- Inspect curves with touch or keyboard tracing and export value tables.
- Link notepad expressions to graphs with their document variables.
- Find commands and modules from a searchable palette.
- Edit axis bounds, fit finite samples and undo graph changes.
- Review expressions translated by an optional configured AI provider before
  calculating. Requests support cancellation, timeout and retry.
- Restore German, French and Spanish preferences and translated examples.
- Include the OCR runtime and CPU dependencies in desktop artifacts, with
  installed-library resolution verified on Linux, Windows and macOS.
- Recover saved documents if their index is damaged; migrate legacy storage
  without replacing newer records.

The candidate artifacts use pinned dependency revisions and verified native
binary checksums. macOS requires version 12 or later. Physical-device coverage
and AI translation quality are reported separately from build and contract tests.
