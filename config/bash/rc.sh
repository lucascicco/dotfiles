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

# Telemetry/Analytics opt-out
export HOMEBREW_NO_ANALYTICS=1
export SAM_CLI_TELEMETRY=0
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export AZURE_CORE_COLLECT_TELEMETRY=0
export DO_NOT_TRACK=1 # Generic opt-out (respects by some tools)

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

opencode() {
  XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}${XDG_DATA_EXTRA:-}" mise exec opencode@latest -- opencode "${@}"
}

# Reload AI tools configuration
# Regenerates mise config and zsh plugins based on ai.toml
ai-reload() {
  local ai_script="${DOTFILES_DIR}/scripts/utils/ai.sh"
  if [[ ! -s "$ai_script" ]]; then
    echo "Error: ai.sh not found" >&2
    return 1
  fi

  source "$ai_script"

  echo "Reloading AI tools configuration..."
  print_ai_status

  # Regenerate mise config
  local mise_config="${HOME}/.config/mise/config.local.toml"
  write_mise_ai_config "$mise_config"

  # Regenerate zsh plugins
  local zsh_base="${DOTFILES_DIR}/config/zsh/zsh_plugins.base.txt"
  local zsh_target="${HOME}/.zsh_plugins.txt"
  if [[ -s "$zsh_base" ]]; then
    write_zsh_plugins "$zsh_base" "$zsh_target"
    # Clear antidote cache so changes take effect
    rm -f "${HOME}/.zsh_plugins.zsh"
  fi

  # Install mise tools if any AI tools enabled
  if any_ai_enabled; then
    echo "Installing mise tools..."
    mise install -y
  fi

  # Uninstall disabled AI tools from mise
  uninstall_disabled_ai_tools

  # Clean unused Neovim plugins (Lazy removes plugins not in spec)
  if command -v nvim &>/dev/null; then
    echo "Cleaning unused Neovim plugins..."
    nvim --headless "+Lazy! clean" +qa 2>/dev/null || true
  fi

  echo ""
  echo "Done! Restart your shell (exec zsh) for zsh plugin changes."
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
