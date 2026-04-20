#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$ROOT_DIR/manifests/validation_targets.yaml"
INPUT_CSV="$ROOT_DIR/reporting/summary_results.csv"
OUT_CSV="$ROOT_DIR/reporting/classified_results.csv"
OUT_MD="$ROOT_DIR/reporting/classification_summary.md"

if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: manifest not found at $MANIFEST" >&2
    exit 2
fi

if [ ! -f "$INPUT_CSV" ]; then
    echo "ERROR: input CSV not found at $INPUT_CSV" >&2
    exit 2
fi

echo "=== Probingnoise empirical validation run ==="
echo "manifest : $MANIFEST"
echo "input    : $INPUT_CSV"
echo ""

python "$ROOT_DIR/validate_result.py" \
    --manifest "$MANIFEST" \
    --input-csv "$INPUT_CSV" \
    --out-csv "$OUT_CSV" \
    --out-md "$OUT_MD"

RC=$?

if [ $RC -ne 0 ]; then
    echo "validate_result.py exited with rc=$RC" >&2
    exit $RC
fi

echo ""
echo "classified CSV : $OUT_CSV"
echo "summary MD     : $OUT_MD"
