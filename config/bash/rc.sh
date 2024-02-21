#!/bin/bash

# Constants
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"

export CORP_EXTRA_SCRIPTS_DIR="$HOME/.corp"
export SECRET_ENV="$HOME/.secret_env.sh"

export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin
export EDITOR="lvim"
export LANG="en_US.UTF-8"
export MISE_USE_TOML=1
export MISE_EXPERIMENTAL=1

MISE_FZF_BASE_DIR="$HOME/.local/share/mise/installs/fzf/latest/"
if [ -d "$MISE_FZF_BASE_DIR" ]; then
  # If the fzf installed with mise exists, we use it.
  export FZF_BASE="$MISE_FZF_BASE_DIR"
fi

if [ -s "$SECRET_ENV" ]; then
  source "${SECRET_ENV}"
fi

if [ -d "$CORP_EXTRA_SCRIPTS_DIR" ]; then
  find "$CORP_EXTRA_SCRIPTS_DIR" -type f -name "*.sh" -print0 | while IFS= read -r -d '' file; do
    source "$file"
  done
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
)
dynamic_batch_load_path "${BASE_PATHS[@]}"
