#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/files/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source "$BASE_CONFIG"
BREW_BIN="/opt/homebrew/bin/brew"
JENV_BIN="/opt/homebrew/bin/jenv"

# Paths
PATHS=(
  "$HOME/.docker/bin"
)
dynamic_load_path "${PATHS[@]}"
export PATH

# Evals
[[ -d "$PYENV_ROOT" ]] && eval "$(pyenv init --path)"
[[ -s "$BREW_BIN" ]] && eval "$("$BREW_BIN" shellenv)"
[[ -s "$JENV_BIN" ]] && eval "$("$JENV_BIN" init -)"

# FIXME: https://github.com/lionheart/openradar-mirror/issues/15361#issuecomment-267367902
{ eval `ssh-agent`; ssh-add -A; } &>/dev/null
