#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/files/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source "$BASE_CONFIG"
BREW_BIN="$(which brew)"
JENV_ROOT="$HOME/.jenv"

# Paths
PATH="$HOME/.docker/bin:$PATH"
PATH="$HOME/.jenv/bin:$PATH"
export PATH

# Evals
[[ -s "$BREW_BIN" ]] && eval "$("$BREW_BIN" shellenv)"
[[ -d "$PYENV_ROOT" ]] && eval "$(pyenv init --path)"
[[ -d "$JENV_ROOT" ]] && eval "$(jenv init -)"
