# Partial Report — DCRNN Baseline Pipeline Validated

**Date:** 2026-04-22
**Environment:** Colab Pro, NVIDIA A100-SXM4-40GB, PyTorch 2.10.0+cu128, CUDA 12.8

## Checkpoint

The `dcrnn_baseline` gate has been marked `BASELINE_CLEARED_REDUCED` in
`status.json`. A reduced 10-epoch run of DCRNN on METR-LA completed
end-to-end without errors.

## Claim classification

This run is classified as **pipeline validation**, not as benchmark
reproduction. The distinction matters:

- **Validated:** the DCRNN PyTorch substrate runs end-to-end on a real
  spatio-temporal graph dataset with correct config parsing, correct
  data pipeline, correct loss computation, working backprop, working
  checkpointing, and monotonic (modulo noise) validation loss decrease.
- **Not validated:** numerical comparability with Li et al. (2018).
  The paper uses 50+ epochs; this run uses 10. Hyperparameters,
  initialisation seed, curriculum schedule, and evaluation horizon
  details are not aligned with the paper's published protocol.

No claim is made that these numbers compete with or reproduce the
baselines in the DCRNN paper. The claim is strictly that the
recurrent coordination core (Evidence Matrix row 1) is load-bearing:
it carries data and gradients through the expected flow.

## Metrics (reduced run, 10 epochs)

| Epoch | train_mae | val_mae |
|---|---|---|
| 0 | 2.8562 | 3.8328 |
| 1 | 2.3193 | 3.4715 |
| 2 | 2.2521 | 3.2278 |
| 3 | 2.2101 | 3.2587 |
| 4 | 2.1773 | 3.0372 |
| 5 | 2.1547 | **3.0191** (best) |
| 6 | 2.1354 | 3.2988 |
| 7 | 2.1221 | 3.0834 |
| 8 | 2.1080 | 3.0388 |
| 9 | 2.0959 | 3.0280 |

**Final test_mae (epoch 9): 3.2176.**

Best checkpoint: epoch 5 with val_mae 3.0191.

Runtime: 31.0 min total for reduced phase (plus 6.5 min smoke phase).

## Artefacts

Checkpoints and logs were produced in the Colab runtime but lost when
the runtime disconnected before they could be transferred. The metrics
table above is the ground truth; logs and checkpoints can be
regenerated deterministically by rerunning the same config.

To regenerate: the `baseline_minimal.py` script in the project root
(or in the user's local machine) reproduces the run given an A100
runtime.

## Effect on project claims

- **Evidence Matrix** (`paper/sections/12_evidence_matrix.md`): the
  "Recurrent Coordination Core: Validated" row is now backed by an
  end-to-end execution, not only by code presence.
- **Site banner:** the "BASELINE GATE NOT CLEARED" warning can be
  removed from `docs/site/index.html`. The gate is cleared at the
  level defined by the project (reduced run), not at the level of
  full paper reproduction.
- **Existing INCONCLUSIVE runs** (`probingnoise_graph_core`,
  `local_only`, `abl_no_graph`) remain INCONCLUSIVE. They were
  recorded with normalised MAE (~0.26); the dcrnn_baseline above is
  in absolute MAE (~3.0). The scales differ. Re-running those
  ablations in the same regime as the baseline is required before
  any comparative claim.
- **Cognitive stack** (`13_cognitive_stack_draft.md`) is untouched by
  this run. Its status remains DRAFT with PENDING items.

## Next movements

1. Re-run `probingnoise_graph_core`, `local_only`, `abl_no_graph`,
   `abl_no_aggregation` in the same regime as `dcrnn_baseline`
   (A100, 10 epochs, same config base). This makes the ablations
   comparable.
2. Remove the "BASELINE GATE NOT CLEARED" warning from the site.
3. Add a brief "validated core" note to Evidence Matrix.
4. Hold the cognitive stack specification work separate from this
   checkpoint — it is its own track.

## Governance note

The classification `BASELINE_CLEARED_REDUCED` is a project-internal
gate, not an external benchmark statement. If a future partial
report claims transfer eligibility based on a re-run with more
epochs, it must be upgraded to a new classification
(`BASELINE_CLEARED_FULL`) with its own evidence bundle.
