# empirical_validation/

This subsystem tracks the empirical validation of the narrowed Probingnoise claim. It is **not** a results folder. It is a manifest-driven scaffold for running scope-checked probes, replications, and extension tests, and for publishing honest claim-status readouts.

## Claim ceiling (source of truth)

On tasks with shared-signal structure across nodes per timestep, the currently supported load-bearing mechanism is:

- skip-connected graph coordination with normalization
- skip-connected local-global aggregation

Residual gating and adaptive scheduling are **conditional extensions, not validated core**.

All empirical evidence currently comes from two synthetic stand-ins. **No real-benchmark result is yet claimed.**

## Folder map

| Folder | Role |
| --- | --- |
| `scope_probe/` | Out-of-scope probes. A null here confirms a scope limit; it does not falsify the method. |
| `scope_match/` | In-scope real benchmarks. These are the only targets whose wins can extend the core claim. |
| `extensions/` | Residual gating and adaptive scheduling. Separate claim budgets. Cannot be promoted to core without scope-matched replication. |
| `replication/` | Multi-seed sweeps. Gating condition before any result is eligible for `FOLLOW THROUGH`. |
| `reporting/` | Public-facing claim status and open empirical gaps. |
| `manifests/` | Canonical target list and decision rules. |

## How results get classified

All classifications go through `validate_result.py`, which consumes a CSV conforming to `reporting/sample_results.csv` and applies the rules in `manifests/decision_rules.md`. Three classes only:

- `FOLLOW THROUGH` — replicated, scope-matched, passes effect-size and stability gates
- `INCONCLUSIVE` — scope-matched but unreplicated, weak, or unstable; OR out-of-scope null
- `FAILED-REOPEN` — scope-matched and materially fails against baselines

A result cannot leave `INCONCLUSIVE` without replication across distinct seeds (and, where applicable, distinct scope-matched tasks).

## How to run

```bash
bash run_validation.sh
