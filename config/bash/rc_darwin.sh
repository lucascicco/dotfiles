#!/bin/bash

readonly BASE_RC_CONFIG="$HOME/dotfiles/config/bash/rc.sh"
[[ -s "$BASE_RC_CONFIG" ]] && source "$BASE_RC_CONFIG"
readonly BREW_BIN="/opt/homebrew/bin/brew"
readonly -a DYNAMIC_PATHS=(
  "$HOME/.docker/bin"
  "/usr/local/opt/coreutils/libexec/gnubin"
)

load_dynamic_paths "${DYNAMIC_PATHS[@]}"
export PATH

# Evals
[[ -s "$BREW_BIN" ]] && eval "$("$BREW_BIN" shellenv)"
