#!/usr/bin/env bash
# Kit Qualità — hook Stop (quando Claude sta per chiudere il turno)
# Se nel progetto ci sono modifiche al codice non ancora verificate con
# /qualita, chiede a Claude di eseguire la checklist prima di chiudere.
# Interviene una sola volta per turno (stop_hook_active) e solo se dopo
# l'ultima verifica (.claude/.qualita-ok) qualche file è cambiato.
# Per disattivarlo in un progetto: crea il file .claude/kit-qualita-off

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
QUI="$(cd "$(dirname "$0")" && pwd)"
INPUT="$(cat)"

leggi() {
  printf '%s' "$INPUT" | node -e '
    let d=""; process.stdin.on("data",c=>d+=c).on("end",()=>{
      try { const j=JSON.parse(d); const v=j[process.argv[1]];
        process.stdout.write(v==null ? "" : String(v)); } catch(e) {} });' "$1" 2>/dev/null
}

[ "$(leggi stop_hook_active)" = "true" ] && exit 0
CWD="$(leggi cwd)"; [ -n "$CWD" ] || CWD="$PWD"
cd "$CWD" 2>/dev/null || exit 0
[ -f .claude/kit-qualita-off ] && exit 0

# 1. Valutazioni e lavori di interfaccia: sono state usate le skill del kit?
MSG="$(printf '%s' "$INPUT" | node "$QUI/verifica-skill.mjs" 2>/dev/null)"
if [ -n "$MSG" ]; then printf '%s\n' "$MSG" >&2; exit 2; fi

# 2. Modifiche al codice non ancora verificate con /qualita
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
ROOT="$(git rev-parse --show-toplevel)"; cd "$ROOT" || exit 0
[ -f .claude/kit-qualita-off ] && exit 0

MARK=".claude/.qualita-ok"
ESTENSIONI='\.(ts|tsx|js|jsx|mjs|vue|svelte|astro|html|css|scss|py|php|rb|go|swift|kt|sql)$'

CAMBIATI="$(git status --porcelain --untracked-files=all 2>/dev/null \
  | sed -E 's/^.{3}//; s/^.* -> //; s/^"(.*)"$/\1/' \
  | grep -E "$ESTENSIONI" | grep -vE '(^|/)(node_modules|dist|build|\.next)/')"
[ -z "$CAMBIATI" ] && exit 0

if [ -f "$MARK" ]; then
  NUOVI=""
  while IFS= read -r f; do
    [ -f "$f" ] && [ "$f" -nt "$MARK" ] && NUOVI+="$f"$'\n'
  done <<<"$CAMBIATI"
  [ -z "$NUOVI" ] && exit 0
  ELENCO="$NUOVI"
else
  ELENCO="$CAMBIATI"
fi

N="$(printf '%s\n' "$ELENCO" | grep -c .)"
cat >&2 <<EOF
Kit qualità: $N file di codice modificati non sono ancora stati verificati.
Prima di chiudere esegui la checklist di consegna (comando /qualita, file
~/.claude/commands/qualita.md), limitandoti alle aree toccate da queste modifiche.
Se la modifica è banale (un testo, un refuso) puoi saltare i controlli: dillo
esplicitamente nel riepilogo.
In entrambi i casi, alla fine esegui: mkdir -p .claude && touch $MARK
Primi file:
$(printf '%s\n' "$ELENCO" | head -n 10)
EOF
exit 2
