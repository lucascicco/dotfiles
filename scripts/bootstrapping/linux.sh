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

APT_PACKAGES="$(get_packages "${PACKAGES_DIR}" apt)"
readonly APT_PACKAGES

# Libs
function _packages {
  task "APT" "installing packages"

  local -r extra_opts="-t unstable -y"

  sudo apt update --list-cleanup
  sudo apt dist-upgrade --purge
  # shellcheck disable=2086
  sudo apt dist-upgrade --purge ${extra_opts}
  # shellcheck disable=2086
  sudo apt build-dep python3 ${extra_opts}
  # shellcheck disable=2086
  sudo apt install --purge "${APT_PACKAGES[@]}" ${extra_opts}
  sudo apt autoremove --purge
  sudo apt clean
}

function _neovim {
  task "Neovim" "installing neovim"
  download_executable "${BIN_DIR}/nvim" "$NVIM_APP_IMAGE_URL"
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
  _python_libs "$@"
  _mise_reshim "$@"
}

echo
set -x
"_${1}" "$@"
