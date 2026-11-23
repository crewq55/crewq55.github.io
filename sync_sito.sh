#!/usr/bin/env bash
# sincronizza docs/ -> sito pubblico crewq55.github.io/pungiball/
# privacy+terms pubblici, checklist+idee CIFRATE con la password gate
# uso: bash sync_sito.sh [password]
set -e
PW="${1:-saidsaid}"
SRC="C:/Users/icelil/PunchBall/docs"
SITE="C:/Users/icelil/site/pungiball"
TPL="C:/Users/icelil/site/gate_template.html"
mkdir -p "$SITE"
cp "$SRC/privacy.html" "$SRC/terms.html" "$SITE/"
lock() {
  local f="$1" title="$2"
  local blob; blob=$(openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -md sha256 -in "$SRC/$f" -pass "pass:$PW" | base64 -w0)
  awk -v blob="$blob" -v title="$title" '{gsub(/__TITLE__/,title); if($0~/__BLOB__/){print blob; next} print}' "$TPL" > "$SITE/$f"
}
lock BETA_CHECKLIST.html "Checklist"
lock IDEE.html "Bacheca Idee"
cd "C:/Users/icelil/site"
git add -A && git commit -qm "sync sito $(date +%Y-%m-%d)" && git push -q
echo "OK -> https://crewq55.github.io/pungiball/"
