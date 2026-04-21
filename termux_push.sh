#!/data/data/com.termux/files/usr/bin/bash
set -e
REPO_DIR="${1:-.}"
REMOTE="${2:-origin}"
cd "$REPO_DIR"
echo "==> Repo: $(pwd)"
echo "==> Remote: $REMOTE ($(git remote get-url "$REMOTE" 2>/dev/null || echo 'NOT SET'))"
echo "==> Fetching everything..."
git fetch --all --prune --tags
echo "==> Tracking remote branches locally..."
for remote_branch in $(git branch -r | grep -v '\->' | grep -v "$REMOTE/HEAD"); do
  local_branch="${remote_branch#"$REMOTE"/}"
  if ! git show-ref --verify --quiet "refs/heads/$local_branch"; then
    git branch --track "$local_branch" "$remote_branch" 2>/dev/null || true
    echo "   tracked: $local_branch"
  fi
done
echo "==> Pushing all branches..."
git push "$REMOTE" --all
echo "==> Pushing all tags..."
git push "$REMOTE" --tags
echo "==> Writing bundle backup..."
STAMP=$(date +%Y%m%d-%H%M%S)
BUNDLE="/sdcard/$(basename "$(pwd)")-$STAMP.bundle"
git bundle create "$BUNDLE" --all 2>/dev/null || BUNDLE="$(pwd)/backup-$STAMP.bundle" && git bundle create "$BUNDLE" --all
echo "   bundle: $BUNDLE"
echo ""
echo "==> DONE. Colab can clone from:"
git remote get-url "$REMOTE"
