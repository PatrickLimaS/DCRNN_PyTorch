# Partial Report — abl_no_aggregation Reduced Run

**Date:** 2026-04-22
**Environment:** Colab Pro, NVIDIA A100-SXM4-80GB, PyTorch 2.10.0+cu128

## Classification

**PIPELINE_VALIDATED_REDUCED** — same regime as cleared baseline. First ablation with metric scale (absolute MAE) directly comparable to `dcrnn_baseline`.

## Configuration

Flags (from `data/model/dcrnn_la_probingnoise_abl_no_aggregation.yaml`):

- `use_graph`: True
- `use_aggregation`: False
- `use_graph_skip_ln`: True
- `use_agg_skip_ln`: False

Note: this differs from `dcrnn_baseline` (which uses no probingnoise flags). It is an ablation *within* the Probingnoise family, not an ablation of DCRNN vanilla.

## Full metric trajectory

| Epoch | train_mae | val_mae | Saved |
| :--- | :--- | :--- | :--- |
| 0 | 3.6872 | 3.9534 | yes |
| 1 | 2.4512 | 3.6180 | yes |
| 2 | 2.4162 | 5.0948 | no |
| 3 | 2.3368 | 3.3600 | yes |
| 4 | 2.3023 | 3.6821 | no |
| 5 | 2.2903 | 3.2581 | yes |
| 6 | 2.2302 | 3.3191 | no |
| 7 | 2.2611 | 3.7757 | no |
| 8 | 2.2366 | 3.2409 | yes |
| 9 | 2.2002 | **3.1129** | yes (best) |

Final test_mae (epoch 9): **3.3295**.
Runtime: 33.0 min.

## Comparison with dcrnn_baseline

| Metric | dcrnn_baseline | abl_no_aggregation | Delta |
| :--- | :--- | :--- | :--- |
| best val_mae | 3.0191 (ep 5) | 3.1129 (ep 9) | +0.094 |
| final val_mae | 3.0280 (ep 9) | 3.1129 (ep 9) | +0.085 |
| final test_mae | 3.2176 | 3.3295 | +0.112 |
| final train_mae | 2.0959 | 2.2002 | +0.104 |
| parameter count | 372,353 | 372,865 | +512 |
| runtime | 31.0 min | 33.0 min | +2.0 |

Baseline outperforms abl_no_aggregation on all four loss metrics despite abl_no_aggregation having a marginally larger parameter count. The baseline's val_mae converged earlier (epoch 5) while abl_no_aggregation's best came at epoch 9, suggesting the ablation trains less stably.

## Claim boundary

- Both runs: 10 epochs, A100, same dataset, same optimizer. Comparable in regime.
- Neither is a benchmark reproduction of Li et al. (2018). The paper uses 50+ epochs with a different hyperparameter protocol.
- `abl_no_aggregation` is an ablation of the **Probingnoise** variant family. It is not an ablation of DCRNN vanilla. A full matrix comparison requires running `local_only`, `abl_no_graph`, and `probingnoise_graph_core` in the same regime.
- The +0.112 delta in test_mae is observable but not statistically characterised (single seed, single run).

## What this result permits claiming

- The pipeline runs end-to-end for this ablation variant under the same regime as the baseline.
- The val/test loss differences between baseline and this ablation are observable in a controlled 10-epoch setup.
- The difference is in the direction expected if the aggregation block was providing useful signal to the baseline's graph-conditioned path.

## What this result does NOT permit claiming

- That abl_no_aggregation is categorically worse than baseline (requires multiple seeds and full-regime runs).
- That any specific component (aggregation, skip_ln) is load-bearing (requires isolated ablation matrix).
- That Probingnoise overall improves over or degrades relative to baseline (requires the full 4-run matrix).

## Next movements

1. Run `local_only` (all flags False except baseline flags) in this same regime.
2. Run `abl_no_graph` in this same regime.
3. Run `probingnoise_graph_core` (all four flags True) in this same regime.
4. With all 4 ablation rows + baseline, produce a 5-row comparison table. Only then consider any claim-tier promotion for individual Probingnoise components.
5. The comparison table is the first place in the project where a first-order capability claim could be made, subject to multi-seed repetition being scheduled separately.
