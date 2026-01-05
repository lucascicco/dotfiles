#!/bin/bash

readonly BOOTSTRAP_COMMON_SCRIPT_PATH="$HOME/dotfiles/scripts/bootstrapping/common.sh"
if [[ -s "$BOOTSTRAP_COMMON_SCRIPT_PATH" ]]; then
  # shellcheck disable=1090
  source "$BOOTSTRAP_COMMON_SCRIPT_PATH"
else
  echo "Error: $BOOTSTRAP_COMMON_SCRIPT_PATH not found" >&2
  exit 1
fi

readonly BREW_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Load brew packages based on profile
# Priority: 1. DOTFILES_PROFILE env var  2. ~/.config/dotfiles/ai.toml [dotfiles] profile
# Options: "" (full), "core" (minimal), "corporate" (corporate-safe)
# Supports cask: prefix for GUI apps/fonts (e.g., cask:ghostty)
_get_dotfiles_profile() {
  # 1. Check environment variable
  [[ -n "${DOTFILES_PROFILE:-}" ]] && echo "$DOTFILES_PROFILE" && return

  # 2. Check local config file
  local config_file="${HOME}/.config/dotfiles/ai.toml"
  [[ ! -f "$config_file" ]] && return

  local in_dotfiles=false line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue

    if [[ "$line" == "["*"]" ]]; then
      [[ "$line" == "[dotfiles]" ]] && in_dotfiles=true || in_dotfiles=false
      continue
    fi

    if [[ "$in_dotfiles" == true ]] && [[ "$line" == *"="* ]]; then
      key="${line%%=*}" && key="${key// /}"
      value="${line#*=}" && value="${value## }" && value="${value%% }"
      value="${value//\"/}" # Remove quotes
      [[ "$key" == "profile" && -n "$value" ]] && echo "$value" && return
    fi
  done <"$config_file"
}

_parse_brew_packages() {
  local package_file="$1"
  local formulas="" casks=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue

    if [[ "$line" == cask:* ]]; then
      casks="${casks} ${line#cask:}"
    else
      formulas="${formulas} ${line}"
    fi
  done <"$package_file"

  echo "FORMULAS=${formulas}"
  echo "CASKS=${casks}"
}

DOTFILES_PROFILE="$(_get_dotfiles_profile)"
if [[ -n "$DOTFILES_PROFILE" && -f "${PACKAGES_DIR}/brew.${DOTFILES_PROFILE}" ]]; then
  eval "$(_parse_brew_packages "${PACKAGES_DIR}/brew.${DOTFILES_PROFILE}")"
  # shellcheck disable=SC2153
  BREW_PACKAGES="$FORMULAS"
  # shellcheck disable=SC2153
  BREW_CASKS="$CASKS"
  info "Using brew profile: ${DOTFILES_PROFILE}"
else
  eval "$(_parse_brew_packages "${PACKAGES_DIR}/brew")"
  # shellcheck disable=SC2153
  BREW_PACKAGES="$FORMULAS"
  # shellcheck disable=SC2153
  BREW_CASKS="$CASKS"
  info "Using brew profile: full (default)"
fi
readonly BREW_PACKAGES
readonly BREW_CASKS

# Libs
function _packages {
  task "Brew" "installing packages"

  if ! command -v brew &>/dev/null; then
    curl -fsSL -o- "${BREW_INSTALL_SCRIPT_URL}" | bash
    eval "$(/opt/homebrew/bin/brew shellenv)"
    reload_zsh
  fi

  # Install formulas
  if [[ -n "${BREW_PACKAGES// /}" ]]; then
    # shellcheck disable=2086
    brew install ${BREW_PACKAGES}
  fi

  # Install casks (GUI apps, fonts)
  if [[ -n "${BREW_CASKS// /}" ]]; then
    # shellcheck disable=2086
    brew install --cask ${BREW_CASKS}
  fi

  brew update
  brew upgrade
  brew autoremove
  brew cleanup
}

function _neovim {
  task "Neovim" "installing neovim"

  local -r file=${LOCAL_BUILD_DIR}/nvim.tar.gz
  local -r url=https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz

  if [ "$(download_file "${file}" "${url}")" == "1" ]; then
    rm -rf "${LOCAL_BUILD_DIR}/nvim-macos-arm64"
    tar xzf "${file}" -C "${LOCAL_BUILD_DIR}"
    ln -sf "${LOCAL_BUILD_DIR}/nvim-macos-arm64/bin/nvim" "${BIN_DIR}/nvim"
  fi
}

function _ {
  _create_core_dirs "$@"
  _symlinks "$@"
  _packages "$@"
  _neovim "$@"
  _neovim_spell_check "$@"
  _symlinks "$@"
  _fonts "$@"
  _mise "$@"
  _zsh "$@"
  _mise_reshim "$@"
}

"_${1}" "$@"
