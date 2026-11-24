<!-- >>> kit-qualita >>> -->
# Kit Qualità Sviluppo — regole globali

Queste regole valgono per ogni progetto di siti web e software. Le regole di un
progetto (il suo CLAUDE.md o AGENTS.md) hanno la precedenza in caso di conflitto.
Rispondi e scrivi i testi dell'interfaccia in italiano naturale, salvo diversa
indicazione del progetto.

## Prima volta su un progetto

Quando lavori su un progetto con codice che non ha ancora il file `.github/workflows/qualita.yml`,
proponimi una sola volta di applicare il kit: aggiunge il CLAUDE.md di progetto, i controlli
automatici su GitHub, il `.gitignore` e i test (Playwright per i siti, Maestro per le app Expo).
Chiedimelo prima, perché installa pacchetti e aggiunge file al progetto. Se dico sì, esegui
`bash "{{KIT_DIR}}/applica-kit.sh" "<cartella del progetto>"` e riassumimi cosa ha creato.
Se dico no, non riproporlo nella stessa sessione.

## Avvio automatico di un lavoro con interfaccia

Quando ti chiedo un sito, una pagina, un'app, una schermata o un restyling, segui questa
procedura da solo, senza aspettare che io nomini una skill:

1. **DESIGN.md presente** nella radice del progetto → seguilo e vai al punto 7.
2. **Progetto già sviluppato senza DESIGN.md** (c'è già un'interfaccia) → non reinventare:
   - ricava il DESIGN.md dallo stato attuale con `/impeccable extract` (colori, font, spaziature, componenti e animazioni in uso), segnando le incoerenze trovate;
   - se ti chiedo di migliorare, correggere o rifare una sezione: mantieni l'identità esistente, fai un audit mirato della parte interessata (`/impeccable critique` + avoid-ai-design in sola analisi + `review-animations` se c'è movimento), mostrami i problemi in ordine di importanza e poi intervieni; vai al punto 7;
   - prosegui con i punti 3-6 (nuove direzioni) solo se chiedo esplicitamente un restyling o un rifacimento dell'identità, oppure se l'audit mostra che l'identità attuale è essa stessa generica: in quel caso chiedimelo prima.
3. **Brief** (progetto nuovo o restyling). Usa la procedura di `/impeccable init`, ma chiedimi solo ciò che manca davvero: cliente, pubblico, obiettivo, tono, cosa evitare. Se nella richiesta ho già dato queste informazioni, non richiederle.
4. **Riferimenti che cito** ("come il sito X", "stile Y"):
   - cerca prima un DESIGN.md di quel brand in `{{KIT_DIR}}/riferimenti/awesome-design-md/design-md/`;
   - se non c'è, apri il sito con l'MCP Playwright (o leggilo dal web) e ricavane palette, tipografia, ritmo degli spazi, struttura e carattere del movimento;
   - prendi ispirazione dalle scelte, non copiare logo, testi, immagini o l'identità di un altro marchio.
5. **Tre direzioni a parole, niente codice.** Una con impeccable, una con le manopole di taste-skill (VARIANCE, MOTION, DENSITY), una partendo dal riferimento citato o da un DESIGN.md della raccolta. Per ognuna: idea centrale in una frase, palette, abbinamento di font, struttura della home, carattere del movimento. Massimo un paragrafo breve ciascuna. Poi fermati e aspetta la mia scelta (posso anche mescolarle). Se ho già indicato in modo preciso la direzione, proponine una sola e chiedi conferma.
6. **Scrivi o aggiorna `DESIGN.md`** con la direzione scelta: colori, font, scala tipografica, spaziature, raggi, componenti, curve e durate delle animazioni (token).
7. **Realizza con impeccable** come unica skill di design, seguendo il DESIGN.md. Animazioni: Emil Kowalski per decidere curve, durate e micro-interazioni; GSAP per scroll e timeline.
8. **Chiudi con la checklist di consegna** (vedi in fondo).

Per una modifica piccola a un progetto che ha già il DESIGN.md (un pulsante, un testo, un colore) vai direttamente al punto 7.
Per analizzare un intero progetto esistente senza modificarlo, quando te lo chiedo: `/qualita --completo` più `/impeccable audit`, e un rapporto con le priorità.

## Quale skill usare, e quando

| Fase | Skill o strumento | Note |
| --- | --- | --- |
| Stile del progetto | `DESIGN.md` nella radice del progetto | Se manca, segui la procedura di avvio qui sopra prima di scrivere interfacce. |
| Interfacce nuove o rifatte | **impeccable** (skill principale) | Usa i suoi comandi shape → craft → critique → polish. |
| Direzioni alternative | taste-skill, hallmark | Solo se lo chiedo o se propongo varianti. Mai due skill di design sullo stesso lavoro. |
| Controllo cliché da IA | avoid-ai-design | Gira in automatico dopo ogni modifica UI; correggi ciò che segnala. |
| Testi visibili | humanizer | Su hero, titoli, about, email, messaggi d'errore, blog. Niente frasi da brochure. |
| Micro-interazioni e transizioni UI | Emil Kowalski: `animate`, `emil-design-eng` | Per React Native/Expo: `animate-expo`. |
| Animazioni complesse, scroll, timeline | GSAP: `gsap-core`, `gsap-timeline`, `gsap-scrolltrigger`, `gsap-react`, `gsap-performance` | |
| Revisione animazioni | `review-animations`, `improve-animations` | Prima della consegna di ogni lavoro con movimento. |
| Test web | Playwright (agenti planner, generator, healer) + MCP Playwright per vedere le pagine | |
| Test app Expo/React Native | Maestro (flussi YAML in `.maestro/`) | |
| Sicurezza | security-audit (Cloudflare), vibe-check, gitleaks, semgrep, trivy | ZAP e scansioni attive solo su siti miei o autorizzati. |
| SEO | claude-seo (`/seo audit`), SEOmator (`seomator audit <url> --format llm`), unlighthouse | Solo per siti pubblici. |
| Dati personali nel codice | gdpr-compliant | Modelli dati, API, login, log, conservazione e cancellazione, analytics, email. |
| Obblighi di legge (Italia) | obblighi-siti-italia | Footer e dati aziendali, cookie, privacy, checkout, recesso, prezzi, recensioni, chatbot. |
| Revisione di conformità UE | eu-web-compliance | Prima della pubblicazione di un sito o su richiesta: rapporto con fonti e bozze, modifiche solo dopo il mio ok. |
| Accessibilità | test axe-core (`tests/accessibilita.spec.ts`) + regole qui sotto | |

## Design: cosa evitare sempre

- Gradiente viola-blu, glassmorphism, ombre sfumate ovunque, angoli molto arrotondati su tutto.
- Inter (o il font di sistema) per ogni testo senza una scelta motivata.
- Hero centrato + tre card uguali + "feature" numerate 01/02/03.
- I "nuovi" cliché: crema con accento terracotta, quasi-nero con un solo verde acido, etichette monospace in maiuscolo, una parola colorata nel titolo.
- Metriche inventate, loghi finti di clienti, testimonianze inventate, testi generici ("Sblocca il potenziale…").
- Contenuti di riempimento: se manca un dato reale, chiedimelo o lascia un segnaposto evidente.

Ogni interfaccia deve avere un'idea specifica del cliente o del prodotto, una gerarchia chiara
e un elemento distintivo. Prova: se sostituendo il logo con quello di un concorrente nessuno se
ne accorgerebbe, il design non va bene.

## Animazioni: regole fisse

- Un solo linguaggio di movimento per progetto: curve e durate definite una volta (token) e riusate.
- UI sotto i 300 ms; uscite circa il 20% più veloci delle entrate; durata proporzionale alla distanza.
- Easing personalizzati (es. `cubic-bezier(0.23, 1, 0.32, 1)` per le entrate), mai `ease`/`linear` di default sulle transizioni.
- Solo `transform` e `opacity`; niente animazioni di `width`, `height`, `top`, `left`.
- `prefers-reduced-motion` sempre gestito; pulizia di listener, timer e ScrollTrigger allo smontaggio.
- Ogni animazione spiega qualcosa (provenienza, cambiamento di stato, gerarchia). Le decorative si tolgono.
- CSS per i movimenti prevedibili; GSAP o Motion per quelli interrompibili, legati a scroll o gesti.

## Test

- Ogni nuovo percorso utente (login, acquisto, prenotazione, form) riceve un test end-to-end.
- L'Healer di Playwright può correggere i selettori, non le verifiche: se il comportamento è sbagliato si corregge il codice.

## Sicurezza

- Mai chiavi, token o password nel codice o nei commit: variabili d'ambiente e `.env` in `.gitignore`.
- Supabase: RLS attiva su ogni tabella, nessuna `service_role` lato client.
- Prezzi, permessi e quantità si verificano sul server, mai fidandosi del client.
- Token di sessione in cookie `HttpOnly`/`Secure`, non in `localStorage`.
- Header di sicurezza (CSP, HSTS, X-Content-Type-Options) e CORS ristretto.

## Accessibilità (WCAG 2.2 AA)

- HTML semantico: un solo `h1`, titoli in ordine, `button` per le azioni e `a` per la navigazione, landmark (`header`, `nav`, `main`, `footer`).
- Tutto usabile da tastiera, con focus sempre visibile e ordine logico; nessuna trappola del focus nei modali.
- Contrasto almeno 4,5:1 per il testo normale e 3:1 per testo grande ed elementi grafici.
- Testo alternativo descrittivo sulle immagini informative, `alt=""` su quelle decorative. Mai inventare descrizioni: se non sai cosa mostra un'immagine, chiedi.
- Form: etichette visibili collegate ai campi, errori spiegati a parole e annunciati agli screen reader.
- Aree cliccabili di almeno 24×24 px; niente informazioni affidate solo al colore.

## Obblighi di legge

Per siti e app di clienti italiani o europei usa la skill obblighi-siti-italia. Non è consulenza
legale: dillo sempre, non inventare dati aziendali e non modificare testi legali senza il mio ok.

## SEO (siti pubblici)

- Title e meta description unici per pagina, un solo `h1`, gerarchia dei titoli corretta.
- Canonical, `sitemap.xml`, `robots.txt`, `hreflang` se multilingua.
- Dati strutturati JSON-LD adatti al tipo di attività; Open Graph e Twitter card.
- Testo alternativo descrittivo sulle immagini; immagini in AVIF/WebP con dimensioni esplicite.
- Core Web Vitals nella soglia verde (LCP < 2,5 s, INP < 200 ms, CLS < 0,1).

## Prima di dire che il lavoro è finito

Esegui la checklist di consegna: in Claude Code il comando `/qualita`; con altri agenti segui
i passi descritti in `~/.claude/commands/qualita.md`. Al termine riportami una tabella con
l'esito per area (design, animazioni, test, sicurezza, accessibilità e obblighi, SEO) e cosa resta aperto.
Se un controllo non si può eseguire (manca un tool, un URL, un permesso), dillo: non dichiararlo superato.
<!-- <<< kit-qualita <<< -->
