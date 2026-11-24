# Kit Qualità Sviluppo

Design senza "effetto IA", animazioni professionali, test, sicurezza e SEO,
applicati in automatico da Claude Code (e Codex) mentre sviluppi.

Questo repository è l'unica fonte del kit. Si usa in due modi:

| Dove | Come | Aggiornamento |
| --- | --- | --- |
| Mac (Claude Code e Codex) | `installa.sh`: installa skill esterne, strumenti e collega regole, hook e `/qualita` a questa cartella | `bash aggiorna.sh` |
| Cloud e altri computer | Plugin Claude Code `kit-qualita` (regole, hook, `/qualita`, skill del kit) | Automatico alla sessione successiva |

Sul Mac non serve installare anche il plugin: se lo fai, i suoi hook si accorgono
dell'installazione locale e non fanno nulla, così i controlli non girano due volte.

## Installazione sul Mac (una volta sola)

1. Scarica il repository nella cartella dove resterà (le regole globali puntano a questo percorso):

   ```
   git clone https://github.com/giuseppecatalano989/DevelopmentQualityKit.git ~/Documents/Kit-Qualita-Sviluppo
   ```

2. Esegui l'installazione:

   ```
   bash ~/Documents/Kit-Qualita-Sviluppo/installa.sh
   ```

3. Apri Claude Code e scrivi una volta `/seo setup`.
4. Riavvia Claude Code.

Skill del kit, hook e comando `/qualita` vengono **collegati** a questa cartella, non copiati:
dopo un aggiornamento Claude usa subito la versione nuova. Le regole globali invece vengono
scritte dentro `~/.claude/CLAUDE.md` e `~/.codex/AGENTS.md` (tra i marcatori `kit-qualita`),
per questo l'aggiornamento riesegue `installa.sh --solo-regole`.
Se trova vecchie copie al loro posto, le sposta in `~/.claude/kit-qualita-backup/<data>/`.
I file di configurazione modificati vengono prima salvati con estensione `.bak-<data>`.

## Aggiornare il kit sul Mac

```
bash ~/Documents/Kit-Qualita-Sviluppo/aggiorna.sh
```

Scarica le novità dal repository (`git pull`) e riapplica regole, hook, skill e `/qualita`.
Per aggiornare anche skill esterne e strumenti (impeccable, GSAP, gitleaks, semgrep…)
rilancia `installa.sh` senza opzioni.

## Plugin (cloud e altri computer)

In Claude Code:

```
/plugin marketplace add giuseppecatalano989/DevelopmentQualityKit
/plugin install kit-qualita@developmentqualitykit
```

Il plugin porta regole globali (caricate all'avvio di ogni sessione), hook, `/qualita` e le
skill scritte per il kit. **Non** include le skill esterne (impeccable, GSAP, Emil Kowalski…)
né gli strumenti da riga di comando: dove mancano, i controlli che li usano vanno segnalati
come "non eseguiti", come dicono le regole.

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

## Modificare il kit

1. Fai la modifica in questo repository (sul Mac o chiedendola a Claude in una sessione cloud).
2. Se aggiungi una skill: crea `skills/<nome-skill>/SKILL.md` e aggiungi una riga alla tabella
   "Quale skill usare, e quando" in `claude/CLAUDE.md`, così Claude sa quando usarla da solo.
3. Aumenta `version` in `.claude-plugin/plugin.json` (es. 1.1.0 → 1.2.0): è il numero che fa
   aggiornare il plugin.
4. Commit e push. Sul Mac: `bash aggiorna.sh`. Nel cloud: dalla sessione successiva.

## Contenuto

| Percorso | Cosa contiene |
| --- | --- |
| `installa.sh` | Installazione completa sul Mac |
| `aggiorna.sh` | Aggiornamento sul Mac (`git pull` + regole, hook, skill e `/qualita`) |
| `applica-kit.sh` | Configurazione di un progetto |
| `claude/CLAUDE.md` | Regole globali (inserite in `~/.claude/CLAUDE.md` e `~/.codex/AGENTS.md`) |
| `claude/hooks/` | Promemoria automatico sulle richieste di design e controlli automatici |
| `claude/commands/qualita.md` | Comando `/qualita` |
| `claude/attiva-hook.mjs` | Aggiunge gli hook a `~/.claude/settings.json` |
| `skills/` | Skill scritte per il kit (obblighi di legge per siti italiani) |
| `template-progetto/` | CLAUDE.md di progetto e workflow GitHub "Qualità" |
| `.claude-plugin/`, `hooks/hooks.json` | Definizione del plugin e del marketplace |
| `riferimenti/` | Raccolte scaricate dall'installer (non versionate) |
| `installazione.log` | Registro dell'ultima installazione (non versionato) |
