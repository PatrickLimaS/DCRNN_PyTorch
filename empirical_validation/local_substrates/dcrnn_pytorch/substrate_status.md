# Substrate status: DCRNN PyTorch on METR-LA

_Last updated: 2026-04-20_

## Substrate identity

- **Codebase:** fork of `chnsh/DCRNN_PyTorch`
- **Local path:** `~/DCRNN_PyTorch`
- **Public visibility:** this public repository tracks governance only, not raw experimental code or logs

## Benchmark target

- **Dataset:** METR-LA
- **Role:** real spatio-temporal benchmark candidate
- **Scope reading:** provisionally scope-matched to the Probingnoise claim, but no public real-benchmark claim is authorized yet

## Purpose

To test whether the Probingnoise two-pillar hypothesis remains load-bearing on a real spatio-temporal benchmark:

- skip-connected graph coordination with normalization
- skip-connected local-global aggregation

## Implemented / intended variants

| Variant | Role | Status |
| --- | --- | --- |
| `dcrnn_baseline` | baseline reproducibility gate | in progress |
| `probingnoise_graph_core` | primary core variant | in progress |
| `abl_no_graph` | remove graph coordination | pending |
| `abl_no_aggregation` | remove local-global aggregation | pending |
| `abl_graph_no_skip` | isolate graph skip+norm effect | optional / pending |
| `abl_agg_no_skip` | isolate aggregation skip+norm effect | optional / pending |

## Current state

**In progress. No real-benchmark claim authorized.**

The local substrate is being used to test whether the public Probingnoise concept survives contact with a real benchmark. Any local partial runs, smoke tests, or incomplete sweeps remain below the threshold for public claim transfer.

## What would count as meaningful progress

1. The baseline reproduces a reasonable METR-LA reference range.
2. The core variant runs cleanly across at least 3 seeds.
3. The key ablations are completed.
4. Results
