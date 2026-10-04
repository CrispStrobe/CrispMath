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

Before attributing the remaining errors solely to training, obtain the
corresponding checkpoint and reproduce the same inputs and decoding in an
independent Python reference. The published checkpoint repository returned
HTTP 401 to anonymous access. No usable Hugging Face training credentials or
Kaggle credentials were available during this session. No training was
started, and no additional blind encoder ablation is warranted by the current
evidence.
