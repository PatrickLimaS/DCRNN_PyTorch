# Architecture proposal: asynchronous inference extension

**Status:** proposal only. Not validated. Not part of the defended Probingnoise claim.

## Summary

An extension of the current two-pillar architecture that reframes the model
as an asynchronous inference system rather than a direct predictor. The
central architectural hypothesis is that the difference between local and
global representations — `z_local(W) − z_global(W)` — carries signal that
neither representation alone does. Secondary hypotheses concern explicit
time-scale windows, asynchronous event-time state, hypermetrics as
inference-quality diagnostics, and cross-system disagreement as structured
signal.

## Relationship to the current claim

The proposal does **not** alter the current public claim. The defended
core remains: skip-connected graph coordination with normalization plus
skip-connected local-global aggregation, on tasks with shared-signal
structure across nodes per timestep, evaluated on synthetic stand-ins.
No real-benchmark result is yet claimed.

The divergence-as-first-class-object idea is a direct refinement of the
current aggregation pillar and is the natural next architectural step
to test if the current claim transfers to a real scope-matched benchmark.

## Components (in validation order)

1. Explicit `z_local − z_global` tensor with a parallel task head.
2. Short / medium / long window fusion.
3. Hypermetrics as post-hoc diagnostics (never as training signal).
4. Asynchronous event-time state (Python prototype only; no managed
   infrastructure).
5. `S_raw → S_typed → I_state` interpretation layer with a specific
   mechanism (e.g. vector-quantized bottleneck).
6. Cross-system dissonance layer.

Components 1–3 are validatable on the existing DCRNN/METR-LA substrate
without new infrastructure. Components 4–6 require additional wiring
and should be deferred until 1–3 classify.

## Load-bearing assumptions, ranked

1. `z_local − z_global` carries signal that `z_local` alone does not.
2. Time-scale structure (short / medium / long windows) captures
   genuinely different dynamics on scope-matched benchmarks.
3. Interpreted latent state is learnable from raw observables without
   full task supervision.
4. Asynchronous event-time state improves inference under drift relative
   to synchronous state.
5. Cross-system dissonance is more than initialization variance.
6. Hypermetrics measure inference quality independently of task metrics.

If assumption 1 is false, the rest of the proposal loses its anchor.

## Falsification criteria

- For each component, a minimum effect size against its direct ablation
  must be specified before the run, not after.
- Any component whose ablation matches the full system within noise on
  two independent scope-matched tasks is declared **not load-bearing**
  and is moved to conditional-extensions status, following the same
  discipline already applied to residual gating and adaptive scheduling.

## What this proposal does not authorize

- No change to the root README.
- No change to `paper_main.md`.
- No update to `claim_status.md`.
- No introduction of Kafka, Flink, or paid infrastructure before
  component 4 is reached in the validation order above, if ever.
- No use of hypermetrics as training signals.

## Next concrete step

Implement component 1 (explicit divergence tensor with parallel task head)
in the local DCRNN/METR-LA substrate. Run a single-seed, full-budget
ablation against the current `graph_core`. Normalize the result into
`summary_results.csv` per the transfer rules. Classification of that run
governs whether the rest of this proposal is pursued.
