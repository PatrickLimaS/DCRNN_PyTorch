#!/data/data/com.termux/files/usr/bin/bash
USER="PatrickLimaS"
curl -s "https://api.github.com/users/$USER/repos?per_page=100" | \
python3 -c "
import json, sys
repos = json.load(sys.stdin)
print(f'{len(repos)} repos for $USER:\n')
for r in repos:
    fork = ' [fork]' if r['fork'] else ''
    print(f\"  • {r['name']}{fork}\")
    print(f\"    {r['html_url']}\")
    print(f\"    default: {r['default_branch']}  |  updated: {r['updated_at'][:10]}\")
    if r['description']: print(f\"    {r['description']}\")
    print()
"
