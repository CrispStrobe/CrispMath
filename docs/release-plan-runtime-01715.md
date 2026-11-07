# CrispMath release plan: CrispEmbed 0.17.15

Status: planning only, 7 November 2026. No new app version, tag, binary, store
upload or review submission is created by this document. The candidate must be
selected and frozen after the current App Store state is known.

## Change to deliver

CrispMath main `580143e5e7cbfd725eb1e716945a482477ec359c` includes
[PR16](https://github.com/CrispStrobe/CrispMath/pull/16), which pins CrispEmbed
source `d28ca2ea43a95934d673d1a54177fdf721614ade` and its published 0.17.15
native/WASM asset hashes. The released `v1.2.0` artifacts contain the earlier
0.17.12 dependency. This is an app runtime update, not adoption of unreleased
CrispEmbed 0.17.16 or promotion of experimental models.

The app verifies the downloaded WASM pair and applies its recorded bounded
Emscripten UTF-8 repair to the 0.17.15 loader. Preserve both published and patched
hashes and the fail-closed source/version checks. The first unpatched browser
run [42235004883](https://github.com/CrispStrobe/CrispMath/actions/runs/42235004883)
failed; corrected browser and gallery [42238302614](https://github.com/CrispStrobe/CrispMath/actions/runs/42238302614)
passed. Packaged Windows OCR and consent grant/withdrawal passed
[42241800813](https://github.com/CrispStrobe/CrispMath/actions/runs/42241800813);
packaged macOS OCR passed [42241800772](https://github.com/CrispStrobe/CrispMath/actions/runs/42241800772)
after correcting the initial test-library path. Android, Linux, iOS, web and
CI checks passed on the same PR head. Main feature validation
[42314818655](https://github.com/CrispStrobe/CrispMath/actions/runs/42314818655)
passed unit, native OCR, release/debug browser and gallery jobs. These are
bounded consumer checks, not universal model quality or physical-device proof.

## Store state and version decision

The 7 November read-only inspection [42371965467](https://github.com/CrispStrobe/CrispMath/actions/runs/42371965467)
confirmed build 27 is valid and current, and that App Store version 1.2.0 has
that build attached with state `WAITING_FOR_REVIEW`. The age-rating declaration
and the active submission are also waiting for review. The inspection made no
submission or other store change. Internal assignment was last verified on
5 November; inspect it again if it is needed for a later release. Recheck all
store states before acting because review can advance independently.

After reviewing that state, choose the next legal marketing version and an
unused build number greater than 27. Do not assume 1.2.1 or build 28 is available:
check store readback first. A version already in review must not be withdrawn,
replaced or resubmitted as a side effect of this planning task.

## Candidate and gates

1. Freeze the exact candidate source after selecting version/build. Update
   `pubspec.yaml`, release notes and generated README facts together; retain the
   immutable dependency lock and complete checksum table. Run the release-manifest
   controls and check that every platform stages the same declared release.
2. Run hosted analysis, unit tests, all platform builds, accumulated math and
   release/debug browser/gallery checks on that exact candidate. Require real
   bundled native OCR, actual browser module initialization and UTF-8 controls,
   and the Windows license-gate grant/withdrawal test. Preserve failures and
   source/artifact hashes. Re-run candidate-specific checks after any code or
   dependency change; do not treat the earlier PR runs as candidate validation.
3. Review real Apple-device evidence where devices are available; explicitly
   record untested devices. Verify package metadata, signed-app purpose strings,
   privacy and listing claims, and any version-specific platform limitations.
4. Require a successful exact-source Feature validation run and pass its ID to
   the iOS release workflow. Confirm the new build number is unused. Inspect the
   exact release workflow and candidate artifacts before signing or uploading.
5. After separate authorization for the concrete candidate, publish once, wait
   for actual store processing and read back the build and assignment states.
   App Review submission or replacement is a separate explicit action. Do not
   rebuild or reupload merely to retry a metadata-only step.
6. Verify the immutable release artifacts and hashes and the deployed web builds
   against the candidate source. Record the actual results and remaining limits;
   retain prior release assets and evidence.

## Draft release-note scope

- Update the bundled OCR runtime to the verified CrispEmbed 0.17.15 release.
- Preserve the existing research-model consent flow and improve compatibility of
  the web OCR runtime with modern browsers.
- Carry over the already merged application fixes since the previous release;
  review their precise user-visible scope against the final candidate.

Do not claim newly qualified OCR models, PP-OCRv6 issue 164's 0.17.16 changes,
physical-device validation or App Review approval without separate evidence.
