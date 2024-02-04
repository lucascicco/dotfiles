#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
FUNCTIONS="$DOTFILES_DIR/scripts/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "${FUNCTIONS}"

BOOTSTRAP_COMMONS="$DOTFILES_DIR/scripts/bootstrapping/commons.sh"
[[ -s "$BOOTSTRAP_COMMONS" ]] && source "$BOOTSTRAP_COMMONS"

FONTS_DIR="${HOME}/.local/share/fonts"

# Libs
DNF_PACKAGES=(
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
  kubetail
  libbz2-dev
  libffi-dev
  liblzma-dev
  libncurses-dev
  libreadline-dev
  libsox-fmt-mp3
  libsqlite3-dev
  libssl-dev
  libtool-bin
  libwebkit2gtk-4.0-dev
  libxml2-dev
  libxmlsec1-dev
  libpcap-dev
  libsox-fmt-mp3
  lsb-release
  make
  mercurial
  meld
  ninja-build
  pipx
  python3-dev
  python3-pip
  python3-pynvim
  ncdu
  sed
  sox
  software-properties-common
  tmux
  tree
  vim
  zlib1g-dev
  zsh
  zsh-antigen
  xclip
)

function _packages {
  task "Install and update common dnf packages"
  sudo dnf upgrade -y
  sudo dnf install -y "${DNF_PACKAGES[@]}"
  sudo dnf autoremove -y
}

function _neovim {
  info "installing neovim"
  git_clone_or_pull "$LOCAL_BUILD_DIR/neovim" https://github.com/neovim/neovim master
  (
    cd "$LOCAL_BUILD_DIR/neovim" || return
    rm -rf .deps build
    make CMAKE_INSTALL_PREFIX="$LOCAL_BIN_DIR" CMAKE_BUILD_TYPE=Release -j4 -Wno-dev &&
      make CMAKE_INSTALL_PREFIX="$LOCAL_BIN_DIR" CMAKE_BUILD_TYPE=Release install || true
  )
}

function _fonts {
  info "installing fonts"
  [[ -d "${FONTS_DIR}" ]] || mkdir -p "${FONTS_DIR}"
  # Use dnf to install the required fonts
  sudo dnf install -y fira-code-fonts hack-fonts
  # Set the font if not already set
  if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 10'" ]; then
    gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 10'
  fi
}

function _ {
  _packages "$@"
  _neovim "$@"
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
  _lunarvim "$@"
  _neovim_spell_check "$@"
  _rtx_reshim "$@"
}

echo
set -x
"_${1}" "$@"
