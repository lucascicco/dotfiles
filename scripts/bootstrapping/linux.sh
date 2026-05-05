#!/bin/bash

readonly BOOTSTRAP_COMMON_SCRIPT_PATH="$HOME/.dotfiles/scripts/bootstrapping/common.sh"
if [[ -s "$BOOTSTRAP_COMMON_SCRIPT_PATH" ]]; then
  # shellcheck disable=1090
  source "$BOOTSTRAP_COMMON_SCRIPT_PATH"
else
  echo "Error: $BOOTSTRAP_COMMON_SCRIPT_PATH not found" >&2
  exit 1
fi

# Load base apt packages
APT_PACKAGES="$(tr '\n' ' ' <"${PACKAGES_DIR}/apt")"
readonly APT_PACKAGES

# Libs
function _packages {
  task "APT" "installing packages"

  info "APT packages: ${APT_PACKAGES}"

  sudo apt update --list-cleanup
  # shellcheck disable=2086
  sudo apt dist-upgrade --purge
  # shellcheck disable=2086
  sudo apt build-dep python3
  # shellcheck disable=2086
  sudo apt install --purge ${APT_PACKAGES}
  sudo apt autoremove --purge
  sudo apt clean
}

function _neovim {
  task "Neovim" "installing neovim"

  local arch
  arch="$(uname -m)"
  if [ "${arch}" = "aarch64" ] || [ "${arch}" = "arm64" ]; then
    arch="arm64"
  else
    arch="x86_64"
  fi
  download_executable \
    "${BIN_DIR}/nvim" \
    "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-${arch}.appimage"
}

function _ {
  _symlinks
  _create_core_dirs
  _packages
  _neovim
  _symlinks
  _nvim_spell
  _groovyls
  _fonts
  _mise
  _python
  _agents
  _zsh
  _mise_reshim
}

echo
set -x
"_${1}" "$@"
