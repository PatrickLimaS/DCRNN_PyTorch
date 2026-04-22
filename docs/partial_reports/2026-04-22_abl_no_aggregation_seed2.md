# Partial Report - abl_no_aggregation Seed 2

Date: 2026-04-22. Environment: A100-SXM4-80GB.

Classification: PIPELINE_VALIDATED_REDUCED_MULTI_SEED.

## Seed comparison

| Metric | Seed 1 | Seed 2 | Delta |
| --- | --- | --- | --- |
| best val_mae | 3.1129 (ep 9) | 3.1241 (ep 8) | +0.0112 |
| final val_mae | 3.1129 | 3.2493 | +0.1364 |
| final test_mae | 3.3295 | 3.4662 | +0.1367 |
| runtime (min) | 33.0 | 31.7 | -1.3 |

## Interpretation

Best val_mae highly reproducible across seeds (delta ~0.01). Final test_mae variance (~0.14) is comparable to baseline-vs-ablation delta (~0.11), indicating observation is near the noise floor at this seed count.

## Claim boundary

Two seeds confirm pipeline reproduces stable best-val_mae. Not sufficient for statistical significance. The direction of the baseline-vs-ablation comparison is consistent but the magnitude is near noise floor.

## Next

- probingnoise_graph_core in absolute regime
- local_only in absolute regime
- abl_no_graph in absolute regime
- second seed of baseline for symmetric variance analysis
