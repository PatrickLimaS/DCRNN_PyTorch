# Sprint 3 — Final Report

**Date:** 2026-04-19
**Scope:** (a) freeze v2 architecture, (b) re-run packet on harder stand-in, (c) deliver Wild-Time adapter, (d) honest disclosure about what was and was not actually run.

---

## 1. Executive summary

Three things happened in this sprint.

**One:** v2 architecture is frozen and reproducible. Six files, MD5s recorded, all results from the previous sprint regenerate with `python3 run.py`. See `v2_frozen/FROZEN.md`.

**Two:** I ran the same 10-variant × 3-seed packet on a **harder stand-in** designed to be structurally closer to Wild-Time (longer horizon, higher dimensionality, multi-regime drift with rotation + class-prior flip + recovery, heterogeneous per-node observation noise). The headline result is a nuanced one the authors need to understand before attempting real Wild-Time:

- **proposed_full: 0.764 ± 0.006** beats local_only (0.618) by +14.6 pp
- **graph_no_residual: 0.759 ± 0.006** — essentially tied with proposed_full (indistinguishable at this noise level)
- **abl_no_residual: 0.779 ± 0.018** — *beats* proposed_full
- **abl_frozen_scheduler: 0.769 ± 0.015** — matches proposed_full
- **abl_no_graph: 0.608**, **abl_flat_latent: 0.479** — both collapse

The architectural implication: **graph coordination (with skip+norm) + aggregation** is carrying the win. The residual gate and the adaptive scheduler *do not earn their place* on the harder stand-in. This is a materially different story from v2, where the scheduler at least saved compute at matched accuracy. On the harder task, removing the residual and freezing K=1 is not just equal to the full system — it is slightly better.

**Three:** I cannot run real Wild-Time in this sandbox. No network access, no cached data. I built a complete Wild-Time adapter (`wildtime_adapter/wildtime_loader.py`) that the user can run off-sandbox with one environment variable. What I *did not do* is claim Wild-Time results I cannot produce.

---

## 2. Honest disclosure on Wild-Time

I confirmed in this session that:

- `urllib.request.urlopen` → blocked (URLError)
- No Wild-Time data cached in `/root/.cache`, `/data`, `/datasets`, `~/.cache/torch`, or HuggingFace cache locations
- The only Wild-Time-adjacent file on this machine is `/usr/share/doc/libwildmidi2` (midi library, unrelated)

Any numbers labeled "Wild-Time" from this session would be fabricated. I refuse to produce them.

What I produced instead:

- **`wildtime_adapter/wildtime_loader.py`** — 140-line runnable adapter targeting Wild-Time's Yearbook task. Reads Yao et al. 2022's pickle format, implements the training years [1930-1969] / streaming years [1970-2013] Eval-Stream protocol, produces the same interface signature as the stand-in data loader so every downstream module (models, training, evaluation, run driver) runs unchanged. Includes inline design notes on node semantics, encoder choice (the MLP will underfit 1024-dim images — a small CNN encoder is recommended), and honest caveats about Yearbook's suitability.
- **Wild-Time pre-run check.** Before running Wild-Time, the authors should reproduce our local_only on their machine and compare to Yao et al. 2022 Table 18's ERM row for Yearbook. If our local_only approximately matches their ERM (same protocol, same split, simple MLP may be below CNN), the rest of the packet is a trustworthy comparison.

---

## 3. Architecture fingerprint (v2 frozen)

| Fix | Code location | Effect on v2 stand-in |
|---|---|---|
| Skip + LayerNorm around graph layer | `modules.py:GraphCoordLayer` | +25.5 pp (graph_no_res: 0.496 → 0.751) |
| Skip connection on local-global agg | `modules.py:LocalGlobalAgg` | +24 pp over no-skip agg (caught in probe) |
| Gate init bias = 0 (was −1) | `modules.py:ResidualTerm` | fixed training-dynamics trap |
| Scheduler warmup + hysteresis | `modules.py:Scheduler` | fixed closed-loop deadlock |

Reference: `v2_frozen/FROZEN.md` for MD5s and full v2 results table.

---

## 4. Harder stand-in: task design

Files: `outputs_harder/data_harder.py`, `outputs_harder/run_harder.py`.

| Axis | v2 | Harder |
|---|---|---|
| T (timesteps) | 2000 | 3000 |
| N (nodes) | 8 | 10 |
| d_in | 16 | 32 |
| Graph | ring + 2 shortcuts | ring + 4 shortcuts |
| Shift events | 1 abrupt rotation | rotation + class-prior flip + recovery |
| Label noise | stationary 0.2 | nonstationary: 0.15 → 0.25 → 0.20 |
| Observation noise | uniform across nodes | heterogeneous (0.6×–1.4× per node) |
| Epochs | 25 | 18 |
| Hidden/latent | 32/16 | 48/20 |

The harder task preserves v2's "shared latent factor, noisy per-node observations" structure (so the graph has real work to do), but adds multi-regime drift, per-node noise heterogeneity, and nonstationary label noise — three features shared by real Wild-Time tasks.

---

## 5. Harder stand-in: results (3 seeds)

### 5.1 Main results table

| Model | Accuracy | ±sd | ECE | adapt lag | p50 ms | p95 ms | K mean |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| local_only | 0.618 | 0.038 | 0.092 | 0 | 0.009 | 0.013 | 1.00 |
| graph_no_residual | 0.759 | 0.006 | 0.141 | 2 | 0.060 | 0.097 | 1.00 |
| tent_like | 0.582 | 0.043 | 0.056 | 1 | 0.044 | 0.068 | 1.00 |
| proposed_no_scheduler | 0.741 | 0.030 | 0.162 | 1 | 0.093 | 0.135 | 2.00 |
| **proposed_full** | **0.764** | **0.006** | 0.160 | 2 | 0.072 | 0.112 | 1.00 |
| abl_no_residual | **0.779** | 0.018 | 0.154 | 2 | 0.073 | 0.108 | 2.00 |
| abl_no_graph | 0.608 | 0.065 | 0.202 | 1 | 0.033 | 0.048 | 1.00 |
| abl_no_aggregation | 0.734 | 0.011 | 0.151 | 1 | 0.070 | 0.099 | 1.33 |
| abl_frozen_scheduler | 0.769 | 0.015 | 0.154 | 0 | 0.072 | 0.104 | 1.00 |
| abl_flat_latent | 0.479 | 0.063 | 0.123 | 1 | 0.037 | 0.053 | 1.00 |

### 5.2 Per-regime accuracy (harder stand-in)

| Model | reg1 (0–400)<br>clean | reg2 (400–900)<br>rotation | reg3 (900–1200)<br>prior flip | reg4 (1200–1500)<br>recovery |
|---|:---:|:---:|:---:|:---:|
| local_only | 0.610 | 0.586 | 0.663 | 0.637 |
| graph_no_residual | 0.812 | 0.725 | 0.739 | 0.765 |
| proposed_full | 0.829 | 0.735 | 0.735 | 0.756 |
| abl_no_residual | 0.834 | 0.740 | 0.774 | 0.778 |
| abl_frozen_scheduler | 0.834 | 0.727 | 0.756 | 0.767 |

**abl_no_residual dominates across every regime.** This is the key observation.

---

## 6. The difficult finding, stated plainly

On v2 stand-in, proposed_full (0.760) was approximately tied with graph_no_residual (0.751), with the scheduler saving compute at matched accuracy. The residual-gate component was already marginal (abl_no_residual 0.765 was within noise).

On the harder stand-in:

- **proposed_full (0.764) ≈ abl_no_residual (0.779) ≈ abl_frozen_scheduler (0.769) ≈ graph_no_residual (0.759).** None of these differences exceeds 2σ.
- The residual gate, which the original manuscript framed as a core pillar, **is not load-bearing**. Removing it does not hurt; on this task, it slightly helps.
- The scheduler, which was defensible on v2 (K_mean=1.00 at equal accuracy = 2× graph-FLOP savings), provides **no additional accuracy** on the harder task, and `abl_frozen_scheduler` achieves the same result with simpler logic.

The part of the architecture that *is* load-bearing:

- **Graph coordination with skip+norm**: removing it collapses performance by 15–30 pp (abl_no_graph, abl_flat_latent).
- **Local-global aggregation**: contributes ~3 pp (proposed_full 0.764 vs abl_no_aggregation 0.734).

### 6.1 Implication for the manuscript's framing

The original manuscript claims four pillars: residual-sensitive inference, graph-organized latent coordination, local-to-global adaptive updating, latency-aware control. Two of these four pillars (residual, latency-aware scheduler) cannot be defended empirically on harder synthetic data. **The paper's claim ceiling is narrower than stated.**

Three options, ranked by honesty:

1. **Narrow the contribution to two pillars**: "graph-organized latent coordination with skip-connected local-global aggregation under temporal shift." This is a publishable methods paper. The residual and scheduler become optional extensions that may help on other tasks (Wild-Time is the next test).
2. **Find a task where residual and scheduler earn their place.** The harder stand-in does not. A structured-shift task where shift severity is *spatially* heterogeneous across nodes is the candidate — only some nodes are shifted at a time, which is when per-node residual-gating should help. This is a principled task redesign, not goalpost-moving, but the authors must justify it.
3. **Keep all four pillars in the framing but flag them as conjectures not yet empirically supported.** Acceptable but weaker.

I recommend option 1 until a task is found where residual and scheduler earn their place.

### 6.2 Implication for Wild-Time

The next empirical question is falsifiable:

- **Null result:** On Wild-Time Yearbook, `graph_no_residual` ≈ `proposed_full`. Residual and scheduler add nothing. The contribution narrows to option 1 above.
- **Win for residual/scheduler:** On Wild-Time Yearbook, `proposed_full` > `abl_no_residual` and `proposed_full` > `abl_frozen_scheduler` both by more than 2σ. The four-pillar framing survives.
- **Null for the whole architecture:** `graph_no_residual` ≈ `local_only` on Wild-Time. The graph coordination inductive bias doesn't transfer to Yearbook (which has no per-timestep correlated structure — each image is an independent sample).

All three outcomes are informative. The third would be the most important finding, because it would mean the manuscript's central claim only holds on tasks with shared-signal structure (common in multi-sensor/multi-site deployment, absent in single-sample classification).

---

## 7. Figures

- **`outputs_harder/adaptation_figure.png`** — streaming accuracy across three regime shifts. proposed_full and graph_no_residual track each other within noise across all regimes. local_only and tent_like track each other well below. abl_no_graph and abl_flat_latent (not plotted in this figure) collapse.
- **`outputs_harder/ablation_figure.png`** — ablation bars. abl_no_residual bar is slightly *above* proposed_full. abl_frozen_scheduler matches proposed_full. abl_no_graph and abl_flat_latent are the only two that fall substantially.
- **`outputs_harder/calibration_figure.png`** — reliability diagrams. All four shown models (local_only, graph_no_residual, tent_like, proposed_full) produce meaningful confidence distributions (not the single-bin collapse from sprint 1).

---

## 8. What is deliverable now

| Deliverable | Status |
|---|---|
| v2 architecture frozen | ✅ `v2_frozen/` with FROZEN.md + 6 source files + MD5s |
| v2 artifacts regenerated | ✅ `outputs_v2/` (tables, figures, configs) |
| Harder stand-in designed and run | ✅ `outputs_harder/` (tables, figures, configs, code) |
| Wild-Time adapter | ✅ `wildtime_adapter/wildtime_loader.py` (runnable off-sandbox) |
| Wild-Time run | ❌ **Cannot run in this sandbox.** Requires network + Wild-Time pickle. |
| Publishable methods claim | ⚠️ **Conditional.** Narrow claim (graph+agg) is supportable from the two stand-ins. Full four-pillar claim requires Wild-Time confirmation at minimum. |

---

## 9. The exact sequence from here

1. **Clone Wild-Time**, download yearbook.pkl, set `WILDTIME_ROOT`. ~30 min.
2. **Verify local_only matches ERM** from Yao et al. 2022 Table 18. If it doesn't, the MLP encoder is insufficient and a small CNN encoder must be swapped in (the rest of the architecture is encoder-agnostic). ~30 min if MLP works; ~2 hours if CNN swap needed.
3. **Run the packet on Yearbook.** ~10–20 min on CPU, ~1 min on GPU. Same 10 variants × 3+ seeds.
4. **Read the results honestly**:
   - If `proposed_full > abl_no_residual > 2σ` and `proposed_full > abl_frozen_scheduler > 2σ`: the four-pillar framing is empirically defensible. Paper is publishable.
   - If not: narrow the claim to graph+aggregation per option 1 in §6.1. Still publishable, just a different paper.
5. **Ideally, run one more Wild-Time task** (arXiv or MIMIC) to avoid single-task overfitting of the claim.

Do not skip step 2. If local_only is well below reported ERM on Yearbook, every subsequent comparison is a comparison of an under-capacity system against itself, not against the state of the art.

---

## 10. Claim ceiling, as of this sprint

### Supportable now (from v2 + harder stand-in)

- Graph coordination with skip+norm is load-bearing under temporal shift on two distinct synthetic tasks.
- Local-global aggregation with skip connection earns ~3 pp on both stand-ins.
- The combined (graph+agg) architecture beats a local-only baseline by 14–20 pp on tasks where cross-node signal is present.

### Not supportable (but user can falsify on Wild-Time)

- Residual-as-gate is a meaningful component. It is not, on either stand-in.
- The adaptive scheduler adds value over a fixed-K=1 policy. It does not, on either stand-in.
- The architecture generalizes to Wild-Time-like natural shift. Untested.

### Not supportable, period

- Any deployment, latency-under-load, or real-world claims. No runtime, no observability, no fail-safe.

---

*Every number in this report comes from executed code. The harder stand-in used files `data_harder.py` and `run_harder.py`, reproducible with the single command `PHASE=all python3 run_harder.py` (or split into `baselines`, `proposed`, `ablations` phases if bash timeouts are a constraint). No numbers are estimates or paraphrased from elsewhere.*
