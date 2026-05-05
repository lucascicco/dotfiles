#!/bin/bash

# CONSTANTS #

export DOTFILES_DIR="${HOME}/.dotfiles"
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

# git
export GIT_SSH=ssh
export GIT_USERS_DIR="$DOTFILES_DIR/config/git/users"
export GIT_CONFIG_FILE="$DOTFILES_DIR/config/git/gitconfig"

# paths
export PROJECT_HOME=${HOME}/projects
export GOBIN=${HOME}/.local/bin
export GOPATH=${HOME}/.go

# os
export EDITOR="nvim"
export LANG="en_US.UTF-8"

# mise
export MISE_USE_TOML=1

# dotfiles config (functions only; export_dotfiles_config called later from zshrc)
DOTFILES_CONFIG_SCRIPT="${DOTFILES_DIR}/scripts/utils/dotfiles.sh"
if [[ -s "$DOTFILES_CONFIG_SCRIPT" ]]; then
  source "$DOTFILES_CONFIG_SCRIPT"
fi

# xdg
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

export PERL_LOCAL_LIB_ROOT="${HOME}/.local/perl"
export PIP_REQUIRE_VIRTUALENV=true
export RIPGREP_CONFIG_PATH="$DOTFILES_DIR/config/rg/ripgreprc"
export PYTHON_CFLAGS="-march=native -mtune=native"
export PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-lto"

# safe
export SAFEHOUSE_ADD_DIRS="${HOME}/Downloads:${HOME}/.cache"
SAFEHOUSE_ADD_DIRS_RO="${HOME}/Library/Caches/Homebrew"
SAFEHOUSE_ADD_DIRS_RO+=":${HOME}/.gitconfig:${HOME}/.gitignore:${HOME}/.gitattributes"
[[ -e "${HOME}/.npmrc" ]] && SAFEHOUSE_ADD_DIRS_RO+=":${HOME}/.npmrc"
[[ -e "${HOME}/.dotfiles" ]] && SAFEHOUSE_ADD_DIRS_RO+=":${HOME}/.dotfiles"
SAFEHOUSE_ADD_DIRS_RO+=":/Applications/Ghostty.app"
export SAFEHOUSE_ADD_DIRS_RO
export SAFEHOUSE_TRUST_WORKDIR_CONFIG=1

SAFEHOUSE_ENABLE="docker,chromium-full,browser-native-messaging,ssh,shell-init,all-agents"

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
#

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
  local activate_path
  local current_dir

  # Check for existing virtual environment that matches current directory
  if [ -n "${VIRTUAL_ENV}" ] && [ -d "${VIRTUAL_ENV}" ] && [ -f "${VIRTUAL_ENV}/bin/activate" ]; then
    activate_path="${VIRTUAL_ENV}/bin/activate"
  fi

  # Search for venv in current and parent directories
  if [ -z "${activate_path}" ]; then
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      # Check common venv directory names
      for venv_dir in ".venv" "venv"; do
        if [ -f "$current_dir/$venv_dir/bin/activate" ]; then
          activate_path="$current_dir/$venv_dir/bin/activate"
          break 2
        fi
      done
      current_dir="$(dirname "$current_dir")"
    done
  fi

  # Check for Poetry environment (only if pyproject.toml exists to avoid slow calls)
  if [ -z "${activate_path}" ]; then
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
      if [ -f "$current_dir/pyproject.toml" ]; then
        if command -v poetry &>/dev/null && grep -q '\[tool\.poetry\]' "$current_dir/pyproject.toml" 2>/dev/null; then
          local poetry_venv
          poetry_venv=$(poetry env info --path -C "$current_dir" 2>/dev/null)
          if [ -n "${poetry_venv}" ] && [ -f "${poetry_venv}/bin/activate" ]; then
            activate_path="${poetry_venv}/bin/activate"
          fi
        fi
        break
      fi
      current_dir="$(dirname "$current_dir")"
    done
  fi

  if [ -n "${activate_path}" ] && [ -f "${activate_path}" ]; then
    # shellcheck disable=1090
    source "${activate_path}"
  fi

  nvim "${@}"
}

function safe() {
  safehouse --enable="${SAFEHOUSE_ENABLE}" --env -- "${@}"
}

function claude() {
  safe claude --dangerously-skip-permissions --plugin-dir "${DOTFILES_DIR}/agents" "${@}"
}

opencode() {
  safe npx opencode-ai@latest "${@}"
}

# Reload dotfiles configuration
# Regenerates zsh plugins based on dotfiles.yaml and updates mise
dotfiles-config-reload() {
  local dotfiles_script="${DOTFILES_DIR}/scripts/utils/dotfiles.sh"
  if [[ ! -s "$dotfiles_script" ]]; then
    echo "Error: dotfiles.sh not found" >&2
    return 1
  fi

  source "$dotfiles_script"

  echo "Reloading dotfiles configuration..."
  print_dotfiles_status

  # Export MISE_ENV based on profile
  export_dotfiles_config
  echo "MISE_ENV=${MISE_ENV:-<not set>}"

  # Regenerate zsh plugins (for wakatime, etc.)
  local zsh_base="${DOTFILES_DIR}/config/zsh/zsh_plugins.base.txt"
  local zsh_target="${HOME}/.zsh_plugins.txt"
  if [[ -s "$zsh_base" ]]; then
    write_zsh_plugins "$zsh_base" "$zsh_target"
    # Clear antidote cache so changes take effect
    rm -f "${HOME}/.zsh_plugins.zsh"
  fi

  # Install mise tools based on MISE_ENV
  echo "Installing mise tools..."
  mise install -y

  # Clean unused Neovim plugins (Lazy removes plugins not in spec)
  if command -v nvim &>/dev/null; then
    echo "Cleaning unused Neovim plugins..."
    nvim --headless "+Lazy! clean" +qa 2>/dev/null || true
  fi

  echo ""
  echo "Done! Restart your shell (exec zsh) for changes to take effect."
}

dotfiles-mise-lock() {
  if ! command -v mise &>/dev/null; then
    echo "Error: mise not found" >&2
    return 1
  fi

  local original_mise_env="${MISE_ENV-__UNSET__}"
  local original_mise_locked="${MISE_LOCKED-__UNSET__}"
  local lock_failed=0

  _dotfiles_mise_lock_for_env() {
    local env_value="$1"
    local label="$2"

    echo "Refreshing mise lock for ${label}..."
    if [[ -z "$env_value" ]]; then
      unset MISE_ENV
    else
      export MISE_ENV="$env_value"
    fi

    MISE_LOCKED=0 mise lock --global || return 1
    return 0
  }

  _dotfiles_mise_lock_for_env "" "restricted profile" || lock_failed=1
  [[ "$lock_failed" -eq 0 ]] && _dotfiles_mise_lock_for_env "ai" "ai environment" || lock_failed=1
  [[ "$lock_failed" -eq 0 ]] && _dotfiles_mise_lock_for_env "personal" "personal environment" || lock_failed=1
  [[ "$lock_failed" -eq 0 ]] && _dotfiles_mise_lock_for_env "ai,personal" "personal+ai profile" || lock_failed=1

  unset -f _dotfiles_mise_lock_for_env

  if [[ "$original_mise_env" == "__UNSET__" ]]; then
    unset MISE_ENV
  else
    export MISE_ENV="$original_mise_env"
  fi

  if [[ "$original_mise_locked" == "__UNSET__" ]]; then
    unset MISE_LOCKED
  else
    export MISE_LOCKED="$original_mise_locked"
  fi

  if [[ "$lock_failed" -ne 0 ]]; then
    echo "Error: Failed to refresh mise lock for one or more environments." >&2
    return 1
  fi

  echo "Done. Review and commit ~/.config/mise/mise.lock (repo: config/mise/mise.lock)."
}

aws_eks_kubeconfig_profiles_parallel() {
  local AWS_CONFIG_FILE="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
  local KUBECONFIG_FILE="${KUBECONFIG:-$HOME/.kube/config}"
  local LOCKFILE="/tmp/.kubeconfig.lock"
  local profiles regions clusters profile region cluster

  # Get all profiles using AWS CLI
  mapfile -t profiles < <(aws configure list-profiles)
  if [ ${#profiles[@]} -eq 0 ]; then
    echo "No profiles found."
    return 1
  fi

  # Backup and remove kubeconfig
  if [ -f "$KUBECONFIG_FILE" ]; then
    cp "$KUBECONFIG_FILE" "${KUBECONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    rm "$KUBECONFIG_FILE"
    echo "Backed up and removed $KUBECONFIG_FILE"
  fi

  # Function to process a single profile
  process_profile() {
    local profile="$1"
    local regions clusters region cluster
    echo "Processing profile: $profile"

    mapfile -t regions < <(aws ec2 describe-regions --profile "$profile" --query 'Regions[].RegionName' --output text 2>/dev/null)
    if [ ${#regions[@]} -eq 0 ]; then
      echo "No regions found for profile $profile, skipping..."
      return
    fi

    for region in "${regions[@]}"; do
      mapfile -t clusters < <(aws eks list-clusters --profile "$profile" --region "$region" --query 'clusters[]' --output text 2>/dev/null)
      for cluster in "${clusters[@]}"; do
        echo "Updating kubeconfig for cluster $cluster in region $region (profile $profile)"
        # Use flock to prevent concurrent writes
        flock "$LOCKFILE" aws eks update-kubeconfig \
          --profile "$profile" \
          --region "$region" \
          --name "$cluster" \
          --alias "${profile}-${cluster}-${region}"
      done
    done
  }

  export -f process_profile

  # Parallelize processing using background jobs
  for profile in "${profiles[@]}"; do
    process_profile "$profile" &
  done

  wait
  echo "All profiles processed in parallel."
}
