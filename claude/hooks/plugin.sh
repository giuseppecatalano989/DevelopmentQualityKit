#!/usr/bin/env bash
# Kit Qualità — punto di ingresso degli hook quando il kit è usato come plugin.
# Se sul computer il kit è già installato con installa.sh (cartella
# ~/.claude/hooks/kit-qualita), non fa nulla: così gli hook non girano due volte.
# Uso: plugin.sh <regole|instrada|modifica|consegna>

[ -e "$HOME/.claude/hooks/kit-qualita" ] && { cat >/dev/null; exit 0; }

QUI="$(cd "$(dirname "$0")" && pwd)"
case "${1:-}" in
  regole)   cat >/dev/null; exec node "$QUI/regole-sessione.mjs" "$(cd "$QUI/../.." && pwd)" ;;
  instrada) exec bash "$QUI/instrada-richiesta.sh" ;;
  modifica) exec bash "$QUI/controllo-modifica.sh" ;;
  consegna) exec bash "$QUI/controllo-consegna.sh" ;;
  *)        cat >/dev/null; exit 0 ;;
esac
