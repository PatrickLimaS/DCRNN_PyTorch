# VLM as Stage A Scene Graph Generator — Proposal

**Status: PROPOSAL (Tier 3).** Not implemented. Target model: GLM-4.1V-9B-Thinking. Target canonical domain: DROID. No capability is claimed.

## Intent

Specify how a vision-language model with explicit reasoning capabilities could generate scene graphs that serve as Stage A ingestion input for the cascade. The proposal extends the cascade's Stage A beyond raw sensor streams to include VLM-derived structured representations of visual inputs.

The target model is **GLM-4.1V-9B-Thinking** (Zhipu AI / Tsinghua, 2025). Rationale for this choice:

- Open weights, runnable on single-GPU consumer hardware or Colab A100.
- Explicit "Thinking mode" switch aligns with this project's claim discipline — reasoning steps can be surfaced or suppressed as needed.
- 3D spatial reasoning (via 3D-RoPE) addresses the "localização espacial" motivation.
- Competitive with larger models (Qwen2.5-VL-72B) on 29 benchmarks while being 9B parameters.

The **canonical target domain is DROID** (robotics manipulation dataset already cited in §11 and §17), with the expectation that the same architectural pattern generalises to traffic-camera and generic-video domains.

## Position in the cascade

Stage A (ingestion) currently accepts raw temporal signals. This proposal adds a second ingestion pathway: visual frames → VLM scene graph extraction → structured graph delivered to Stage B.

Relation to existing sections:

- **§11 (DROID/OpenVLA integration):** uses DROID as Stage A temporal stream source. §21 uses DROID **frames** as visual input to the VLM, producing a structured graph. The two uses of DROID are orthogonal.
- **§17 (DROID-fed parallel stream):** uses pre-encoded DROID features as Stage B feature source. §21 uses DROID visual input at Stage A. Section 17 feeds already-encoded features laterally; §21 generates fresh scene graphs at ingestion time.
- **§16 (parallel hidden-state, intra-model):** orthogonal. §16 operates on encoder hidden state; §21 operates on graph input.

## Formal specification (primary function — scene graph generator)

Let $I_t \in \mathbb{R}^{H \times W \times 3}$ denote a visual frame at time $t$.

The VLM is treated as a function:
$$
\mathrm{VLM}(I_t, p) = (\mathcal{N}_t, \mathcal{E}_t)
$$
where $p$ is a structured prompt asking the model to extract objects, spatial relations, and time-sensitive attributes, and the output is:

- $\mathcal{N}_t = \{(\mathrm{id}_i, \mathrm{label}_i, \mathrm{bbox}_i, \mathrm{attr}_i)\}_{i=1}^{N_t}$ — object nodes with identifiers, semantic labels, bounding boxes, and attribute dictionaries
- $\mathcal{E}_t = \{(i, j, r_{ij})\}$ — spatial relations between nodes

The graph $(\mathcal{N}_t, \mathcal{E}_t)$ is converted to the adjacency format consumed by DCRNN's diffusion convolution, with node features derived from embedding the labels and bounding-box coordinates.

**Reasoning mode:** GLM-4.1V's `<think>` mode is enabled during extraction when the frame contains occlusion, ambiguous relations, or novel objects. The reasoning trace is stored alongside the graph for auditability. This addresses an audit requirement (claim discipline): the scene graph's construction is not opaque.

## Alternative functions (PENDING)

Two alternative functions for the VLM in the stack are noted but not specified in detail:

**Alternative B — textual description feeding numeric features:** The VLM produces natural-language descriptions of the frame; these are embedded via a text encoder; embeddings enter Stage B as auxiliary features. Less structural, more flexible.

**Alternative C — Stage B co-processor:** The VLM runs alongside the cascade's Stage B, reasoning in parallel about the current scene state, emitting modulation signals to Stage B aggregation. This aligns with §18 framing B (cognitive stack as co-processor) but uses a pre-trained VLM rather than a learned dialogue layer.

Both alternatives remain PENDING. The primary proposal (scene graph generator, above) is the one specified formally.

## PENDING items for the primary proposal

1. **Prompt structure $p$.** The exact prompt that reliably elicits scene graphs in GLM-4.1V's output format is empirically determined. Not specified.
2. **Node embedding.** How VLM-produced object labels and bounding boxes are embedded into feature vectors compatible with DCRNN's input shape is not specified.
3. **Temporal consistency.** VLM-produced scene graphs at consecutive timesteps may not have stable node identifiers (same object, different id). A tracking mechanism is PENDING.
4. **Thinking mode policy.** Always on (expensive, interpretable) vs triggered (faster, less auditable) is not specified.
5. **Rate limiting.** VLM inference is slower than DCRNN inference. At what rate Stage A ingests VLM output (every frame, every k frames, triggered by change) is PENDING.
6. **Validation protocol.** How to verify that the VLM-produced scene graph is correct (not hallucinated, not missing objects) before feeding to Stage B is PENDING.

## Canonical target — DROID

DROID contains paired visual frames (multi-view RGBD) and proprioceptive signals. The proposal's canonical implementation target:

- Visual frames from one or more DROID cameras → GLM-4.1V scene graph extraction → structured graph
- Proprioceptive signals → conventional Stage A ingestion (existing path)
- Both enter Stage B for fusion

This dual ingestion is a new architectural pattern that only exists as proposal. DROID is chosen as canonical because (1) it is already cited in the paper, (2) visual and temporal modalities are pre-aligned in its dataset structure, and (3) robotics manipulation has clear ground-truth for some scene graph elements (gripper state, object identity).

## Generalisation to other domains

The same pattern generalises to:

- **Traffic-camera networks** (extends METR-LA from sensor-only to sensor + camera). Node identity from VLM matches physical lane/intersection IDs.
- **Generic video** (action recognition, anomaly detection). Node identity is constructed per-video.

No specification is offered for these; they are noted as future extensions.

## Claim boundary

- Not implemented.
- GLM-4.1V has not been run inside this stack.
- No claim is made about GLM-4.1V's accuracy on DROID or any other dataset.
- The proposal does not retroactively upgrade any existing ablation.
- Alternatives B and C remain PENDING; if adopted later, they require separate specification sections.
- The DROID canonical target does not imply that the proposal has been tested on DROID — only that DROID is where implementation would begin.

## Governance

A future document claiming §21 is realised in code must present:

1. Committed scene graph extraction pipeline with GLM-4.1V as configurable backend.
2. A DROID-based minimal working example producing scene graphs from at least one episode.
3. An ablation where the VLM pathway is disabled, demonstrating the cascade reproduces prior behaviour.
4. A validation step addressing PENDING item 6 (scene graph correctness).
5. A separate `status.json` classification for the §21-realised variant.

Until all five are satisfied, this section remains a Tier 3 proposal.

## Relation to §18 (cognitive stack framing B)

Alternative C above (VLM as Stage B co-processor) is structurally similar to the dialogue layer in framing B. However, framing B specifies a **learned** dialogue layer trained jointly with the cascade; Alternative C would use a **pre-trained frozen** VLM. The two framings are not interchangeable:

- Framing B's dialogue is trained to modulate aggregation usefully on the task.
- Alternative C's VLM is trained on general multimodal data and its reasoning may not align with the task-specific modulation target.

A hybrid (frozen VLM as initialisation for the dialogue layer, then fine-tuned on the task) is a Tier 4 speculation.
