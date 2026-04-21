#!/data/data/com.termux/files/usr/bin/bash
set -e

cd "$HOME/DCRNN_PyTorch"

BRANCH="governance/scaffolding"

echo "==> [1/8] Creating branch $BRANCH from pytorch_scratch..."
git fetch origin
git checkout pytorch_scratch
git pull origin pytorch_scratch
git checkout -B "$BRANCH"

echo ""
echo "==> [2/8] Creating folder structure..."
mkdir -p defended
mkdir -p active/stage1_local_global_divergence
mkdir -p architecture_proposals/manifesto
mkdir -p architecture_proposals/stages_2_to_5
mkdir -p architecture_proposals/async_stack

echo ""
echo "==> [3/8] Writing GOVERNANCE.md (top-level)..."
cat > GOVERNANCE.md << 'GOV'
# Governance Status

**⚠️ BASELINE REPRODUCTION GATE: NOT CLEARED**

Per the Probingnoise patched documentation (Section 2, 10):

- `dcrnn_baseline` has **not** been run.
- This is a **blocking gate**, not an inconclusive result.
- **No real-benchmark claim is authorized** until this gate is cleared.
- All current completed runs (`probingnoise_graph_core`, `local_only`, `abl_no_graph`) are INCONCLUSIVE (single seed, 10 epochs).
- `abl_no_aggregation` is PARTIAL (not a completed row).

## Active scope

Only **Stage 1** is live: explicit local/global divergence as a first-class inference object.
Stages 2–5 are staged and subordinate. See `architecture_proposals/` for staged material.

## Claim discipline

- The public repo handles claim governance, paper framing, evidence normalization.
- The DCRNN/METR-LA substrate handles execution.
- Defended claims live in `defended/` (currently empty — baseline gate blocks entry).
- Architecture proposals and manifesto/vision language live in `architecture_proposals/`.
- The "six-sense manifesto" and "permeating stream" are **orientation-only** and are NOT validated architecture.

See `NEXT_STEPS.md` for the ordered next actions.
GOV

echo ""
echo "==> [4/8] Writing NEXT_STEPS.md..."
cat > NEXT_STEPS.md << 'NXT'
# Next Steps (ordered, gate-enforced)

Per Probingnoise patched documentation, Section 9.

- [ ] 1. Run `dcrnn_baseline` and clear the baseline reproduction gate.
- [ ] 2. Finish `abl_no_aggregation` to final test metric.
- [ ] 3. Rerun the primary packet under the corrected code path with consistent budget.
- [ ] 4. Only then evaluate whether a full-budget multi-seed sweep is justified.
- [ ] 5. Keep architecture proposal documents separate from the defended public claim.

**Do not proceed to step N until step N-1 is checked off.**
NXT

echo ""
echo "==> [5/8] Writing status.json..."
cat > status.json << 'STATUS'
{
  "baseline_gate_cleared": false,
  "transfer_eligible": false,
  "active_stage": "stage_1_local_global_divergence",
  "runs": {
    "dcrnn_baseline":           { "state": "not_run",  "classification": "GATE_BLOCKING" },
    "probingnoise_graph_core":  { "state": "completed", "metric": "test_mae", "value": 0.2575, "classification": "INCONCLUSIVE", "notes": "single seed, 10 epochs" },
    "local_only":               { "state": "completed", "metric": "test_mae", "value": 0.2565, "classification": "INCONCLUSIVE", "notes": "single seed, 10 epochs, post fc_linear clone fix" },
    "abl_no_graph":             { "state": "completed", "metric": "test_mae", "value": 0.2578, "classification": "INCONCLUSIVE", "notes": "single seed, 10 epochs, post-fix rerun" },
    "abl_no_aggregation":       { "state": "partial",   "metric": "val_mae (latest)", "value": 0.2494, "classification": "INCONCLUSIVE", "notes": "not a completed row; must finish" }
  }
}
STATUS

echo ""
echo "==> [6/8] Moving manifesto + staged material into architecture_proposals/..."
# Move files if they exist; safe no-op if they don't
for f in REPORT_SPRINT3.md WILDTIME_RUNBOOK.md paper_main.md \
         paper_final_version_draft_regenerated_1776633194-2.pdf \
         paper_validacao_externa-4.pdf; do
  if [ -f "$f" ]; then
    git mv "$f" "architecture_proposals/stages_2_to_5/$f" 2>/dev/null || mv "$f" "architecture_proposals/stages_2_to_5/$f"
  fi
done

# Quarantine the typo-filename file
if [ -f "h origin mainq" ]; then
  rm -f "h origin mainq"
  echo "    Removed stray file 'h origin mainq' (shell-typo artifact)."
fi

# Move wildtime runners (async/staged infra per Section 8) into async_stack proposals
for f in run_wildtime.py preflight_wildtime.py; do
  if [ -f "$f" ]; then
    git mv "$f" "architecture_proposals/async_stack/$f" 2>/dev/null || mv "$f" "architecture_proposals/async_stack/$f"
  fi
done

# Move the manifesto-style README section (if the probingnoise README is top-level, keep it but flag)
if [ -f "empirical_validation" ] || [ -d "empirical_validation" ]; then
  # empirical_validation stays at top-level — it's the active validation governance layer
  echo "    Kept empirical_validation/ at top level (active governance)."
fi

echo ""
echo "==> [7/8] Adding banner to top-level README.md..."
if [ -f README.md ]; then
  BANNER=$(cat << 'B'
> **⚠️ Governance status: BASELINE GATE NOT CLEARED.**
> Current evidence is INCONCLUSIVE. No real-benchmark claim is authorized.
> See [GOVERNANCE.md](GOVERNANCE.md) and [NEXT_STEPS.md](NEXT_STEPS.md).

B
)
  # Prepend banner
  printf '%s\n%s' "$BANNER" "$(cat README.md)" > README.md.new
  mv README.md.new README.md
  echo "    Banner added."
else
  echo "# DCRNN_PyTorch + Probingnoise" > README.md
  echo "" >> README.md
  echo "See GOVERNANCE.md and NEXT_STEPS.md." >> README.md
fi

echo ""
echo "==> [8/8] Committing and pushing..."
git add -A
git commit -m "Governance scaffolding: enforce PDF discipline (baseline gate, folder separation, status file)"
git push -u origin "$BRANCH"

echo ""
echo "============================================================"
echo "✅ DONE. Branch pushed: $BRANCH"
echo ""
echo "   Review the diff on GitHub:"
echo "   https://github.com/PatrickLimaS/DCRNN_PyTorch/tree/$BRANCH"
echo ""
echo "   Open a PR to merge into pytorch_scratch:"
echo "   https://github.com/PatrickLimaS/DCRNN_PyTorch/pull/new/$BRANCH"
echo ""
echo "   Or merge directly:"
echo "     git checkout pytorch_scratch"
echo "     git merge $BRANCH"
echo "     git push origin pytorch_scratch"
echo "============================================================"
