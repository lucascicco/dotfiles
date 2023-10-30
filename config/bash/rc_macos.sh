#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source "${BASE_CONFIG}"

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

# Brew Google Cloud SDK
BREW_GCLOUD_PATH_INC="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
BREW_GCLOUD_COMPLETION_INC="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
[[ -s "$BREW_GCLOUD_PATH_INC" ]] && source "$BREW_GCLOUD_PATH_INC"
[[ -s "$BREW_GCLOUD_COMPLETION_INC" ]] && source "$BREW_GCLOUD_COMPLETION_INC"
