#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/files/scripts/functions.sh"

LOCAL_DIR="$HOME/.local"
LOCAL_BUILD_DIR="$HOME/.local_build"
FONTS_DIR="$HOME/.local/share/fonts"
NVIM_CONFIG_ROOT="$DOTFILES_DIR/files/config/nvim"
NVIM_CONFIG="$HOME/.config/nvim"

function _fonts {
  info "installing fonts"
  if [ ! -d "$FONTS_DIR" ]; then
    mkdir -p "$FONTS_DIR"
  fi
  curl -sSL -o- \
    https://github.com/microsoft/vscode-codicons/blob/main/dist/codicon.ttf?raw=true \
    >"$FONTS_DIR/codicon.ttf"
  curl -sSL -o- \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf?raw=true \
    >"$FONTS_DIR/Hack Regular Nerd Font Complete.ttf"
  curl -sSL -o- \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf?raw=true \
    >"$FONTS_DIR/Inconsolata Nerd Font Complete.otf"
  curl -sSL -o- \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf?raw=true \
    >"$FONTS_DIR/Fira Code Regular Nerd Font Complete.ttf"
  fc-cache -fv
  gsettings set org.gnome.desktop.interface monospace-font-name 'Inconsolata Nerd Font 12'
}

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
  _fonts "$@"
  _neovim "$@"
}

echo
set -x
"_${1}" "$@"