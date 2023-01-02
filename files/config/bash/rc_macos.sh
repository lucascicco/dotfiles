#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/files/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source "$BASE_CONFIG"
BREW_BIN="/opt/homebrew/bin/brew"
JENV_ROOT="$HOME/.jenv"

# Paths
PATHS=(
  "$HOME/.docker/bin"
  "$JENV_ROOT/bin"
)
dynamic_load_path "${PATHS[@]}"
export PATH

# Evals
[[ -s "$BREW_BIN" ]] && eval "$("$BREW_BIN" shellenv)"
[[ -d "$PYENV_ROOT" ]] && eval "$(pyenv init --path)"
[[ -d "$JENV_ROOT" ]] && eval "$(jenv init -)"
