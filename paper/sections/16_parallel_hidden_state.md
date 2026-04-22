# Parallel Hidden-State Operator — Proposal (Intra-Model)

**Status: PROPOSAL (Tier 3).** Not implemented. Not benchmarked. No capability is claimed. This document specifies an intra-model extension to the DCRNN substrate. A companion proposal (`17_droid_parallel_integration.md`) specifies an inter-model counterpart with an external feature source.

## Intent

Extend the recurrent coordination core with a second aggregation stream operating on the same encoder hidden state in parallel with the existing graph-conditioned stream. The two streams are fused by a learned gate before being passed to the decoder. The graph-vs-aggregation difference is exposed through the repository's existing `DivergenceHead` as an auxiliary supervision channel.

The proposal sits inside the cascade's Stage B (heterogeneous compute). It does not modify Stage A ingestion or Stage C emission.

## Position in the stack

The current implementation applies `LocalGlobalAggBlock` once per encoder layer on the final encoder hidden state before decoding. This proposal keeps that path intact and adds a parallel path at the same point.

Relation to other sections:

- **Cascade ABC** (`06_cascade_abc.md`): extends Stage B only.
- **GRP operator** (`08_grp.md`): structurally similar; differs in that GRP is a global re-entry projection rather than a parallel aggregation stream.
- **Evidence Matrix** (`12_evidence_matrix.md`): belongs to the Proposed row.
- **Section 17** (`17_droid_parallel_integration.md`): inter-model companion proposal using DROID as external feature source.

## Formal specification

Let $h_t$ denote the encoder hidden state at layer $t$, with shape $B \times N \cdot d$ where $B$ is batch size, $N$ is number of nodes, $d$ is `rnn_units`.

Let $\mathrm{Agg}_g$ and $\mathrm{Agg}_p$ be two `LocalGlobalAggBlock` instances. By default they have **independent weights**; shared weights are a design alternative (see PENDING).

**Stream 1 (graph-conditioned):**
$$h^{g}_t = \mathrm{Agg}_g(h_t)$$

**Stream 2 (parallel):**
$$h^{p}_t = \mathrm{Agg}_p(h_t)$$

**Fusion (learned gate):**
$$g = \sigma(W_g h_t + b_g), \quad g \in [0,1]^{B \times N \cdot d}$$
$$\tilde{h}_t = g \odot h^{g}_t + (1 - g) \odot h^{p}_t$$

**Auxiliary divergence signal:**
$$\delta_t = h^{g}_t - h^{p}_t$$
$$\hat{y}^{\mathrm{div}}_t = \mathrm{DivergenceHead}(\delta_t)$$

**Decoder input:** $\tilde{h}_t$ replaces $h_t$. Decoder unchanged.

## Loss

$$\mathcal{L} = \mathcal{L}_{\mathrm{main}} + \lambda_{\mathrm{div}} \cdot \mathcal{L}_{\mathrm{div}}$$

Default $\lambda_{\mathrm{div}} = 0$. Target of $\mathcal{L}_{\mathrm{div}}$ is PENDING.

## PENDING items

1. **Target of** $\mathcal{L}_{\mathrm{div}}$.
2. **Gate initialisation** ($g \approx 0.5$ vs $g \approx 1$).
3. **Weight sharing** — default independent, shared remains open.
4. **Gate granularity** (per-unit vs per-node vs scalar).
5. **Flag names** — proposed `use_parallel_stream`, `use_divergence_head`, `divergence_loss_weight`.
6. **Parameter budget** implications of doubling the aggregation operator.

## Flag-gated rollout (governance)

When implemented:

- `use_parallel_stream: false` must reproduce baseline forward pass exactly.
- `use_parallel_stream: true` with divergence disabled must match baseline up to added parameter init.
- Divergence supervision must not alter main forecasting loss.

## Claim boundary

- Not implemented.
- No metric produced.
- Does not retroactively upgrade any existing ablation.
- Does not satisfy any PENDING from the cognitive stack draft.
- Future Tier 1 upgrade requires: code behind flags; default-off reproduction of baseline; parallel-on run in same regime; separate `status.json` classification.

## Convergent direction — EEG-GCA (2025)

The EEG-GCA (Frontiers in Medicine, 2025) uses **KL divergence regularization** to align distributions between a target channel and its neighbouring channels, detecting abnormal channel behaviour via the divergence signal. This is a convergent direction with the auxiliary supervision proposed in this section (V4 = DivergenceHead).

Comparison:

- **EEG-GCA:** divergence between channel signal distributions at the representation level; KL divergence is a loss applied to align or distinguish distributions.
- **This section (§16):** divergence between hidden-state outputs of two aggregation streams; `DivergenceHead` predicts from the pre-fusion difference as auxiliary supervision.

Both operationalise "divergence as supervisory signal" but in different parts of the pipeline (input-level vs hidden-state-level). EEG-GCA strengthens the case that divergence-based supervision is a publishable direction in 2025 within adjacent literature.

**Claim boundary:** §16 remains Tier 3 (specified, not implemented). EEG-GCA is Tier 2 (cited from literature). Their structural similarity does not validate §16's specific implementation.
