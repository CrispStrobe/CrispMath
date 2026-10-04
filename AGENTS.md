# Shared VPS resource policy

The user requires this VPS to remain available for other work.

- Before any potentially costly local command, check `uptime`, `free -h`, and
  `df -h / /mnt/volume1`. Consider load, available RAM, swap and free disk together.
- Run builds, full analysis/test suites, CLI corpus batches, Playwright batches,
  native screenshot capture and model benchmarks on GitHub-hosted CI runners.
  These instructions do not restrict work inside those isolated CI runners.
- Use Kaggle for GPU-heavy training when it is available and the task authorizes
  that work. Do not install or run large training workloads on the VPS.
- Keep local work to edits, small targeted checks and remote status queries.
  Do not launch local compute jobs while load is high or memory/disk is tight.
- Download only the reports or images needed for review; keep large app bundles,
  models and datasets in remote artifacts. Avoid repeated artifact downloads.
- Clean up only known transient outputs from this task. Do not terminate other
  projects' processes or remove their files, caches, toolchains or credentials.
- Recheck resources before starting another local batch; an earlier healthy
  measurement does not authorize later heavy work.
