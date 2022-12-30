#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
LOCAL_BIN_DIR="$HOME/.local"
LOCAL_BUILD_DIR="$HOME/.local_build"

CONFIG_DIR="$DOTFILES_DIR/files/config"
FUNCTIONS="$DOTFILES_DIR/files/scripts/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "$FUNCTIONS"

BREW_PACKAGES=(
  git
  htop
  fzf
  bat
  "docker --cast"
  kubectl
  go
  jq
  neovim
  mercurial
  antigen
  nmap
  haproxy
  tfenv
)
PYTHON_LIBS=(
  black
  cmake
  codespell
  debugpy
  flake8
  ipython
  isort
  numpy
  pandas
  pip
  precommit
  pynvim
  wheel
  yamllint
  boto3
  mycli
  pgcli
  azurecli
)
NODE_LIBS=(
  neovim
  tree-sitter-cli
  corepack
  ts-node
  typescript
  yarn
  eslint
  graphql
  prettier
)
KUBERNETES_PLUGINS=(
  popeye
  ns
  ctx
  score
  example
  sniff
  tree
  reap
)
GO_LIBS=(
  golang.stackrox.io/kube-linter/cmd/kube-linter@latest
  github.com/ipinfo/cli/ipinfo@latest
  github.com/jesseduffield/lazygit@latest
  github.com/jesseduffield/lazydocker@latest
  github.com/sachaos/tcpterm@latest
  github.com/instrumenta/kubeval@latest
  github.com/mikefarah/yq/v4@latest
  github.com/stern/stern@latest
  github.com/controlplaneio/kubesec/v2@latest
)
RUST_LIBS=(
  ripgrep
  fd-find
)
SYMLINKS=(
  "$CONFIG_DIR/git/gitattributes $HOME/.gitattributes"
  "$CONFIG_DIR/git/gitconfig $HOME/.gitconfig"
  "$CONFIG_DIR/git/gitignore $HOME/.gitignore"
  "$CONFIG_DIR/zsh/zshrc $HOME/.zshrc"
)
GO_DEFAULT_VERSION="go1.19"

mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"

function _packages {
  task "Install and update common brew packages"
  brew update
  for BP in "${BREW_PACKAGES[@]}"; do
    brew_install_or_update "$BP"
  done
  brew autoremove 
}

function _symlinks {
  info "updating symlinks"
  for FILE in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${FILE}
  done
}

function _fonts {
  task "Install nerd fonts"
  brew tap homebrew/cask-fonts
  brew_install_or_update font-hack-nerd-font
  # NOTE: change the font on iTerm2
}

function _zsh {
  task "Install zsh plugins"
  zsh -i -c "antigen cleanup"
  zsh -i -c "antigen update"
}

function _kubernetes_plugins {
  task "Install and update kubernetes plugins with krew"
  KREW_INSTALLED=$(kubectl krew version); echo "$?"
  if [[ ! $KREW_INSTALLED ]]; then
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
  fi
  K8S_PLUGINS_INSTALLED=$(kubectl krew list | sort)
  for PLG in "${KUBERNETES_PLUGINS[@]}"; do
    if [[ "$K8S_PLUGINS_INSTALLED" != *"$PLG"* ]]; then
      set -x
      debug "Installing $PLG since it's missing on system"
      kubectl krew install "$PLG"
      continue
      set +x
    fi
    kubectl krew upgrade "$PLG"
  done
}

function _poetry {
  info "Install poetry"
  if [ ! -f "$HOME/.poetry/bin/poetry" ]; then
    curl -sSL -o- https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
    poetry config virtualenvs.create true
    poetry config virtualenvs.in-project true
  fi
  poetry self update
}

function _pyenv {
  task "Install pyenv"
  if [ ! -f "$HOME/.pyenv/bin/pyenv" ]; then
    curl -sSL -o- https://pyenv.run | bash
  fi
}

function _python_libs {
  task "Install python libs"
  PIP_REQUIRE_VIRTUALENV=false pip install --user -U "${PYTHON_LIBS[@]}"
}

function _nvm {
  task "Install nvm"
  if [ ! -f "$HOME/.nvm/nvm.sh" ]; then
    curl -ssL -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    nvm install --lts
    nvm use --lts
    nvm alias default --lts
  fi
}

function _node_libs {
  task "Install node libs"
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
  set -x
  npm update -g
}

function _gvm {
  task "Install gvm"
  if [ ! -f "$HOME/.gvm/scripts/gvm" ]; then
    curl -ssL -o- https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
    export GOROOT_BOOTSTRAP=$(which go)
    gvm install "$GO_DEFAULT_VERSION"
    gvm use "$GO_DEFAULT_VERSION"
  fi
}

function _golang_libs {
  task "Install golang libs"
  for G in "${GO_LIBS[@]}"; do
    go install "$G"
  done
}

function _rust {
  task "Install rust"
  if [ ! -d "$HOME/.cargo/bin" ]; then
    curl https://sh.rustup.rs -sSf | sh
  fi
  for R in "${RUST_LIBS[@]}"; do
    cargo install "$R"
  done
}

function _lunarvim {
  task "Install and update LunarVim"
  if command -v lvim; then
    lvim +LvimUpdate +q
    rm -rf ~/.local/share/nvim/site/pack/packer
    lvim +PackerSync # NOTE: +Lazy sync for future updates on LunarVim
  else
    LVIM_INSTALL_SCRIPT="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh"
    EXTRA_ARGS="--no-install-dependencies"
    bash <(curl -s $LVIM_INSTALL_SCRIPT) $EXTRA_ARGS
    create_symlink "$CONFIG_DIR/lvim/config.lua $HOME/.config/lvim/config.lua"
  fi
}

function _ {
  _packages "$@"
  _symlinks "$@"
  _fonts "$@"
  _kubernetes_plugins "$@"
  _zsh "$@"
  _poetry "$@"
  _pyenv "$@"
  _python_libs "$@"
  _nvm "$@"
  _node_libs "$@"
  _gvm "$@"
  _golang_libs "$@"
  _rust "$@"
  _lunarvim "$@"
}

echo
set -x
"_${1}" "$@"
