#!/bin/bash

# Constants
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"

readonly CORP_EXTRA_SCRIPTS_DIR="$HOME/.corp"
readonly SECRET_ENV_SCRIPT="$HOME/.secret_env.sh"
readonly FUNCTIONS_SCRIPT="$DOTFILES_SCRIPTS_DIR/utils/functions.sh"

export GIT_USERS_DIR="$DOTFILES_DIR/config/git/users"
export GITCONFIG_FILE="$DOTFILES_DIR/config/git/gitconfig"

export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin
export EDITOR="lvim"
export LANG="en_US.UTF-8"
export MISE_USE_TOML=1
export MISE_EXPERIMENTAL=1
export GPG_TTY=$(tty)

MISE_FZF_BASE_DIR="$HOME/.local/share/mise/installs/fzf/latest/"
if [ -d "$MISE_FZF_BASE_DIR" ]; then
  # If the fzf installed with mise exists, we use it.
  export FZF_BASE="$MISE_FZF_BASE_DIR"
fi

_load_source_files() {
  local -ra source_files=("$@")
  for file in "${source_files[@]}"; do
    if [ -s "$file" ]; then
      source "$file"
    fi
  done
}

_load_corp_extra_scripts() {
  if [ -d "$CORP_EXTRA_SCRIPTS_DIR" ]; then
    find "$CORP_EXTRA_SCRIPTS_DIR" -type f -name "*.sh" -print0 | while IFS= read -r -d '' file; do
      source "$file"
    done
  fi
}

_load_source_files "$SECRET_ENV_SCRIPT" "$FUNCTIONS_SCRIPT"
_load_corp_extra_scripts

# Functions
function bootstrap() { (
  set -e
  cd "$DOTFILES_DIR" || return
  git pull origin main || true
  bash "$DOTFILES_DIR/bootstrap.sh" "${@}"
); }

function switch_git_config() {
  switch_git_user "$GIT_USERS_DIR" "$GITCONFIG_FILE"
}

# Paths
BASE_PATHS=(
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
)
load_dynamic_paths "${BASE_PATHS[@]}"
export PATH
