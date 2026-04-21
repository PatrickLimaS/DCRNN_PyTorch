# DROID and OpenVLA as Integration Targets

## Status

DROID (Khazatsky et al., 2024) and OpenVLA (Kim et al., 2024) are specified as integration targets for the cascade (`06_cascade_abc.md`). Neither is used, trained on, or benchmarked against in this paper.

## DROID as Stage A exercise

DROID's heterogeneous streams (camera, proprio, gripper, language) at different rates exercise Stage A's multi-rate ingestion without a global sync barrier. No DROID component is retrained; DROID is used as a stream generator. Deferred work.

## OpenVLA as optional Stage C head

Two framings:
- **External oracle** consulted by Stage C (consistent with `07_motivation.md`).
- **Drop-in prediction head** on Stage B output (optionally post-GRP), without modifying the Probingnoise core.

## Interface schemas (specified, not implemented)

Stage A snapshot: `{t, source, payload}`.
Stage B → OpenVLA head: `{fused_representation, visual_context, language_context}`; `fused_representation` concatenated as auxiliary feature.

## Claim boundary

Nothing implemented, nothing benchmarked. Empirical validation is gate-blocked by `dcrnn_baseline`. DROID and OpenVLA results remain the original authors'.
