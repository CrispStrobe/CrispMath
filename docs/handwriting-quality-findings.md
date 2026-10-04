# Handwriting recognition: measured limits and vocabulary gap

Measured on 2026-10-04 using all 50 deterministically selected MathWriting
test drawings. References, selection, rasterization and exact-match scoring
were preserved. These measurements explain part of the open quality gap;
handwriting remains an editable transcription aid, requiring review before
insertion.

[Paired encoder run 37197085191](https://github.com/CrispStrobe/CrispMath/actions/runs/37197085191)
at source `5f7d59fa674b7f2c22253dc6d21a335fea3a81f2` measured **7/50 exact
transcriptions for both default and scalar PosFormer encoders**. The same seven
drawings matched in both arms, while **22/50 token outputs differed**. BTTR and
HMER each measured **0/50**, with no runtime failures. The encoder comparison
does not clear native inference: numerical sensitivity remains, and the
decoder and quantization were shared. The default encoder can also fall back
to scalar if scheduler initialization fails.

[Actual GGUF metadata run 37197856188](https://github.com/CrispStrobe/CrispMath/actions/runs/37197856188)
at source `40782ca771ed7db3fc699e1ffc9d5df0be1f6f4b` confirms **113 tokenizer
entries: 110 lexical tokens and three special tokens**. Padding, start and end
IDs are respectively 0, 1 and 2. Decoder projection dimensions are
`[256, 113]`, with bias `[113]`, agreeing with the tokenizer size.

**27/50 frozen references contain missing canonical tokens and cannot be
assembled from the actual tokenizer's strings under the existing exact-token
scoring.** Examples include `\Omega`, `\omega`, `\partial` and `\nabla`.
The audit checks every possible token concatenation, so a missing command
entry alone does not imply failure if smaller tokens can assemble it.
The other **23 references are lexically representable**. This is a reference
coverage result, not a semantic accuracy ceiling or a recognition guarantee.
Vocabulary limits explain part of the failure; poor recognition of the
remaining references still needs investigation.

## Public MathWriting candidate and native forward investigation

[Candidate run 37202122710](https://github.com/CrispStrobe/CrispMath/actions/runs/37202122710)
at source `864e505964ac1af065714e27ef4a139b829fcc12` tested the publicly
accessible `posformer-mathwriting_v2-f32.gguf` separately. Actual GGUF metadata
confirms **186 tokens, dimension 384, eight attention heads, and projection
`[384, 186]`**. It can assemble **49/50 frozen reference strings**; the remaining
reference needs `\longrightarrow`. Nevertheless, real native recognition
measured **0/50 exact matches**, with zero runtime failures and 50 distinct,
nonempty transcriptions. The unchanged baseline again measured 7/50.
Every case's image hash, reference, dimensions and scoring matched the baseline.

Candidate identity is pinned to Hugging Face revision
`45eb7de7d8ae26708701f06cae68d96f1abb0ef7`, model SHA-256
`12060161fc6dc3c3fde146532ffade00f8f2286dd5a53e1f8777215afa9193c0`, and actual
tokenizer SHA-256
`287722dd3f4aa767c208e195d6c2a9c3a653bc9e9bc956f48e4496f3f9f25e44`.
This closes 26 lexical gaps but does not improve measured recognition. It has
not replaced production weights or been added to the model catalog.

Source inspection found a concrete forward mismatch: the
[converter](https://github.com/CrispStrobe/CrispEmbed/blob/11e6d598521976f38081934106b55095b46b40e3/models/convert-posformer-to-gguf.py)
writes learned `dec.input_norm` weights, and the
[official decoder](https://github.com/SJTU-DeepVisionLab/PosFormer/blob/802019a0533639f3b0bf18d44e93be073945cac5/Pos_Former/model/decoder.py)
applies that normalization after positional addition. The pinned native
decoder omits it. A separate, opt-in hosted diagnostic repairs this ordering
and compares the real native token-input path with independent LayerNorm
math before measuring both models on the unchanged 50 drawings. This is not
yet a validated production repair or full model parity result.

[Normalization diagnostic run 37203847497](https://github.com/CrispStrobe/CrispMath/actions/runs/37203847497)
at source `3b1813bc86fe2b78145257a415ccca26c8195457` passed both builds,
independent native-path controls and strict paired measurements. The actual
patched decoder input path agrees with independent, biased-variance
LayerNorm math to maximum absolute errors **2.16 × 10⁻⁷ at dimension 256** and
**3.18 × 10⁻⁷ at dimension 384**. Negative controls for omitted normalization,
wrong ordering and missing learned affine parameters differ substantially.

Recognition accuracy did **not** improve: original Q8 weights remained
**7/50**, with exactly the same seven matches and **35 changed token outputs**;
the expanded-vocabulary F32 candidate remained **0/50**, with **49 changed token
outputs**. Both patched measurements completed all 50 drawings with zero
runtime failures. Source, frozen manifest, model, image hashes, references,
dimensions and scoring were checked across each pair. This isolates a real
forward mismatch without showing a useful quality gain. Production bridge
and model pins remain unchanged; full independent encoder and decoder parity
is still needed before attributing the remaining failures to the weights.

The diagnostic records base bridge
`11e6d598521976f38081934106b55095b46b40e3` plus patch SHA-256
`2c571c78296f6e062cf81003405c274b1cda9706facc930256ba9e1cbc9b10ff`.
The baseline library SHA-256 is
`f826642932f9777aabd2705ca6b04c881c039275ff04b569728dd5ac239001c9`;
the separately built patched library is
`00750559035493538c8eb977f6b70af4c0259cd310d2a9f95bcebf445501eddb`.
The independent controls exercised that same patched library. Model hashes
are unchanged from the baseline and candidate identities above.

Structural-token coverage masking also uses fixed IDs 82, 83 and 110. These
identify `^`, `_` and `{` in the original tokenizer, but different symbols in
the expanded vocabulary. The
[official ARM implementation](https://github.com/SJTU-DeepVisionLab/PosFormer/blob/802019a0533639f3b0bf18d44e93be073945cac5/Pos_Former/model/transformer/arm.py)
also uses those fixed IDs, so changing only native masking could disagree with
training. The normalization diagnostic leaves this masking unchanged.

The [candidate model card](https://huggingface.co/cstr/posformer-mathwriting-GGUF/blob/45eb7de7d8ae26708701f06cae68d96f1abb0ef7/README.md)
claims BSD licensing and lists the old architecture. Those claims do not
resolve training provenance or the official repository's academic-use
wording. Treat this candidate as benchmark evidence, pending provenance and
licensing clarification before any production adoption.

## Independent exported-weight reference comparison

[Hosted run 37213652595](https://github.com/CrispStrobe/CrispMath/actions/runs/37213652595)
at `6a02c4d7e5785f59f42667167e056d0220d2add6` reconstructed the public
MathWriting v2 FP32 export in the
[official PosFormer encoder](https://github.com/SJTU-DeepVisionLab/PosFormer/blob/802019a0533639f3b0bf18d44e93be073945cac5/Pos_Former/model/encoder.py)
and [decoder](https://github.com/SJTU-DeepVisionLab/PosFormer/blob/802019a0533639f3b0bf18d44e93be073945cac5/Pos_Former/model/decoder.py).
All 270 exported tensors were consumed exactly once with checked names,
shapes and FP32 types. Every initialized reference parameter was replaced;
folded convolution/batch-normalization tensors were used as exported, with
no random weights or invented original batch-normalization statistics.

The comparison used the first five cases of the unchanged frozen manifest,
at most five decoder steps each, baseline and normalization repair, and both
default and scalar encoders. Independent grayscale/polarity preprocessing
agreed in all 20 case/arm comparisons. These binary inputs do not trigger
resizing, so resizing and nonbinary image preprocessing remain unverified.
The scalar encoder agreed at every captured stage, including positional
encoding and normalization; the largest absolute error was `3.8147e-6`.

The default GGML encoder first diverged in shape at the initial max pool for
two cases, the first transition average pool for two, and the second
transition average pool for one. It uses floor pooling; the official and
scalar implementations use `ceil_mode=True`. Consequently it drops odd
edge rows or columns. Earlier stages agreed within the fixed default-path
tolerance; that path explicitly uses FP16 convolutions, unlike the FP32
scalar/reference paths. This identifies a concrete pooling mismatch rather
than attributing all encoder differences to arithmetic precision.

The baseline decoder first diverged at its missing post-position input
normalization. With the isolated normalization repair, every captured
token-input, transformer-layer normalization and logit stage agreed across
all 50 case/step comparisons (25 default and 25 scalar), with maximum
absolute error `5.7220e-6`. Decoder checks deliberately use native encoded
features and native token prefixes to isolate decoder behavior. Combined
with the independently checked scalar encoder, this establishes bounded
exported-weight forward parity for the normalization-repaired scalar path.
It does not establish original-checkpoint conversion/training parity,
full-length decoding parity or improved 50-case recognition accuracy.

Artifact `11307279136`, `handwriting-exported-reference-reports`, contains
four comparisons and two source/library provenance records. The retained
baseline library SHA-256 is
`55f4daccf2aaf5fc78d4a8daa235a7bdb2840a76572d7d8b38041f7426a8d7e5`;
the normalization-repaired library is
`4c415f21635a30285d156b532e9bfaf24452cf902698f374ec149ffdff3ae897`.
Both records identify the original `11e6d5…` source, actual instrumented
source, instrumentation tool and normalization patch hashes. Production
bridge/model pins remain unchanged.

## Measured normalization and ceil-pooling repair

[Hosted run 37215287926](https://github.com/CrispStrobe/CrispMath/actions/runs/37215287926)
at `fed79e99f169e3507a6fbc24822ca39a28151350` measured the baseline,
normalization-only and combined normalization/ceil-pooling arms on the same
frozen references, and repeated the independent exported-weight comparison.
Both hosted jobs completed successfully. The combined repair's actual
native pooling helper matched PyTorch exactly in all 16 synthetic controls,
covering even/odd dimensions, corner handling, multiple channels and
single-row/column inputs; wrong floor/zero-padding and invalid-argument
controls passed. Normalization controls covered dimensions 256 and 384,
with maximum error `3.1789e-7`.

After the combined repair, every captured encoder and decoder stage matched
the reference on all five cases and 25 decoder steps per encoder arm.
Default encoder maximum absolute error was `0.00198841`, within the fixed
FP16-versus-FP32 tolerance; scalar encoder maximum was `3.5763e-6`.
Decoder maximum across both arms was `7.6294e-6`. These are bounded
exported-weight comparisons with the preprocessing and decoder-isolation
limits described above, not original-training/checkpoint parity or
full-length decoding parity.

| Model | Baseline | Normalization only | Normalization and ceil pooling |
| --- | --- | --- | --- |
| Original CROHME Q8 | 7/50 | 7/50 | 7/50 |
| MathWriting v2 FP32 candidate | 0/50 | 0/50 | 0/50 |

All seven originally correct IDs are preserved in both repaired arms:
`0111fa141bb73b48`, `02c39c1be9d660b7`, `0276c02c9b9222e9`,
`0333d9584ff7c0d0`, `002ae6d5dd4173e4`, `02da6f52e30f674d`,
`032278982233fefa`. Baseline-to-normalization and baseline-to-combined
token-output changes were 35 and 38 for the original model, and 49 and 48
for the candidate. Normalization-to-combined changes were 16 and 47.
No runtime failures occurred. No recognition-accuracy gain was measured;
the original vocabulary gaps and the remaining model-quality errors persist.

Quality artifact `11308057664` and reference artifact `11308561639` retain
the strict paired reports and actual source/library/patch provenance.
The combined diagnostic patch SHA-256 is
`79e6e53ba5f1aba9a484ac88261d9dfa5060f7f61a18db47b602c0d5f1343e4d`.
The uninstrumented repaired source SHA-256 is
`9106567aa2d0d0386db1f962d0e4e16bdb500110fa915d7b70de6458440770ec`,
and its quality-test library is
`1c907d77efed09a6fe3eadc321f3044e4c6ae5d69ea6a8fc0b9b6501d789781b`.
The separate instrumented reference library is
`d7c881d7273c85c25e9b55fd3b02861e83aacdbb850190dd22a6d34aeb6082a0`;
its reports identify the additional instrumentation source/tool hashes.

The measurements justify preparing a minimal upstream runtime correction,
without diagnostic exports, followed by matching hosted native/WASM builds,
source/binary provenance, platform checksums and app regression checks.
Production promotion is held until after the first app PR merge; current
bridge/model pins remain unchanged. Candidate weights remain excluded from
production because these results establish neither improved accuracy nor
resolved training/licensing provenance.

## Reproducibility

| Identity | Pinned value |
| --- | --- |
| Native bridge | `11e6d598521976f38081934106b55095b46b40e3` |
| PosFormer Q8 weights SHA-256 | `450211ad27ce19e2f30651e69fdc77ea76a13b66e29e045858286024864bf4a4` |
| MathWriting archive SHA-256 | `cba038def001480a89962b25cb20a60df4c4145e94c86ef9d2af65f192cb82bc` |
| Frozen 50-case manifest SHA-256 | `a2edabf8937298a52f072c41917bf4a8022ecaee9a50d00dcc1d52934b711109` |
| Actual tokenizer SHA-256 | `8cbbeff7fdd14ef06c1d86f73500ae8f255be09bf1e09c27c74a42c57044d080` |

Selection ranks test IDs by SHA-256 with the fixed
`CrispMath-2026-10-02` seed. Scoring removes only whitespace and the BPE
separator; equivalent alternate LaTeX is not an exact match. Images and
references are identical across paired arms, checked by hashes. The
[pinned model card](https://huggingface.co/cstr/posformer-crohme-GGUF/blob/230657859144cc43a88605a4e737b47929181d4c/README.md)
describes CROHME training with a limited MathWriting supplement and the
canonical vocabulary. Its CROHME scores do not establish quality on these
MathWriting samples.

Run the unchanged three-model baseline and actual-tokenizer audit on a
GitHub-hosted runner:

```sh
gh workflow run handwriting-quality.yml --ref feat/graph-workspace-ux
```

Only when another paired encoder diagnostic is needed:

```sh
gh workflow run handwriting-quality.yml --ref feat/graph-workspace-ux \
  -f scalar_posformer=true
```

To reproduce the separate expanded-vocabulary candidate measurement:

```sh
gh workflow run handwriting-quality.yml --ref feat/graph-workspace-ux \
  -f mathwriting_candidate=true
```

To run the controlled normalization diagnostic on both models:

```sh
gh workflow run handwriting-quality.yml --ref feat/graph-workspace-ux \
  -f input_norm_diagnostic=true
```

To run the bounded exported-FP32 reference comparison on hosted CPU:

```sh
gh workflow run handwriting-quality.yml --ref feat/graph-workspace-ux \
  -f reference_parity=true
```

This explicitly selects the separate
[reference job](../.github/workflows/handwriting-reference-parity.yml),
without repeating the baseline quality batch. The
[reference helper](../tool/handwriting_reference_parity.py),
[native instrumentation](../tool/prepare_handwriting_reference_bridge.py)
and [negative controls](../tool/handwriting_reference_parity_test.py) reject
changed corpus/model/source identities, missing or extra tensors, wrong
shapes, truncated/nonfinite traces and mismatched library/patch provenance.
Numeric controls run only in that hosted job; ordinary tool discovery
requires no PyTorch, GGUF or NumPy installation. A completed diagnostic run
does not mean all stage comparisons passed: measured mismatches stay in its
reports.

To measure the diagnostic normalization-plus-ceil-pooling repair alongside
the same-source baseline and normalization-only arms, and repeat the
bounded independent reference checks:

```sh
gh workflow run handwriting-quality.yml --ref feat/graph-workspace-ux \
  -f forward_repair_diagnostic=true -f input_norm_diagnostic=true
```

The [combined diagnostic patch](../tool/patches/posformer-forward-repair.patch)
replicates only missing odd edges before pooling, preserving valid-sample
averages at the last row, column and corner. Its real native helper is
exercised by [16 PyTorch pooling controls](../tool/check_posformer_pooling.py),
including multiple channels, negative edges, even/odd dimensions and
single-row/column inputs. The
[paired comparator](../tool/compare_handwriting_forward_repair.py) additionally
checks actual repaired-source/patch/library provenance and all frozen 50
references. These are diagnostic changes; results determine any later
production decision.

The [workflow](../.github/workflows/handwriting-quality.yml) retains
`handwriting-vocabulary.json`, the three baseline reports, and optional paired
reports in `real-handwriting-quality`. The
[vocabulary audit](../tool/audit_handwriting_vocabulary.py) and its
[regression tests](../tool/audit_handwriting_vocabulary_test.py) validate
actual metadata, frozen identities and lexical coverage. The
[paired comparator](../tool/compare_handwriting_encoders.py) and its
[regression tests](../tool/compare_handwriting_encoders_test.py) reject
incomplete, changed or inconsistently scored evidence. Inference runs through
the real native bridge in
[handwriting_quality_test.dart](../native_test/handwriting_quality_test.dart).

## Next requirements

A model supporting the missing tokens needs a compatible expanded vocabulary
and trained embedding/output weights; changing only tokenizer metadata cannot
teach those symbols. Validate such a model on independent held-out samples,
preserving these frozen references and reporting both coverage and accuracy.

The diagnostic GGML pooling repair now has bounded independent stage
agreement and preserves all seven correct original-model cases in the
unchanged 50-case measurement. A production correction still requires new
matching runtime binaries and checksums; recognition quality has not
improved on this benchmark.

Original-checkpoint conversion and training parity still require the
corresponding checkpoint. The published checkpoint repository returned
HTTP 401 to anonymous access. No usable Hugging Face training credentials or
Kaggle credentials were available during this session. No training was
started, and no additional blind encoder ablation is warranted by the current
evidence.
