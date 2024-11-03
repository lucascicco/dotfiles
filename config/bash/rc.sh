#!/bin/bash

# CONSTANTS #

export DOTFILES_DIR="$HOME/dotfiles"
export BOOTSTRAP_SCRIPTS_DIR="$DOTFILES_DIR/scripts/bootstrapping"
readonly FUNCTIONS_SCRIPT="${DOTFILES_DIR}/scripts/utils/functions.sh"
if [ -s "${FUNCTIONS_SCRIPT}" ]; then
  # shellcheck source=scripts/utils/functions.sh
  source "${FUNCTIONS_SCRIPT}"
else
  echo "Error: ${FUNCTIONS_SCRIPT} not found" >&2
  exit 1
fi

# scripts
readonly SECRET_ENV_SCRIPT="$HOME/.secret_env.sh"
readonly CORP_EXTRA_SCRIPTS_DIR="$HOME/.corp"

# paths
readonly -a SOURCE_SCRIPT_PATHS=(
  "$SECRET_ENV_SCRIPT"
)
readonly -a BASE_PATHS=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.krew/bin"
)

# EXPORTS #

# git
export GIT_SSH=ssh
export GIT_USERS_DIR="$DOTFILES_DIR/config/git/users"
export GIT_CONFIG_FILE="$DOTFILES_DIR/config/git/gitconfig"

# paths
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin

# os
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# mise
export MISE_USE_TOML=1
export MISE_EXPERIMENTAL=1

export PERL_LOCAL_LIB_ROOT="$HOME/.local/perl"
export PIP_REQUIRE_VIRTUALENV=true
export RIPGREP_CONFIG_PATH="$DOTFILES_DIR/config/rg/ripgreprc"
export PYTHON_CFLAGS="-march=native -mtune=native"
export PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-lto --enable-loadable-sqlite-extensions"

# Sources #

# gpg
GPG_TTY=$(tty)
export GPG_TTY

# fzf
readonly MISE_FZF_BASE_DIR="$HOME/.local/share/mise/installs/fzf/latest/"
if [ -d "$MISE_FZF_BASE_DIR" ]; then
  # If the fzf installed with mise exists, we use it.
  export FZF_BASE="$MISE_FZF_BASE_DIR"
fi

load_dynamic_paths "${BASE_PATHS[@]}"

export PATH

# SOURCES #

dynamic_batch_source "${SOURCE_SCRIPT_PATHS[@]}"
recursive_load_scripts "$CORP_EXTRA_SCRIPTS_DIR"

# FUNCTIONS #

bootstrap() {
  local -r current_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  local -r bootstrap_file="${BOOTSTRAP_SCRIPTS_DIR}/${current_os}.sh"

  if [ ! -s "$bootstrap_file" ]; then
    echo "[BOOTSTRAP] Error: $bootstrap_file not found" >&2
    return 1
  fi

  echo "[BOOTSTRAP] Bootstrap file: $bootstrap_file"

  git -C "$DOTFILES_DIR" pull origin main &&
    bash "$bootstrap_file" "${@}"
}

switch_git_config() {
  switch_git_user "$GIT_USERS_DIR" "$GIT_CONFIG_FILE"
}
