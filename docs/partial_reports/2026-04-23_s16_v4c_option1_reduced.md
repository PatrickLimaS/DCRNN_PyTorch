# §16 V4=c Option 1 — Reduced Run (2026-04-23)

**Status:** TIER 1 — first Tier 3 → Tier 1 promotion in the project.
**Classification:** PIPELINE_VALIDATED_REDUCED + EXTENSION_EMPIRICAL_SINGLE_SEED

## Claim boundary

- §16 V4=c Option 1 is implemented and empirically tested for the first time.
- Single seed. Not sufficient for categorical comparison against baseline (variance observed in prior ablations is ~0.14; here delta is +0.035).
- Architectural effect cannot be separated from capacity effect in this experiment: §16 V4=c has 8.5x more parameters than baseline.
- No claim of improvement. No claim of harm. Both are within noise floor of single-seed comparison.

## Implementation

Commit: 003a7ff (last of 11 iterations; 20d31f3 contains the conceptual rewrite).

Architecture (corrected reading of probingnoise_blocks.py):
- Single LocalGlobalAggBlock called with return_parts=True, exposing (y, z_local, z_global, delta)
- DivergenceHead(dim_in=num_nodes*rnn_units, dim_out=output_dim*num_nodes) receives (z_local, z_global)
- Auxiliary loss computed against main target, weighted by divergence_loss_weight=0.1
- Auxiliary loss added in both train and evaluate loops

Conceptual amendment required in §16 of paper: original spec described V1-V3-V4 as "second parallel stream + gate + DivergenceHead." Implementation reveals the parallel stream was always internal to LocalGlobalAggBlock.

## Configuration

- Config: data/model/dcrnn_la_parallel_stream.yaml
- Flags: use_parallel_stream=True, use_divergence_head=True, divergence_loss_weight=0.1
- Dataset: METR-LA, reduced regime (10 epochs)
- GPU: A100 80GB, runtime 31.4 min

## Results

Total trainable parameters: 3,149,712 (vs baseline 372,353 - 8.5x capacity)

Training trajectory:

| Epoch | train_mae | val_mae |
|-------|-----------|---------|
| 0 | 2.9687 | 3.8124 |
| 1 | 2.3794 | 3.3131 |
| 2 | 2.3145 | 3.6282 |
| 3 | 2.2686 | 3.1383 |
| 4 | 2.2194 | 3.0633 |
| 5 | 2.2009 | 3.0528 |
| 6 | 2.1705 | 2.9636 (best val) |
| 7 | 2.1530 | 3.0432 |
| 8 | 2.1405 | 3.5191 |
| 9 | 2.1368 | 3.0443 |

Final test_mae (epoch 9): **3.2525**
Best val_mae: **2.9636** (epoch 6)

## Comparison

| Row | Model | test_mae | params | seeds |
|-----|-------|----------|--------|-------|
| 1 | dcrnn_baseline | 3.2176 | 372,353 | 1 |
| 2 | abl_no_aggregation | 3.3295 / 3.4662 | 372,865 | 2 |
| 3 | §16 V4=c Option 1 | 3.2525 | 3,149,712 | 1 |

Delta §16 vs baseline: +0.035 MAE (§16 slightly worse).
Noise floor observed in abl_no_aggregation: 0.14 MAE.
Delta of +0.035 is well within noise floor — no categorical claim possible.

## Honest interpretation

What this run shows:
- §16 V4=c Option 1 is mechanically correct (non-regression preserved in OFF, training converges, eval runs, DivergenceHead receives gradients)
- Test MAE comparable to baseline despite 8.5x parameter count
- Val_mae oscillates more than baseline; possible causes: aux loss weight, DivergenceHead not yet converged, or §16 genuinely unstable in reduced regime

What this run does NOT show:
- Whether §16 V4=c improves test MAE (1 seed insufficient)
- Whether §16 V4=c reaches lower test MAE in longer training
- Whether test MAE at best-val checkpoint (epoch 6) would be lower

## Next movements

1. Multi-seed: 2 additional seeds to establish variance
2. Fair capacity comparison: baseline with ~3M params
3. Best-val checkpoint evaluation: test on models/epo6.tar
4. Paper §16 amendment (in this commit)

## Governance note

First Tier 3 → Tier 1 promotion. Path: 11 iterations, 9 bugs caught, conceptual re-reading at iteration 9, diagnostic script validation before commit, two smoke tests, one reduced run. No false Tier 1 claim made during process.

---

## Update 2026-04-23: Seed 2 results

Second seed of §16 V4=c Option 1 via run_with_seed.py wrapper (torch.manual_seed(2) before training imports).

Trajectory (seed 2):

| Epoch | train_mae | val_mae |
|-------|-----------|---------|
| 4 | 2.2196 | 3.0743 |
| 5 | 2.1898 | 3.0228 |
| 6 | 2.1661 | 3.0248 |
| 7 | 2.1617 | 3.1585 |
| 8 | 2.1310 | 2.9486 (best val) |
| 9 | 2.1167 | 2.9887 |

Final test_mae: **3.1883**
Best val_mae: **2.9486** (epoch 8)
Runtime: 31.2 min

## Multi-seed summary (2 seeds)

| | Seed 1 | Seed 2 |
|---|---|---|
| best_val_mae | 2.9636 | 2.9486 |
| test_mae | 3.2525 | 3.1883 |

Delta seeds: 0.064 MAE (within 0.1 stability threshold).
Mean test_mae: 3.2204
Std (n=2): 0.0454

## Updated comparison

| Row | Model | test_mae (mean) | params | seeds |
|-----|-------|-----------------|--------|-------|
| 1 | dcrnn_baseline | 3.2176 | 372,353 | 1 |
| 2 | abl_no_aggregation | 3.3979 | 372,865 | 2 |
| 3 | §16 V4=c Option 1 | 3.2204 | 3,149,712 | 2 |

Delta §16 vs baseline: +0.003 MAE (essentially identical).

## Honest interpretation updated

- §16 V4=c produces test_mae 3.22 ± 0.05 across 2 seeds
- Mean essentially identical to baseline (delta +0.003)
- With 8.5x more parameters, §16 reaches same test performance
- Does not overfit despite large capacity - possible regularization from DivergenceHead aux loss

No claim of improvement. No claim of harm. Next: seed 3 to complete statistical triangle.
