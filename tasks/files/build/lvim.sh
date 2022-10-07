#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/tasks/files/scripts/functions.sh"

NVIM_BIN="$HOME/.local/bin/nvim"
LUNAR_VIM_BIN="$HOME/.local/bin/lvim"
LUNAR_VIM_CONFIG_ROOT="$DOTFILES_DIR/tasks/files/config/lvim/config.lua"
LUNAR_VIM_CONFIG="$HOME/.config/lvim/config.lua"

function _lvim {
  info "installing lvim"
  if [ ! -f $NVIM_BIN ]; then
    echo "Neovim binary not found, install it before proceeding with LunarVim installation"
    exit 1;
  fi
  LVIM_INSTALL_SCRIPT="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh"
  EXTRA_ARGS="--no-install-dependencies"
  bash <(curl -s $LVIM_INSTALL_SCRIPT) $EXTRA_ARGS
  create_symlink $LUNAR_VIM_CONFIG_ROOT $LUNAR_VIM_CONFIG
}

function _ {
  _lvim "$@"
}

echo
set -x
"_${1}" "$@"
exit 0
