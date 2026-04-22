# DROID-Fed Parallel Stream — Proposal (Inter-Model)

**Status: PROPOSAL (Tier 3).** Not implemented. Not benchmarked. No capability is claimed. This document specifies an inter-model integration target using DROID as an external feature source. It is the inter-model companion to the intra-model proposal in `16_parallel_hidden_state.md`.

## Intent

Replace the intra-model parallel stream (`16_parallel_hidden_state.md`) with a stream derived from an external pipeline. Specifically: use DROID-derived features as the second stream input, and fuse them with the DCRNN-internal graph-conditioned stream via cross-attention. The graph-vs-external difference remains exposable through the `DivergenceHead`, reused as in section 16.

The proposal sits inside Stage B of the cascade and does not modify Stage A ingestion or Stage C emission. It is a strictly more general form of section 16 — section 16 is recovered when the external source is replaced by a second intra-model transformation.

## Why DROID

DROID is already cited in `11_droid_openvla_integration.md` as a Stage A stream source and in `09_robotic_vision_lineage.md` as an architectural lineage. This proposal reuses that citation and specifies a different integration surface: features at the fusion layer, not raw sensor streams at ingestion. The two roles are distinguished explicitly below.

## Distinction from section 11

Section 11 positions DROID as **Stage A stream generator** — raw temporal sensor signals entering ingestion. This proposal positions DROID as **Stage B feature source** — pre-encoded features entering the fusion point, after the external pipeline has already encoded them.

The two roles are not redundant:

- Stage A use of DROID = DROID output is a signal stream, encoded by the DCRNN substrate from scratch.
- Stage B use of DROID = DROID output is an already-encoded feature, used as a second high-level view of the state.

Both remain proposals. A future version of the paper may adopt one, both, or neither.

## Formal specification

Let $h_t$ denote the DCRNN encoder hidden state at layer $t$.

Let $e_t \in \mathbb{R}^{B \times N \cdot d}$ denote an external feature tensor derived from a DROID-family model, projected to match the hidden dimensionality of $h_t$. The projection is an adapter (see PENDING).

**Stream 1 (graph-conditioned, internal):**
$$h^{g}_t = \mathrm{Agg}_g(h_t)$$

**Stream 2 (external, DROID-derived):**
$$h^{d}_t = \mathrm{Adapter}(e_t)$$

**Fusion (cross-attention):**
Internal stream as query, external stream as key and value:
$$Q = h^{g}_t W_Q, \quad K = h^{d}_t W_K, \quad V = h^{d}_t W_V$$
$$\mathrm{Attn}(Q, K, V) = \mathrm{softmax}\!\left(\frac{Q K^\top}{\sqrt{d_k}}\right) V$$
$$\tilde{h}_t = h^{g}_t + \mathrm{Attn}(Q, K, V)$$

The residual connection ensures that if the attention output is zero, the baseline behaviour is preserved.

**Auxiliary divergence signal:**
$$\delta_t = h^{g}_t - h^{d}_t$$
$$\hat{y}^{\mathrm{div}}_t = \mathrm{DivergenceHead}(\delta_t)$$

**Decoder input:** $\tilde{h}_t$ replaces $h_t$.

## Loss

Same form as section 16:
$$\mathcal{L} = \mathcal{L}_{\mathrm{main}} + \lambda_{\mathrm{div}} \cdot \mathcal{L}_{\mathrm{div}}$$

Default $\lambda_{\mathrm{div}} = 0$. Target of $\mathcal{L}_{\mathrm{div}}$ is PENDING.

## Why cross-attention (not gate)

Section 16 uses a sigmoid gate because both streams are symmetric — two transformations of the same input. Here the streams are asymmetric: one is internal graph state, the other is pre-encoded external features from a different model. Cross-attention is the standard mechanism for asymmetric fusion between heterogeneous feature sources, and it scales naturally to different external sources without changing the fusion code.

## PENDING items

1. **Adapter architecture.** Linear projection, MLP, or multi-layer transformer block? Not adopted.
2. **Number of attention heads.** Default PENDING.
3. **Residual scaling.** Whether the attention output is scaled before adding to $h^{g}_t$. PENDING.
4. **Frozen vs trainable DROID encoder.** The external pipeline can be frozen (DROID as feature extractor only) or fine-tuned jointly. Default: frozen. Alternative remains open.
5. **Source of** $e_t$. A concrete DROID checkpoint and feature-extraction protocol must be specified before implementation. Not adopted.
6. **Target of** $\mathcal{L}_{\mathrm{div}}$. Same PENDING as section 16.

## Flag-gated rollout (governance)

When implemented:

- `use_external_stream: false` must reproduce baseline forward pass exactly.
- `use_external_stream: true` with `external_source: null` must raise a configuration error rather than silently degrade.
- Configuration must declare which external source is active (e.g., `external_source: droid_v1`).

## Claim boundary

- Not implemented.
- No metric produced.
- Does not retroactively upgrade any existing ablation.
- Does not satisfy any PENDING from the cognitive stack draft.
- Section 11's status (Stage A integration target) is not altered.
- Future Tier 1 upgrade requires the same four conditions as section 16, plus: a committed external-source adapter, a reproducible DROID feature-extraction script, and explicit documentation of the external pipeline version used.

## Relation to section 16

Section 16 is the degenerate case of this proposal where the external source is replaced by a second intra-model operator. Implementing section 17 effectively subsumes section 16. The two sections are kept separate in the paper for pedagogical clarity and because they have different governance requirements (intra-model change vs. external dependency).
