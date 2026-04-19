# Probingnoise

Scoped methods project on graph-organized local-global adaptation under temporal shift.

## Claim (narrow)

On tasks where there is shared-signal structure across nodes at each
timestep, skip-connected graph coordination plus skip-connected
local-global aggregation is load-bearing under temporal shift.

## Scope of current evidence

All empirical evidence in this repository comes from two synthetic
stand-ins (v2 and harder). No real-benchmark result is yet claimed.

## Validated core

- Graph coordination with skip + LayerNorm
- Local-global aggregation with skip connection

## Conditional extensions (not validated core)

- Residual gating
- Adaptive scheduling

On both synthetic stand-ins these two components fail to outperform
their ablations. They are retained as optional modules pending a task
where they earn their place empirically.

## Wild-Time positioning

Wild-Time Yearbook is included as a scope / falsification probe.
Yearbook lacks per-timestep cross-node shared structure, so a null
result there would confirm the scope limit of the claim, not falsify
the method. A positive benchmark requires a Wild-Time task whose
distribution-shift structure is cross-node correlated per timestep
(candidates: arXiv, MIMIC).

## Project status

| Item | Status |
| --- | --- |
| Narrow claim framing | done |
| Synthetic stand-in evidence (v2 + harder) | done |
| Scope-matched real benchmark | pending |
| Wild-Time Yearbook scope probe | pending |

## Repository layout

- `REPORT_SPRINT3.md` — current empirical report
- `WILDTIME_RUNBOOK.md` — runbook for the Yearbook scope probe
- `wildtime_loader.py`, `preflight_wildtime.py`, `run_wildtime.py` — adapter and runner
- `results_aggregate.csv`, `per_regime_table.csv`, `latency_table.csv` — synthetic stand-in results
- `archive/` — superseded drafts, retained for provenance only

## Author

Patrick S.,DS
