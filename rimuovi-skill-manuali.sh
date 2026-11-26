#!/bin/bash
# Rimuove i comandi /sviluppa /audit /hardening /seo e la libreria di skill del Kit Qualità.
SKILLS="$HOME/.claude/skills"
if [ -f "$SKILLS/.skill-manuali-kit" ]; then
  while read -r n; do [ -n "$n" ] && rm -rf "$SKILLS/$n" && echo "  ✗ $n"; done < "$SKILLS/.skill-manuali-kit"
  rm -f "$SKILLS/.skill-manuali-kit"
fi
rm -rf "$HOME/.claude/skill-libreria" && echo "  ✗ libreria"
echo "✅ Rimosso."
