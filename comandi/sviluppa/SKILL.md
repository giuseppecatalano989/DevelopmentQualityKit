---
name: sviluppa
description: Sviluppa o modifica un sito o un'app con qualità da professionista (codice, UX/UI, grafica, testi, pulsanti, animazioni) usando le skill della libreria del Kit Qualità.
disable-model-invocation: true
argument-hint: "<cosa vuoi sviluppare o migliorare>"
---

# /sviluppa — sviluppo di qualità professionale

Richiesta dell'utente: **$ARGUMENTS**
(Se è vuota, chiedi in una riga cosa sviluppare o migliorare.)

## Libreria

Le skill specialistiche stanno in `~/.claude/skill-libreria/<nome>/SKILL.md`. Non sono caricate in automatico: leggi tu, con il tool Read, solo quelle che servono a questa richiesta (di solito 2-4). Se una skill rimanda a file in `references/` o `scripts/`, i percorsi sono relativi alla sua cartella; leggili solo quando servono davvero.

## 1. Capisci il contesto (breve)

Guarda il progetto (package.json, framework, librerie UI e animazioni già in uso, stile esistente). Rispetta le scelte già fatte, a meno che l'utente chieda un rifacimento.

## 2. Scegli le skill in base a cosa tocca la richiesta

| Se la richiesta riguarda… | Leggi |
|---|---|
| Interfaccia, layout, pagine, componenti, colori, tipografia | `impeccable`, `design-taste-frontend` |
| Evitare l'aspetto generico "fatto dall'IA" (sempre, se c'è UI nuova) | `avoid-ai-design` |
| Dettagli di rifinitura, micro-interazioni, pulsanti, stati | `emil-design-eng` |
| Scelta di una libreria UI | `pick-ui-library` |
| App iOS/Android o Expo | `apple-design`, `mobile-native`, `vercel-react-native-skills` |
| Testi, titoli, microcopy, etichette dei pulsanti | `humanizer` |
| Animazioni, transizioni, scroll | `animate`, `choreograph`; con GSAP `gsap-core` e `gsap-scrolltrigger` (o `gsap-react`); in Expo `animate-expo`; gesti `gestures` |
| Codice React / Next.js | `vercel-react-best-practices`, `vercel-composition-patterns` |
| Form con dati personali, cookie, e-commerce, footer | `obblighi-siti-italia`, `gdpr-compliant` |

## 3. Sviluppa

Applica le regole delle skill lette mentre scrivi il codice: niente template generici, gerarchia visiva chiara, stati di caricamento, vuoti ed errore, accessibilità di base (contrasto, focus, aree di tocco, `prefers-reduced-motion`), codice tipizzato e pulito.

## 4. Verifica prima di consegnare

Esegui lint, type-check e build (o i test) se il progetto li ha. Se puoi avviarlo, controlla la pagina in mobile e desktop. Correggi quello che trovi.

## 5. Chiudi

In 3-5 righe: cosa hai fatto, quali skill hai usato, eventuali punti aperti. Suggerisci `/audit` solo se la modifica è ampia. Rispondi in italiano.
