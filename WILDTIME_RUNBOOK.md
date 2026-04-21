# Wild-Time Yearbook — step-by-step

I cannot run this inside the sandbox. This is the procedure for the machine
that has network and disk space.

## What this directory contains

| File | Purpose |
|---|---|
| `wildtime_loader.py` | Reads Wild-Time's yearbook.pkl, produces the same interface as `data.py` |
| `cnn_encoder.py` | Drop-in CNN replacement for LocalEncoder (MLP will underfit 32x32 images) |
| `preflight_wildtime.py` | Runs before the sprint. Catches every failure mode I could anticipate. |
| `run_wildtime.py` | Full sprint driver: 10 variants × 3 seeds, phase-splittable |

## What I verified here before shipping

- The adapter returns `(A, A_norm, (Xtr, ytr), (Xst, yst), shift)` with shapes `(8,8), (8,8), (40,8,1024), (44,8,1024), 0` — matching the documented Wild-Time format with N=8 nodes.
- The CNN encoder passes a gradient check.
- The full 10-variant driver runs end-to-end in ~30 seconds on a 4-year fixture pickle built in the exact documented format.
- Every artifact (results table, latency table, adaptation figure, ablation figure) generates correctly.
- The v2 modules (`modules.py`, `models.py`, `train.py`) require **zero code changes** — only the `LocalEncoder` is monkey-patched to CNN at import time.

## What I did NOT verify

- The accuracy numbers. The fixture has random labels, so the sprint produced ~0.50 accuracy for every variant, as expected. Real accuracies require real Wild-Time data.

## Step-by-step instructions

### 1. Prerequisites
```bash
python3 -m pip install numpy scipy matplotlib pandas
# no PyTorch needed; everything is pure NumPy
```

### 2. Get Wild-Time
```bash
git clone https://github.com/huaxiuyao/Wild-Time
cd Wild-Time
# Follow their README to download yearbook.pkl (~100 MB)
# Expected path: <somewhere>/yearbook.pkl
```

### 3. Stage code
```bash
# Assuming v2_frozen/ contains data.py, modules.py, models.py, train.py, metrics.py, run.py
cp wildtime_adapter/*.py v2_frozen/
cd v2_frozen
```

### 4. Preflight (do this before the expensive run)
```bash
export WILDTIME_ROOT=/absolute/path/to/directory/containing/yearbook.pkl
python3 preflight_wildtime.py
```

Expected output (5 checks, all `[ok]`, ending with `ALL PREFLIGHT CHECKS PASSED`):

```
[ok]   WILDTIME_ROOT=<your path>
[ok]   pickle loads; 84 years; 1930 has <N> images of shape (1, 32, 32)
[ok]   adapter returns Xtr=(40, 8, 1024), Xst=(44, 8, 1024), labels in {0,1}
[ok]   CNN encoder gradient check passed: max_rel=<small>, max_abs=<small>
[ok]   1-epoch LocalOnly on Wild-Time Yearbook: acc=<something>  time=<s>
[ok]   sanity floor cleared: LocalOnly pre-shift acc = <>0.55 after 3 epochs
```

If any check fails, the error message will tell you exactly what went wrong.

### 5. Full sprint
```bash
# Either all at once (~10-20 min CPU):
python3 run_wildtime.py

# Or in phases if your environment has per-process timeouts:
PHASE=baselines  python3 run_wildtime.py   # ~2-4 min
PHASE=proposed   python3 run_wildtime.py   # ~2-3 min
PHASE=ablations  python3 run_wildtime.py   # ~5-8 min
PHASE=finalize   python3 run_wildtime.py   # seconds (aggregates partials, makes figures)
```

### 6. Read the results

Outputs land in `outputs_wildtime/`:

- `results_table.csv` — all 10 variants × key metrics (acc, acc_sd, acc_early, acc_late, ECE, p50/p95 ms, K_mean)
- `results_aggregate.csv` — same with full aggregation
- `results_raw.csv` — per-seed numbers for variance analysis
- `latency_table.csv` — latency percentiles
- `adaptation_figure.png` — accuracy across years 1970–2013
- `ablation_figure.png` — ablation summary
- `config.json` — exact hyperparameters used

## How to read the outcome

From the sprint-3 harder stand-in, the four-pillar framing of the manuscript
is already not supportable. The residual gate and the adaptive scheduler
did not earn their place on harder synthetic data. Wild-Time is the final
falsification test.

### Outcome A — residual gate and scheduler earn their place

Criterion:
- `proposed_full` acc > `abl_no_residual` acc by more than 2σ, AND
- `proposed_full` acc > `abl_frozen_scheduler` acc by more than 2σ.

Implication: four-pillar framing survives. Paper is defensible as originally pitched.

### Outcome B — graph coordination + aggregation earn their place; residual and scheduler do not

Criterion:
- `graph_no_residual` and `proposed_full` both beat `local_only` by more than 2σ, but
- `abl_no_residual` and/or `abl_frozen_scheduler` match `proposed_full` within 2σ.

Implication: narrow the paper's contribution from four pillars to two. Still publishable, just a narrower claim.

### Outcome C — graph coordination does not transfer to Yearbook

Criterion:
- `graph_no_residual` does not beat `local_only` by more than 2σ.

Implication: the architecture's inductive bias (cross-node averaging of a shared latent factor) does not apply to Yearbook, where each image is independent. This is not a bug; it is a characterization. The paper should explicitly scope the claim to tasks with shared-signal structure (multi-site sensing, cohort-based clinical prediction, federated learning over correlated data). Then run the sprint on MIMIC or arXiv where such structure exists.

All three outcomes are informative. **Outcome C is the most important to detect early** because it reframes the whole paper. If C holds, the v2 architecture is correct but its applicability is narrower than the manuscript currently claims.

## Notes and gotchas

- **Encoder capacity.** If local_only gets stuck near chance on real Yearbook, the CNN in `cnn_encoder.py` is too small. Bump channels: replace `CNNEncoder(d_lat, rng)` with `CNNEncoder(d_lat, rng, c1=16, c2=32)`. If still stuck, the encoder needs a third conv layer — at that point you should port to PyTorch.
- **Learning rate.** Default `lr=0.02` is based on the fixture. Real Yearbook may need `lr=0.005` or `lr=0.01`. If training loss oscillates, lower it.
- **Seeds.** 3 seeds is the floor. For a submission, run 5+ and report standard error.
- **Yao et al. 2022 comparison point.** Table 18 reports Yearbook ERM at 77.9% avg accuracy in the Eval-Fix setup. Our `local_only` under the Eval-Stream setup should land in a comparable range. If it's below 0.60, something is wrong with encoder capacity or LR, not with the architecture comparison.
- **`abl_no_graph` and `abl_flat_latent`.** These are ablations that remove or replace the graph layer. On Yearbook — where per-timestep samples are independent — they *might not collapse* the way they did on the stand-in, because there's no shared-signal structure for the graph to exploit. If they don't collapse, that's Outcome C above: the graph's value is task-specific, and the paper's claim should reflect that.

## Claim-ceiling cheat sheet

Before running Wild-Time:
- **Max supportable claim:** graph coordination with skip+norm + aggregation helps on temporal-shift tasks with shared-signal structure.
- **Min supportable claim:** the architecture composes correctly, trains cleanly, and has identifiable and measurable components.

After a successful Outcome A on Wild-Time:
- **Max supportable claim:** full four-pillar framing, empirically defensible on synthetic multi-regime drift AND real Wild-Time Yearbook.

After Outcome B:
- **Max supportable claim:** graph coordination under temporal shift; residual gating and adaptive scheduling as optional extensions for tasks where they help.

After Outcome C:
- **Max supportable claim:** graph coordination for tasks with shared-signal structure under temporal shift. Must run MIMIC or similar to confirm.

**Do not claim more than the data supports.** All three outcomes give you a publishable paper if framed honestly.
