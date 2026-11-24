---
name: obblighi-siti-italia
description: Checklist degli obblighi di legge italiani ed europei per siti web, e-commerce e app di aziende che operano in Italia (dati aziendali obbligatori, cookie secondo il Garante, privacy GDPR, recesso e pulsante di recesso, prezzi e sconti, recensioni, accessibilità EAA, trasparenza dell'IA). Usala quando costruisci o rivedi un sito o un e-commerce per un cliente italiano, quando tocchi footer, note legali, checkout, banner cookie, form, newsletter, chatbot, o quando l'utente chiede se un sito è "a norma".
---

# Obblighi per siti e app in Italia — checklist tecnica

Ultima verifica delle fonti: 24 novembre 2026. Le norme cambiano: per le voci contrassegnate
"verifica" controlla con una ricerca web lo stato attuale e annota la data del controllo.

## Regole d'uso

1. **Non è consulenza legale.** Scrivilo nel riepilogo ogni volta. Testi legali (privacy policy,
   cookie policy, condizioni di vendita) vanno fatti verificare da un professionista o generati con
   un servizio specializzato: tu prepari la struttura tecnica e le bozze con segnaposto evidenti.
2. **Non inventare dati.** Partita IVA, ragione sociale, REA, capitale sociale, PEC, contatti,
   tempi di conservazione: se non li hai, chiedili o lascia un segnaposto tipo `[PARTITA IVA]`.
3. **Prima di modificare testi legali esistenti** mostra un piano scritto e attendi l'approvazione.
4. **Applica solo ciò che serve:** chiedi o deduci il tipo di sito (vetrina, e-commerce B2C,
   B2B, app, servizio con account) e la dimensione dell'azienda, poi usa le sezioni pertinenti.

## 1. Dati dell'azienda sul sito (ogni sito aziendale)

- Partita IVA visibile nella home page (di solito nel footer) per chi ne è titolare.
- Società: denominazione, sede, ufficio del registro imprese e numero di iscrizione (REA), capitale
  sociale versato ove previsto, stato di liquidazione se presente (art. 2250 c.c.).
- Servizi online e commercio elettronico: nome, indirizzo, contatti rapidi incluso un indirizzo email,
  iscrizioni ad albi o autorizzazioni se presenti (D.Lgs. 70/2003, art. 7).

## 2. Cookie e tracciamento (Garante privacy, linee guida 10 giugno 2021)

- Nessun cookie o script di profilazione/analytics non anonimizzato prima del consenso: verificalo
  davvero aprendo il sito in una sessione pulita (MCP Playwright) e controllando cookie e richieste.
- Banner con pulsante per rifiutare ben visibile; la "X" di chiusura equivale a rifiuto con
  mantenimento delle sole impostazioni di default.
- Lo scroll non è consenso; niente cookie wall; niente caselle pre-spuntate.
- Non riproporre il banner prima di 6 mesi dal rifiuto, salvo cambi rilevanti.
- Link a cookie policy e possibilità di cambiare le scelte in qualsiasi momento (es. link nel footer).
- Analytics: senza consenso solo se configurati come tecnici secondo le indicazioni del Garante
  (es. IP mascherato, nessun incrocio di dati) — **verifica** lo strumento usato.

## 3. Privacy (GDPR)

- Informativa privacy (art. 13) raggiungibile da ogni pagina e nei punti di raccolta dati (form,
  registrazione, checkout, newsletter).
- Form: solo i campi necessari; consenso marketing separato, facoltativo e non pre-selezionato.
- Newsletter: consenso esplicito; per clienti esistenti eventuale "soft spam" su prodotti analoghi con
  possibilità di opposizione in ogni email (art. 130, c. 4, Codice privacy) — **verifica** il caso.
- Fornitori che trattano dati (hosting, email, pagamenti, analytics, CRM): accordi di nomina a
  responsabile (art. 28) e attenzione ai trasferimenti fuori dallo Spazio economico europeo.
- Usa anche la skill `gdpr-compliant` per le regole di sviluppo (log, cancellazione, cifratura).

## 4. E-commerce verso consumatori (Codice del Consumo, D.Lgs. 206/2005)

- Informazioni precontrattuali chiare prima dell'ordine: caratteristiche, prezzo totale con imposte,
  spese di consegna, modalità di pagamento e consegna, durata, recesso (artt. 49 e seguenti).
- Pulsante d'ordine con dicitura che indichi l'obbligo di pagare (es. "Ordine con obbligo di pagamento").
- Diritto di recesso di 14 giorni con modulo tipo, salvo esclusioni di legge.
- **Pulsante di recesso** obbligatorio dal 19 giugno 2026 per i contratti conclusi da quella data
  (art. 54-bis, introdotto dal D.Lgs. 209/2025): funzione visibile e accessibile per tutto il periodo
  di recesso, con le diciture "recedi dal contratto qui" e "Conferma recesso", conferma e ricevuta
  automatica al consumatore.
- Annunci di riduzione di prezzo: indicare il prezzo più basso applicato nei 30 giorni precedenti.
- Recensioni: indicare se e come si verifica che provengano da chi ha davvero acquistato.
- **Piattaforma ODR: togli il link.** La piattaforma europea è stata chiusa il 20 luglio 2025
  (Reg. UE 2024/3228); restano da indicare, se applicabili, gli organismi ADR a cui si aderisce.

## 5. Accessibilità (European Accessibility Act, D.Lgs. 82/2022)

- Dal 28 giugno 2025 si applica ai servizi digitali verso i consumatori, tra cui l'e-commerce.
  Riferimento tecnico: EN 301 549 / WCAG livello AA; Linee guida AgID sull'accessibilità dei servizi.
- Esenzione per le microimprese di servizi (meno di 10 persone e fatturato o bilancio annuo non
  superiore a 2 milioni di euro): **verifica** la dimensione del cliente. Anche se esente, il kit
  applica comunque WCAG 2.2 AA come buona pratica.
- Dichiarazione/informazioni di accessibilità del servizio dove richieste — **verifica** le Linee guida AgID.
- Il test automatico axe-core (`tests/accessibilita.spec.ts`) copre una parte dei criteri: completa
  con controlli manuali su tastiera, focus visibile, contrasto, testi alternativi, form ed errori.

## 6. Intelligenza artificiale (AI Act, art. 50)

- Chatbot e assistenti: l'utente deve sapere che parla con un sistema di IA.
- Contenuti generati o manipolati con IA (immagini, audio, video realistici): obblighi di
  segnalazione. **Verifica** date di applicazione ed eventuali rinvii (Digital Omnibus).

## 7. Altro da chiedere al cliente

- Settori regolati (alimentare, farmaci, alcolici, giochi, servizi finanziari, viaggi) hanno obblighi
  aggiuntivi: segnalali e non improvvisare.
- Vendita all'estero: possono valere regole di altri Paesi (lingua, IVA, recesso).

## Fonti

- Pulsante di recesso, art. 54-bis Codice del Consumo (D.Lgs. 209/2025): https://cms.law/it/ita/publication/diritto-di-recesso-online-introdotta-la-nuova-funzione-digitale-nel-codice-del-consumo
- Diciture obbligatorie del pulsante: https://www.iubenda.com/it/blog/funzione-di-recesso-online-direttiva-2023-2673/
- Chiusura piattaforma ODR: https://cms.law/en/deu/legal-updates/the-odr-platform-is-closing-what-businesses-need-to-know
- EAA in Italia, esenzione microimprese: https://www.altroconsumo.it/hi-tech/internet-telefono/news/accessibilita-prodotti-servizi
- Linee guida AgID sull'accessibilità dei servizi: https://www.agid.gov.it/it/notizie/european-accessibility-act-eaa-pubblicate-le-linee-guida-agid-sullaccessibilita-dei-servizi
- Garante privacy, linee guida cookie: https://www.garanteprivacy.it
