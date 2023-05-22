#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/scripts/utils/functions.sh"

LOCAL_DIR="$HOME/.local"
LOCAL_BUILD_DIR="$HOME/.local_build"
FONTS_DIR="$HOME/.local/share/fonts"

NVIM_CONFIG_ROOT="$DOTFILES_DIR/config/nvim"
NVIM_CONFIG="$HOME/.config/nvim"

function _neovim {
  info "installing neovim"
  git_clone_or_pull "$LOCAL_BUILD_DIR/neovim" https://github.com/neovim/neovim master
  (
    cd "$LOCAL_BUILD_DIR/neovim" || return
    rm -rf .deps build
    # shellcheck disable=2015
    make CMAKE_INSTALL_PREFIX="$LOCAL_DIR" CMAKE_BUILD_TYPE=Release -j4 -Wno-dev &&
      make CMAKE_INSTALL_PREFIX="$LOCAL_DIR" CMAKE_BUILD_TYPE=Release install || true
  )
  if [ -d "$NVIM_CONFIG_ROOT" ]; then
    create_symlink "$NVIM_CONFIG_ROOT" "$NVIM_CONFIG"
  fi
  info "installing vim-spell"
  if [ ! -f "$NVIM_CONFIG/spell/.done" ]; then
    SPELL_DIR="$NVIM_CONFIG/spell"
    if [ ! -d "$SPELL_DIR" ]; then
      mkdir -p "$SPELL_DIR"
    fi
    (
      cd "$SPELL_DIR" || return
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/en.* --timeout=5 || exit 1
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/pt.* --timeout=5 || exit 1
      touch .done
    )
  fi
}

function _ {
  _neovim "$@"
}

echo
set -x
"_${1}" "$@"
