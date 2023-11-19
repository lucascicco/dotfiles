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
BREW_GCLOUD_CASKROOM_DIR="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
GCLOUD_SDK_SOURCES=(
  "$BREW_GCLOUD_CASKROOM_DIR/path.zsh.inc"
  "$BREW_GCLOUD_CASKROOM_DIR/completion.zsh.inc"
)
dynamic_batch_source "${GCLOUD_SDK_SOURCES[@]}"
