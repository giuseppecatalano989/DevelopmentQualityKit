#!/usr/bin/env bash
# Kit Qualità — aggiorna il kit su questo Mac all'ultima versione del repository.
# Scarica le novità e riapplica regole, hook, skill e comando /qualita.
# Uso: bash aggiorna.sh
set -eu
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
git -C "$KIT_DIR" pull --ff-only
bash "$KIT_DIR/installa.sh" --solo-regole
