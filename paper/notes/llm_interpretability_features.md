# LLM Interpretability and Feature Generation — Exploratory Note

**Status: TIER 4 (SPECULATIVE).** Not a formal proposal. No implementation intent. Registered here to preserve the idea without inflating the active specification surface.

## Motivation

Two possible uses of an LLM (target: GLM-4.1V-Thinking, same as §21) in the project beyond scene graph generation:

**Function A — Interpretability at Stage C:**
An LLM reads the DCRNN's encoder hidden states, decoder predictions, or DivergenceHead outputs, and produces natural-language explanations. The LLM does not modify the forward pass. It acts as a post-hoc interpreter.

Example output: "The delta at node 17 indicates a regime change because the graph-conditioned stream predicted X while the parallel stream predicted Y, and this divergence pattern matches..."

**Function B — Feature generation for Stage A or B:**
The LLM extracts auxiliary features from raw input (text descriptions, reasoning traces about scenes, structured attributes) that are embedded and fed into Stage A (new ingestion) or Stage B (lateral input).

These two functions are orthogonal. Implementing one does not imply implementing the other.

## Why Tier 4 and not Tier 3

Promoting this to Tier 3 requires:
- Formal specification of LLM input/output schema
- Integration point in the cascade
- Loss function or consumption protocol
- PENDING list

None of these is written. Until written, the idea is speculation.

## Why register it at all

The idea connects with §21 (scene graph generation via GLM-4.1V) and §18 (dialogue layer as co-processor). Preserving it as a note allows future unification if the project's direction supports it.

## Condition for promotion to Tier 3

This note may be upgraded to a formal Tier 3 section only after:
1. §16 is confirmed as Tier 1 (parallel hidden-state implementation tested and documented)
2. §21 is confirmed as Tier 1 (GLM-4.1V scene graph pipeline tested)

Without both, adding a third LLM-involving proposal would over-extend the active surface.

## Claim boundary

- No part of this note is evidence of anything.
- No code exists.
- The LLM has not been integrated into any part of the stack.
- This is speculation registered for preservation, not for action.
