# CrispMath review evidence draft

This document is preparation for a future submission, not a message sent to App
Review. The September 14 rejection of 1.0.3 (7), guideline 4.3(a), remains open.
Build 12 was rejected at delivery for ITMS-90683 (missing photo-library purpose).
Replacement 1.2.0 (13) adds photo-library/camera explanations and a signed-bundle
privacy gate. [Release CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37028331142) verifies the signed
bundle and successful upload, Apple VALID processing and existing Internal
Testers assignment for source `7247074`. This is TestFlight delivery evidence;
no App Store review submission was made.
Build 13 was subsequently [submitted to external TestFlight beta review](https://github.com/CrispStrobe/CrispMath/actions/runs/37032322549)
on October 2 at 16:17 UTC, initially WAITING_FOR_REVIEW with Public Beta
assignment confirmed. [Read-only API verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37092308470)
on October 3 confirms beta review APPROVED and both internal and external
IN_BETA_TESTING. The [public beta](https://testflight.apple.com/join/E6HdVhTx) is
available. The later mathematical fixes are not in build 13. Beta approval
does not resolve the earlier 4.3(a) rejection.
Build 14 now includes the later mathematical fixes. [Signed release CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37094979914)
passes for source `e0a0614999ba5f22c592b8fd61c18a2c9aacaa71`, version 1.2.0 (14):
48 tooling tests, signed photo/camera purpose strings and version/build checks,
production-source/dependency parity with green browser/gallery CI, successful
upload, Apple VALID processing and Internal Testers assignment.
[External TestFlight CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37095571010)
confirms beta review APPROVED and internal/external IN_BETA_TESTING with Public
Beta assignment. The existing public link offered build 14. The submission record
matches build ID `26a96c77-406f-4bf0-8571-68834fe068e5`; Apple returns no submission
timestamp. No App Review submission occurred. See [the third audit](round3-math-audit-50.md).
Build 15 includes the fourth independent audit and worksheet-scope/graph fixes.
[Signed release CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37099298115)
passes 48 tooling tests, signed photo/camera purpose strings and version checks,
and identical-source production validation for
`39c3591576bd0ab2d82e9a4e28ac1fd76e336d1e`, version 1.2.0 (15).
Upload succeeds, Apple processing is VALID and Internal Testers are assigned.
[External verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37099901727)
confirms beta review APPROVED, internal/external IN_BETA_TESTING and Public Beta
assignment. The submission record matches build ID
`a33926e8-4a4f-4112-96fa-8345c1c537ea`; Apple returns no submission timestamp.
The public link offered build 15. All 413 accumulated runtime cases pass on
Linux, WASM, packaged macOS, Pages and Vercel, together with 5,511 unit/widget
tests (eight documented skips) and 82 actual desktop/phone worksheet entries.
See [the fourth audit](round4-math-audit-50.md). No App Review submission occurred.
Beta approval does not resolve guideline 4.3(a).

The English beta description is corrected in
[metadata-only CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37100740297)
after 52 tooling tests pass. It now describes core calculations on-device and
optional configured connected AI/cloud services. Actual read-back confirms that
only the description changes; custom release notes, locale/privacy fields,
groups and submission records remain intact. Build 15 retains its approved beta
state. See [the fifth audit](round5-math-audit-50.md).

Build 16 includes the fifth independent audit and formal-scope/badge fixes.
[Signed release CI](https://github.com/CrispStrobe/CrispMath/actions/runs/37105698802)
passes all 52 tooling tests, signed photo-library/camera purpose strings,
version 1.2.0/build 16 and identical production source/dependency validation for
`1afa020420871204fbda9fec577ee3c908d59015`. Upload succeeds, Apple processing is
VALID and Internal Testers are assigned.
[External beta verification](https://github.com/CrispStrobe/CrispMath/actions/runs/37106359044)
confirms APPROVED, internal/external IN_BETA_TESTING and Public Beta assignment.
The build/submission record is `1b484f10-8f35-4311-b549-28c22289b8a4`, with no
submission timestamp returned by Apple. The public link now offers build 16.
All 469 accumulated runtime checks pass across Linux/WASM, packaged macOS,
Pages and Vercel; full CI passes 5,536 unit/widget tests (eight skips), 124 actual
desktop/phone entries plus fourteen binding-edit states, release/debug assertions
and performance/gallery checks. The truthful beta description is retained.
No App Review submission occurs; beta approval does not resolve guideline 4.3(a).

Physical iPhone/iPad checks are explicitly deferred to another session.

Apple asks for distinct functionality and accurate metadata in its
[App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/#spam).
A source repository, test count or changed screenshots alone cannot establish
that Apple will accept the app. The earlier suggestion that the finding was an
automated similarity check is unverified.

The concrete workflow to demonstrate is a persistent mathematical worksheet:
create `a=3`, `f(t)=t^2+a`, `f(4)` and obtain 19; change `a` and recalculate;
link an expression to a graph; export the calculation, graph and values from a
single preview; save a checkpoint, compare it and restore it; transfer the
source worksheet through Files and recalculate its results locally.
Calculator, worksheet, graph, checkpoint and export screens should show this
connected workflow. The native URL bridge can create the same worksheet.

The latest [33-image native gallery](https://github.com/CrispStrobe/CrispMath/actions/runs/37104046317)
passes for capture source `2927336`, with 11 populated scenes each on iPhone/iPad
simulators and the real native macOS application. Evaluated engineering
worksheets, sampled graphs, tracing, value tables, export/history and visible
handwriting are asserted; selected macOS graph/worksheet/table images are
visually reviewed, and iPhone/iPad manifests/evidence are inspected. See
[the capture evidence and limitations](native-apple-gallery.md). The subsequent
`1afa020` changes only the live-test helper; production code remains unchanged.

The native gallery workflow captures actual iPhone/iPad simulator screens and
retains CAS assertions (the derivative of sin(x) is cos(x); the integral of
x² from zero to one is 1/3). It adds the export preview, history and handwriting
input to the prior calculator, worksheet, graph and workflow-link scenes.
The 14-image native gallery passed in
[run 37020555224](https://github.com/CrispStrobe/CrispMath/actions/runs/37020555224)
for source `34bb88f`. Its manifest records the source revision, actual dimensions
and simulator identity. Original captures are retained. The upload images preserve their RGB
pixels, remove redundant alpha and follow
[Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).
Simulator checks do not establish actual Siri invocation, Files provider
behavior, Apple Pencil behavior, physical multitasking or App Store approval.

Review notes draft:

> CrispMath lets users build and retain mathematical worksheets whose variables
> and functions drive subsequent calculations and linked graphs. Worksheets can
> be transferred through Files; imported calculations are recalculated on the
> device. Export preview produces calculations, linked plots and sampled values
> together. Checkpoints offer comparisons and restore, and portable workspace
> backups preserve conflicting copies rather than selecting a device clock as
> the winner. Core calculator, worksheet and graph workflows work offline.
> The public source and reproducible CI evidence are available at
> https://github.com/CrispStrobe/CrispMath.

The optional handwriting feature is an editable transcription aid. It requires
review before insertion; local model weights are optional downloads. Cloud
recognition requires explicit confirmation and a configured provider. The
50-human-sample benchmark measured only 7/50 exact transcriptions for PosFormer
and 0/50 for BTTR/HMER. Do not advertise handwriting as reliable or show an
unverified recognition success in store images. Dataset and weight licenses
remain separate from application code; benchmark weights are not shipped as
app assets.

A configured cloud project and a real two-device account check remain pending.
Portable Files backups and local checkpoints are independently usable without
that service. Do not claim deployed cloud sync or invent review credentials.
