#!/usr/bin/env bash
# =============================================================================
#  Kit Qualità — scarica le skill esterne e le salva nel kit (cartella esterne/)
#
#  Le skill elencate in esterne/elenco.txt vengono installate con lo stesso
#  strumento usato prima dall'installer (npx skills) in una cartella temporanea
#  e copiate in esterne/skills/. Così Mac, cloud e plugin usano la stessa
#  versione, registrata in esterne/skill-lock.json e in esterne/FONTI.md.
#
#  Uso:  bash aggiorna-skill-esterne.sh
#  Poi controlla le differenze con "git diff --stat", aumenta "version" in
#  .claude-plugin/plugin.json e fai commit.
# =============================================================================
set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
ELENCO="$KIT_DIR/esterne/elenco.txt"
DEST="$KIT_DIR/esterne/skills"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v npx >/dev/null || { echo "Serve Node.js (npx)."; exit 1; }

echo "Scarico le skill esterne in una cartella temporanea..."
while read -r repo skill _; do
  case "$repo" in ''|\#*) continue ;; esac
  if [ -n "${skill:-}" ]; then
    echo "  • $repo ($skill)"
    HOME="$TMP" npx -y skills add "$repo" --skill "$skill" -g -a claude-code -y </dev/null >>"$TMP/registro.log" 2>&1
  else
    echo "  • $repo"
    HOME="$TMP" npx -y skills add "$repo" -g -a claude-code -y </dev/null >>"$TMP/registro.log" 2>&1
  fi || { echo "    ! non riuscito: dettagli sotto"; tail -n 20 "$TMP/registro.log"; exit 1; }
done <"$ELENCO"

# Sostituisce la copia precedente con quella appena scaricata.
# I collegamenti simbolici vengono risolti (cp -L): nel repository finiscono file veri.
rm -rf "$DEST"
mkdir -p "$DEST"
cp -RL "$TMP/.claude/skills/." "$DEST/"
find "$DEST" -name .git -prune -exec rm -rf {} +
find "$DEST" -name .DS_Store -delete

# Alcune raccolte includono file per chi le sviluppa (CLAUDE.md, AGENTS.md,
# .mcp.json, manifest di plugin). Non fanno parte della skill e Claude Code li
# tratterebbe come istruzioni o configurazione (es. avviando un server MCP):
# li tolgo dalle copie.
find "$DEST" \( -iname 'claude.md' -o -iname 'claude.local.md' -o -iname 'agents.md' \
  -o -name '.mcp.json' -o -name '.lsp.json' -o -name '.worktreeinclude' \
  -o -name '.gitmodules' -o -name '.gitattributes' -o -name '.lfsconfig' \) -type f -print -delete \
  | sed "s|^$DEST/|  • tolto |"
find "$DEST" \( -name '.claude-plugin' -o -name '.claude' -o -name '.mcpb-cache' \) -type d -prune -print \
  -exec rm -rf {} + | sed "s|^$DEST/|  • tolto |"
cp "$TMP/.agents/.skill-lock.json" "$KIT_DIR/esterne/skill-lock.json"

# Le licenze MIT e Apache chiedono che il testo della licenza accompagni ogni copia.
# Molte raccolte lo tengono solo alla radice del repository: se la cartella della
# skill non ne ha uno, scarico quello della raccolta alla stessa versione.
echo "Controllo le licenze..."
node -e '
  const s = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).skills;
  for (const [nome, v] of Object.entries(s)) console.log(nome, v.source, v.commit);
' "$KIT_DIR/esterne/skill-lock.json" | while read -r nome source commit; do
  cartella="$DEST/$nome"
  # Apache 2.0: anche l'eventuale file NOTICE della raccolta va conservato.
  if ! ls "$cartella" | grep -qi '^notice'; then
    for f in NOTICE NOTICE.md NOTICE.txt; do
      curl -fsSL "https://raw.githubusercontent.com/$source/$commit/$f" -o "$cartella/$f" 2>/dev/null && break
      rm -f "$cartella/$f"
    done
  fi
  ls "$cartella" | grep -qiE '^(licen[cs]e|copying)' && continue
  trovata=0
  for f in LICENSE LICENSE.md LICENSE.txt license COPYING; do
    if curl -fsSL "https://raw.githubusercontent.com/$source/$commit/$f" -o "$cartella/LICENSE" 2>/dev/null; then
      trovata=1; break
    fi
  done
  if [ $trovata -eq 0 ]; then
    rm -f "$cartella/LICENSE"
    echo "  ! $nome: licenza non trovata in $source, va verificata a mano"
  fi
done

# Elenco leggibile di fonti, versioni e licenze.
node - "$KIT_DIR/esterne" <<'JS'
const fs = require("fs"), path = require("path");
const dir = process.argv[2];
const lock = JSON.parse(fs.readFileSync(path.join(dir, "skill-lock.json"), "utf8")).skills;
const licenza = (nome) => {
  const d = path.join(dir, "skills", nome);
  const f = fs.readdirSync(d).find((x) => /^(licen[cs]e|copying)/i.test(x));
  if (!f) return "da verificare (nessun file di licenza nella skill)";
  const t = fs.readFileSync(path.join(d, f), "utf8").slice(0, 400);
  if (/MIT License/i.test(t)) return "MIT";
  if (/Apache License/i.test(t)) return "Apache 2.0";
  return `vedi ${f}`;
};
const righe = Object.entries(lock).sort(([a], [b]) => a.localeCompare(b)).map(([nome, s]) =>
  `| ${nome} | [${s.source}](${s.sourceUrl.replace(/\.git$/, "")}) | \`${(s.commit || "").slice(0, 7)}\` | ${licenza(nome)} |`);
fs.writeFileSync(path.join(dir, "FONTI.md"), `# Skill esterne incluse nel kit

Copie delle skill di altri autori, incluse così come le installa \`npx skills\`.
Restano dei rispettivi autori e sotto la loro licenza; non modificarle qui:
per aggiornarle esegui \`bash aggiorna-skill-esterne.sh\`.
Generato automaticamente: non modificare a mano.

| Skill | Fonte | Versione | Licenza |
| --- | --- | --- | --- |
${righe.join("\n")}
`);
JS

echo
echo "Fatto: $(ls "$DEST" | wc -l | tr -d ' ') skill in esterne/skills ($(du -sh "$DEST" | cut -f1))."
echo "Fonti e licenze: esterne/FONTI.md"
