// Kit Qualità — aggiunge gli hook del kit a ~/.claude/settings.json
// senza toccare le altre impostazioni. Ripetibile: rimuove le voci del kit
// già presenti e le riscrive.
// Uso: node attiva-hook.mjs <settings.json> <cartella-hook>
import fs from 'node:fs';
import path from 'node:path';

const [settingsPath, hookDir] = process.argv.slice(2);
if (!settingsPath || !hookDir) {
  console.error('Uso: node attiva-hook.mjs <settings.json> <cartella-hook>');
  process.exit(1);
}

let settings = {};
if (fs.existsSync(settingsPath)) {
  const raw = fs.readFileSync(settingsPath, 'utf8').trim();
  if (raw) {
    try { settings = JSON.parse(raw); }
    catch (e) {
      console.error(`settings.json non è JSON valido, non lo modifico: ${e.message}`);
      process.exit(1);
    }
  }
}

const MARCA = 'kit-qualita';
const cmd = (file) => `"${path.join(hookDir, file)}"`;

const nuovi = {
  UserPromptSubmit: {
    hooks: [{ type: 'command', command: cmd('instrada-richiesta.sh'), timeout: 10 }],
  },
  PostToolUse: {
    matcher: 'Write|Edit|MultiEdit',
    hooks: [{ type: 'command', command: cmd('controllo-modifica.sh'), timeout: 60 }],
  },
  Stop: {
    hooks: [{ type: 'command', command: cmd('controllo-consegna.sh'), timeout: 30 }],
  },
};

settings.hooks ??= {};
for (const [evento, voce] of Object.entries(nuovi)) {
  const esistenti = Array.isArray(settings.hooks[evento]) ? settings.hooks[evento] : [];
  // toglie le voci del kit già presenti, lascia intatte le altre
  const pulite = esistenti
    .map((g) => ({ ...g, hooks: (g.hooks ?? []).filter((h) => !String(h.command ?? '').includes(MARCA)) }))
    .filter((g) => g.hooks.length > 0);
  settings.hooks[evento] = [...pulite, voce];
}

fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log(`Hook del kit attivi in ${settingsPath}`);
