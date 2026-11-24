# Kit Qualità Sviluppo

Design senza "effetto IA", animazioni professionali, test, sicurezza e SEO,
applicati in automatico da Claude Code (e Codex) mentre sviluppi.

Questo repository è l'unica fonte del kit. Si usa in due modi:

| Dove | Come | Aggiornamento |
| --- | --- | --- |
| Mac (Claude Code e Codex) | `installa.sh`: installa gli strumenti e collega regole, hook, `/qualita` e tutte le skill a questa cartella | `bash aggiorna.sh` |
| Cloud e altri computer | Plugin Claude Code `kit-qualita`: regole, hook, `/qualita` e tutte le skill | Automatico alla sessione successiva |

Le skill di altri autori (impeccable, GSAP, Emil Kowalski, humanizer…) sono **incluse nel
repository**, in `esterne/skills`, con licenza e fonte di ognuna in `esterne/FONTI.md`.
Così Mac, cloud e plugin usano sempre la stessa versione.

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
Per aggiornare anche gli strumenti (gitleaks, semgrep, trivy, Maestro…) rilancia
`installa.sh` senza opzioni.

Non usare `npx skills update` sul Mac: le skill in `~/.claude/skills` sono collegamenti
al repository e verrebbero modificate lì. Per le skill esterne usa la procedura qui sotto.

## Aggiornare le skill esterne

```
bash aggiorna-skill-esterne.sh
```

Scarica l'ultima versione di ogni skill elencata in `esterne/elenco.txt`, copia accanto a
ognuna il testo della licenza e rigenera `esterne/FONTI.md`. Controlla le differenze con
`git diff --stat`, aumenta `version` in `.claude-plugin/plugin.json` e fai commit.
Per aggiungere o togliere una skill esterna modifica `esterne/elenco.txt` e rilancia lo script.

## Plugin (cloud e altri computer)

In Claude Code:

```
/plugin marketplace add giuseppecatalano989/DevelopmentQualityKit
/plugin install kit-qualita@developmentqualitykit
```

Il plugin porta regole globali (caricate all'avvio di ogni sessione), hook, `/qualita` e tutte
le skill, sia quelle scritte per il kit sia quelle esterne. Non porta gli strumenti da riga di
comando (gitleaks, semgrep, trivy, Lighthouse): li esegue GitHub a ogni push con il workflow
"Qualità" dei progetti; dove servono in sessione e mancano, i controlli vanno segnalati come
"non eseguiti", come dicono le regole.

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
2. Se scrivi una skill tua: crea `skills/<nome-skill>/SKILL.md` (le skill esterne vanno invece
   in `esterne/elenco.txt`, vedi sopra) e aggiungi una riga alla tabella
   "Quale skill usare, e quando" in `claude/CLAUDE.md`, così Claude sa quando usarla da solo.
3. Aumenta `version` in `.claude-plugin/plugin.json` (es. 1.2.0 → 1.3.0): è il numero che fa
   aggiornare il plugin.
4. Commit e push. Sul Mac: `bash aggiorna.sh`. Nel cloud: dalla sessione successiva.

## Contenuto

| Percorso | Cosa contiene |
| --- | --- |
| `installa.sh` | Installazione completa sul Mac |
| `aggiorna.sh` | Aggiornamento sul Mac (`git pull` + regole, hook, skill e `/qualita`) |
| `aggiorna-skill-esterne.sh` | Scarica le skill esterne in `esterne/skills` |
| `applica-kit.sh` | Configurazione di un progetto |
| `claude/CLAUDE.md` | Regole globali (inserite in `~/.claude/CLAUDE.md` e `~/.codex/AGENTS.md`) |
| `claude/hooks/` | Promemoria automatico sulle richieste di design e controlli automatici |
| `claude/commands/qualita.md` | Comando `/qualita` |
| `claude/attiva-hook.mjs` | Aggiunge gli hook a `~/.claude/settings.json` |
| `skills/` | Skill scritte per il kit (obblighi di legge per siti italiani) |
| `esterne/` | Skill di altri autori incluse nel kit, con elenco, versioni e licenze |
| `template-progetto/` | CLAUDE.md di progetto e workflow GitHub "Qualità" |
| `.claude-plugin/`, `hooks/hooks.json` | Definizione del plugin e del marketplace |
| `riferimenti/` | Raccolte scaricate dall'installer (non versionate) |
| `installazione.log` | Registro dell'ultima installazione (non versionato) |
