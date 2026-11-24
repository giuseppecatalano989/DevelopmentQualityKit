#!/usr/bin/env bash
# =============================================================================
#  Kit Qualità Sviluppo — installazione per macOS
#  Installa skill, plugin, MCP e tool per: design non da IA, animazioni,
#  test, sicurezza e SEO; poi attiva il flusso automatico in Claude Code.
#
#  Uso:   bash installa.sh            (installa tutto)
#         bash installa.sh --solo-regole   (aggiorna solo regole e hook)
#
#  Lo script è ripetibile: rilanciarlo aggiorna senza duplicare nulla.
#  Ogni file di configurazione esistente viene salvato in un backup prima
#  di essere modificato.
# =============================================================================
set -u

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$KIT_DIR/installazione.log"
STAMP="$(date +%Y%m%d-%H%M%S)"
CLAUDE_HOME="$HOME/.claude"
CODEX_HOME="$HOME/.codex"
SOLO_REGOLE=0
[ "${1:-}" = "--solo-regole" ] && SOLO_REGOLE=1

OK=()
FALLITI=()
DA_FARE=()

titolo() { printf '\n\033[1;34m== %s ==\033[0m\n' "$1"; }
esegui() {
  # esegui "descrizione" comando argomenti...
  local desc="$1"; shift
  printf '  • %s ... ' "$desc"
  { echo; echo "### $(date '+%H:%M:%S') $desc"; echo "\$ $*"; } >>"$LOG"
  if "$@" >>"$LOG" 2>&1; then
    printf '\033[32mok\033[0m\n'; OK+=("$desc")
  else
    printf '\033[31mfallito\033[0m (dettagli in installazione.log)\n'; FALLITI+=("$desc")
  fi
}
ha() { command -v "$1" >/dev/null 2>&1; }

echo "Kit Qualità Sviluppo — installazione del $STAMP" >"$LOG"

# -----------------------------------------------------------------------------
titolo "1. Controllo dei prerequisiti"
# -----------------------------------------------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
  echo "Questo script è pensato per macOS."; exit 1
fi

# Homebrew appena installato non è ancora nel PATH di questo Terminale:
# lo attiviamo qui e lo rendiamo permanente in ~/.zprofile (passo standard
# indicato dall'installer di Homebrew).
for BREW in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if ! ha brew && [ -x "$BREW" ]; then
    eval "$("$BREW" shellenv)"
    if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
      printf '\neval "$(%s shellenv)"\n' "$BREW" >>"$HOME/.zprofile"
      echo "  • Homebrew aggiunto a ~/.zprofile"
    fi
  fi
done

if ! ha brew; then
  cat <<'EOF'
  Homebrew non è installato. Installalo prima con il comando ufficiale
  (ti chiederà la password del Mac):

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  Poi chiudi e riapri il Terminale e rilancia: bash installa.sh
EOF
  exit 1
fi
echo "  • Homebrew presente"

if ! ha git; then
  echo "  git non trovato: macOS ti proporrà di installare gli Strumenti da riga di comando."
  xcode-select --install 2>/dev/null
  echo "  Al termine rilancia lo script."; exit 1
fi
echo "  • git presente"

if ! ha node; then
  esegui "Node.js (necessario per npx e per le skill)" brew install node
fi
if ha node; then
  NODE_MAJ="$(node -p 'process.versions.node.split(".")[0]')"
  NODE_MIN="$(node -p 'process.versions.node.split(".")[1]')"
  if [ "$NODE_MAJ" -lt 20 ] || { [ "$NODE_MAJ" -eq 20 ] && [ "$NODE_MIN" -lt 18 ]; }; then
    echo "  Node $(node -v) è troppo vecchio (serve 20.18 o successivo)."
    esegui "Aggiornamento di Node.js" brew upgrade node
  fi
  echo "  • Node $(node -v)"
else
  echo "  Node.js non disponibile: impossibile continuare."; exit 1
fi

export PATH="$HOME/.local/bin:$PATH"
if ! ha claude && [ $SOLO_REGOLE -eq 0 ]; then
  # Installer ufficiale (native install) da https://code.claude.com/docs
  esegui "Claude Code (riga di comando)" bash -c "curl -fsSL https://claude.ai/install.sh | bash"
  hash -r
fi
# rende "claude" disponibile anche nei Terminali aperti in seguito
if [ -x "$HOME/.local/bin/claude" ] && ! grep -qs '.local/bin' "$HOME/.zshrc"; then
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$HOME/.zshrc"
  echo "  • ~/.local/bin aggiunto a ~/.zshrc"
fi
HA_CLAUDE=0; ha claude && HA_CLAUDE=1
HA_CODEX=0;  { ha codex || [ -d "$CODEX_HOME" ]; } && HA_CODEX=1
if [ $HA_CLAUDE -eq 1 ]; then echo "  • Claude Code presente"; else
  echo "  ! Claude Code non trovato: salto plugin e MCP (le skill vengono comunque installate)."
  DA_FARE+=("Installa Claude Code e rilancia lo script per aggiungere plugin SEO e MCP di Playwright")
fi
[ $HA_CODEX -eq 1 ] && echo "  • Codex presente: le skill verranno installate anche lì"

mkdir -p "$CLAUDE_HOME"

# -----------------------------------------------------------------------------
if [ $SOLO_REGOLE -eq 0 ]; then
# -----------------------------------------------------------------------------
titolo "2. Skill per Claude Code (e Codex)"

AGENTI=(claude-code)
[ $HA_CODEX -eq 1 ] && AGENTI+=(codex)

installa_skill() {
  # installa_skill "nome leggibile" repo [nome-skill]
  local nome="$1" repo="$2" skill="${3:-}"
  local agente
  for agente in "${AGENTI[@]}"; do
    if [ -n "$skill" ]; then
      esegui "$nome → $agente" npx -y skills add "$repo" --skill "$skill" -g -a "$agente" -y
    else
      esegui "$nome → $agente" npx -y skills add "$repo" -g -a "$agente" -y
    fi
  done
}

echo " Design e testi"
installa_skill "impeccable (design principale)"      https://github.com/pbakaus/impeccable impeccable
installa_skill "taste-skill (direzioni alternative)" https://github.com/Leonxlnx/taste-skill design-taste-frontend
installa_skill "hallmark (temi su richiesta)"        https://github.com/Nutlope/hallmark
installa_skill "avoid-ai-design (controllo cliché)"  https://github.com/funboy322/avoid-ai-design
installa_skill "humanizer (testi naturali)"          https://github.com/blader/humanizer
echo " Animazioni"
installa_skill "GSAP skills ufficiali"               https://github.com/greensock/gsap-skills
installa_skill "Emil Kowalski skills"                https://github.com/emilkowalski/skills
echo " Sicurezza"
installa_skill "Cloudflare security-audit"          https://github.com/cloudflare/security-audit-skill security-audit
installa_skill "vibe-check"                         https://github.com/benavlabs/vibe-check
echo " SEO"
installa_skill "SEOmator seo-audit"                 https://github.com/seo-skills/seo-audit-skill
echo " Privacy, obblighi di legge e accessibilità"
installa_skill "GDPR per sviluppatori (GitHub)"     https://github.com/github/awesome-copilot gdpr-compliant
installa_skill "Conformità web UE (GDPR, cookie, EAA, AI Act)" https://github.com/gricyk/claude-skill-eu-web-compliance

# -----------------------------------------------------------------------------
titolo "3. Strumenti da riga di comando"
# -----------------------------------------------------------------------------
brew_installa() { # brew_installa formula
  if brew list --formula "$1" >/dev/null 2>&1; then
    esegui "$1 (aggiornamento)" brew upgrade "$1"
  else
    esegui "$1" brew install "$1"
  fi
}
brew_installa gitleaks
brew_installa semgrep
brew_installa trivy

# OWASP ZAP: il pacchetto Homebrew è stato disattivato (Gatekeeper, settembre 2026);
# si usa l'immagine Docker ufficiale, scaricata solo se Docker è disponibile.
if ha docker && docker info >/dev/null 2>&1; then
  esegui "OWASP ZAP (immagine Docker zaproxy/zap-stable)" docker pull zaproxy/zap-stable
else
  DA_FARE+=("OWASP ZAP: avvia Docker Desktop e rilancia lo script (usa l'immagine zaproxy/zap-stable)")
fi

# Maestro richiede Java 17 o successivo
if ! /usr/libexec/java_home -v 17+ >/dev/null 2>&1; then
  brew_installa openjdk@17
  DA_FARE+=("Se Maestro segnala che Java manca: sudo ln -sfn \"\$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk\" /Library/Java/JavaVirtualMachines/openjdk-17.jdk")
fi
esegui "tap di Maestro" brew tap mobile-dev-inc/tap
if brew list --formula maestro >/dev/null 2>&1; then
  esegui "Maestro (aggiornamento)" brew upgrade mobile-dev-inc/tap/maestro
else
  esegui "Maestro (test app Expo/React Native)" brew install mobile-dev-inc/tap/maestro
fi

esegui "SEOmator CLI" npm install -g @seomator/seo-audit
esegui "Unlighthouse CLI" npm install -g unlighthouse

# -----------------------------------------------------------------------------
titolo "4. Plugin e MCP"
# -----------------------------------------------------------------------------
if [ $HA_CLAUDE -eq 1 ]; then
  if claude mcp get playwright >/dev/null 2>&1; then
    echo "  • MCP Playwright già configurato"
  else
    esegui "MCP Playwright (Claude Code, tutti i progetti)" claude mcp add playwright -s user -- npx -y @playwright/mcp@latest
  fi
  esegui "Marketplace claude-seo"   claude plugin marketplace add AgriciDaniel/claude-seo
  esegui "Plugin claude-seo"        claude plugin install claude-seo@agricidaniel-claude-seo
  DA_FARE+=("Apri Claude Code e scrivi /seo setup una volta (prepara l'ambiente Python di claude-seo)")
fi
if [ $HA_CODEX -eq 1 ] && ha codex; then
  esegui "MCP Playwright (Codex)" codex mcp add playwright -- npx -y @playwright/mcp@latest
fi

# -----------------------------------------------------------------------------
titolo "5. Raccolte di riferimento"
# -----------------------------------------------------------------------------
mkdir -p "$KIT_DIR/riferimenti"
clona_o_aggiorna() { # clona_o_aggiorna repo cartella
  if [ -d "$2/.git" ]; then esegui "aggiorno $(basename "$2")" git -C "$2" pull --ff-only
  else esegui "scarico $(basename "$2")" git clone --depth 1 "$1" "$2"; fi
}
clona_o_aggiorna https://github.com/VoltAgent/awesome-design-md "$KIT_DIR/riferimenti/awesome-design-md"

fi # fine SOLO_REGOLE

# -----------------------------------------------------------------------------
titolo "6. Regole automatiche, hook e comando /qualita"
# -----------------------------------------------------------------------------
backup() { [ -f "$1" ] && cp "$1" "$1.bak-$STAMP" && echo "  • backup: $1.bak-$STAMP"; return 0; }

# Inserisce (o sostituisce) il blocco del kit in un file di regole, senza
# toccare il resto del file.
inserisci_blocco() { # inserisci_blocco file-destinazione file-blocco
  local dest="$1" blocco="$2"
  mkdir -p "$(dirname "$dest")"; touch "$dest"; backup "$dest"
  awk '/^<!-- >>> kit-qualita >>> -->$/{salta=1}
       !salta{buf[++n]=$0}
       /^<!-- <<< kit-qualita <<< -->$/{salta=0}
       END{while(n>0 && buf[n] ~ /^[[:space:]]*$/) n--; for(i=1;i<=n;i++) print buf[i]}' "$dest" >"$dest.tmp"
  { cat "$dest.tmp"; [ -s "$dest.tmp" ] && echo; sed "s|{{KIT_DIR}}|$KIT_DIR|g" "$blocco"; } >"$dest"
  rm -f "$dest.tmp"
}

esegui "Regole globali in ~/.claude/CLAUDE.md" inserisci_blocco "$CLAUDE_HOME/CLAUDE.md" "$KIT_DIR/claude/CLAUDE.md"
if [ $HA_CODEX -eq 1 ]; then
  esegui "Regole globali in ~/.codex/AGENTS.md" inserisci_blocco "$CODEX_HOME/AGENTS.md" "$KIT_DIR/claude/CLAUDE.md"
fi

# Skill scritte per il kit (es. obblighi-siti-italia): Claude Code legge ~/.claude/skills,
# Codex legge ~/.agents/skills
copia_skill_kit() {
  local dest
  for dest in "$@"; do
    mkdir -p "$dest" && cp -R "$KIT_DIR/skills/"* "$dest/" || return 1
  done
}
DEST_SKILL=("$CLAUDE_HOME/skills")
[ $HA_CODEX -eq 1 ] && DEST_SKILL+=("$HOME/.agents/skills")
esegui "Skill del kit (obblighi siti Italia)" copia_skill_kit "${DEST_SKILL[@]}"

mkdir -p "$CLAUDE_HOME/hooks/kit-qualita" "$CLAUDE_HOME/commands"
esegui "Hook di controllo" cp "$KIT_DIR/claude/hooks/"*.sh "$KIT_DIR/claude/hooks/"*.mjs "$CLAUDE_HOME/hooks/kit-qualita/"
chmod +x "$CLAUDE_HOME/hooks/kit-qualita/"*.sh 2>/dev/null
backup "$CLAUDE_HOME/commands/qualita.md" >/dev/null
esegui "Comando /qualita" cp "$KIT_DIR/claude/commands/qualita.md" "$CLAUDE_HOME/commands/qualita.md"

backup "$CLAUDE_HOME/settings.json"
esegui "Attivazione hook in ~/.claude/settings.json" node "$KIT_DIR/claude/attiva-hook.mjs" "$CLAUDE_HOME/settings.json" "$CLAUDE_HOME/hooks/kit-qualita"

# -----------------------------------------------------------------------------
titolo "Riepilogo"
# -----------------------------------------------------------------------------
echo "  Riusciti: ${#OK[@]}"
if [ ${#FALLITI[@]} -gt 0 ]; then
  echo "  Falliti: ${#FALLITI[@]}"
  for f in "${FALLITI[@]}"; do echo "    - $f"; done
  echo "  I dettagli sono in: $LOG"
fi
if [ ${#DA_FARE[@]} -gt 0 ]; then
  echo "  Da fare a mano:"
  for d in "${DA_FARE[@]}"; do echo "    - $d"; done
fi
echo
echo "  Riavvia Claude Code (o apri una nuova sessione) per caricare skill e hook."
echo "  Per applicare il kit a un progetto:  bash \"$KIT_DIR/applica-kit.sh\" /percorso/del/progetto"
[ ${#FALLITI[@]} -eq 0 ]
