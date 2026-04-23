# §16 Amendment — Implementation Reality vs Original Spec (2026-04-23)

**Status:** AMENDMENT to §16. Original section retained for historical transparency; this amendment documents the conceptual correction discovered during implementation.

## What the original §16 specified

- V1=a: second stream receives same hidden state
- V2=a: fusion by learned sigmoid gate (bias init +3.0)
- V3=a: independent weights (second LocalGlobalAggBlock)
- V4=c: DivergenceHead supervises the delta between streams

Implemented across 8 iterations producing two LocalGlobalAggBlock instances + learned gate + optional DivergenceHead.

## What implementation revealed

DivergenceHead in probingnoise_blocks.py has signature forward(z_local, z_global) — expects the two projections of a SINGLE LocalGlobalAggBlock called with return_parts=True, not a pre-computed delta from two separate blocks.

The "parallel stream" was always internal to LocalGlobalAggBlock (local projection + global mean projection). The original §16 spec described a second-level parallelism the library was not designed for.

## What §16 actually is (Option 1, commit 20d31f3)

- Single LocalGlobalAggBlock with return_parts=True exposing (y, z_local, z_global, delta)
- y used by decoder; (z_local, z_global) passed to DivergenceHead
- y_div serves as auxiliary supervision target
- No second block, no gate, no convex fusion

## Why the original spec was wrong

Imagined "parallel" as "two streams on same input." Library already factorizes parallelism inside LocalGlobalAggBlock. Duplicating the block added capacity without structural distinction beyond what already exists.

Specification error, not implementation error. Corrected at iteration 9 after 8 iterations revealed the mismatch.

## Governance implication

When spec and library are misaligned, patches chain indefinitely. Correct response: re-read library interfaces and update spec. Standalone diagnostic validation before commit is the documented pattern for future Tier 3 → Tier 1 promotions.

## Updated claim

§16 V4=c Option 1 is Tier 1. Reduced 10 epochs, 1 seed, test_mae 3.2525 vs baseline 3.2176, delta within noise floor. See docs/partial_reports/2026-04-23_s16_v4c_option1_reduced.md.

V1, V2, V3 of original spec no longer correspond to implemented code.
