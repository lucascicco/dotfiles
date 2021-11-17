#!/bin/bash

set -e

MY_DIR=$(dirname "${0}")
BASE_DIR=$(dirname "${MY_DIR}")
source "${MY_DIR}/funcs.sh"

LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
LOCAL_BUILD_DIR="${HOME}/.local_build"
APT_PACKAGES=(
  nmap
  tcpdump
  haproxy
  redis
  redis-server
  flatpak
  build-essential
  fzf
  git
  gitg
  meld
  zsh
  zsh-antigen
)
PYTHON_LIBS=(
  pre-commit
  cmake
  flake8
  pip
)
NODE_LIBS=(
  bash-language-server
  corepack
  create-react-native-app
  dockerfile-language-server-nodejs
  eslint
  expo-cli
  fixjson
  graphql
  graphql-language-service-cli
  npm
  opencollective
  patch-package
  prettier
  pyright
  react-native-cli
  tree-sitter
  tree-sitter-cli
  ts-server
  ts-node
  typescript
  typescript-language-server
  yaml-language-server
  yarn
)
SYMLINKS=(
  "${BASE_DIR}/git/gitattributes ${HOME}/.gitattributes"
  "${BASE_DIR}/git/gitconfig ${HOME}/.gitconfig"
  "${BASE_DIR}/git/gitignore ${HOME}/.gitignore"
  "${BASE_DIR}/git/gitignore ${HOME}/.gitignore"
  "${BASE_DIR}/zsh/zshrc ${HOME}/.zshrc"
)

[ -d "${BASE_DIR}" ] || exit 1
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"

function _system {
  EXTRA_OPTS="-t unstable"
  info "updating the system"
  sudo apt update --list-cleanup
  # shellcheck disable=2086
  sudo apt dist-upgrade --purge "$@"
  # shellcheck disable=2086
  sudo apt install "${APT_PACKAGES[@]}" "${@}" -y
  info "apts all instaled..."
  sudo flatpak update
  sudo flatpak uninstall --unused
  sudo apt autoremove --purge
  sudo apt clean
}

function _symlinks {
  info "updating symlinks"
  for FILE in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${FILE}
  done
}

function _zsh {
  if [ ! -f "${HOME}/.antigen.zsh" ]; then
     curl -L git.io/antige > antigen.zsh
  fi
  info "installing zsh plugins"
  zsh -i -c "antigen cleanup"
  zsh -i -c "antigen update"
}

function _poetry {
  info "installing poetry"
  if [ ! -f "${HOME}/.poetry/bin/poetry" ]; then
    curl -sSL -o- https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
    # poetry config virtualenvs.create true
    # poetry config virtualenvs.in-project true
  fi
  # poetry self update
}

function _nvm {
  info "installing nvm"
  if [ ! -f "${HOME}/.nvm/nvm.sh" ]; then
    curl -ssL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    nvm install 16
    nvm use 16
    nvm alias default 16
  fi
  zsh -i -c "nvm upgrade"
}

function _node-libs {
  info "installing node libs"
  set +x
  NODE_INSTALLED=$(
    npm list -g --depth=0 --parseable |
      sort | grep node_modules | grep -v npm | rev | cut -d'/' -f1 | rev
  )
  NP="${NODE_LIBS[*]}"
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
  _system "$@"
  _symlinks "$@"
  _zsh "$@"
  _poetry "$@"
  _nvm "$@"
  _node-libs "$@"
}

echo
set -x
"_${1}" "$@"