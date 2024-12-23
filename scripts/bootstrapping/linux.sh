#!/bin/bash

readonly BOOTSTRAP_COMMON_SCRIPT_PATH="$HOME/dotfiles/scripts/bootstrapping/common.sh"
if [[ -s "$BOOTSTRAP_COMMON_SCRIPT_PATH" ]]; then
  # shellcheck disable=1090
  source "$BOOTSTRAP_COMMON_SCRIPT_PATH"
else
  echo "Error: $BOOTSTRAP_COMMON_SCRIPT_PATH not found" >&2
  exit 1
fi

readonly NVIM_APP_IMAGE_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
readonly NVIM_BIN_PATH="${BIN_DIR}/nvim"

APT_PACKAGES="$(get_packages "${PACKAGES_DIR}" apt)"
readonly APT_PACKAGES
readonly ENABLE_UNSTABLE="${ENABLE_UNSTABLE:-false}"

# Libs
function _packages {
  task "APT" "installing packages"

  info "APT packages: ${APT_PACKAGES}"

  local apt_extra_options=""
  if [ "${ENABLE_UNSTABLE}" = "true" ]; then
    apt_extra_options="-t unstable"
  fi

  sudo apt update --list-cleanup
  sudo apt dist-upgrade --purge
  # shellcheck disable=2086
  sudo apt dist-upgrade --purge ${apt_extra_options}
  # shellcheck disable=2086
  sudo apt build-dep python3 ${apt_extra_options}
  # shellcheck disable=2086
  sudo apt install --purge ${apt_extra_options} ${APT_PACKAGES}
  sudo apt autoremove --purge
  sudo apt clean
}

function _neovim {
  task "Neovim" "installing neovim"

  download_executable "${NVIM_BIN_PATH}" "${NVIM_APP_IMAGE_URL}"
}

function _ {
  _symlinks "$@"
  _create_core_dirs "$@"
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
