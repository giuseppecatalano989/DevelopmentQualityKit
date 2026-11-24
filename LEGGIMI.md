# Kit Qualità Sviluppo

Design senza "effetto IA", animazioni professionali, test, sicurezza e SEO,
applicati in automatico da Claude Code (e Codex) mentre sviluppi.

## Installazione (una volta sola)

1. Sposta questa cartella dove vuoi tenerla, per esempio `~/Documents/Kit-Qualita-Sviluppo`.
   Lasciala lì: le regole globali puntano a questo percorso.
2. Apri il Terminale ed esegui:

   ```
   bash ~/Documents/Kit-Qualita-Sviluppo/installa.sh
   ```

3. Apri Claude Code e scrivi una volta `/seo setup`.
4. Riavvia Claude Code.

Puoi rilanciare `installa.sh` quando vuoi per aggiornare tutto. Con
`bash installa.sh --solo-regole` aggiorni solo regole, hook e comando `/qualita`.
Ogni file di configurazione modificato viene prima salvato con estensione `.bak-<data>`.

## Per ogni progetto

```
bash ~/Documents/Kit-Qualita-Sviluppo/applica-kit.sh /percorso/del/progetto
```

Poi compila il `CLAUDE.md` del progetto e crea il `DESIGN.md`.

## Uso quotidiano

- Lavori normalmente con Claude: quando chiedi un sito, una pagina o un'app, Claude applica da solo la procedura di avvio e le skill giuste, senza che tu le nomini.
- Dopo ogni modifica un controllo rapido cerca chiavi esposte e cliché di design da IA.
- Quando Claude sta per chiudere, se ci sono modifiche non verificate esegue `/qualita`.
- Puoi lanciarlo tu: `/qualita`, `/qualita https://anteprima.miosito.it`, `/qualita --completo`.
- Per spegnere i controlli automatici in un progetto: crea il file `.claude/kit-qualita-off`.

## Contenuto

| Percorso | Cosa contiene |
| --- | --- |
| `installa.sh` | Installazione e aggiornamento |
| `applica-kit.sh` | Configurazione di un progetto |
| `claude/CLAUDE.md` | Regole globali (copiate in `~/.claude/CLAUDE.md` e `~/.codex/AGENTS.md`) |
| `claude/hooks/` | Promemoria automatico sulle richieste di design e controlli automatici |
| `claude/commands/qualita.md` | Comando `/qualita` |
| `claude/attiva-hook.mjs` | Aggiunge gli hook a `~/.claude/settings.json` |
| `skills/` | Skill scritte per il kit (obblighi di legge per siti italiani) |
| `template-progetto/` | CLAUDE.md di progetto e workflow GitHub "Qualità" |
| `riferimenti/` | Raccolte scaricate dall'installer |
| `installazione.log` | Registro dell'ultima installazione |
