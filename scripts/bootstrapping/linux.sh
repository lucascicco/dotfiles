#!/bin/bash

FUNCTIONS="$DOTFILES_DIR/scripts/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "${FUNCTIONS}"

BOOTSTRAP_COMMONS="$HOME/dotfiles/scripts/bootstrapping/commons.sh"
[[ -s "$BOOTSTRAP_COMMONS" ]] && source "$BOOTSTRAP_COMMONS"

FONTS_DIR="${HOME}/.local/share/fonts"

# Libs
APT_PACKAGES=(
  apt-transport-https
  automake
  autoconf
  bat
  binutils
  bison
  btop
  broot
  build-essential
  ca-certificates
  curl
  flatpak
  fonts-powerline
  g++
  gcc
  git
  gitk
  gitg
  gnupg
  htop
  libpcap-dev
  libtool-bin
  lsb-release
  make
  mercurial
  meld
  ninja-build
  ncdu
  redis
  redis-server
  sed
  software-properties-common
  tmux
  tree
  vim
  zsh
  zsh-antigen
  xclip
)

function _packages {
  task "Install and update common apt packages"
  EXTRA_OPTS="-t unstable"
  sudo apt update --list-cleanup
  sudo apt dist-upgrade --purge
  # shellcheck disable=2086
  sudo apt dist-upgrade --purge ${EXTRA_OPTS}
  # shellcheck disable=2086
  sudo apt build-dep python3 ${EXTRA_OPTS}
  # shellcheck disable=2086
  sudo apt install --purge "${APT_PACKAGES[@]}" ${EXTRA_OPTS}
  sudo apt autoremove --purge
  sudo apt clean
}

function _neovim {
  info "installing neovim"
  git_clone_or_pull "$LOCAL_BUILD_DIR/neovim" https://github.com/neovim/neovim master
  (
    cd "$LOCAL_BUILD_DIR/neovim" || return
    rm -rf .deps build
    # shellcheck disable=2015
    make CMAKE_INSTALL_PREFIX="$LOCAL_BIN_DIR" CMAKE_BUILD_TYPE=Release -j4 -Wno-dev &&
      make CMAKE_INSTALL_PREFIX="$LOCAL_BIN_DIR" CMAKE_BUILD_TYPE=Release install || true
  )
}

function _fonts {
  info "installing fonts"
  [[ -d "${FONTS_DIR}" ]] || mkdir -p "${FONTS_DIR}"
  download_file \
    "${FONTS_DIR}/codicon.ttf" \
    https://github.com/microsoft/vscode-codicons/blob/main/dist/codicon.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Hack Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Inconsolata Nerd Font Complete.otf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/InconsolataNerdFont-Regular.ttf?raw=true
  download_file \
    "${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf" \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf?raw=true

  if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 10'" ]; then
    gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 10'
  fi
}

function _ {
  _packages "$@"
  _symlinks "$@"
  _fonts "$@"
  _rtx "$@"
  _kubernetes_plugins "$@"
  _zsh "$@"
  _python_libs "$@"
  _golang_libs "$@"
  _node_libs "$@"
  _rust_libs "$@"
  _golang_libs "$@"
  _neovim "$@"
  _lunarvim "$@"
  _neovim_spell_check "$@"
  _rtx_reshim "$@"
}

echo
set -x
"_${1}" "$@"
