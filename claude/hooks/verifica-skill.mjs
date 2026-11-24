// Kit Qualità — parte dell'hook Stop (vedi controllo-consegna.sh).
// Legge la trascrizione della sessione: se l'ultima richiesta dell'utente era una
// valutazione o un lavoro di interfaccia/animazioni e da allora Claude non ha usato
// nessuna skill, stampa un messaggio (che l'hook trasforma in una richiesta a Claude).
// In ogni caso dubbio non stampa nulla.
import fs from "node:fs";
import { reUI, reMotion, reRevisione } from "./riconosci.mjs";

function testo(content) {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  if (content.some(c => c && c.type === "tool_result")) return "";
  return content.filter(c => c && c.type === "text").map(c => c.text || "").join("\n");
}

function usaSkill(content) {
  if (!Array.isArray(content)) return false;
  return content.some(c => c && c.type === "tool_use" &&
    (/skill/i.test(String(c.name || "")) || /slashcommand/i.test(String(c.name || ""))));
}

let d = "";
process.stdin.on("data", c => d += c).on("end", () => {
  try {
    const j = JSON.parse(d);
    if (j.stop_hook_active) return;
    const tp = j.transcript_path;
    if (!tp || !fs.existsSync(tp)) return;

    const righe = fs.readFileSync(tp, "utf8").split("\n").filter(Boolean);
    let richiesta = null, skillUsate = false, ultimoTesto = "";
    for (const r of righe) {
      let e; try { e = JSON.parse(r); } catch { continue; }
      const msg = e.message || {};
      if (e.type === "user" && !e.isMeta) {
        const t = testo(msg.content);
        if (t.trim()) { richiesta = t; skillUsate = false; ultimoTesto = ""; }
      } else if (e.type === "assistant" && richiesta !== null) {
        if (usaSkill(msg.content)) skillUsate = true;
        const tt = Array.isArray(msg.content)
          ? msg.content.filter(c => c && c.type === "text").map(c => c.text || "").join("\n").trim()
          : "";
        if (tt) ultimoTesto = tt;
      }
    }
    if (!richiesta || skillUsate) return;
    // Claude si è fermato con una domanda all'utente (es. "Prima volta su un progetto",
    // scelta tra le direzioni di design): va bene, il lavoro non è ancora iniziato.
    // (solo risposte brevi: un rapporto completo che finisce con "Vuoi che proceda?" non passa)
    if (ultimoTesto.length < 1500 && /\?[^?]{0,40}$/.test(ultimoTesto)) return;
    const t = richiesta.trim();
    if (t.startsWith("/") || /<command-name>/.test(t)) return;   // comando o skill chiamati dall'utente

    const revisione = reRevisione.test(t);
    if (!revisione && !reUI.test(t) && !reMotion.test(t)) return;

    process.stdout.write(
      "Kit qualità: la richiesta dell'utente era " +
      (revisione ? "una valutazione/revisione" : "un lavoro di interfaccia o animazioni") +
      ", ma in questa risposta non hai usato nessuna skill del kit. Prima di chiudere applica le skill pertinenti " +
      (revisione ? "(sezione \"Revisioni, valutazioni e audit\" delle regole globali) " : "(impeccable, Emil Kowalski/GSAP per il movimento, humanizer per i testi) ") +
      "e aggiorna la risposta con quello che emerge. Se per questa richiesta le skill non servono (es. una domanda o una modifica banale), scrivi in una riga perché e chiudi."
    );
  } catch { /* nel dubbio, nessun blocco */ }
});
