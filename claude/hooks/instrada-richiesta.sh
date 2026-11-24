#!/usr/bin/env bash
# Kit Qualità — hook UserPromptSubmit (a ogni messaggio che invii)
# Se il messaggio riguarda siti, app o interfacce, aggiunge per Claude un
# promemoria breve con la procedura giusta. Così le skill di competenza
# intervengono senza doverle nominare. Gli altri messaggi passano intatti.
# Per disattivarlo in un progetto: crea il file .claude/kit-qualita-off

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

node "$(dirname "$0")/instrada-richiesta.mjs"
exit 0
