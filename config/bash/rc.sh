#!/bin/bash

# Constants
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"
export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin
export EDITOR="lvim"
export RTX_USE_TOML=1

# Dynamically loads openai api key, if exists
OPENAI_API_KEY_PATH="$HOME/openai_api_key"
if [[ -f "$OPENAI_API_KEY_PATH" ]]; then
  OPENAI_API_KEY=$(cat "$OPENAI_API_KEY_PATH")
  export OPENAI_API_KEY=$OPENAI_API_KEY
fi

# Sources
FUNCTIONS="$DOTFILES_SCRIPTS_DIR/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "${FUNCTIONS}"
SOURCES=(
  # Version Managers
  "$HOME/.sdkman/bin/sdkman-init.sh"
  "$HOME/.jabba/jabba.sh"
  "$HOME/.nvm/nvm.sh"
  "$HOME/.gvm/scripts/gvm"
  # Utils
  "$DOTFILES_DIR/config/k8s/k8s.sh"
)
dynamic_batch_source "${SOURCES[@]}"

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
