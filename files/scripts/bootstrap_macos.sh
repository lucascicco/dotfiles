#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
LOCAL_BIN_DIR="$HOME/.local"
LOCAL_BUILD_DIR="$HOME/.local_build"
CONFIG_DIR="$DOTFILES_DIR/files/config"
FUNCTIONS="$DOTFILES_DIR/files/scripts/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "$FUNCTIONS"

# Libs
BREW_PACKAGES=(
  antigen
  bat
  # hyperkit
  # docker-machine-driver-hyperkit
  curl
  wget
  fzf
  git
  haproxy
  htop
  jq
  jenv
  kubectl
  mercurial
  neovim
  nmap
  tfenv
  zsh
  gnu-sed # spectre.nvim

)
BREW_CASK_PACKAGES=(
  docker
  iterm2
  minishift
)
PYTHON_LIBS=(
  azure-cli
  black
  boto3
  cmake
  codespell
  debugpy
  flake8
  ipython
  isort
  numpy
  mycli
  pandas
  pip
  pre-commit
  pynvim
  pgcli
  tree
  wheel
  yamllint
)
NODE_LIBS=(
  corepack
  eslint
  graphql
  neovim
  pyright
  prettier
  tree-sitter-cli
  ts-node
  typescript
  ts-server
  yarn
  rimraf
)
KUBERNETES_PLUGINS=(
  ctx
  example
  ns
  popeye
  reap
  score
  sniff
  tree
)
GO_LIBS=(
  github.com/controlplaneio/kubesec/v2@latest
  github.com/instrumenta/kubeval@latest
  github.com/ipinfo/cli/ipinfo@latest
  github.com/jesseduffield/lazydocker@latest
  github.com/jesseduffield/lazygit@latest
  github.com/mikefarah/yq/v4@latest
  github.com/sachaos/tcpterm@latest
  github.com/stern/stern@latest
  golang.stackrox.io/kube-linter/cmd/kube-linter@latest
)
RUST_LIBS=(
  ripgrep
  fd-find
  broot
)
SYMLINKS=(
  "$CONFIG_DIR/git/gitattributes $HOME/.gitattributes"
  "$CONFIG_DIR/git/gitconfig $HOME/.gitconfig"
  "$CONFIG_DIR/git/gitignore $HOME/.gitignore"
  "$CONFIG_DIR/zsh/zshrc $HOME/.zshrc"
  "$CONFIG_DIR/vim/vimrc $HOME/.vimrc"
)

# Language versions
GO_DEFAULT_VERSION="go1.19"
PYTHON_DEFAULT_VERSION="${PYENV_VERSION:-3.10-dev}"
JAVA_DEFAULT_VERSION="openjdk64-11.0.0"

# LunarVim
LVIM_INSTALL_SCRIPT="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh"
EXTRA_ARGS="--no-install-dependencies"
NVIM_SPELL_DIRS=(
  "$HOME/.local/share/nvim/site/spell"
  "$HOME/.local/share/lunarvim/site"
)
NVIM_SPELL_LANGUAGES=(
  "en"
  "pt"
)

mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"

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
    brew_cask_install_or_update "$BCP"
  done
  brew autoremove 
}

function _symlinks {
  task "Update symlinks"
  for FILE in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${FILE}
  done
}

function _fonts {
  task "Install nerd fonts"
  brew tap homebrew/cask-fonts
  brew_cask_install_or_update font-hack-nerd-font
  # NOTE: change the font on iTerm2 (LunarVim depends on it)
}

function _zsh {
  task "Install zsh plugins"
  ANTIGEN_SCRIPT_PATH="$HOME/antigen.zsh"
  if [[ ! -s "$ANTIGEN_SCRIPT_PATH" ]]; then
  (
    brew reinstall antigen &&
    curl -L git.io/antigen > "$ANTIGEN_SCRIPT_PATH" &&
    chmod +x $ANTIGEN_SCRIPT_PATH
  )
  reload_zsh
  fi
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
  K8S_PLUGINS_INSTALLED=$(kubectl krew list | tail -n +2 | sort)
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

function _pyenv {
  task "Install pyenv"
  if [ ! -f "$HOME/.pyenv/bin/pyenv" ]; then
    curl -sSL -o- https://pyenv.run | bash
    reload_zsh
    pvenv install "$PYTHON_DEFAULT_VERSION"
    pvenv global "$PYTHON_DEFAULT_VERSION"
  fi
  zsh -i -c "pyenv update"
}

function _poetry {
  task "Install poetry"
  if [ ! -f "$HOME/.local/bin/poetry" ]; then
    curl -sSL https://install.python-poetry.org | python3 -
    reload_zsh
    poetry config virtualenvs.create true
    poetry config virtualenvs.in-project true
  fi
  poetry self update
}

function _python_libs {
  task "Install python libs"
  PIP_REQUIRE_VIRTUALENV=false pip3 install --user -U "${PYTHON_LIBS[@]}"
}

function _nvm {
  task "Install nvm"
  if [ ! -f "$HOME/.nvm/nvm.sh" ]; then
    curl -ssL -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    reload_zsh
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
    brew install go
    curl -ssL -o- https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
    reload_zsh
    gvm install "$GO_DEFAULT_VERSION"
    gvm use "$GO_DEFAULT_VERSION" --default
    brew uninstall go
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
    reload_zsh
  fi
  for R in "${RUST_LIBS[@]}"; do
    cargo install "$R"
  done
}

function _lunarvim {
  task "Install and update LunarVim"
  if command -v lvim; then
    rm -rf ~/.local/share/nvim/site/pack/packer
    lvim +LvimUpdate +q
    lvim +PackerSync # NOTE: +Lazy sync for future updates on LunarVim
  else
    bash <(curl -s $LVIM_INSTALL_SCRIPT) $EXTRA_ARGS
    create_symlink "$CONFIG_DIR/lvim" "$HOME/.config/lvim"
    TEMP_DIR=$(mktemp -d)
    for L in "${NVIM_SPELL_LANGUAGES[@]}"; do
      set -x
      debug "Spell check for language (${L}) is missing, downloading it..."
      wget -N -nv "ftp://ftp.vim.org/pub/vim/runtime/spell/$L.*" --timeout=5 -P "$TEMP_DIR" || exit 1
      set +x
    done
    for SD in "${NVIM_SPELL_DIRS[@]}"; do
      [[ -d "$SD" ]] || mkdir -p "$SD"
      # NOTE: default aliased to `cp -i`
      /bin/cp -rf "$TEMP_DIR" "$SD/"
    done
  fi
}

function _ {
  _packages "$@"
  _symlinks "$@"
  _fonts "$@"
  _kubernetes_plugins "$@"
  _zsh "$@"
  _poetry "$@"
  _jenv "$@"
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
