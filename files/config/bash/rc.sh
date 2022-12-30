#!/bin/bash

# Common variables
export DOTFILES_DIR="$HOME/dotfiles"
export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin

FUNCTIONS="$DOTFILES_DIR/files/scripts/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "$FUNCTIONS"

SOURCES=(
  # Version Managers
  "$HOME/.sdkman/bin/sdkman-init.sh"
  "$HOME/.jabba/jabba.sh"
  "$HOME/.nvm/nvm.sh"
  "$HOME/.gvm/scripts/gvm"
  # Utils
  "$DOTFILES_DIR/files/config/k8s/k8s.sh"
)
batch_source "${SOURCES[@]}"

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VERSION="3.10-dev"
