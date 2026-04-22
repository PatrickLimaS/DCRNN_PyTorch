# Cognitive Stack — Q6 Resolution: Schedule-Based Gating

**Status: PROPOSAL (Tier 3).** Resolves Q6 from `13_cognitive_stack_draft.md` as extended in `18_cognitive_stack_q1_resolved.md`. Does not resolve Q2–Q5 or Q7. No capability is claimed; no implementation exists.

## Context

Framing B (co-processor) was adopted in section 18. Framing B introduces the possibility of unbounded feedback between the dialogue layer and Stage B. Section 18 listed three candidate stability mechanisms without adopting one:

- **Bounded staleness.** Dialogue signals consumed at tick $k$ must come from stack state at tick $k - \tau$ or earlier, for some fixed $\tau \geq 1$.
- **Explicit decay.** Dialogue modulation signal passes through a decay factor $\gamma \in (0, 1)$ at each tick.
- **Schedule-based gating.** Dialogue emits signal to Stage B only at pre-declared ticks, not continuously.

This document resolves Q6 by adopting schedule-based gating.

## Decision

**Schedule-based gating is adopted** as the primary stability mechanism. Bounded staleness arises implicitly as a consequence (see below). Explicit decay is rejected for this project.

## Specification

Let $k \in \mathbb{Z}_{\geq 1}$ be a fixed emission period. Let $t$ denote the cascade tick index. The dialogue layer's output $m_t$ (the modulation signal fed into Stage B) is defined as:

$$
m_t = \begin{cases}
\mathrm{Dialogue}(S_{t-1}) & \text{if } t \bmod k = 0 \\
\mathbf{0} & \text{otherwise}
\end{cases}
$$

where $S_{t-1}$ is the stack state at the previous tick and $\mathrm{Dialogue}(\cdot)$ is the monitoring/modulation function (its internal form is PENDING — Q3 and Q4).

Stage B receives $m_t$ at every tick, but $m_t = \mathbf{0}$ outside emission ticks. In emission ticks, $m_t$ modulates Stage B's aggregation via the mechanism to be specified in Q4.

## Implicit bounded staleness

Because $m_t$ depends on $S_{t-1}$ and is only consumed at ticks where $t \bmod k = 0$, the effective staleness is $\tau = 1$ within an emission interval. Across intervals, the stack's view of Stage B lags by at most $k$ ticks, because the stack's own update schedule is separately specified. This gives the system a natural upper bound on feedback latency without requiring an independent bounded-staleness constraint.

## Why schedule-based (not decay)

Three reasons, in descending order of weight.

**1. Computational economy.**

Schedule-based gating evaluates the dialogue at $1/k$ of the cascade's rate. For $k = 4$, dialogue overhead is reduced to 25% of its continuous-emission cost. Explicit decay requires evaluating the dialogue at every tick, even when its signal is strongly attenuated — saving no compute.

**2. Debuggability.**

With schedule, "is dialogue active at this tick?" is a boolean derivable from $t$ and $k$ alone. With decay, the question becomes "is the current magnitude of $m_t$ above a threshold I care about?", which requires inspecting the signal. Binary visibility is easier to reason about, especially during implementation and ablation.

**3. Staleness for free.**

As described above, the schedule naturally produces bounded staleness without introducing an independent $\tau$ parameter. Decay does not; decay needs an additional constraint to guarantee non-instantaneous feedback.

## Cost of schedule-based gating

Introducing $k$ creates a new hyperparameter coupled to the stack–cascade relationship:

- $k = 1$: dialogue emits every tick. Effectively continuous; stability advantage reduces to bounded staleness alone.
- $k$ too large: dialogue is essentially absent; cognitive modulation contributes nothing.
- Intermediate $k$: dialogue contributes periodically; the period is a tunable architectural knob.

The choice of $k$ is **sub-PENDING** within Q6. Proposed default for exploration: $k = 4$, based on no empirical justification — a placeholder that forces concreteness during implementation. This placeholder must be revisited before any claim is made.

## Relation to Q5 (schedule)

Q5 asked whether the dialogue's update is synchronous, sub-tick, or event-triggered. Schedule-based gating is a form of **periodic sub-tick update**: the dialogue itself may update every tick internally, but its emission to Stage B is sub-sampled. Q5 is therefore partially constrained by this resolution: the emission is periodic, the internal update can be anything compatible with that periodicity. The remaining choice (does the dialogue's internal state update every tick or only on emission ticks?) is held as a sub-PENDING of Q5.

## What Q6 resolution requires next

With schedule-based gating adopted, the following items inherit constraints:

- **Q2 (layer signatures).** Each of L1–L5 has a clock; the dialogue's clock is $k$ times slower than the cascade's for emission purposes.
- **Q4 (dialogue modulation).** The modulation signal $m_t$ must be well-defined at zero (the off-period value). This constrains how modulation is applied in Stage B: it must be an additive or multiplicative structure where $m_t = \mathbf{0}$ leaves Stage B unchanged. Q4 must respect this.
- **Q5 (schedule).** Already partially constrained as above.
- **Q7 (ablation).** Disabling the dialogue corresponds to setting $k = \infty$ (or equivalently, `dialogue_enabled: false`). The system must degrade to framing A behaviour in that case. This is consistent with section 18's Q7 requirement.

## Claim boundary

- Schedule-based gating is a specification choice, not an implementation.
- The value of $k$ is unresolved; any concrete $k$ mentioned here is a placeholder.
- This document does not upgrade the cognitive stack's tier.
- Q2, Q3, Q4, Q5, Q7 remain PENDING. Q6 is resolved up to the choice of $k$.

## Governance

A future document claiming schedule-based gating is realised in code must present:

1. Committed implementation with a configurable `k` parameter and a default value documented.
2. An ablation showing that with `dialogue_enabled: false` (equivalently $k = \infty$) the system reproduces the framing-A behaviour and, at the limit, the baseline.
3. At least two values of $k$ tested, with the choice justified by an explicit criterion (stability, performance, or compute).
4. A separate `status.json` classification for the framed-B-with-schedule-gating variant.

Until all four are satisfied, the resolution of Q6 remains a specification commitment only.
