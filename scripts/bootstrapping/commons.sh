#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
BIN_DIR="${HOME}/bin"
LOCAL_DIR="$HOME/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
LOCAL_BUILD_DIR="$HOME/.local_build"

CONFIG_DIR="$DOTFILES_DIR/config"
FUNCTIONS="$DOTFILES_DIR/scripts/utils/functions.sh"
[[ -s "$FUNCTIONS" ]] && source "${FUNCTIONS}"
CONFIG_LVIM_DIR="$HOME/.config/lvim"
MISE_CONFIG="$HOME/.config/mise/"
MISE_BINARY="${HOME}/.local/bin/mise"
ZSH_SITE_FUNCTIONS="$HOME/.local/share/zsh/site-functions"

# LunarVim
LVIM_INSTALL_SCRIPT="https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh"
EXTRA_ARGS="--no-install-dependencies"
NVIM_SPELL_LANGUAGES=(
  "en"
  "pt"
)

PYTHON_LIBS=(
  black
  codespell
  djlint
  flake8
  ipdb
  ipython
  isort
  mypy
  pdm
  pipx
  poetry
  pre-commit
  ruff
  ruff-lsp
  tox
  yamlfix
  yamllint
)
PYTHON_INJECTIONS=(
  "poetry poetry-plugin-up"
  "ipython numpy pandas requests httpx openpyxl xlsxwriter"
)
GO_LIBS=(
  github.com/ipinfo/cli/ipinfo@latest
  github.com/sachaos/tcpterm@latest
  golang.stackrox.io/kube-linter/cmd/kube-linter@latest
  github.com/cheat/cheat/cmd/cheat@latest
)

mkdir -p "${BIN_DIR}"
mkdir -p "${LOCAL_DIR}"
mkdir -p "${LOCAL_BIN_DIR}"
mkdir -p "${LOCAL_BUILD_DIR}"
mkdir -p "${MISE_CONFIG}"
mkdir -p "${ZSH_SITE_FUNCTIONS}"

SYMLINKS=(
  "$CONFIG_DIR/git/gitattributes $HOME/.gitattributes"
  "$CONFIG_DIR/git/gitconfig $HOME/.gitconfig"
  "$CONFIG_DIR/git/gitignore $HOME/.gitignore"

  "$CONFIG_DIR/mise/config.toml $HOME/.config/mise/config.toml"
  "$CONFIG_DIR/mise/node-packages ${HOME}/.default-nodejs-packages"
  "$CONFIG_DIR/mise/rust-packages $HOME/.default-cargo-crates"
  "$CONFIG_DIR/mise/gcloud-components ${HOME}/.default-cloud-sdk-components"

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

function _mise {
  info "installing mise"
  if [ ! -f "${MISE_BINARY}" ]; then
    curl https://mise.jdx.dev/install.sh | sh
  fi

  eval "$("$MISE_BINARY" activate bash)"

  local -r today=$(date +%Y-%m-%d)
  local -r marker_file="${HOME}/.cache/mise-last-cache-clear"
  local -r last_run_date=$(cat "$marker_file")
  if [ ! -e "$marker_file" ] || [ "$last_run_date" != "$today"]; then
    "${MISE_BINARY}" cache clear
    echo "$today" >"$marker_file"
  fi

  "$MISE_BINARY" self-update || true
  "$MISE_BINARY" plugins update -y || true
  "$MISE_BINARY" install -y
  "$MISE_BINARY" upgrade -y
  "$MISE_BINARY" prune -y

  "$MISE_BINARY" complete -s zsh >"${ZSH_SITE_FUNCTIONS}/_mise"
}

function _gh {
  gh extension install github/gh-copilot
  gh extension upgrade --all
}

function _zsh {
  task "Install zsh plugins"
  ANTIGEN_SCRIPT_PATH="$HOME/antigen.zsh"
  if [[ ! -s "$ANTIGEN_SCRIPT_PATH" ]]; then
    (
      curl -L git.io/antigen >"$ANTIGEN_SCRIPT_PATH" &&
        chmod +x "$ANTIGEN_SCRIPT_PATH"
    )
    reload_zsh
  fi
  zsh -i -c "antigen cleanup"
  zsh -i -c "antigen update"
  zsh -i -c "antigen cache-gen"
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
    {
      cd "$CONFIG_LVIM_DIR/spell" || exit 1
      for L in "${NVIM_SPELL_LANGUAGES[@]}"; do
        debug "Spell check for language (${L}) is missing, downloading it..."
        wget -N -nv "ftp://ftp.vim.org/pub/vim/runtime/spell/${L}.*" --timeout=5 || exit 1
      done
      touch "$SPELL_DONE_FILE"
    }
  fi
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

function _mise_reshim {
  info "reshimming mise"
  "$MISE_BINARY" reshim
}
