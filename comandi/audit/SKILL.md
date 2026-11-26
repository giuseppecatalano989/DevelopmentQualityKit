---
name: audit
description: Audit completo di quanto sviluppato (codice, funzionalità, UX/UI, grafica, testi, pulsanti, animazioni, prestazioni, accessibilità, obblighi di legge) con report per gravità e correzioni su approvazione.
disable-model-invocation: true
argument-hint: "[aree o pagine da controllare] (vuoto = tutto)"
---

# /audit — controllo qualità completo

Ambito richiesto: **$ARGUMENTS** (vuoto = tutto il progetto; se indica aree o pagine, controlla solo quelle).

## Libreria

Le skill specialistiche stanno in `~/.claude/skill-libreria/<nome>/SKILL.md`. Leggi con il tool Read solo quelle delle aree in esame; i file in `references/` e `scripts/` sono relativi alla cartella della skill.

## Aree (in quest'ordine)

1. **Codice**: esegui lint, type-check, build e test esistenti. Poi cerca errori di logica, casi limite, gestione degli errori, codice morto o duplicato, dipendenze inutili.
2. **Funzionalità (test reali)**: skill `webapp-testing`. Avvia il progetto in locale, percorri i flussi principali (navigazione, form, login, checkout, pulsanti), raccogli gli errori in console e di rete, fai screenshot da mobile e da desktop. Poi `break-ui` per testi lunghi, dati vuoti, schermi stretti e input strani.
3. **UX/UI, grafica e pulsanti**: skill `web-design-guidelines` (regole di Vercel; recupera l'elenco aggiornato come indicato nella skill) e `impeccable` in modalità critica. Usa `avoid-ai-design` per segnalare ciò che appare generico.
4. **Testi**: skill `humanizer`. Testi artificiali, incoerenti, con refusi, CTA poco chiare.
5. **Animazioni**: skill `review-animations` e `animation-performance`. Durate, easing, coerenza, `prefers-reduced-motion`, animazioni che bloccano o che rallentano.
6. **Prestazioni**: per React e Next.js `vercel-react-best-practices`, per Expo `vercel-react-native-skills`. Bundle, immagini, font, re-render, Core Web Vitals.
7. **Accessibilità e obblighi di legge**: `eu-web-compliance` (accessibilità EAA/WCAG), `obblighi-siti-italia`, `gdpr-compliant`. Cookie banner, privacy policy, P.IVA, condizioni di vendita e recesso per gli e-commerce.

Sicurezza e SEO non rientrano qui: hanno i comandi `/hardening` e `/seo`.

## Regole

- Durante l'audit non modificare nulla.
- Verifica ogni problema nel codice prima di riportarlo: niente falsi positivi.
- Per ogni problema indica: gravità (🔴 bloccante · 🟠 importante · 🟡 miglioria), area, file:riga, cosa non va, come correggerlo.
- Scrivi il report completo in `REPORT-AUDIT.md` nella radice del progetto.
- In chat mostra TUTTI i problemi e i miglioramenti trovati, nessuno escluso: raggruppali per area, ordinati per gravità (prima 🔴, poi 🟠, poi 🟡), una riga ciascuno con file:riga e correzione. In testa metti il conteggio per gravità.
- Chiudi chiedendo: «Correggo tutto o solo i 🔴 e i 🟠?». Dopo il sì, correggi, verifica di nuovo con build e test e aggiorna il report.
- Rispondi in italiano.
