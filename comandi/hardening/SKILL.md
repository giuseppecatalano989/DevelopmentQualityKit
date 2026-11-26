---
name: hardening
description: Test di sicurezza e hardening di un sito o di un'app per trovare e prevenire vulnerabilità, configurazioni deboli ed esposizione dei dati, con report e correzioni su approvazione.
disable-model-invocation: true
argument-hint: "[parti da controllare] (vuoto = tutto)"
---

# /hardening — sicurezza e hardening

Ambito: **$ARGUMENTS** (vuoto = tutto il progetto).

## Libreria

Le skill specialistiche stanno in `~/.claude/skill-libreria/<nome>/SKILL.md`. Leggi con Read: `security-audit` (metodo di audit di Cloudflare) e `vibe-check` (errori tipici del codice scritto con l'IA); `gdpr-compliant` se il progetto tratta dati personali.

## Controlli

1. **Segreti**: chiavi, token e password nel codice, nella cronologia git, nei file `.env` committati e nel bundle client (variabili `NEXT_PUBLIC_`/`EXPO_PUBLIC_` con dati sensibili). Usa `gitleaks` se è installato.
2. **Dipendenze**: `npm audit` (o l'equivalente), pacchetti abbandonati o non necessari; `semgrep` e `trivy` se installati.
3. **Autenticazione e autorizzazione**: route e API senza controllo, accesso ai dati di altri utenti (IDOR), ruoli verificati solo lato client, sessioni, reset della password.
4. **Database e backend**: con Supabase, RLS attiva su ogni tabella e policy corrette, nessuna service key nel client. Query parametrizzate, validazione dell'input lato server (es. zod).
5. **Web**: XSS (`dangerouslySetInnerHTML`, `innerHTML`), CSRF, SSRF, upload di file, redirect aperti, rate limiting su login e form.
6. **Configurazione**: header HTTP (CSP, HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, frame-ancestors), CORS, cookie `Secure`/`HttpOnly`/`SameSite`, messaggi di errore che rivelano dettagli interni, source map in produzione.
7. **App mobile** (se presenti): dati sensibili in AsyncStorage invece che in SecureStore, deep link non validati, chiavi nel bundle.
8. **Dati personali**: minimizzazione, cifratura, conservazione, log che contengono dati personali.

## Regole

- Non eseguire attacchi su siti in produzione o di terzi: lavora sul codice e sul progetto in locale.
- Verifica ogni problema prima di riportarlo e indica come sfruttarlo in una riga, senza codice di exploit.
- Per ogni problema indica: gravità (🔴 critica · 🟠 alta · 🟡 media/bassa), file:riga, rischio, correzione.
- Report completo in `REPORT-HARDENING.md`. In chat mostra TUTTI i problemi e i miglioramenti trovati, nessuno escluso, ordinati per gravità, una riga ciascuno con file:riga, rischio e correzione; in testa il conteggio per gravità.
- Chiudi chiedendo: «Applico tutte le correzioni o solo le 🔴 e 🟠?». Dopo il sì, correggi, verifica di nuovo e aggiorna il report.
- Ricorda in una riga che `/security-review`, già integrato in Claude Code, controlla anche le sole modifiche del branch.
- Rispondi in italiano.
