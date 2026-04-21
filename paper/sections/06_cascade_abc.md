# Asynchronous Inferential Cascade — A → B → C

This section specifies a three-stage asynchronous inferential cascade layered
on top of the existing Probingnoise core. The cascade is a proposed
architectural extension and is not empirically validated within the present
work. The Probingnoise core described elsewhere in this paper remains the
implemented synchronous, Colab-trainable base; its blocks, residual
pathways, and training regime are preserved.

## Positioning paragraph

This work specifies a three-stage asynchronous inferential cascade layered on
top of the existing Probingnoise core. The base remains the implemented
synchronous, Colab-trainable stack described previously; the cascade is
proposed as an additive extension and is not empirically validated within
this paper. The three stages address three distinct regimes of asynchrony
identified as architecturally independent.

**Stage A — multi-rate ingestion.** Heterogeneous input streams (e.g., visual
frames, auxiliary sensors, discrete events) arrive at different timescales.
Stage A normalizes them into a common representational substrate without
imposing a global synchronization barrier. Its architectural role is to
decouple upstream rate from downstream computation. Prior work on
event-driven and asynchronous graph processing (Faber and Wattenhofer, 2022,
2024) establishes that useful representation can be maintained without
strict message-level synchronization; we adopt this only as lineage.

**Stage B — heterogeneous compute.** The Probingnoise core operates within
Stage B as the spatiotemporal backbone. Sub-processes within this stage have
unequal computational cost, and a synchronous schedule would block fast
sub-processes behind slow ones. Stage B is specified to permit non-blocking
progress across sub-processes, drawing architectural precedent from lock-free
stochastic optimization (Niu et al., 2011) and foundational work on
asynchronous iterative methods (Bertsekas and Tsitsiklis, 1989). No property
of those works is inherited as a property of the current implementation.

**Stage C — anytime refinement.** The topmost stage is specified to emit
partial predictions and continue refining in the background, rather than
blocking output on convergence. This design follows the general
anytime-algorithm regime; the contribution here is integration with Stages A
and B within a consistent cascade, not the anytime principle itself.

Novelty is claimed at the level of the integrated cascade — specifically, the
assignment of one asynchronous regime to each stage and the specification of
their composition on top of the Probingnoise residual structure — rather
than at the level of any individual stage component. Empirical validation of
the cascade is deferred to future work.

## Design doc

### Invariants (non-negotiable across the stack)

- Downstream stages never block on strict ordering guarantees from upstream stages.
- Each stage has an explicit definition of what "partial output" means for it.
- The Probingnoise core is preserved as-is within Stage B; no changes to its
  blocks, residual pathways, or training regime.

### Stage A — Multi-rate ingestion layer

- **Input:** heterogeneous streams at native rates.
- **Output:** normalized representations tagged with arrival time and source.
- **Async regime:** multi-rate. No global clock; each source produces when ready.
- **Partial output semantics:** a snapshot reflecting whichever sources have
  reported since last read.
- **Literature basis:** asynchronous / event-driven graph processing (lineage only).

### Stage B — Heterogeneous compute layer (Probingnoise core lives here)

- **Input:** Stage A snapshots.
- **Output:** intermediate representations from the Probingnoise residual
  stack, optionally annotated with which sub-processes completed.
- **Async regime:** lock-free / non-blocking across sub-processes of unequal cost.
- **Partial output semantics:** intermediate representations computed from
  whichever sub-processes have finished; stale sub-process outputs permitted
  within a bounded staleness window.
- **Literature basis:** Bertsekas & Tsitsiklis (1989), Niu et al. (2011) —
  lineage only.
- **Integrity note:** the Probingnoise training regime remains synchronous;
  Stage B's async regime applies to inference-time composition of the core's
  outputs, not to its training.

### Stage C — Anytime refinement layer

- **Input:** Stage B intermediate representations.
- **Output:** predictions, emitted progressively.
- **Async regime:** anytime — output is available at any point; quality
  improves with compute budget.
- **Partial output semantics:** first prediction is emitted as soon as a
  quality floor is met; refinement continues in background until the next
  Stage B update invalidates the frame.
- **Literature basis:** anytime-algorithm regime (general lineage, no single
  paper load-bearing).

### Composition rule

A → B → C is a directional cascade. Each boundary is an async buffer, not a
synchronous hand-off. Backpressure is handled per-stage (drop-oldest by
default).

### What is implemented today

None of A, B, or C as specified. The Probingnoise synchronous core exists
and is what would live inside B once B is implemented. The specification
above is architectural.

## Literature mapping (no overlap between stages)

| Stage | Literature | Role |
|-------|------------|------|
| A | Faber & Wattenhofer (2022, 2024) | Event-driven / async graph — lineage for multi-rate ingestion |
| B | Bertsekas & Tsitsiklis (1989); Niu et al. (2011) | Async iterative / lock-free — lineage for heterogeneous compute |
| C | Anytime algorithms (general lineage) | Progressive refinement |

No reference is load-bearing for any capability claim. All references
establish lineage only.
