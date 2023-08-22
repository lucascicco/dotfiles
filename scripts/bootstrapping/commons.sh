#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
LOCAL_BIN_DIR="$HOME/.local"
LOCAL_BUILD_DIR="$HOME/.local_build"
CONFIG_DIR="$DOTFILES_DIR/config"
FUNCTIONS="$DOTFILES_DIR/scripts/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "${FUNCTIONS}"
CONFIG_LVIM_DIR="$HOME/.config/lvim"
RTX_CONFIG="$HOME/.config/rtx/"

# LunarVim
LVIM_INSTALL_SCRIPT="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh"
EXTRA_ARGS="--no-install-dependencies"
NVIM_SPELL_DIRS=(
  "$HOME/.config/lvim/spell"
)
NVIM_SPELL_LANGUAGES=(
  "en"
  "pt"
)

PYTHON_LIBS=(
  awscli
  azure-cli
  black
  boto3
  cmake
  codespell
  flake8
  gcloud
  haproxy
  ipython
  isort
  mycli
  mypy
  net-tools
  nmap
  pgcli
  pip
  pipx
  pre-commit
  pynvim
  ruff
  ruff-lsp
  tcpdump
  tox
  tree
  wheel
  whois
  yamlfix
  yamllint
)
PYTHON_INJECTIONS=(
  "poetry poetry-plugin-up"
  "ipython numpy pandas requests httpx"
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
  github.com/hidetatz/kubecolor/cmd/kubecolor@latest
  github.com/ipinfo/cli/ipinfo@latest
  github.com/jesseduffield/lazydocker@latest
  github.com/jesseduffield/lazygit@latest
  github.com/mikefarah/yq/v4@latest
  github.com/sachaos/tcpterm@latest
  github.com/stern/stern@latest
  golang.stackrox.io/kube-linter/cmd/kube-linter@latest
  github.com/rhysd/actionlint/cmd/actionlint@latest
  github.com/digitalocean/doctl/cmd/doctl@latest
)

mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"
mkdir -p "${RTX_CONFIG}"

SYMLINKS=(
  "$CONFIG_DIR/git/gitattributes $HOME/.gitattributes"
  "$CONFIG_DIR/git/gitconfig $HOME/.gitconfig"
  "$CONFIG_DIR/git/gitignore $HOME/.gitignore"

  "$CONFIG_DIR/rtx/config.toml $HOME/.config/rtx/config.toml"
  "$CONFIG_DIR/rtx/node-packages $HOME/.default-nodejs-packages"
  "$CONFIG_DIR/rtx/rust-packages $HOME/.default-cargo-crates"

  "$CONFIG_DIR/zsh/zshrc $HOME/.zshrc"
  "$CONFIG_DIR/vim/vimrc $HOME/.vimrc"
)

function _symlinks {
  task "Update symlinks"
  for FILE in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${FILE}
  done
}

function _rtx {
  info "installing rtx"
  RTX_BINARY="${HOME}/.local/share/rtx/bin/rtx"
  if [ ! -f "${RTX_BINARY}" ]; then
    curl https://rtx.pub/install.sh | sh
  fi

  eval "$("${HOME}/.local/share/rtx/bin/rtx" activate bash)"
  "${HOME}/.local/share/rtx/bin/rtx" self-update
  "${HOME}/.local/share/rtx/bin/rtx" plugins update -a --install-missing
  "${HOME}/.local/share/rtx/bin/rtx" install
  "${HOME}/.local/share/rtx/bin/rtx" prune

  mkdir -p "${HOME}/.local/share/zsh/site-functions"
  "${HOME}/.local/share/rtx/bin/rtx" complete -s zsh >"${HOME}/.local/share/zsh/site-functions/_rtx"
}

function _zsh {
  task "Install zsh plugins"
  ANTIGEN_SCRIPT_PATH="$HOME/antigen.zsh"
  if [[ ! -s "$ANTIGEN_SCRIPT_PATH" ]]; then
    (
      brew reinstall antigen &&
        curl -L git.io/antigen >"$ANTIGEN_SCRIPT_PATH" &&
        chmod +x "$ANTIGEN_SCRIPT_PATH"
    )
    reload_zsh
  fi
  zsh -i -c "antigen cleanup"
  zsh -i -c "antigen update"
}

function _lunarvim {
  task "Install and update LunarVim"
  if command -v lvim; then
    lvim +LvimUpdate +q
    lvim --headless "+Lazy! sync" +qa
  else
    bash <(curl -s $LVIM_INSTALL_SCRIPT) $EXTRA_ARGS || exit 1
    # NOTE: Backup the config folder before removing it and symlink
    CURRENT_TIMESTAMP="$(date +%s)"
    /bin/cp -rf "$CONFIG_LVIM_DIR" "$CONFIG_LVIM_DIR.backup-$CURRENT_TIMESTAMP"
    rm -rf "$CONFIG_LVIM_DIR"
    create_symlink "$DOTFILES_DIR/lvim" "$CONFIG_LVIM_DIR"
  fi
}

function _neovim_spell_check {
  task "Download the spell check files for neovim"
  SPELL_DONE_FILE="$CONFIG_LVIM_DIR/spell/.done"
  if [[ -f "$SPELL_DONE_FILE" ]]; then
    info "Spell check is already downloaded, skipping it."
  else
    TEMP_DIR=$(mktemp -d)
    for L in "${NVIM_SPELL_LANGUAGES[@]}"; do
      set -x
      debug "Spell check for language (${L}) is missing, downloading it..."
      wget -N -nv "ftp://ftp.vim.org/pub/vim/runtime/spell/${L}.*" \
        --timeout=5 -P "$TEMP_DIR" || exit 1
      set +x
    done
    for D in "${NVIM_SPELL_DIRS[@]}"; do
      [[ -d "$D" ]] || mkdir -p "$D"
      # NOTE: default aliased to `cp -i`
      /bin/cp -rf "$TEMP_DIR/" "$D/"
    done
    touch "$SPELL_DONE_FILE"
  fi
}

function _kubernetes_plugins {
  task "Install and update kubernetes plugins with krew"
  KREW_INSTALLED=$(kubectl krew version)
  echo "$?"
  if [[ ! $KREW_INSTALLED ]]; then
    (
      set -x
      cd "$(mktemp -d)" &&
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

# Languages packages

function _python_libs {
  task "Install python libs"
  PP="${PYTHON_LIBS[*]}"
  for P in ${PP}; do
    pipx install "${P}"
  done

  for P in "${PYTHON_INJECTIONS[@]}"; do
    # shellcheck disable=2086
    pipx inject ${P}
  done

  pipx upgrade-all -f --include-injected

  info "installing debugpy latest version"
  if [ ! -f "${HOME}/.debugpy/bin/poetry" ]; then
    python3 -m venv "${HOME}/.debugpy"
  fi
  "${HOME}/.debugpy/bin/pip" install -U pip
  "${HOME}/.debugpy/bin/pip" install -U git+https://github.com/microsoft/debugpy.git@main
}

function _golang_libs {
  task "Install golang libs"
  for G in "${GO_LIBS[@]}"; do
    go install "$G"
  done
}

function _rust_libs {
  info "update rust libs"
  cargo install-update -a
}

function _node_libs {
  info "update node libs"
  npm update -g
}

function _rtx_reshim {
  info "reshimming rtx"
  "${HOME}/.local/share/rtx/bin/rtx" reshim
}
