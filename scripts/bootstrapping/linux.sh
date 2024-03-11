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
  dnsutils
  flatpak
  fonts-powerline
  g++
  gcc
  git
  gitk
  gitg
  gnupg
  inotify-tools
  iputils-ping
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
  net-tools
  ninja-build
  pipx
  python3-dev
  python3-pip
  python3-pynvim
  rsync
  ncdu
  netcat
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
  download_executable \
    "${BIN_DIR}/nvim" \
    https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
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

  if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 11'" ]; then
    gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
  fi
}

function _ {
  _packages "$@"
  _neovim "$@"
  _symlinks "$@"
  _fonts "$@"
  _mise "$@"
  _gh "$@"
  _zsh "$@"
  _python_libs "$@"
  _golang_libs "$@"
  _rust_libs "$@"
  _golang_libs "$@"
  _lunarvim "$@"
  _neovim_spell_check "$@"
  _mise_reshim "$@"
}

echo
set -x
"_${1}" "$@"
