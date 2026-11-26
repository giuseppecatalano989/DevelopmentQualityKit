---
name: seo
description: Audit e ottimizzazione SEO di un sito (tecnica, on-page, contenuti, dati strutturati, prestazioni, SEO locale e visibilità nei motori di ricerca e nelle risposte delle IA), con correzioni su approvazione.
disable-model-invocation: true
argument-hint: "[pagine, parole chiave o obiettivo] (vuoto = tutto il sito)"
---

# /seo — posizionamento e ottimizzazione

Ambito o obiettivo: **$ARGUMENTS** (vuoto = tutto il sito).

## Libreria

Leggi con Read `~/.claude/skill-libreria/seo-audit/SKILL.md` e segui il suo metodo. Se il progetto è React/Next.js, per le prestazioni consulta anche `vercel-react-best-practices`.

## Controlli

1. **Tecnica**: indicizzabilità (robots.txt, meta robots, noindex accidentali), sitemap.xml, URL canonici, redirect, 404, rendering lato server dei contenuti importanti, hreflang per i siti multilingua, HTTPS.
2. **On-page**: title (unico, max ~60 caratteri) e meta description per ogni pagina, un solo H1, gerarchia dei titoli, URL leggibili, link interni, testo alternativo delle immagini.
3. **Dati strutturati**: JSON-LD adatto al tipo di sito (Organization/LocalBusiness, Product e Offer per gli e-commerce, Article, FAQ, BreadcrumbList); verifica che sia valido.
4. **Condivisione**: Open Graph e Twitter Card con immagini delle dimensioni corrette, favicon e manifest.
5. **Prestazioni**: Core Web Vitals (LCP, CLS, INP), immagini in formati moderni e con dimensioni esplicite, font, JavaScript bloccante.
6. **Contenuti**: pertinenza rispetto alle parole chiave dell'obiettivo, contenuti sottili o duplicati, struttura leggibile.
7. **SEO locale** (attività con sede): NAP coerente, LocalBusiness, pagina contatti e mappa, suggerimenti per il Profilo dell'attività su Google.
8. **Visibilità nelle IA** (risposte di Google AI e chatbot): contenuti chiari e citabili, FAQ, `llms.txt` se utile.

## Regole

- Prima il report, poi le modifiche: per ogni problema indica priorità (🔴 · 🟠 · 🟡), pagina o file, cosa non va, correzione.
- Report completo in `REPORT-SEO.md`. In chat mostra TUTTI i problemi e i miglioramenti trovati, nessuno escluso, raggruppati per area e ordinati per priorità, una riga ciascuno con pagina o file e correzione; in testa il conteggio per priorità.
- Chiudi chiedendo: «Applico tutte le correzioni o solo le 🔴 e 🟠?». Dopo il sì, applicale e verifica con la build.
- Ricorda che i risultati di posizionamento dipendono anche da fattori esterni (link, concorrenza, tempo): non promettere posizioni.
- Rispondi in italiano.
