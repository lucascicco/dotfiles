#!/bin/bash

# Constants
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"
export SECRET_ENV="$HOME/.secret_env.sh"
export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin
export EDITOR="lvim"
export MISE_USE_TOML=1

if [ -s "$SECRET_ENV" ]; then
  source "${SECRET_ENV}"
fi

# Sources
FUNCTIONS="$DOTFILES_SCRIPTS_DIR/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "${FUNCTIONS}"

# Functions
function bootstrap() { (
  set -e
  cd "$DOTFILES_DIR" || return
  git pull origin main || true
  bash "$DOTFILES_DIR/bootstrap.sh" "${@}"
); }

function switch_git_config {
  python3 "$DOTFILES_SCRIPTS_DIR/python/github_config_user_switcher.py"
}

# Paths
BASE_PATHS=(
  "$HOME/.cargo/bin"
  "$HOME/.krew/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
  "$PYENV_ROOT/bin"
)
dynamic_batch_load_path "${BASE_PATHS[@]}"
