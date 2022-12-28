#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/files/scripts/functions.sh"
BUILD_DIR="$DOTFILES_DIR/files/build"
LVIM_UNINSTALL_SCRIPT="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/uninstall.sh"

function force_nvim_upgrade {
  info "uninstalling lvim"
  command -v lvim && (curl -s $LVIM_UNINSTALL_SCRIPT | bash)
  info "removing packer cache and reinstalling neovim and lunarvim"
  rm -rf ~/.local/share/nvim/site/pack/packer
  [[ -s "$BUILD_DIR/neovim.sh" ]] && source "$BUILD_DIR/neovim.sh"
  [[ -s "$BUILD_DIR/lvim.sh" ]] && source "$BUILD_DIR/lvim.sh"
}

force_nvim_upgrade

exit 0
