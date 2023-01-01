#!/bin/bash

# Constants
export DOTFILES_DIR="$HOME/dotfiles"
export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin
export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VERSION="3.10-dev"

# Sources
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

# Functions
function bootstrap() { (
  set -e
  cd "$DOTFILES_DIR" || return
  git pull origin master || true
  bash "$DOTFILES_DIR/run_bootstrap.sh" "${@}"
); }

# Paths
BASE_PATHS=(
  "$HOME/.cargo/bin"
  "$HOME/.poetry/bin"
  "$HOME/.krew/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
  "$PYENV_ROOT/bin"
)
dynamic_load_path "${BASE_PATHS[@]}"
