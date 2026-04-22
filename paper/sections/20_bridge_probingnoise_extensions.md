# Bridge — Probingnoise Flags vs Proposed Extensions

**Status: CLARIFICATION (Tier 1 for factual claims about the code, Tier 3 where proposals are discussed).** No capability is claimed.

## Why this section exists

Sections 16, 17, 18, and 19 specify proposed extensions (parallel hidden-state with gate and divergence, DROID-fed inter-model integration, cognitive stack in framing B with schedule-based gating). Sections 1–14 and the empirical commits to date reference a different surface: the **Probingnoise flags** (`use_graph`, `use_aggregation`, `use_graph_skip_ln`, `use_agg_skip_ln`). A reader moving through the paper in order may ask: "what is the relation between the flags that were tested and the extensions that were proposed?"

This section answers that question.

## What the flags are

The Probingnoise flags are toggles on an early set of architectural variants added to the DCRNN substrate as part of this project's initial exploration. They govern:

- Whether the graph-conditioned path is active (`use_graph`).
- Whether a local-global aggregation block is applied to the hidden state (`use_aggregation`).
- Whether skip-layer-norm is applied to each respective path (`use_graph_skip_ln`, `use_agg_skip_ln`).

These flags produce the four ablation variants that define the empirical matrix:
- `local_only`: all flags off (pessimistic bound).
- `abl_no_graph`: aggregation without graph conditioning.
- `abl_no_aggregation`: graph conditioning without the aggregation block.
- `probingnoise_graph_core`: all flags on (Probingnoise as a complete system).

The baseline (`dcrnn_baseline`) uses none of these flags and matches the original DCRNN paper's architecture.

## What the proposed extensions are

The extensions in sections 16–19 are not the Probingnoise flags. They are **new structural proposals**, currently unimplemented:

- **Section 16** proposes running a second `LocalGlobalAggBlock` (an independent instance) in parallel with the first, fusing via a learned sigmoid gate, with the difference exposed through the already-present-but-dormant `DivergenceHead`.
- **Section 17** generalises the second stream to come from an external pipeline (DROID), with cross-attention fusion.
- **Sections 18–19** frame a cognitive stack as a co-processor parallel to the cascade, with schedule-based gating for stability.

The extensions reuse some existing module classes (`LocalGlobalAggBlock`, `DivergenceHead`, `SkipLayerNorm`) but compose them in structurally new ways. The Probingnoise flags cannot toggle the proposed extensions into existence; new flags and new forward-pass logic would be required.

## Relation table

| Aspect | Probingnoise flags (tested) | Proposed extensions (specified, not implemented) |
| :--- | :--- | :--- |
| State | Implemented, running ablations | Sections 16–19, Tier 3 |
| Fusion mechanism | Sequential (`LocalGlobalAggBlock` applied once per layer) | Parallel streams with gate (§16) or cross-attention (§17) |
| Second aggregation instance | None | Two independent instances (§16 V3) |
| DivergenceHead role | Dormant in repo | Active supervision on graph-vs-parallel delta (§16, §17) |
| External features | None | DROID features projected via adapter (§17) |
| Cognitive modulation | None | Dialogue emission into Stage B under schedule gating (§18, §19) |

## What the ablation matrix tells us (and does not)

The empirical ablation matrix — when complete — speaks to **the Probingnoise flags**. It does not speak to the proposed extensions. A row of the matrix showing, for instance, that `probingnoise_graph_core` outperforms `dcrnn_baseline` would be evidence that the Probingnoise flag combination is useful. It would not be evidence that the parallel stream (§16) is useful, because §16 is not implemented.

Conversely, a finding that `abl_no_aggregation` underperforms `probingnoise_graph_core` suggests the aggregation block contributes signal to the baseline-plus-flags configuration. It does not suggest anything about the parallel stream (§16), which differs in that it runs two aggregation instances concurrently rather than applying one block with or without graph conditioning.

## Why both surfaces remain in the project

The Probingnoise flags are the **empirical foundation** — the only configurations currently available for run-and-compare. They exist to give the project a minimum viable ablation matrix before any Tier 3 proposal is implemented.

The proposed extensions are the **specification frontier** — the direction the project argues for, written claim-disciplined so that implementation, if pursued, has a formal target.

Both surfaces exist in the paper because the paper documents the full arc: what was tested, what is claimed, and what is proposed with explicit boundary between them. The Evidence Matrix shows Probingnoise rows under Tier 1 (actual runs) and proposal rows under Tier 3 (specifications). The Bridge is this section.

## Governance implication

Any future claim that "this project's extension outperforms baseline" must be unambiguous about **which surface** the claim refers to. Three distinct statements are permitted, and they are not interchangeable:

1. "Probingnoise flags X produce test_mae Y at regime Z." (Tier 1, requires run data.)
2. "Extension §N is specified with property P." (Tier 3, requires section text only.)
3. "Extension §N, when implemented, produces test_mae Y at regime Z." (Tier 1, requires run data of the implementation, which does not yet exist.)

Statements 1 and 2 are presently supported. Statement 3 is presently unsupported for any §N in 16–19.
