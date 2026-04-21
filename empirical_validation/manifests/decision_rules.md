# Decision rules for Probingnoise empirical validation

These rules are executed by `validate_result.py`. They are deliberately narrow and conservative. The rules prefer `INCONCLUSIVE` over optimistic classification when in doubt.

## Inputs required per result row

| Field | Meaning |
| --- | --- |
| `target_id` | Must match an entry in `manifests/validation_targets.yaml`. |
| `in_scope` | Boolean. Must match the manifest entry's `in_scope`. Mismatch is a hard error. |
| `role` | Must match manifest role. Mismatch is a hard error. |
| `n_seeds` | Integer ≥ 1. |
| `seed_std` | Standard deviation of the primary metric across seeds, or `nan` if `n_seeds == 1`. |
| `effect_vs_baseline` | Difference between the core variant and the appropriate baseline, in the primary metric. Positive = core outperforms. |
| `effect_sigma_ratio` | Absolute effect divided by `seed_std`. `nan` if `n_seeds == 1`. |
| `replicated` | Boolean. |
| `baseline_collapse` | Boolean. |
| `null_observed` | Boolean. |

## Classification rules

Applied in order. First matching rule wins.

1. **Out-of-scope null → `INCONCLUSIVE`.**
   If `in_scope == False` and `null_observed == True`, return `INCONCLUSIVE` with rationale `scope_confirmation_not_falsification`.

2. **Out-of-scope positive → `INCONCLUSIVE`.**
   If `in_scope == False` and effect is positive, return `INCONCLUSIVE` with rationale `out_of_scope_positive_requires_scope_review`.

3. **Scope-matched baseline collapse → `FAILED-REOPEN`.**
   If `in_scope == True` and `baseline_collapse == True`, return `FAILED-REOPEN` with rationale `underperforms_baseline_in_scope`.

4. **Scope-matched single-seed result → `INCONCLUSIVE`.**
   If `in_scope == True` and `n_seeds < 3`, return `INCONCLUSIVE` with rationale `insufficient_seeds`.

5. **Scope-matched weak effect → `INCONCLUSIVE`.**
   If `in_scope == True` and `effect_sigma_ratio < 2.0`, return `INCONCLUSIVE` with rationale `effect_within_noise`.

6. **Scope-matched unreplicated gain → `INCONCLUSIVE`.**
   If `in_scope == True`, `effect_sigma_ratio >= 2.0`, but `replicated == False`, return `INCONCLUSIVE` with rationale `needs_replication`.

7. **Scope-matched, replicated, strong effect → `FOLLOW THROUGH`.**
   If `in_scope == True`, `n_seeds >= 3`, `effect_sigma_ratio >= 2.0`, `replicated == True`, and `baseline_collapse == False`, return `FOLLOW THROUGH`.

8. **Default → `INCONCLUSIVE`.**
   Any row that does not match rules 1–7 returns `INCONCLUSIVE` with rationale `unclassified`.

## Anti-overread clauses

- A positive result on one real benchmark is not enough to authorize a broad public claim update.
- A null on an explicitly out-of-scope task is not claim failure.
- `INCONCLUSIVE` is not failure; it means add seeds, improve design, or replicate.
