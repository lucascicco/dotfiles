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

BREW_PACKAGES="$(get_packages "${PACKAGES_DIR}" brew)"
readonly BREW_PACKAGES

# Libs
function _packages {
  task "Brew" "installing packages"

  if ! command -v brew; then
    curl -ssL -o- "${BREW_INSTALL_SCRIPT_URL}" | bash
    reload_zsh
  fi

  brew install "${BREW_PACKAGES}"
  brew update
  brew upgrade
  brew autoremove
  brew cleanup
}

function _neovim {
  task "Neovim" "installing neovim"

  local file=${LOCAL_BUILD_DIR}/nvim.tar.gz
  local url=https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz

  if [ "$(download_file ${file} ${url})" == "1" ]; then
    rm -rf ${LOCAL_BUILD_DIR}/nvim-macos-arm64
    tar xzf ${file} -C ${LOCAL_BUILD_DIR}
    ln -sf ${LOCAL_BUILD_DIR}/nvim-macos-arm64/bin/nvim ${BIN_DIR}/nvim
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
  _gh "$@"
  _zsh "$@"
  _mise_reshim "$@"
}

"_${1}" "$@"
