// Kit Qualità — logica dell'hook UserPromptSubmit (vedi instrada-richiesta.sh)
// Aggiunge per Claude un promemoria breve con la procedura giusta:
//  - al PRIMO messaggio della sessione, se al progetto mancano i file del kit,
//    impone di chiedere all'utente prima di qualsiasi altra cosa;
//  - per richieste di valutazione/revisione, elenca le skill da usare;
//  - per richieste di interfaccia o animazioni, la procedura di lavoro.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import { reUI, reMotion, reRevisione } from "./riconosci.mjs";

function main(d) {
  let j; try { j = JSON.parse(d); } catch { return; }
  const prompt = String(j.prompt || "");
  const cwd = j.cwd || process.cwd();
  if (!prompt || prompt.startsWith("/")) return;               // i comandi espliciti passano
  if (fs.existsSync(path.join(cwd, ".claude", "kit-qualita-off"))) return;

  // un progetto "esistente" ha già codice
  const segni = ["package.json", "index.html", "src", "app", "pages", "components", "public", "app.json"];
  const esistente = segni.some(f => fs.existsSync(path.join(cwd, f)));
  const kitApplicato = fs.existsSync(path.join(cwd, ".github", "workflows", "qualita.yml"));

  // primo messaggio di questa sessione? (un segnaposto per sessione nella cartella temporanea)
  const sid = String(j.session_id || "").replace(/[^\w-]/g, "");
  let primo = false;
  if (sid) {
    const segnaposto = path.join(os.tmpdir(), `kit-qualita-${sid}`);
    primo = !fs.existsSync(segnaposto);
    try { fs.writeFileSync(segnaposto, ""); } catch {}
  }

  const isUI = reUI.test(prompt), isMotion = reMotion.test(prompt), isRevisione = reRevisione.test(prompt);
  const righe = [];

  if (primo && esistente && !kitApplicato) {
    righe.push("[Kit Qualità] PRIMA DI TUTTO: a questo progetto mancano i file del kit (manca .github/workflows/qualita.yml). La tua risposta a questo messaggio deve essere SOLO la domanda prevista dalle regole globali (\"Prima volta su un progetto\"): chiedi se aggiungere test e controlli automatici del kit, poi fermati e aspetta. Non analizzare, non valutare e non modificare nulla prima della risposta. Il kit (regole e skill) è già attivo: non dire che va installato.");
  }

  if (!isUI && !isMotion && !isRevisione) {
    if (righe.length) process.stdout.write(righe.join("\n") + "\n");
    return;
  }

  righe.push("[Kit Qualità] Richiesta riconosciuta: applica le regole del kit senza aspettare che l'utente nomini le skill.");

  if (isRevisione) {
    righe.push("È una richiesta di valutazione/revisione: segui la sezione \"Revisioni, valutazioni e audit\" delle regole globali. Usa le skill (impeccable critique/audit, avoid-ai-design in sola analisi, review-animations, humanizer in sola analisi, vibe-check, seo-audit, obblighi-siti-italia), non solo un'analisi a mano, e nel rapporto indica quale skill hai usato per ogni area.");
  } else {
    const haDesign = fs.existsSync(path.join(cwd, "DESIGN.md"));
    const rifare = /\b(restyling|redesign|rifa(re|i|mmo)|rifacimento|ridisegna\w*|nuova (grafica|identità|veste)|cambia(re)? (lo )?stile|da zero)\b/i.test(prompt);
    if (isUI && haDesign) {
      righe.push(rifare
        ? "C'è un DESIGN.md ma l'utente parla di rifare: se riguarda tutta l'identità chiedi conferma e segui i punti 3-6 della procedura di avvio; se riguarda una sezione, rispetta il DESIGN.md e realizza con impeccable."
        : "C'è un DESIGN.md: seguilo e realizza con impeccable come unica skill di design.");
    } else if (isUI && esistente) {
      righe.push(rifare
        ? "Progetto esistente senza DESIGN.md, l'utente parla di rifare: ricava prima il DESIGN.md attuale con /impeccable extract; se il rifacimento riguarda tutta l'identità segui i punti 3-6 della procedura di avvio, se riguarda una sezione mantieni l'identità e fai un audit mirato prima di intervenire."
        : "Progetto esistente senza DESIGN.md: non proporre nuove direzioni. Ricava il DESIGN.md attuale con /impeccable extract, fai un audit mirato della parte richiesta (impeccable critique, avoid-ai-design in sola analisi), mostra i problemi per priorità e poi intervieni mantenendo l'identità.");
    } else if (isUI) {
      righe.push("Progetto nuovo senza DESIGN.md: segui la \"procedura di avvio\" delle regole globali (brief solo per ciò che manca, tre direzioni a parole senza codice, poi attendi la scelta).");
    }
  }

  const rif = /\b(come (il|lo|la|quello di|quello del)|stile (di|del|della)|simile a|ispirat\w* a|tipo (il|lo|la)?)\b|https?:\/\//i;
  if (rif.test(prompt) && !isRevisione) righe.push("L'utente cita un riferimento: cerca prima il DESIGN.md del brand nella raccolta awesome-design-md del kit, altrimenti analizza il sito con l'MCP Playwright; ispirati alle scelte, non copiare l'identità.");
  if (isMotion) righe.push("Animazioni: decidi curve, durate e micro-interazioni con le skill di Emil Kowalski (animate, animate-expo per Expo), usa le skill GSAP per scroll e timeline; poi review-animations.");
  if (!isRevisione) righe.push("Testi visibili con humanizer. Prima di chiudere: checklist /qualita.");
  process.stdout.write(righe.join("\n") + "\n");
}

let d = "";
process.stdin.on("data", c => d += c).on("end", () => main(d));
