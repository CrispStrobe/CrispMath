# CrispMath review evidence draft

This document is preparation for a future submission, not a message sent to App
Review. The September 14 rejection of 1.0.3 (7), guideline 4.3(a), remains open.
Build 12 was rejected at delivery for ITMS-90683 (missing photo-library purpose).
Replacement 1.2.0 (13) adds photo-library/camera explanations and a signed-bundle
privacy gate; its upload and processing are being verified in CI.
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
