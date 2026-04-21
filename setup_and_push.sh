#!/data/data/com.termux/files/usr/bin/bash
set -e

USER="pat177251-lgtm"
REPO="DCRNN_PyTorch"

read -rsp "Paste your GitHub token (hidden): " TOKEN
echo ""

echo "==> Setting remote with token..."
git remote set-url origin "https://${USER}:${TOKEN}@github.com/${USER}/${REPO}.git"

echo "==> Testing access..."
if ! git ls-remote origin &>/dev/null; then
  echo "ERROR: Can't reach repo. Check that:"
  echo "  1. Repo exists at https://github.com/${USER}/${REPO}"
  echo "  2. Token has 'repo' scope (classic) OR Contents:write (fine-grained)"
  exit 1
fi

echo "==> Access OK. Running push script..."
./termux_push.sh . origin
