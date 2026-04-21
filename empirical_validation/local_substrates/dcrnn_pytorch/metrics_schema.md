# Metrics schema for the DCRNN / METR-LA substrate

This schema defines how local results from `~/DCRNN_PyTorch` should be interpreted before they are allowed to influence the public Probingnoise repo.

## Primary metric

- **Primary metric:** MAE at horizon h=12
- **Secondary metrics:** MAE at h=3 and h=6, RMSE at h=3/6/12
- **Optional tertiary metric:** MAPE, if computed consistently across all variants

## Horizon handling

- Do not collapse all horizons into one number for claim decisions.
- Use **MAE at h=12** as the main comparison point.
- Report shorter horizons as supporting context, not as the main decision signal.

## Seed reporting

- Canonical seeds: `42`, `1337`, `2024`
- Minimum for any claim-relevant row: **3 seeds**
- Single-seed or two-seed rows are automatically treated as insufficient for public claim transfer.

## Baseline comparison logic

For each Probingnoise variant, compare against:

1. `dcrnn_baseline`
2. the relevant ablation (`abl_no_graph`, `abl_no_aggregation`, etc.)

The main comparison field for normalization is:

- `effect_vs_baseline`

Interpretation:
- positive = the Probingnoise core variant is better than the comparison baseline
- near zero = inconclusive
- negative = potential challenge to the hypothesis

## Baseline collapse

Set `baseline_collapse = True` if any of the following happens:

- `probingnoise_graph_core` is materially worse than `dcrnn_baseline`
- `probingnoise_graph_core` is worse than `abl_no_graph`
- the run diverges, produces NaNs, or requires restart to finish

A baseline collapse on a scope-matched target is a strong warning signal.

## Unstable variance

Treat the result as unstable when:

- seed variance is large relative to the measured effect
- rank ordering between core and ablations changes across seeds
- a result looks positive on one seed and disappears on others

Unstable results should be normalized as `INCONCLUSIVE`, not overread.

## Promising but inconclusive

A result is promising but still inconclusive when:

- the core beats a baseline numerically
- the effect is not yet stable enough
- replication or more seeds are still missing

This status does not authorize a public README or manuscript update.
































# Metrics schema for the DCRNN / METR-LA substrate

This schema defines how local results from `~/DCRNN_PyTorch` should be interpreted before they are allowed to influence the public Probingnoise repo.

## Primary metric

- **Primary metric:** MAE at horizon h=12
- **Secondary metrics:** MAE at h=3 and h=6, RMSE at h=3/6/12
- **Optional tertiary metric:** MAPE, if computed consistently across all variants

## Horizon handling

- Do not collapse all horizons into one number for claim decisions.
- Use **MAE at h=12** as the main comparison point.
- Report shorter horizons as supporting context, not as the main decision signal.

## Seed reporting

- Canonical seeds: `42`, `1337`, `2024`
- Minimum for any claim-relevant row: **3 seeds**
- Single-seed or two-seed rows are automatically treated as insufficient for public claim transfer.

## Baseline comparison logic

For each Probingnoise variant, compare against:

1. `dcrnn_baseline`
2. the relevant ablation (`abl_no_graph`, `abl_no_aggregation`, etc.)

The main comparison field for normalization is:

- `effect_vs_baseline`

Interpretation:
- positive = the Probingnoise core variant is better than the comparison baseline
- near zero = inconclusive
- negative = potential challenge to the hypothesis

## Baseline collapse

Set `baseline_collapse = True` if any of the following happens:

- `probingnoise_graph_core` is materially worse than `dcrnn_baseline`
- `probingnoise_graph_core` is worse than `abl_no_graph`
- the run diverges, produces NaNs, or requires restart to finish

A baseline collapse on a scope-matched target is a strong warning signal.

## Unstable variance

Treat the result as unstable when:

- seed variance is large relative to the measured effect
- rank ordering between core and ablations changes across seeds
- a result looks positive on one seed and disappears on others

Unstable results should be normalized as `INCONCLUSIVE`, not overread.

## Prom
