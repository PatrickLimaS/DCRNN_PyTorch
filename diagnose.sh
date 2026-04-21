#!/data/data/com.termux/files/usr/bin/bash
USER="pat177251-lgtm"
REPO="DCRNN_PyTorch"

read -rsp "Paste your GitHub token (hidden): " TOKEN
echo ""
echo ""

API="https://api.github.com"
AUTH="Authorization: Bearer $TOKEN"

echo "==> [1/4] Is the token valid?"
USER_JSON=$(curl -s -H "$AUTH" "$API/user")
LOGIN=$(echo "$USER_JSON" | grep -o '"login": *"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$LOGIN" ]; then
  echo "    FAIL: Token is invalid or expired."
  echo "    FIX: Generate a new token at https://github.com/settings/tokens"
  exit 1
fi
echo "    OK: Token belongs to '$LOGIN'"

if [ "$LOGIN" != "$USER" ]; then
  echo "    WARNING: Token is for '$LOGIN', but script expects '$USER'."
  echo "    Switching to '$LOGIN'."
  USER="$LOGIN"
fi

echo ""
echo "==> [2/4] Does repo $USER/$REPO exist?"
REPO_CODE=$(curl -s -o /tmp/repo.json -w "%{http_code}" -H "$AUTH" "$API/repos/$USER/$REPO")
if [ "$REPO_CODE" = "404" ]; then
  echo "    FAIL: Repo does not exist."
  echo "    Auto-creating it now..."
  CREATE=$(curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
    "$API/user/repos" -d "{\"name\":\"$REPO\",\"private\":false}")
  if echo "$CREATE" | grep -q '"full_name"'; then
    echo "    OK: Repo created."
  else
    echo "    FAIL: Could not create repo. Token needs 'repo' scope (classic) or 'Administration: write' + 'Contents: write' (fine-grained)."
    echo "$CREATE" | head -20
    exit 1
  fi
elif [ "$REPO_CODE" = "200" ]; then
  echo "    OK: Repo exists."
else
  echo "    FAIL: HTTP $REPO_CODE"
  cat /tmp/repo.json | head -20
  exit 1
fi

echo ""
echo "==> [3/4] Can token write to repo?"
PERM=$(curl -s -H "$AUTH" "$API/repos/$USER/$REPO" | grep -o '"push": *[a-z]*' | head -1 | cut -d':' -f2 | tr -d ' ')
if [ "$PERM" = "true" ]; then
  echo "    OK: Token has push permission."
else
  echo "    FAIL: Token has no push permission."
  echo "    FIX (classic token): enable 'repo' scope."
  echo "    FIX (fine-grained):  set Contents -> Read and write, include repo '$REPO'."
  exit 1
fi

echo ""
echo "==> [4/4] Updating remote and pushing..."
git remote set-url origin "https://$USER:$TOKEN@github.com/$USER/$REPO.git"
./termux_push.sh . origin
