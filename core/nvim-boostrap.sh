#!/bin/bash

set -e

# Variables PATH
export NVIM_GTK_NO_HEADERBAR=1
export NVIM_GTK_PREFER_DARK_THEME=1

MY_DIR=$(dirname "${0}")
BASE_DIR=$(dirname "${MY_DIR}")

source "${DOTFILES_DIR}/utils/functions.sh"

LOCAL_DIR="${HOME}/.local"
LOCAL_BUILD_DIR="${HOME}/.local_build"

FONTS_DIR="${HOME}/.local/share/fonts"

NVIM_CONFIG="${HOME}/.config/nvim"
NVIM_BIN="${HOME}/.local/bin/nvim"

NVIM_SYM_LINK="${BASE_DIR}/vim ${HOME}/.config/nvim"

REQUIRED_APT_PACKAGES=(
  ninja-build
  gettext
  libtool
  libtool-bin
  autoconf
  automake
  cmake
  g++
  pkg-config
  unzip
  curl
  doxygen
)
LSP_NODE_LIBS=(
  bash-language-server
  dockerfile-language-server-nodejs
  eslint
  graphql
  graphql-language-service-cli
  neovim
  prettier
  pyright
  stylelint
  tree-sitter
  tree-sitter-cli
  ts-server
  typescript
  typescript-language-server
  vim-language-server
  vscode-langservers-extracted
  yaml-language-server
  yarn
)

function _neovim-apt-packages {
  EXTRA_OPTS="-t unstable"
  info "download required neovim apt packages"
  sudo apt install "${APT_PACKAGES[@]}" "${@}" -y
  info "apts all instaled..."
  sudo apt autoremove --purge
  sudo apt clean
}

function _nvim-sym-link {
  info "adding symlink for nvim"
  create_symlink ${NVIM_SYM_LINK}
}

function _fonts {
  info "installing fonts"
  curl -sSL -o- \
    https://github.com/microsoft/vscode-codicons/blob/main/dist/codicon.ttf?raw=true \
    >"${FONTS_DIR}/codicon.ttf"
  curl -sSL -o- \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf?raw=true \
    >"${FONTS_DIR}/Hack Regular Nerd Font Complete.ttf"
  curl -sSL -o- \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf?raw=true \
    >"${FONTS_DIR}/Inconsolata Nerd Font Complete.otf"
  curl -sSL -o- \
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf?raw=true \
    >"${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf"
  fc-cache -fv
  gsettings set org.gnome.desktop.interface monospace-font-name 'Inconsolata Nerd Font 12'
}

function _neovim {
  info "installing neovim"
  git_clone_or_pull "${LOCAL_BUILD_DIR}/neovim" https://github.com/neovim/neovim master
  # jellybeans-nvim
  (
    cd "${LOCAL_BUILD_DIR}/neovim"
    # shellcheck disable=2015
    make CMAKE_INSTALL_PREFIX="${LOCAL_DIR}" CMAKE_BUILD_TYPE=Release -j4 -Wno-dev &&
      make CMAKE_INSTALL_PREFIX="${LOCAL_DIR}" CMAKE_BUILD_TYPE=Release install || true
  )
  info "installing vim-spell"
  if [ ! -f "${NVIM_CONFIG}/spell/.done" ]; then
    (
      cd "${NVIM_CONFIG}/spell"
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/en.* --timeout=5 || exit 1
      wget -N -nv ftp://ftp.vim.org/pub/vim/runtime/spell/pt.* --timeout=5 || exit 1
      touch .done
    )
  fi
}

function _language-servers {
  info "installing stylua"
  git_clone_or_pull "${LOCAL_BUILD_DIR}/stylua" https://github.com/JohnnyMorganz/StyLua master
  (
    cd "${LOCAL_BUILD_DIR}/stylua"
    git pull origin master
    cargo install --path . 2>/dev/null
  )
  # lua-ls
  # sudo apt-get install ninja-build
  info "installing lua-ls"
  git_clone_or_pull \
    "${LOCAL_BUILD_DIR}/lua-language-server" https://github.com/sumneko/lua-language-server master
  (
    cd "${LOCAL_BUILD_DIR}/lua-language-server"
    cd 3rd/luamake
    ./compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild
  )
}

function _neovim-plugins {
  info "updating nvim plugins"
  ${NVIM_BIN} -c 'PackerSync'
  ${NVIM_BIN} --headless -c "TSUpdateSync" -c "sleep 100m | write! /tmp/ts.update.result | qall"
  cat /tmp/ts.update.result
};


function _lsp-node-libs {
  info "installing lsp node libs"
  set +x
  NODE_INSTALLED=$(
    npm list -g --depth=0 --parseable |
      sort | grep node_modules | grep -v npm | rev | cut -d'/' -f1 | rev
  )
  NP="${LSP_NODE_LIBS[*]}"
  for P in ${NP}; do
    if [ "${P}" = "npm" ]; then
      continue
    fi
    if [[ "$NODE_INSTALLED" != *"$P"* ]]; then
      set -x
      debug "${P} is missing, installing it..."
      npm -g i "$P"
      set +x
    fi
  done
  for I in $NODE_INSTALLED; do
    if [[ "${NP}" != *"$I"* ]]; then
      set -x
      debug "${I} should not be installed, uninstalling it..."
      npm -g uninstall "$I"
      set +x
    fi
  done
  set -x
  npm update -g
}

function _ {
  _neovim-apt-packages "$@"
  _nvim-sym-link "$@"
  _fonts "$@"
  _neovim "$@"
  _neovim-plugins "$@"
  _language-servers "$@"
  _lsp-node-libs "$@"
}

echo
set -x
"_${1}" "$@"
