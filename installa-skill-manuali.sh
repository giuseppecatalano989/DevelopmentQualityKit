#!/bin/bash
# Installa i 4 comandi del Kit Qualità: /sviluppa /audit /hardening /seo
# - Le skill specialistiche vanno in ~/.claude/skill-libreria (NON caricate da Claude Code:
#   zero token e niente voci nel menu /). I comandi le leggono solo quando servono.
# - I 4 comandi sono solo manuali (disable-model-invocation: true).
# Ogni esecuzione riscarica da GitHub le versioni più recenti di tutte le skill.
# Uso: bash installa-skill-manuali.sh   (rieseguilo quando vuoi aggiornare)
# Nel cloud (Linux) l'aggiornamento viene saltato in automatico, per un avvio più veloce.
set -e

KIT="$(cd "$(dirname "$0")" && pwd)"
SKILLS="$HOME/.claude/skills"
LIB="$HOME/.claude/skill-libreria"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$SKILLS"

# 1) Pulizia di installazioni precedenti fatte da questo script
if [ -f "$SKILLS/.skill-manuali-kit" ]; then
  while read -r n; do [ -n "$n" ] && rm -rf "$SKILLS/$n"; done < "$SKILLS/.skill-manuali-kit"
  rm -f "$SKILLS/.skill-manuali-kit"
fi
if [ "${SALTA_AGGIORNAMENTO:-0}" = "1" ] || [ "$(uname)" != "Darwin" ]; then
  echo "▶ Aggiornamento saltato (cloud): uso le skill salvate nel kit"
elif echo "▶ Aggiorno da GitHub le skill del kit (può richiedere un paio di minuti)"; bash "$KIT/aggiorna-skill-esterne.sh" > "$TMP/aggiorna.log" 2>&1; then
  echo "  ✓ skill del kit aggiornate all'ultima versione"
else
  echo "  ⚠️  aggiornamento non riuscito (rete o Node.js?): uso le copie già salvate nel kit"
  tail -n 5 "$TMP/aggiorna.log" | sed 's/^/     /'
fi

rm -rf "$LIB"
mkdir -p "$LIB"

aggiungi() {   # aggiungi <cartella sorgente> <nome>
  if [ -f "$1/SKILL.md" ]; then cp -R "$1" "$LIB/$2"; echo "  ✓ $2"
  else echo "  ⚠️  $2: non trovata, salto"; fi
}

echo "▶ Libreria: skill del kit"
for d in "$KIT"/esterne/skills/* "$KIT"/skills/*; do
  [ -d "$d" ] && aggiungi "$d" "$(basename "$d")"
done

echo "▶ Libreria: skill da GitHub"
if git clone -q --depth 1 https://github.com/anthropics/skills "$TMP/anthropic" 2>/dev/null; then
  aggiungi "$TMP/anthropic/skills/webapp-testing" webapp-testing
else echo "  ⚠️  github.com/anthropics/skills non raggiungibile"; fi
if git clone -q --depth 1 https://github.com/vercel-labs/agent-skills "$TMP/vercel" 2>/dev/null; then
  aggiungi "$TMP/vercel/skills/web-design-guidelines" web-design-guidelines
  aggiungi "$TMP/vercel/skills/react-best-practices"  vercel-react-best-practices
  aggiungi "$TMP/vercel/skills/react-native-skills"   vercel-react-native-skills
  aggiungi "$TMP/vercel/skills/composition-patterns"  vercel-composition-patterns
else echo "  ⚠️  github.com/vercel-labs/agent-skills non raggiungibile"; fi

echo "▶ Comandi"
: > "$SKILLS/.skill-manuali-kit"
for c in sviluppa audit hardening seo; do
  rm -rf "$SKILLS/$c"
  cp -R "$KIT/comandi/$c" "$SKILLS/$c"
  echo "$c" >> "$SKILLS/.skill-manuali-kit"
  echo "  ✓ /$c"
done

echo ""
echo "✅ Fatto: 4 comandi (/sviluppa /audit /hardening /seo) e $(ls "$LIB" | wc -l | tr -d ' ') skill in libreria."
echo "   Se una sessione di Claude Code era già aperta, scrivi /reload-plugins."
echo "   Per rimuovere tutto: bash \"$KIT/rimuovi-skill-manuali.sh\""
