# OCR parsing handoff entry point

The original session prompt is superseded by the
[current executable handoff](https://github.com/CrispStrobe/CrispMath/blob/main/docs/current-state-and-next-steps.md).
Start with O1 for inference/reference diagnosis and U1 for actual editable
recognition-to-calculator behavior. Recognition quality, parsing correctness and
model vocabulary are separate causes; do not diagnose one from another's score.

Public code and regression entry points:

- [OCR provider](https://github.com/CrispStrobe/CrispMath/blob/main/lib/engine/ocr_provider.dart)
- [LaTeX conversion](https://github.com/CrispStrobe/CrispMath/blob/main/lib/utils/latex_conversion_utils.dart)
- [OCR provider tests](https://github.com/CrispStrobe/CrispMath/blob/main/test/ocr_provider_test.dart)
- [LaTeX conversion tests](https://github.com/CrispStrobe/CrispMath/blob/main/test/latex_conversion_utils_test.dart)
- [Hosted Feature validation](https://github.com/CrispStrobe/CrispMath/blob/main/.github/workflows/feature-validation.yml)
- [Measured handwriting limits](https://github.com/CrispStrobe/CrispMath/blob/main/docs/handwriting-quality-findings.md)

First inspect current code and tests before treating an old parsing gap as open.
For a new failure, freeze the original LaTeX and independently intended meaning,
trace OCR cleanup through conversion and actual engine dispatch, and add both a
correctness case and a malformed/meaning-changing negative control. Run targeted
and full checks on hosted CI. Verify actual editable UI insertion and recalculation;
do not validate only a rewritten string or hide an unsupported command.

Done means source semantics survive conversion or the user receives a clear
unsupported/error result, with real engine/UI evidence and no reliable-recognition
claim. Architecture-specific paths and private toolchain setup are maintained in
private operator notes, not in this public handoff.
