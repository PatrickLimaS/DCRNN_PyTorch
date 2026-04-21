# Transfer rules: when a local DCRNN result may influence the public Probingnoise framing

This file defines the conditions under which a result from the local `~/DCRNN_PyTorch` substrate is allowed to propagate into this public repository's framing.

A result that has not passed every gate below must not change public framing, regardless of how good its numbers look.

## Gate 1: Scope match

The benchmark must exhibit per-timestep cross-node shared-signal structure as defined by the current Probingnoise claim.

- Pass: METR-LA as a provisional scope-matched real benchmark candidate
- Fail: per-sample classification tasks without cross-node temporal structure

## Gate 2: Baseline reproduction

`dcrnn_baseline` must reproduce a reasonable METR-LA reference range before any Probingnoise variant is interpreted as evidence.

## Gate 3: Complete variant packet

At minimum, the following variants must exist in interpretable form:

- `dcrnn_baseline`
- `probingnoise_graph_core`
- `abl_no_graph`
- `abl_no_aggregation`

Without these, local wins do not transfer.

## Gate 4: Seed stability

- at least 3 seeds
- no post-hoc seed selection
- no transfer from unstable variance patterns

## Gate 5: Normalization

Raw logs do not enter this public repo. Results only enter through normalized rows in:

`empirical_validation/reporting/summary_results.csv`

## Gate 6: Classification

The normalized row must be processed by:

`empirical_validation/validate_result.py`

and receive a verdict.

## Gate 7: No single-target overclaim

A positive result on METR-LA alone is not enough to retire the public statement:

**No real-benchmark result is yet claimed.**

A second independent scope-matched target is required before broader public framing changes.

## Gate 8: Separate evidence and claim commits

Evidence rows and public claim changes must not be committed together.  
The evidence commit comes first.  
Any README / manuscript change comes later, in a separate auditable commit.

## Gate 9: Reverse-transfer rule

If later evidence weakens or overturns the original local result, the corresponding public framing must be revised back down.

## Summary

The local DCRNN fork is an experimental substrate.  
The public Probingnoise repo is the claim-governance layer.  
The bridge between them is controlled, explicit, and reversible.
