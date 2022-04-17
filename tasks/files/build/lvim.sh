#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/tasks/files/scripts/functions.sh"

NVIM_BIN="$HOME/.local/bin/nvim"
LUNAR_VIM_BIN="$HOME/.local/bin/lvim"
LUNAR_VIM_CONFIG_ROOT="$DOTFILES/tasks/files/config/lvim/config.lua"
LUNAR_VIM_CONFIG="$HOME/.config/lvim/config.lua"

if [ -f $NVIM_BIN ] && [ ! -f $LUNAR_VIM_BIN ]; then
  set +x
  info "Installing lunar vim"
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
  create_symlink $LUNAR_VIM_CONFIG_ROOT $LUNAR_VIM_CONFIG
  set -x
fi

exit 0
