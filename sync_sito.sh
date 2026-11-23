#!/usr/bin/env bash
# sincronizza docs/ -> sito pubblico crewq55.github.io/pungiball/
# privacy+terms pubblici; checklist+idee dietro gate password.
# Il gate cifra SOLO il nome del file segreto -> redirect -> la pagina vera
# e' HTML normale: script/bottoni/immagini funzionano su telefono.
# uso: bash sync_sito.sh [password]
set -e
PW="$(echo "${1:-saidsaid}" | tr 'A-Z' 'a-z')"
SRC="C:/Users/icelil/PunchBall/docs"
SITE="C:/Users/icelil/site/pungiball"
TPL="C:/Users/icelil/site/gate_template.html"
mkdir -p "$SITE"
cp "$SRC/privacy.html" "$SRC/terms.html" "$SITE/"

lock() {
  local f="$1" title="$2"
  # nome segreto deterministico: <base>-<hash(file+pw)>.html
  local base="${f%.html}"
  local h; h=$(echo -n "${base}:${PW}" | sha256sum | cut -c1-8)
  local secret="${base}-${h}.html"
  cp "$SRC/$f" "$SITE/$secret"
  # il blob = il nome segreto cifrato con la password
  local blob; blob=$(echo -n "$secret" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -md sha256 -pass "pass:$PW" | base64 -w0)
  awk -v blob="$blob" -v title="$title" '{gsub(/__TITLE__/,title); if($0~/__BLOB__/){print blob; next} print}' "$TPL" > "$SITE/$f"
  echo "gate $f -> $secret"
}

lock BETA_CHECKLIST.html "Checklist"
lock IDEE.html "Bacheca Idee"
lock FIREBASE_REGOLE.html "Regole Firebase"

cd "C:/Users/icelil/site"
git add -A && git commit -qm "sync sito $(date +%Y-%m-%d)" && git push -q
echo "OK -> https://crewq55.github.io/pungiball/"
