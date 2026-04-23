# Baseline DCRNN Multi-Seed (2026-04-23)

**Status:** TIER 1 - baseline variance triangle complete.
**Outcome:** §16 V4=c Option 1 does NOT improve over baseline. Matched 3-seed comparison overlaps within ±1σ; §16 mean is 0.048 MAE worse.

## Configuration

- Config: dcrnn_la_parallel_stream_OFF.yaml (§16 flags OFF)
- Dataset: METR-LA, reduced regime (10 epochs)
- GPU: NVIDIA RTX PRO 6000 Blackwell (G4, ~2.2x speedup over A100)
- Runtime per seed: ~14 min
- Total params: 372,353

## Results per seed

### Seed 2 (test_mae: 3.0663, best_val 2.8916 epoch 9)
### Seed 3 (test_mae: 3.1395, best_val 2.9523 epoch 9)

## Baseline 3-seed aggregate

| Seed | test_mae |
|------|----------|
| 1 | 3.2176 |
| 2 | 3.0663 |
| 3 | 3.1395 |

Mean: **3.1411**, Std: **0.0757** (< 0.1 threshold)

## Matched comparison

| Model | mean | std | params |
|-------|------|-----|--------|
| baseline | 3.1411 | 0.0757 | 372,353 |
| §16 V4=c Option 1 | 3.1892 | 0.0628 | 3,149,712 |

Delta §16 - baseline: **+0.0481 MAE** (§16 worse)

Ranges ±1σ:
- §16 V4=c: [3.126, 3.252]
- baseline: [3.066, 3.217]
- Overlap. Not distinguishable.

## Honest interpretation

§16 V4=c Option 1 does NOT improve over baseline. 8.5x more parameters provides no measurable benefit. Mean is 0.048 MAE worse than baseline. Ranges overlap within 1σ — not statistically distinguishable at this sample size.

Earlier single-seed comparison (commit 3c4b1c6) showed apparent delta -0.028 (§16 better). That comparison was not matched. With matched 3-seed: delta flips to +0.048 (§16 worse). Apparent advantage was seed noise.

## Claim boundary

Can say:
- Baseline DCRNN achieves 3.14 ± 0.08 across 3 seeds (reduced)
- §16 V4=c does not improve over baseline in this regime
- Both mechanically correct

Cannot say:
- §16 worse with statistical significance (overlap)
- Full training would reveal different result
- Different hyperparameters would not help §16

## Next movements

1. Fair-capacity baseline (rnn_units 192, ~3M params without §16 machinery)
2. Best-val checkpoint evaluation
3. Hyperparameter sensitivity (divergence_loss_weight 0.05 and 0.2)
4. Post-Pro+: full training 100 epochs

## Governance

Protocol worked: matched comparison done before any external improvement claim. §16 remains Tier 1 mechanically but loses any implicit benefit framing. The partial reports never claimed improvement — they claimed "essentially identical to baseline." Matched comparison confirms that framing.
