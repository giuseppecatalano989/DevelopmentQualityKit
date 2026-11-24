#!/usr/bin/env bash
# =============================================================================
#  Kit Qualità Sviluppo — applica il kit a un progetto
#  Uso:  bash applica-kit.sh /percorso/del/progetto
#
#  - copia CLAUDE.md di progetto e il workflow GitHub "Qualità" (senza
#    sovrascrivere file esistenti)
#  - aggiorna .gitignore
#  - sito/web app: installa Playwright e i suoi agenti (planner, generator, healer)
#  - app Expo/React Native: crea la cartella .maestro con un primo flusso
# =============================================================================
set -u
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
TPL="$KIT_DIR/template-progetto"

PROGETTO="${1:-}"
if [ -z "$PROGETTO" ] || [ ! -d "$PROGETTO" ]; then
  echo "Uso: bash applica-kit.sh /percorso/del/progetto"; exit 1
fi
PROGETTO="$(cd "$PROGETTO" && pwd)"
NOME="$(basename "$PROGETTO")"
cd "$PROGETTO" || exit 1
echo "Applico il Kit Qualità a: $PROGETTO"

copia() { # copia sorgente destinazione
  if [ -e "$2" ]; then echo "  • $2 esiste già: lo lascio com'è"
  else mkdir -p "$(dirname "$2")" && cp "$1" "$2" && echo "  • creato $2"; fi
}

copia "$TPL/github-workflows/qualita.yml" ".github/workflows/qualita.yml"
if [ -e CLAUDE.md ]; then
  echo "  • CLAUDE.md esiste già: lo lascio com'è (il modello è in $TPL/CLAUDE.md)"
else
  sed "s|{{NOME_PROGETTO}}|$NOME|g" "$TPL/CLAUDE.md" > CLAUDE.md && echo "  • creato CLAUDE.md (compila i campi)"
fi

touch .gitignore
for riga in ".claude/.qualita-ok" ".env" ".env.*" "!.env.example" ".unlighthouse/" "playwright-report/" "test-results/"; do
  grep -qxF "$riga" .gitignore || echo "$riga" >> .gitignore
done
echo "  • .gitignore aggiornato"

[ -f DESIGN.md ] || echo "  ! Manca DESIGN.md: chiedi a Claude \"/impeccable init\" o partite da un file in $KIT_DIR/riferimenti/awesome-design-md/design-md/"

if [ ! -f package.json ]; then
  echo "  • Nessun package.json: salto la configurazione dei test JavaScript."
  exit 0
fi

if grep -qE '"(expo|react-native)"' package.json; then
  echo "  • Progetto Expo/React Native: preparo Maestro"
  mkdir -p .maestro
  if [ ! -f .maestro/avvio.yaml ]; then
    APPID="$(node -e 'try{const a=require("./app.json").expo||{};console.log((a.ios&&a.ios.bundleIdentifier)||(a.android&&a.android.package)||"")}catch(e){console.log("")}')"
    cat > .maestro/avvio.yaml <<EOF
# Primo flusso Maestro: l'app si apre e mostra la schermata iniziale.
# Avvio: maestro test .maestro/
appId: ${APPID:-com.esempio.app}   # controlla che corrisponda a app.json
---
- launchApp
- assertVisible:
    id: "schermata-iniziale"       # aggiungi testID="schermata-iniziale" alla prima schermata
EOF
    echo "  • creato .maestro/avvio.yaml"
  fi
else
  echo "  • Sito/web app: installo Playwright e i suoi agenti"
  if ! grep -q '"@playwright/test"' package.json; then
    npm install -D @playwright/test || echo "  ! installazione di @playwright/test non riuscita"
  fi
  if [ ! -f playwright.config.ts ] && [ ! -f playwright.config.js ] && [ ! -f playwright.config.mjs ]; then
    cat > playwright.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';

// URL da testare: BASE_URL se impostato, altrimenti il server locale.
const baseURL = process.env.BASE_URL ?? 'http://localhost:3000';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  reporter: [['html', { open: 'never' }]],
  use: { baseURL, trace: 'on-first-retry' },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 15'] } },
  ],
  // Avvia il sito in locale se non è indicato un BASE_URL (adatta il comando e la porta).
  webServer: process.env.BASE_URL ? undefined : {
    command: 'npm run dev',
    url: baseURL,
    reuseExistingServer: !process.env.CI,
  },
});
EOF
    echo "  • creato playwright.config.ts (controlla comando e porta del server)"
  fi
  # Test di accessibilità WCAG 2.2 AA con axe-core (Deque)
  if ! grep -q '"@axe-core/playwright"' package.json; then
    npm install -D @axe-core/playwright || echo "  ! installazione di @axe-core/playwright non riuscita"
  fi
  if [ ! -f tests/accessibilita.spec.ts ]; then
    mkdir -p tests
    cat > tests/accessibilita.spec.ts <<'EOF'
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

// Pagine da controllare: aggiungi qui le pagine principali del sito.
const pagine = ['/'];

for (const pagina of pagine) {
  test(`accessibilità WCAG 2.2 AA: ${pagina}`, async ({ page }) => {
    await page.goto(pagina);
    const risultati = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze();
    const riepilogo = risultati.violations.map((v) => ({
      regola: v.id,
      impatto: v.impact,
      elementi: v.nodes.length,
      aiuto: v.helpUrl,
    }));
    expect(riepilogo, 'Violazioni di accessibilità trovate da axe-core').toEqual([]);
  });
}
EOF
    echo "  • creato tests/accessibilita.spec.ts (aggiungi le pagine principali)"
  fi
  npx playwright install chromium webkit || echo "  ! download dei browser non riuscito"
  npx playwright init-agents --loop=claude || echo "  ! init-agents non riuscito: aggiorna @playwright/test (serve 1.56 o successivo)"
fi

echo
echo "Fatto. Apri il progetto in Claude Code: le regole del kit sono già attive."
