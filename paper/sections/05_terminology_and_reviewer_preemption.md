# Terminology Safety Check

- Base architecture — "Probingnoise core": neutral and descriptive; does not smuggle in a capability claim.
- Visual extension — "visual-evidence extension for multimodal prediction": names input and task, not capability.
- Bridge module — "bridge module that projects visual representations into the Probingnoise stack": describes projection, not guaranteed alignment.
- Head module — "prediction head": standard, neutral, tied to task output rather than reasoning.

# Reviewer Objection Preemption

1. Objection: claims reasoning without evidence.
   Fix: "reasoning" appears only in the cited title (Zhang et al., 2024); the head is named "prediction head."

2. Objection: asynchronous framing is overreach.
   Fix: paper explicitly states Probingnoise is synchronous; asynchronous references are lineage only.

3. Objection: what is novel beyond stacking ViT + CLIP + BLIP-2 + MCoT?
   Fix: novelty is restricted to integration into the Probingnoise residual structure; component-level novelty is disclaimed.

4. Objection: specifying an architecture without validating it.
   Fix: contribution is declared architecture-level and narrow; empirical validation is deferred.

5. Objection: alignment is not shown.
   Fix: the bridge "projects"; the representation is "fused," not "aligned."
