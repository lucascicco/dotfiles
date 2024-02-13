#!/bin/bash

FUNCTIONS="$DOTFILES_DIR/scripts/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "$FUNCTIONS"

BOOTSTRAP_COMMONS="$HOME/dotfiles/scripts/bootstrapping/commons.sh"
[[ -s "$BOOTSTRAP_COMMONS" ]] && source "$BOOTSTRAP_COMMONS"

# Libs
BREW_PACKAGES=(
  antigen
  bat
  btop
  cpanminus
  curl
  exa
  fzf
  git
  gnu-sed
  htop
  jq
  libffi
  libtool
  md5sha1sum
  ninja
  openssl
  orbstack
  pipx
  readline
  mise
  sqlite
  universal-ctags
  watchman
  wget
  xmlsectool
  xz
  zlib
  zsh
)

function _packages {
  task "Install and update common brew packages"
  if ! command -v brew; then
    curl -ssL -o- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
    reload_zsh
  fi
  brew install "${BREW_PACKAGES[@]}"
  brew update
  brew upgrade
  brew autoremove
  brew cleanup
}

function _neovim {
  info "installing neovim"
  brew install --HEAD neovim
  brew upgrade neovim --fetch-HEAD
}

function _fonts {
  task "Install nerd fonts"
  brew tap homebrew/cask-fonts
  brew_install_or_upgrade font-hack-nerd-font cask
  # NOTE: change the font on iTerm2 (LunarVim depends on it)
}

function _ {
  _symlinks "$@"
  _packages "$@"
  _neovim "$@"
  _symlinks "$@"
  _fonts "$@"
  _mise "$@"
  _zsh "$@"
  _python_libs "$@"
  _golang_libs "$@"
  _rust_libs "$@"
  _golang_libs "$@"
  _rust_libs "$@"
  _lunarvim "$@"
  _neovim_spell_check "$@"
  _mise_reshim "$@"
}

echo
set -x
"_${1}" "$@"
