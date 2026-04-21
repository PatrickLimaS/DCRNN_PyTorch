# Partial Project Report — Probingnoise × DCRNN_PyTorch

*Documentation draft for ongoing work, baseline discipline, and cognition-to-architecture projection.*

| Date | 2026-04-21 | Report Type | Partial progress / design note |
| --- | --- | --- | --- |
| Current Focus | Baseline + Global Re-entry Projection | Status | Pre-baseline, architecture disciplined |

## 1. Executive Snapshot

The project has evolved from a loose idea set into a governed research artifact with code substrate, claim discipline, paper scaffolding, and staged architectural proposals.

The immediate hard gate remains baseline reproduction. Until the DCRNN baseline is completed cleanly, no transfer-eligible empirical claim should be promoted.

A new design direction is now defined: a global pooled latent projected back into local states through a residual normalized path, treated as a functional analogue of pervasive evaluative pressure rather than any literal consciousness claim.

## 2. Current Project State

**Repository condition.** The merged stack already contains the DCRNN substrate, governance files, staged paper materials, and a clean public framing as research in progress.

**Evidence condition.** Baseline is still the blocking gate. Existing variant numbers are useful as exploratory traces but remain non-defended until the baseline row is completed under a consistent budget.

**Strategic condition.** The project is now limited more by empirical completion than by conceptual clarity.

## 3. Functional Projection of Brain Processes

**Design principle.** The goal is not biological emulation or mind transfer. The goal is to translate stable cognitive process motifs into computational operators that can be specified, ablated, and measured.

| Observed cognitive motif | Computational operator | Paper-safe phrasing |
| --- | --- | --- |
| Global/local co-presence | Pooled global latent + broadcast projection | Global re-entry projection |
| Constraint pressure on local thought | Residual global signal merged into local states | Pervasive evaluative constraint |
| Fast anomaly pickup | Salience gate or divergence-weighted routing | Anomaly-sensitive modulation |
| Multiple partial tracks | Parallel state branches / unequal-cost paths | Heterogeneous sub-process composition |
| Delayed stronger synthesis | Anytime refinement | Time-bounded output with background refinement |

## 4. Selected Module: Global Re-entry Projection (GRP)

**Core idea.** The distributed hidden state is pooled into a single global latent and projected back into each local state through a residual normalized path.

- g_t = P(H_t)
- p_{i,t} = W_g · g_t
- ~h_{i,t} = LN(h_{i,t} + α · p_{i,t})

**Interpretation.** Every local state remains local, but all local states are touched by the same global projection. This yields a field-like global pressure without anthropomorphic overclaim.

## 5. Baseline Discipline

| Layer | Objective | What stays fixed | Status |
| --- | --- | --- | --- |
| Smoke run | Verify pipeline | Data path, logging, metric path, config contract | Required |
| Reduced run | Check training dynamics | Same config family, short budget | Required |
| Full baseline | Clear reproduction gate | Vanilla DCRNN only | Blocking |
| GRP ablation | Measure added value | Everything except GRP | After baseline |

## 6. Partial Findings to Preserve

- The project already has unusually strong claim discipline for its stage.
- The main threshold is empirical completion, not conceptual positioning.
- GRP is the cleanest first module for projecting cognition-inspired process into the current stack.
- Use "conscience" only as an internal metaphor; public language should stay with global constraint, evaluative projection, or re-entry projection.

## 7. Recommended Documentation Rhythm

Create one partial report per meaningful checkpoint, not per minor thought.

## 8. Reusable Partial Report Template

See `docs/PARTIAL_REPORT_TEMPLATE.md`.

---

*Prepared as a documentation artifact for ongoing project continuity.*
