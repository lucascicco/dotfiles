#!/bin/bash

FUNCTIONS="$DOTFILES_DIR/scripts/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "$FUNCTIONS"

BOOTSTRAP_COMMONS="$HOME/dotfiles/scripts/bootstraping/commons.sh"
[[ -s "$BOOTSTRAP_COMMONS" ]] && source "$BOOTSTRAP_COMMONS"

# Libs
BREW_PACKAGES=(
  antigen
  # hyperkit
  # docker-machine-driver-hyperkit
  coreutils
  curl
  wget
  git
  haproxy
  htop
  jenv
  mercurial
  neovim
  nmap
  zsh
  gnu-sed # spectre.nvim
  pipx
  openssl
  readline
  sqlite3
  xz
  zlib
  tcl-tk
)
BREW_CASK_PACKAGES=(
  docker
  iterm2
  minishift
)

function _packages {
  task "Install and update common brew packages"
  if ! command -v brew; then
    curl -ssL -o- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
    reload_zsh
  fi
  brew update
  for BP in "${BREW_PACKAGES[@]}"; do
    brew_install_or_update "$BP"
  done
  for BCP in "${BREW_CASK_PACKAGES[@]}"; do
    brew_install_or_update "$BCP" cask
  done
  brew autoremove 
}

function _fonts {
  task "Install nerd fonts"
  brew tap homebrew/cask-fonts
  brew_install_or_update font-hack-nerd-font cask
  # NOTE: change the font on iTerm2 (LunarVim depends on it)
}

function _jenv {
  task "Install jenv"
  JENV_INSTALLED_VERSIONS=$(expr $(wc -l <<< "$(jenv versions)") - 1)
  if [[ $JENV_INSTALLED_VERSIONS -lt 2 ]]; then
    brew install --cask adoptopenjdk/openjdk/adoptopenjdk8
    jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
    brew install --cask adoptopenjdk/openjdk/adoptopenjdk11
    jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home/
    jenv global "$JAVA_DEFAULT_VERSION"
  fi
}

function _ {
  _symlinks "$@"
  # _packages "$@"
  _symlinks "$@"
  _fonts "$@"
  _jenv  "$@"
  _rtx "$@"
  _fonts "$@"
  _kubernetes_plugins "$@"
  _zsh "$@"
  _python_libs "$@"
  _golang_libs "$@"
  _node_libs "$@"
  _rust_libs "$@"
  _golang_libs "$@"
  _rust_libs "$@"
  _lunarvim "$@"
  _rtx_reshim "$@"
}

echo
set -x
"_${1}" "$@"
