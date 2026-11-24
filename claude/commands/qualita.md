---
description: Checklist di consegna del Kit Qualità — design, animazioni, test, sicurezza e SEO sulle modifiche correnti
argument-hint: "[url-anteprima opzionale] [--completo]"
---

# Checklist di consegna (Kit Qualità)

Argomenti ricevuti: $ARGUMENTS

Esegui i passi nell'ordine. Lavora solo sulle aree toccate dalle modifiche, a meno che
gli argomenti contengano `--completo`. Correggi i problemi che trovi, poi ripeti il
controllo che li aveva segnalati. Non dichiarare superato un controllo che non hai
potuto eseguire.

## 0. Perimetro

1. Elenca i file cambiati: `git status --porcelain` e `git diff --stat` (anche rispetto al branch principale se esiste).
2. Riconosci il tipo di progetto: sito/web app (package.json con Next, Astro, Vite…), app Expo/React Native (dipendenza `expo` o `react-native`), backend.
3. Leggi il CLAUDE.md/AGENTS.md del progetto e, se c'è, `DESIGN.md`.
4. URL da controllare: il primo argomento se è un URL; altrimenti il campo "URL anteprima" del CLAUDE.md del progetto; altrimenti un server locale avviato con lo script `dev` o `preview` (fermalo alla fine).

## 1. Design (se sono cambiati file di interfaccia)

- Esegui avoid-ai-design in modalità solo audit sui file UI cambiati e correggi i segnali trovati.
- Esegui `/impeccable critique` (e, per lavori grandi, `/impeccable audit`) sulle schermate toccate; applica le correzioni con priorità alta.
- Controlla la coerenza con `DESIGN.md` (colori, font, spaziature, componenti). Se manca `DESIGN.md`, segnalalo nel riepilogo.
- Se l'MCP Playwright è disponibile, apri la pagina a 390 px e a 1440 px di larghezza e guarda il risultato reale.
- Testi visibili nuovi o cambiati: passali con humanizer, mantenendo il significato.

## 2. Animazioni (se è cambiato codice con movimento)

- Esegui `review-animations` sui file con animazioni; per interventi estesi `improve-animations`.
- Verifica: durate UI sotto 300 ms, easing personalizzati, solo transform/opacity, `prefers-reduced-motion` gestito, pulizia di ScrollTrigger/listener allo smontaggio, un solo linguaggio di movimento.

## 3. Test

- Web con Playwright configurato: `npx playwright test`. Se un test fallisce per un selettore cambiato usa l'agente healer; se fallisce per un comportamento sbagliato correggi il codice.
- Nuovo percorso utente senza test: crea il piano con l'agente planner e il test con il generator.
- Expo/React Native con cartella `.maestro/`: `maestro test .maestro/` (serve un simulatore o emulatore avviato; se non c'è, dillo).
- Script `test` in package.json: `npm test`. Controllo tipi se c'è TypeScript: `npx tsc --noEmit`. Lint se configurato.

## 4. Sicurezza

- `gitleaks dir . --no-banner --redact` (segreti nei file) e, se è un repository, `gitleaks git . --no-banner --redact` (storico).
- `semgrep scan --config p/default --error --quiet .`
- `trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL .`
- Modifiche ad autenticazione, pagamenti, API, permessi o database: esegui la skill security-audit sulle parti toccate. Per Supabase verifica RLS su ogni tabella (puoi usare `npx -y @vibefoundry/vibe-shield@latest scan .`).
- Sito online o in anteprima: usa la skill vibe-check per header, CORS, cookie e file esposti. Scansioni attive (OWASP ZAP) solo se il sito è mio o autorizzato e solo se lo chiedo: `docker run --rm -t zaproxy/zap-stable zap-baseline.py -t <url>` (scansione passiva di base).

## 5. Accessibilità e obblighi di legge

- Se il progetto ha `tests/accessibilita.spec.ts`, è già incluso in `npx playwright test`: le violazioni WCAG 2.2 AA trovate da axe-core vanno corrette. Aggiungi all'elenco `pagine` del test le pagine nuove.
- Controlla a mano su ciò che hai toccato: tastiera, focus visibile, contrasto, testi alternativi, etichette ed errori dei form.
- Se sono cambiati footer, note legali, banner cookie, form, newsletter, checkout, prezzi, recensioni o chatbot: applica la skill obblighi-siti-italia alle parti toccate.
- Con `--completo` su un sito pubblico, o prima della prima pubblicazione: esegui la revisione della skill eu-web-compliance e consegnami il rapporto (non modificare testi legali senza il mio ok).
- Nel riepilogo ricorda che i controlli legali non sono consulenza legale.

## 6. SEO (solo siti pubblici, se c'è un URL)

- `seomator audit <url> --format llm` (aggiungi `--crawl -m 20` con `--completo`).
- `npx -p unlighthouse unlighthouse-ci --site <url> --budget 80` per prestazioni, accessibilità e SEO di tutte le pagine.
- Per un rilascio importante o con `--completo`: `/seo audit <url>` (claude-seo).
- Controlla le regole SEO del CLAUDE.md globale sulle pagine toccate.

## 7. Chiusura

1. Riepilogo in una tabella: Area | Esito (superato / corretto / aperto / non eseguito) | Dettagli. Aree: design, animazioni, test, sicurezza, accessibilità e obblighi, SEO.
2. Elenca cosa resta aperto e cosa non hai potuto verificare, con il motivo.
3. Segna la verifica: `mkdir -p .claude && touch .claude/.qualita-ok`
