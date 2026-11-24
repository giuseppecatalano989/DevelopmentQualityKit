#!/usr/bin/env bash
# Kit Qualità — hook PostToolUse (dopo Write/Edit/MultiEdit)
# Controlli rapidi sul solo file appena modificato:
#   1. chiavi/segreti esposti (gitleaks)
#   2. cliché di design da IA nei file di interfaccia (avoid-ai-design)
# Se trova problemi esce con codice 2: Claude legge il messaggio e corregge.
# Per disattivarlo in un progetto: crea il file .claude/kit-qualita-off

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
INPUT="$(cat)"

leggi() { # leggi campo  → stampa il valore dal JSON dell'hook
  printf '%s' "$INPUT" | node -e '
    let d=""; process.stdin.on("data",c=>d+=c).on("end",()=>{
      try { const j=JSON.parse(d); const k=process.argv[1];
        const v = k==="file" ? (j.tool_input && (j.tool_input.file_path || j.tool_input.path)) : j[k];
        process.stdout.write(v==null ? "" : String(v));
      } catch(e) {} });' "$1" 2>/dev/null
}

FILE="$(leggi file)"
CWD="$(leggi cwd)"
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0
[ -n "$CWD" ] && [ -f "$CWD/.claude/kit-qualita-off" ] && exit 0

case "$FILE" in
  */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/.next/*|*.lock|*-lock.json) exit 0 ;;
esac

PROBLEMI=""

# 1. Segreti
if command -v gitleaks >/dev/null 2>&1; then
  OUT="$(gitleaks dir "$FILE" --no-banner --redact 2>&1)"
  if printf '%s' "$OUT" | grep -qi "leaks found"; then
    PROBLEMI+=$'\n[gitleaks] Possibile chiave o segreto in '"$FILE"$'. Spostalo in una variabile d\'ambiente (.env non versionato) e non riportarne il valore.\n'"$(printf '%s' "$OUT" | grep -v '^\s*$' | tail -n 15)"$'\n'
  fi
fi

# 2. Cliché di design da IA (solo file di interfaccia)
case "$FILE" in
  *.tsx|*.jsx|*.vue|*.svelte|*.astro|*.html|*.css|*.scss)
    DETECT=""
    KIT="$(cd "$(dirname "$0")/../.." && pwd -P)"
    for p in "$HOME/.claude/skills/avoid-ai-design/scripts/detect.mjs" \
             "$HOME/.agents/skills/avoid-ai-design/scripts/detect.mjs" \
             "$KIT/esterne/skills/avoid-ai-design/scripts/detect.mjs"; do
      [ -f "$p" ] && DETECT="$p" && break
    done
    if [ -n "$DETECT" ]; then
      OUT="$(printf '%s' "$INPUT" | node "$DETECT" --hook 2>&1)"; RC=$?
      if [ $RC -eq 2 ] && [ -n "$OUT" ]; then
        PROBLEMI+=$'\n[avoid-ai-design] '"$OUT"$'\n'
      fi
    fi
    ;;
esac

if [ -n "$PROBLEMI" ]; then
  printf 'Kit qualità — problemi nel file appena modificato:%s\nCorreggili prima di proseguire.\n' "$PROBLEMI" >&2
  exit 2
fi
exit 0
