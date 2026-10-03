# Eighth independent mathematical audit

Fifty questions and independent references are drafted before observing app
outputs: [algebra/calculus](round8-math-algebra.md) and
[numeric/statistics/units/constraints](round8-math-numeric.md). Each fixture
contains 25 questions. Prior exact duplicates are replaced before the joint
freeze; their replacements are documented in the reference drafts. References
remain unchanged after the first app observation.

The accumulated runtime corpus now contains 637 questions. Initial native,
WebAssembly and packaged macOS results will be preserved before diagnosing
failures. Confirmed problems will receive shared fixes plus positive and negative
regression controls, then actual desktop/phone checks and deployed Pages/Vercel
verification. All builds, app execution, analysis and test batches run on hosted
CI. Only small reports and selected screenshots are downloaded to cold storage.

Physical iPhone/iPad tests remain deferred. Handwriting accuracy, real
Siri/Files-provider and two-device cloud checks, and Apple's 4.3(a) App Review
rejection remain separate open items. Build 18 remains the approved public beta
until a changed production build has passed all gates and delivery verification.
