# Cognitive Stack — Q1 Resolution: Framing B (Co-Processor)

**Status: PROPOSAL (Tier 3).** Resolves Q1 from `13_cognitive_stack_draft.md`. Does not resolve Q2–Q7. No capability is claimed; no implementation exists.

## Context

The cognitive stack draft (`13_cognitive_stack_draft.md`) enumerated three candidate framings for the relationship between the cognitive stack and the cascade ABC:

- **A — Stack as consumer.** Cascade runs Stage A → B → C to completion; stack receives Stage C output; stack produces downstream projection with no feedback to the cascade.
- **B — Stack as co-processor.** Stack runs in parallel with the cascade; each layer consults Stage B at prescribed moments; the internal dialogue layer emits signals that feed back into Stage B's aggregation.
- **C — Stack embedded in Stage B.** Stage B is replaced by the five-layer stack; the internal dialogue layer replaces Stage B's current aggregation logic.

This document resolves Q1 by adopting framing B.

## Decision

**Framing B is adopted** as the authoritative relation between the cognitive stack and the cascade for all future specification work in this project.

Framing A is rejected for this project. Framing C is retained as an alternative to be revisited only if B fails during implementation.

## Justification

Three reasons, in descending order of weight.

**1. Preserves both structures.**

Framing A degrades the stack to a post-processing module; it cannot express any hypothesis in which cognitive regulation shapes perceptual computation. Framing C collapses the stack into Stage B, erasing the distinction between the architectural cascade (ABC) and the proposed cognitive organisation. Only framing B keeps both as live first-class structures, with a specified interface.

**2. Compatibility with sections 16 and 17.**

Sections 16 (`16_parallel_hidden_state.md`) and 17 (`17_droid_parallel_integration.md`) specify parallel streams inside Stage B, with fusion via learned gate or cross-attention. Framing B places cognitive layers alongside the cascade, interfacing with Stage B through a dialogue-emitted signal. The two are compositional: Stage B's internal fusion (sections 16 and 17) is orthogonal to Stage B's lateral input from the stack (this section). Framings A and C break that orthogonality — A because it removes lateral input entirely, C because it replaces Stage B and renders sections 16 and 17 ill-defined.

**3. Precedent in cognitively-inspired architectures.**

Co-processor patterns with bidirectional signal flow are the dominant framing in world-model and hierarchical control literature (Dreamer-family, actor-critic with meta-controller, predictive coding with top-down projections). Framing B is the path of least friction for reviewers familiar with that literature. This is not a capability argument; it is a comprehensibility argument.

## Cost of framing B

Bidirectionality introduces the possibility of unbounded feedback. Framing B is accepted only with the constraint that subsequent specification work must address stability. Three candidate mechanisms, none adopted here:

- **Bounded staleness.** Dialogue signals consumed by Stage B at iteration $k$ must come from stack state at iteration $k - \tau$ or earlier, for some fixed $\tau \geq 1$. Prevents instantaneous loops.
- **Explicit decay.** Dialogue modulation signal is passed through a decay factor $\gamma \in (0, 1)$ at each tick. Eventual attenuation guaranteed.
- **Schedule-based gating.** Dialogue emits to Stage B only at pre-declared ticks (e.g., every $k$-th step), not continuously.

Any future resolution of Q6 (stability) must select one of these mechanisms or specify another.

## What framing B requires to be specified next

Framing B makes the following items load-bearing for implementation. Each is a separate PENDING from the cognitive stack draft:

- **Q2 (layer signatures).** Under B, each of L1–L5 has an input that includes both its predecessor layer's output and a query into Stage B. Both input schemas must be specified.
- **Q3 (dialogue monitoring).** Under B, the dialogue layer monitors L1–L5 and must also monitor the cascade's Stage B output to compose a feedback signal.
- **Q4 (dialogue modulation).** Under B, the dialogue emits a signal that the cascade's Stage B consumes. The form of that signal — gating weight, additive residual, routing decision — must be specified.
- **Q5 (schedule).** Under B, schedule is constrained by the stability mechanism chosen for Q6. The two answers are coupled.
- **Q6 (stability).** See Cost of framing B above.
- **Q7 (ablation behaviour).** Under B, disabling the dialogue layer must degrade to framing A behaviour, not to arbitrary failure. This is a governance requirement.

## What framing B does NOT require

- Framing B does not require that the stack be implemented before the cascade is implemented.
- Framing B does not require that any layer of the stack be implemented in the current project scope.
- Framing B does not alter the baseline gate status. `dcrnn_baseline` remains the cleared reference; Stage B's behaviour with zero dialogue input must reproduce the baseline exactly.

## Claim boundary

- Framing B is a specification choice, not an implementation.
- Choosing framing B does not upgrade the cognitive stack's tier.
- The draft in `13_cognitive_stack_draft.md` is not superseded by this document; it is extended. Q2–Q7 remain PENDING.
- This document may not be cited as evidence of any system capability.

## Governance

A future document that claims framing B is realised in code must present:

1. Committed implementation of at least L1 and the dialogue layer, with explicit specification of their input/output schemas.
2. A stability mechanism selected and implemented (one of the three candidates above, or a documented alternative).
3. An ablation run demonstrating that with the dialogue disabled the system reproduces the cascade's baseline behaviour within tolerance.
4. A separate `status.json` classification for the framed-B-realised-in-code variant.

Until all four are satisfied, the resolution of Q1 remains a specification commitment only.
