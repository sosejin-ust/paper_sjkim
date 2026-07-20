#!/usr/bin/env bash
# paper_sjkim 저장소를 원격과 동기화한다 (pull -> commit -> push).
# 사용법: ./scripts/sync.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== git pull =="
git pull --rebase

if [ -n "$(git status --porcelain)" ]; then
    echo "== changes detected, committing =="
    git add -A
    git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
else
    echo "== no local changes =="
fi

echo "== git push =="
git push

echo "== done =="
