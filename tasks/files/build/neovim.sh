#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/tasks/files/scripts/functions.sh"

LOCAL_DIR="$HOME/.local"
LOCAL_BUILD_DIR="$HOME/.local_build"
FONTS_DIR="$HOME/.local/share/fonts"
NVIM_CONFIG_ROOT="$DOTFILES_DIR/tasks/files/config/vim"
NVIM_CONFIG="$HOME/.config/nvim"
NVIM_BIN="$HOME/.local/bin/nvim"

function _fonts {
  info "installing fonts"
  if [ ! -d $FONTS_DIR ]; then
    mkdir -p $FONTS_DIR
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
    cd "$LOCAL_BUILD_DIR/neovim"
    # shellcheck disable=2015
    make CMAKE_INSTALL_PREFIX="$LOCAL_DIR" CMAKE_BUILD_TYPE=Release -j4 -Wno-dev &&
      make CMAKE_INSTALL_PREFIX="$LOCAL_DIR" CMAKE_BUILD_TYPE=Release install || true
  )
  if [ -d $NVIM_CONFIG_ROOT ]; then
    create_symlink $NVIM_CONFIG_ROOT $NVIM_CONFIG
  fi
  info "installing vim-spell"
  if [ ! -f "$NVIM_CONFIG/spell/.done" ]; then
    SPELL_DIR="$NVIM_CONFIG/spell"
    if [ ! -d $SPELL_DIR ]; then
      mkdir -p $SPELL_DIR
    fi
    (
      cd $SPELL_DIR
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/en.* --timeout=5 || exit 1
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/pt.* --timeout=5 || exit 1
      touch .done
    )
  fi
}

function _language-servers {
  # lua-ls
  info "installing lua-ls"
  git_clone_or_pull \
    "$LOCAL_BUILD_DIR/lua-language-server" https://github.com/sumneko/lua-language-server master
  (
    cd "$LOCAL_BUILD_DIR/lua-language-server"
    cd 3rd/luamake
    ./compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild
  )
  info "installing stylua"
  git_clone_or_pull "$LOCAL_BUILD_DIR/stylua" https://github.com/JohnnyMorganz/StyLua master
  (
    cd "$LOCAL_BUILD_DIR/stylua"
    git pull origin master
    cargo install --path . 2>/dev/null
  )
}

function _neovim-plugins {
  info "updating nvim plugins"
  $NVIM_BIN -c 'PackerSync'
  $NVIM_BIN --headless -c "TSUpdateSync" -c "sleep 100m | write! /tmp/ts.update.result | qall"
  cat /tmp/ts.update.result
};

function _ {
  _fonts "$@"
  _neovim "$@"
  # _neovim-plugins "$@"
  _language-servers "$@"
}

echo
set -x
"_${1}" "$@"
exit 0
