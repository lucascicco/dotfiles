#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/scripts/utils/functions.sh"
BUILD_DIR="$DOTFILES_DIR/scripts/build"

function force_nvim_upgrade {
  task "Upgrade LunarVim"
  [[ -s "$BUILD_DIR/neovim.sh" ]] && source "$BUILD_DIR/neovim.sh"
  rm -rf ~/.local/share/nvim/site/pack/packer
  lvim +LvimUpdate +q
  lvim +PackerSync # NOTE: +Lazy sync for future updates on LunarVim
}

force_nvim_upgrade

exit 0
