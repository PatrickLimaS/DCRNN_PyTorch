# Problem Statement

The project addresses the question of how a predictive system should
represent and respond to breaks in regularity over heterogeneous
temporal and structural signals. Three formulations are held jointly;
each is usable at different levels of compactness.

## Expanded

The system models asymmetric context as a rupture of temporal and
structural regularity, treating breaks in frequency, continuity, or
coordination among signals as evidence of a regime change.

## Short

Context asymmetry is treated as a rupture of regularity, localised in
time and structure.

## Hypothesis form

If a system represents context as the joint history of temporal and
structural regularity, then breaks in that regularity — detected
locally and propagated globally — constitute the operational signal
for regime change.

## Relation to the cascade

The three stages of the cascade (`06_cascade_abc.md`) correspond to
three distinct roles in this formulation:

- **Stage A — multi-rate ingestion.** Presents the raw signals at the
  rate at which they arrive, without forcing synchronisation.
- **Stage B — heterogeneous compute with GRP.** Holds the graph
  coordination core; the Global Re-entry Projection
  (`08_grp.md`) is where local and global state interact and where
  rupture detection must land if it is to modulate subsequent
  compute.
- **Stage C — anytime emission.** Exposes the system's best current
  estimate, including rupture-conditioned ones, under bounded
  latency.

This is the architectural side of the statement. The cognitive-stack
draft (`13_cognitive_stack_draft.md`) proposes a parallel structure
that expresses the same problem in layered-agent terms.

## Relation to testbeds

Two testbeds carry complementary aspects of the problem:

- **METR-LA** (traffic forecasting): regularity as multi-sensor
  coordination under diurnal, weekly, and stochastic variation.
  Ruptures here are soft — regime shifts rather than events.
- **Siena EEG** (`14_siena_as_testbed.md`): regularity as
  multi-channel rhythmic structure under clinical annotation.
  Ruptures are hard — seizure onset is a discrete event with
  ground-truth timestamps.

The two regimes span the space of rupture types the system is meant
to handle. Neither is a benchmark target; both are testbeds for
pipeline and cascade behaviour.

## Claim boundary

- No claim is made that the current system detects ruptures better
  than prior work on either testbed.
- No claim is made that the cognitive stack's layers participate in
  rupture detection until their operational detail is specified.
- The problem statement is a framing commitment, not a performance
  claim. It binds the rest of the paper to a specific question; it
  does not answer the question.
