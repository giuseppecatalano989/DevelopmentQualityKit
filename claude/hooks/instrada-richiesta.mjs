// Kit Qualità — logica dell'hook UserPromptSubmit (vedi instrada-richiesta.sh)

import fs from "node:fs";
import path from "node:path";
let d = "";
process.stdin.on("data", c => d += c).on("end", () => {
  let j; try { j = JSON.parse(d); } catch { return; }
  const prompt = String(j.prompt || "");
  const cwd = j.cwd || process.cwd();
  if (!prompt || prompt.startsWith("/")) return;               // i comandi espliciti passano
  if (fs.existsSync(path.join(cwd, ".claude", "kit-qualita-off"))) return;

  const ui = /\b(sit[oi]|website|landing|pagin[ae]|home ?page|homepage|interfacc\w*|ui|ux|schermat\w*|app|applicazion\w*|dashboard|restyling|redesign|layout|hero|template|tema|grafic\w*|design|mockup|componente|portfolio|e-?commerce|negozio online)\b/i;
  const motion = /\b(animazion\w*|animat\w*|transizion\w*|scroll\w*|parallax|movimento|micro-?interazion\w*)\b/i;
  const rif = /\b(come (il|lo|la|quello di|quello del)|stile (di|del|della)|simile a|ispirat\w* a|tipo (il|lo|la)?)\b|https?:\/\//i;

  const isUI = ui.test(prompt), isMotion = motion.test(prompt);
  if (!isUI && !isMotion) return;

  const haDesign = fs.existsSync(path.join(cwd, "DESIGN.md"));
  // un progetto "esistente" ha già codice di interfaccia
  const segniUI = ["package.json", "index.html", "src", "app", "pages", "components", "public"];
  const esistente = segniUI.some(f => fs.existsSync(path.join(cwd, f)));
  const rifare = /\b(restyling|redesign|rifa(re|i|mmo)|rifacimento|ridisegna\w*|nuova (grafica|identità|veste)|cambia(re)? (lo )?stile|da zero)\b/i.test(prompt);

  const righe = ["[Kit Qualità] Richiesta di interfaccia riconosciuta: applica le regole del kit senza aspettare che l'utente nomini le skill."];
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
  if (esistente && !fs.existsSync(path.join(cwd, ".github", "workflows", "qualita.yml"))) {
    righe.push("Il kit non è ancora applicato a questo progetto: se non l'hai già fatto in questa sessione, proponi all'utente di eseguire applica-kit.sh (vedi \"Prima volta su un progetto\" nelle regole globali) e chiedi conferma prima.");
  }
  if (rif.test(prompt)) righe.push("L'utente cita un riferimento: cerca prima il DESIGN.md del brand nella raccolta awesome-design-md del kit, altrimenti analizza il sito con l'MCP Playwright; ispirati alle scelte, non copiare l'identità.");
  if (isMotion) righe.push("Animazioni: decidi curve, durate e micro-interazioni con le skill di Emil Kowalski (animate, animate-expo per Expo), usa le skill GSAP per scroll e timeline; poi review-animations.");
  righe.push("Testi visibili con humanizer. Prima di chiudere: checklist /qualita.");
  process.stdout.write(righe.join("\n") + "\n");
});
