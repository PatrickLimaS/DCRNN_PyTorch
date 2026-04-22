# Cognitive Stack — Draft Specification

**Status: DRAFT.** Sketches the multi-layer extension announced in `12_evidence_matrix.md` as a parallel structure to the cascade ABC. Not final. Items flagged as PENDING are required before any operational claim.

## Position in the architecture

The cognitive stack is proposed as a structure **parallel to** the asynchronous inferential cascade (`06_cascade_abc.md`), not a replacement. The cascade continues to handle ingestion, heterogeneous compute, and anytime emission. The stack sits alongside and exchanges signal at specified interfaces.

**PENDING:** Exact interface schema. Candidate framings below; none adopted.

## Five layers (provisional naming)

| Layer | Provisional name | Motif mapped from |
| :--- | :--- | :--- |
| L1 | Local-state layer | Local thought |
| L2 | Global-state layer | Global/local co-presence |
| L3 | Anomaly-gate layer | Fast anomaly pickup |
| L4 | Multi-track layer | Multiple partial tracks |
| L5 | Refinement layer | Delayed stronger synthesis |

**PENDING for each layer:** input signature, output signature, internal state, update rule, failure mode. Until specified, names are motivational anchors, not operational components.

## Internal dialogue layer

Proposed as a sixth transversal element that monitors L1-L5 and modulates them according to a predefined update schedule.

**PENDING:** what it monitors (activation / divergence / anomaly / composite), what it emits (gating weights / routing / residual), update schedule (sync / sub-tick / event-triggered).

## Interface candidates

Three framings for stack-cascade coupling; none adopted:

- **A — Stack as consumer.** Cascade runs ABC; stack receives Stage C output and produces downstream projection. Minimal coupling.
- **B — Stack as co-processor.** Stack runs in parallel; layers consult Stage B at prescribed moments; dialogue feeds back into Stage B aggregation. Bidirectional; requires stability proof.
- **C — Stack embedded in Stage B.** Stage B replaced by the five-layer stack; dialogue replaces B's aggregation. Single unified architecture; explicitly rejected for this draft.

**PENDING:** Choice between A, B, C with justification.

## Claim boundary

- No layer is implemented.
- No interface with the cascade is implemented.
- Internal dialogue has no operational definition here.
- "Under specification" in the Evidence Matrix corresponds to this document.
- May not be cited as evidence for any system capability.

## Open specification questions

Numbered for reference from future partial reports:

1. Which framing (A/B/C) governs stack-cascade coupling?
2. What are input/output schemas of L1-L5?
3. What signal does the dialogue monitor?
4. What form does dialogue modulation take?
5. Sync, sub-tick, or event-triggered schedule?
6. Stability guarantees for framing B?
7. Default behaviour when dialogue disabled or layer ablated?

## Governance

This document is exempt from "specification voice" only because it explicitly names its pending items. Any text that describes stack behaviour as operational would violate the claim protocol.
