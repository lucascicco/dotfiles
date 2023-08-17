#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source "${BASE_CONFIG}"
CORP_SCRIPT="$HOME/dotfiles/scripts/corp/rc.sh"
[[ -s "$CORP_SCRIPT" ]] && source "${CORP_SCRIPT}"

BREW_BIN="/opt/homebrew/bin/brew"

# Paths
PATHS=(
  "$HOME/.docker/bin"
  "/usr/local/opt/coreutils/libexec/gnubin"
)
dynamic_batch_load_path "${PATHS[@]}"
export PATH

# Evals
[[ -s "$BREW_BIN" ]] && eval "$("$BREW_BIN" shellenv)"

# FIXME: https://github.com/lionheart/openradar-mirror/issues/15361#issuecomment-267367902
{ eval `ssh-agent`; ssh-add -A; } &>/dev/null
