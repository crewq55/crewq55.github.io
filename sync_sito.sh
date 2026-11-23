#!/usr/bin/env bash
# sincronizza docs/ -> sito pubblico crewq55.github.io/pungiball/
# privacy+terms pubblici. checklist+idee sono PAGINE VERE con nome segreto;
# BETA_CHECKLIST.html e IDEE.html sono solo gate: decifrano l'URL e reindirizzano.
# (niente document.write: su mobile ammazzava tutti gli script della pagina)
# uso: bash sync_sito.sh [password]
set -e
PW="${1:-saidsaid}"
SRC="C:/Users/icelil/PunchBall/docs"
SITE="C:/Users/icelil/site/pungiball"
TPL="C:/Users/icelil/site/gate_template.html"
TKC="checklist-5f6ba7e3.html"   # nome segreto della checklist vera
TKI="idee-a8b463cf.html"        # nome segreto della bacheca vera
mkdir -p "$SITE"
cp "$SRC/privacy.html" "$SRC/terms.html" "$SITE/"
cp "$SRC/BETA_CHECKLIST.html" "$SITE/$TKC"
cp "$SRC/IDEE.html" "$SITE/$TKI"
sed -i 's|crewq55.github.io/PUNGIBALL/BETA_CHECKLIST.html (dopo attivazione Pages)|crewq55.github.io/pungiball/BETA_CHECKLIST.html — pw: saidsaid|' "$SITE/$TKC"
lock() {  # $1=url segreto $2=titolo $3=file gate
  local blob; blob=$(printf '%s' "$1" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -md sha256 -pass "pass:$PW" | base64 -w0)
  awk -v blob="$blob" -v title="$2" '{gsub(/__TITLE__/,title); if($0~/__BLOB__/){print blob; next} print}' "$TPL" > "$SITE/$3"
}
lock "$TKC" "Checklist"     "BETA_CHECKLIST.html"
lock "$TKI" "Bacheca Idee"  "IDEE.html"
cd "C:/Users/icelil/site"
git add -A && git commit -qm "sync sito $(date +%Y-%m-%d)" && git push -q
echo "OK -> https://crewq55.github.io/pungiball/"
