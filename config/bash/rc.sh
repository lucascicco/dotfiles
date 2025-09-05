#!/bin/bash

# CONSTANTS #

export DOTFILES_DIR="${HOME}/dotfiles"
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
readonly SECRET_ENV_SCRIPT="${HOME}/.secret_env.sh"
readonly CORP_EXTRA_SCRIPTS_DIR="${HOME}/.corp"

# paths
readonly -a SOURCE_SCRIPT_PATHS=(
  "$SECRET_ENV_SCRIPT"
)
readonly -a BASE_PATHS=(
  "${HOME}/.local/bin"
  "${HOME}/bin"
  "${HOME}/.krew/bin"
)

# EXPORTS #

# git
export GIT_SSH=ssh
export GIT_USERS_DIR="$DOTFILES_DIR/config/git/users"
export GIT_CONFIG_FILE="$DOTFILES_DIR/config/git/gitconfig"

# paths
export PROJECT_HOME=${HOME}/projects
export GOBIN=${HOME}/.local/bin

# os
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# mise
export MISE_USE_TOML=1
export MISE_EXPERIMENTAL=1
export MISE_PIPX_UVX=1

export PERL_LOCAL_LIB_ROOT="${HOME}/.local/perl"
export PIP_REQUIRE_VIRTUALENV=true
export RIPGREP_CONFIG_PATH="$DOTFILES_DIR/config/rg/ripgreprc"
export PYTHON_CFLAGS="-march=native -mtune=native"
export PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-lto"

# Sources #

# gpg
GPG_TTY=$(tty)
export GPG_TTY

# fzf
readonly MISE_FZF_BASE_DIR="${HOME}/.local/share/mise/installs/fzf"
if [ -d "$MISE_FZF_BASE_DIR" ] && [ -z "$FZF_BASE" ]; then
  latest_fzf_dir="$MISE_FZF_BASE_DIR/latest/"
  if [ ! -d "$latest_fzf_dir" ]; then
    all_fzf_subdirs="$(find "$MISE_FZF_BASE_DIR" -mindepth 1 -maxdepth 1 -type d)"
    sorted_fzf_subdirs="$(echo "$all_fzf_subdirs" | sort -V)"
    if [ -n "$sorted_fzf_subdirs" ] && [ ${#sorted_fzf_subdirs[@]} -gt 0 ]; then
      latest_fzf_dir="$(echo "$sorted_fzf_subdirs" | tail -n 1)"
    fi
  fi
  if [ -d "$latest_fzf_dir" ]; then
    export FZF_BASE="$latest_fzf_dir"
  fi
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

vi() {
  if [ -n "${VIRTUAL_ENV}" ] && [ -d "${VIRTUAL_ENV}" ] && [ -f "${VIRTUAL_ENV}/bin/activate" ]; then
    source "${VIRTUAL_ENV}/bin/activate"
  fi
  if command -v poetry &>/dev/null; then
    local poetry_venv
    poetry_venv=$(poetry env info --path -C "$(pwd)" 2>/dev/null)
    if [ -n "${poetry_venv}" ]; then
      source "${poetry_venv}/bin/activate"
    fi
  fi
  nvim "${@}"
}
