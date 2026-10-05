# CrispMath agent entry point

Read the [current state and executable lanes](https://github.com/CrispStrobe/CrispMath/blob/main/docs/current-state-and-next-steps.md) first, then select
one bounded lane and consult PLAN.md and the linked public evidence. Historical
HISTORY.md entries are dated evidence, not instructions to repeat completed work.

## Resource and evidence policy

- Before potentially costly work on shared infrastructure, inspect load, available
  RAM, swap and free space. Keep that host available for other work.
- Run builds, full analysis/test suites, CLI corpora, browser batches, native
  screenshots and model benchmarks on GitHub-hosted CI runners. Use authorized
  remote GPU infrastructure for large training. These limits do not restrict
  isolated hosted runners.
- Keep shared-host work to edits, small targeted checks and remote status queries;
  do not launch compute batches while resources are constrained.
- Retain large models, datasets and app bundles as remote artifacts. Download only
  the reports or selected images needed for review and avoid duplicate fetches.
- Clean only known transient task outputs. Do not stop other projects or remove
  their files, caches, toolchains or credentials. Recheck before later batches.
- Public Markdown contains public source/workflow/service links. Machine paths,
  private access references and operator details belong in private environment
  notes outside either repository. Never commit credential values.
- Preserve frozen mathematical references and initial failures. Require actual
  CLI/native/browser behavior and meaningful wrong-answer controls; component
  parity, simulated devices and external beta approval have distinct limits.

See [CrispEmbed's handoff](https://github.com/CrispStrobe/CrispEmbed/blob/main/docs/current-state-and-next-steps.md)
for vendor-owned tasks. Do not silently upgrade the immutable app dependency or
merge unrelated vendor changes while carrying documentation between repositories.
