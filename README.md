# DCRNN_PyTorch — Probingnoise research substrate

Active branch: `pytorch_scratch`.

This repository is a research substrate, in public, combining the DCRNN architecture (Li et al., 2017) with a claim-disciplined documentation protocol. It is not a benchmark reproduction. It is not a validated clinical or production system. It is a space where architectural proposals are specified alongside the empirical work that constrains them.

## Current state (snapshot: 2026-04-22)

**Validated (Tier 1):**
- DCRNN baseline reimplemented in PyTorch; runs end-to-end at reduced regime (10 epochs, A100, test_mae 3.22). Single seed.
- Probingnoise variant `abl_no_aggregation` runs end-to-end at same regime. Two seeds. Test_mae 3.33 / 3.47. Seed-to-seed variance ~0.14.
- Siena EEG preprocessing pipeline runs on one patient (PN00).

**Specified (Tier 3):**
- Section 16: parallel hidden-state operator, intra-model, with learned gate fusion and DivergenceHead auxiliary supervision.
- Section 17: inter-model variant using DROID features with cross-attention fusion.
- Section 18: cognitive stack in co-processor framing (Q1 resolved).
- Section 19: schedule-based gating as stability mechanism (Q6 resolved).

**Known limits:**
- Single-seed comparisons are insufficient for categorical claims.
- Four ablation variants are committed under a normalised-MAE regime and remain INCONCLUSIVE until re-run in the current absolute-MAE regime.
- No proposed extension (§§16–19) is implemented.
- No training loop has been run on the Siena EEG dataset.

## Structure

- `model/pytorch/` — DCRNN core and Probingnoise blocks (`LocalGlobalAggBlock`, `SkipLayerNorm`, `DivergenceHead`).
- `paper/sections/` — 20 sections, each with declared claim tier.
- `paper/bibtex/references.bib` — ~40 peer-reviewed entries, including GDGCRN (2025) and DGDCN (2025) as convergent recent directions.
- `docs/partial_reports/` — one report per empirical run, with explicit classification (`PIPELINE_VALIDATED_REDUCED`, `PIPELINE_VALIDATED_REDUCED_MULTI_SEED`).
- `docs/site/` — public-facing cyberpunk terminal facade.
- `status.json` — single source of truth for run state and metrics.
- `GOVERNANCE.md` — claim protocol and partial report template.

## Claim protocol

Every section in `paper/` and every report in `docs/partial_reports/` declares one of four tiers:

- **Tier 1** — Implemented and tested; evidence in this repository.
- **Tier 2** — Cited from literature; reference in `references.bib`.
- **Tier 3** — Proposed; specified here but not implemented.
- **Tier 4** — Speculative; explicitly marked as future direction.

No claim in this repository is allowed to cross tiers without an accompanying evidence bundle. The Evidence Matrix (`paper/sections/12_evidence_matrix.md`) tracks where each row sits.

## Site

A public-facing summary is available at:
https://patricklimas.github.io/DCRNN_PyTorch/site/

## License and attribution

Built on the DCRNN PyTorch reimplementation by Chintan Shah (chnsh/DCRNN_PyTorch), itself derived from the original DCRNN TensorFlow implementation by Li et al. (liyaguang/DCRNN).
