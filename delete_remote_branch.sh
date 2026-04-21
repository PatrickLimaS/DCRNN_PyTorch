#!/data/data/com.termux/files/usr/bin/bash
# Retries remote branch deletion with backoff, falls back to instructions.
set -e

cd "$HOME/DCRNN_PyTorch"

BRANCH="${1:-merge/probingnoise}"
MAX_RETRIES=5
DELAY=3

echo "==> Deleting remote branch: $BRANCH"
echo ""

for i in $(seq 1 $MAX_RETRIES); do
  echo "    Attempt $i/$MAX_RETRIES..."
  if git push origin --delete "$BRANCH" 2>&1 | \
       sed -E 's/(gh[pousr]_)[A-Za-z0-9]{20,}/\1REDACTED/g'; then
    echo ""
    echo "    ✅ Deleted remote branch '$BRANCH'."
    echo ""
    echo "==> Pruning stale remote refs locally..."
    git remote prune origin
    echo ""
    echo "============================================================"
    echo "✅ Cleanup complete."
    echo "   Verify: https://github.com/PatrickLimaS/DCRNN_PyTorch/branches"
    echo "============================================================"
    exit 0
  fi
  echo "    Failed. Waiting ${DELAY}s before retry..."
  sleep $DELAY
  DELAY=$((DELAY * 2))
done

echo ""
echo "============================================================"
echo "⚠ Could not delete after $MAX_RETRIES attempts."
echo "   Likely network issue. Delete manually on GitHub:"
echo "   https://github.com/PatrickLimaS/DCRNN_PyTorch/branches"
echo "   → find '$BRANCH' → click trash icon."
echo "============================================================"
exit 1
