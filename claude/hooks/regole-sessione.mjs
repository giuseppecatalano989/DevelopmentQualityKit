// Kit Qualità — hook SessionStart del plugin.
// I plugin non possono caricare un CLAUDE.md: questo hook inserisce le regole
// globali del kit nel contesto all'avvio di ogni sessione.
// Uso: node regole-sessione.mjs <cartella del kit>
import fs from "node:fs";
import path from "node:path";

const kitDir = process.argv[2] || path.resolve(path.dirname(new URL(import.meta.url).pathname), "..", "..");
let regole;
try {
  regole = fs.readFileSync(path.join(kitDir, "claude", "CLAUDE.md"), "utf8");
} catch {
  process.exit(0);
}
regole = regole
  .split("\n")
  .filter((r) => !/^<!-- (>>>|<<<) kit-qualita (>>>|<<<) -->$/.test(r))
  .join("\n")
  .replaceAll("{{KIT_DIR}}", kitDir)
  .trim();

// Testo semplice: Claude Code lo aggiunge al contesto. Il formato JSON
// (additionalContext) ha un limite di 10.000 caratteri, che le regole superano.
process.stdout.write(regole + "\n");
