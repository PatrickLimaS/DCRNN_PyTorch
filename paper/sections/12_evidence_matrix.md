# Evidence Matrix

Audit-friendly summary of what is validated, what is proposed, and what
remains under specification. No capability is claimed beyond the
validated row.

| Component | Status | Implementation | Claim |
| :--- | :--- | :--- | :--- |
| **Recurrent Coordination Core** | Validated | DCRNN PyTorch substrate (skip connections, local-global aggregation) | Load-bearing infrastructure for temporal-shift robustness. |
| **Multi-Layer Extension** | Proposed | Five interacting layers + internal dialogue layer | Proposed structural analogue to selected cognitive processes; asynchronous modulation mechanism under specification. |

## Reading notes

- **Validated** means the component runs end-to-end under the DCRNN PyTorch stack and has produced measurable output on this project's data. Load-bearing claims are permitted here.
- **Proposed** means the component is specified in prose (this paper) but is neither implemented nor benchmarked. No load-bearing claim is permitted.
- **Under specification** means the operational detail (state transitions, update schedule, interface contracts) is in active drafting and not yet committed to the repository.

## Relation to the four-tier claim protocol

- The Validated row corresponds to Tier 1 (implemented fact).
- The Proposed row corresponds to Tier 3 (proposed extension).
- Anything referenced by the Proposed row that is not itself present in the repository remains Tier 4 (future work) until specified.

## Gate status

As of 2026-04-22, the `dcrnn_baseline` reproduction gate is marked
`BASELINE_CLEARED_REDUCED`. This corresponds to a 10-epoch reduced run
on A100, classified as **pipeline validation**, not benchmark
reproduction of Li et al. (2018). The recurrent coordination core
now carries data and gradients through the expected flow, backing
the Validated row empirically rather than by code presence alone.

Final metrics of the reduced run: best val_mae 3.0191 at epoch 5,
final test_mae 3.2176 at epoch 9, runtime 31.0 min. Full log in
`docs/partial_reports/2026-04-22_dcrnn_baseline_cleared.md`.

No transfer-eligible claim is authorised until full-regime
reproduction (50+ epochs with seed-aligned protocol) is completed.

See also:

- `06_cascade_abc.md` — the three-stage cascade
- `08_grp.md` — Global Re-entry Projection operator
- `11_droid_openvla_integration.md` — external integration targets
- `14_siena_as_testbed.md` — multi-channel temporal testbed
- `GOVERNANCE.md` — the four-tier claim protocol
