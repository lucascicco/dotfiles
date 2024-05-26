#!/bin/bash

export DOTFILES_DIR="${HOME}/dotfiles"
export DOTFILES_CONFIG_DIR="${DOTFILES_DIR}/config"
export PACKAGES_DIR="${DOTFILES_CONFIG_DIR}/packages"

readonly FUNCTIONS_SCRIPTS="${DOTFILES_DIR}/scripts/utils/functions.sh"
if [ -s "${FUNCTIONS_SCRIPTS}" ]; then
  # shellcheck source=scripts/utils/functions.sh
  source "${FUNCTIONS_SCRIPTS}"
else
  echo "Error: ${FUNCTIONS_SCRIPTS} not found" >&2
  exit 1
fi

# Binaries directories
readonly BIN_DIR="${HOME}/bin"
readonly LOCAL_DIR="${HOME}/.local"
readonly LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
readonly LOCAL_BUILD_DIR="${HOME}/.local_build"

# Neovim
readonly NVIM_SOURCE_DIR="${DOTFILES_DIR}/nvim"

readonly NVIM_SPELL_URL="ftp://ftp.vim.org/pub/vim/runtime/spell"
readonly NVIM_SPELL_DIR="${NVIM_SOURCE_DIR}/spell"
readonly DOWNLOADED_SPELL_FILE="${NVIM_SPELL_DIR}/.downloaded"

# Mise
readonly MISE_CONFIG_DIR="${HOME}/.config/mise"
MISE_BINARY="$(get_mise_binary_path)"
readonly MISE_BINARY

# ZSH
readonly ZSH_SITE_FUNCTIONS_DIR="${HOME}/.local/share/zsh/site-functions"
readonly ANTIGEN_SCRIPT_PATH="${HOME}/antigen.zsh"

# Symlinks
readonly -a SYMLINKS=(
  "$DOTFILES_CONFIG_DIR/git/gitattributes $HOME/.gitattributes"
  "$DOTFILES_CONFIG_DIR/git/gitconfig $HOME/.gitconfig"
  "$DOTFILES_CONFIG_DIR/git/gitignore $HOME/.gitignore"

  "$DOTFILES_CONFIG_DIR/mise/config.toml $HOME/.config/mise/config.toml"
  "$DOTFILES_CONFIG_DIR/mise/node-packages ${HOME}/.default-nodejs-packages"
  "$DOTFILES_CONFIG_DIR/mise/rust-packages $HOME/.default-cargo-crates"
  "$DOTFILES_CONFIG_DIR/mise/gcloud-components ${HOME}/.default-cloud-sdk-components"

  "$NVIM_SOURCE_DIR} ${HOME}/.config/nvim"

  "$DOTFILES_CONFIG_DIR/zsh/zshrc $HOME/.zshrc"
  "$DOTFILES_CONFIG_DIR/vim/vimrc $HOME/.vimrc"
)

readonly -a CORE_DIRS=(
  "${BIN_DIR}"
  "${LOCAL_DIR}"
  "${LOCAL_BIN_DIR}"
  "${LOCAL_BUILD_DIR}"
  "${MISE_CONFIG_DIR}"
  "${ZSH_SITE_FUNCTIONS_DIR}"
)

MACHINE_OS="$(uname -s)"
readonly MACHINE_OS

function _create_core_dirs {
  task "Core directories" "Creating core directories"

  for dir in "${CORE_DIRS[@]}"; do
    if [ ! -d "${dir}" ]; then
      mkdir -p "${dir}"
    fi
  done
}

function _symlinks {
  task "Symlinks" "Creating symlinks"

  for sfile in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${sfile}
  done
}

function _mise {
  task "Mise" "Installing mise"

  local -r mise_binary="${MISE_BINARY}"

  if [ "${MACHINE_OS}" = "Linux" ]; then
    if [ ! -f "${mise_binary}" ]; then
      curl https://mise.run | sh
    fi
  fi

  eval "$("$mise_binary" activate bash)"

  local -r today=$(date +%Y-%m-%d)
  local -r marker_file="${HOME}/.cache/mise-last-cache-clear"
  local -r last_run_date=$(cat "$marker_file")
  if [ ! -e "$marker_file" ] || [ "$last_run_date" != "$today" ]; then
    "${mise_binary}" cache clear
    echo "$today" >"$marker_file"
  fi

  if [ "${MACHINE_OS}" = "Linux" ]; then
    "${mise_binary}" self-update || true
  fi

  "$mise_binary" plugins update -y || true
  "$mise_binary" install -y
  "$mise_binary" upgrade -y
  "$mise_binary" prune -y

  mkdir -p "${HOME}/.local/share/zsh/site-functions"
  "$mise_binary" complete -s zsh >"${ZSH_SITE_FUNCTIONS_DIR}/_mise"
}

function _mise_reshim {
  task "Mise" "Reshimming mise"

  "$MISE_BINARY" reshim
}

function _gh {
  task "Git Hub" "Installing gh extensions"

  gh extension install github/gh-copilot
  gh extension upgrade --all
}

function _zsh {
  task "Zsh" "Installing zsh"

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

function _python_libs {
  task "Python" "Installing python libraries"

  if [ ! -f "${HOME}/.debugpy/bin/python3" ]; then
    python3 -m venv "${HOME}/.debugpy"
  fi

  "${HOME}/.debugpy/bin/pip" install -U pip
  "${HOME}/.debugpy/bin/pip" install -U git+https://github.com/microsoft/debugpy.git@main
}

function _neovim_spell_check {
  task "Neovim" "Downloading spell check files"

  _download_spell_files() {
    local -r spell_lang="${1}"

    local -r spell_dir="${2:-$NVIM_SPELL_DIR}"
    local spell_url="${3:-$NVIM_SPELL_URL}"

    if [ -n "${spell_lang}" ]; then
      spell_url="${spell_url}/${spell_lang}.*"
    fi

    if [ ! -d "${spell_dir}" ]; then
      mkdir -p "${spell_dir}"
    fi

    wget -N -nv "${spell_url}" --directory-prefix="${spell_dir}" --timeout=5
    return $?
  }

  if [ ! -f "${DOWNLOADED_SPELL_FILE}" ]; then
    (
      _download_spell_files en || exit 1
      _download_spell_files pt || exit 1
      touch "${DOWNLOADED_SPELL_FILE}"
    )
  fi
}

function _fonts {
  task "Fonts" "Downloading fonts"

  local fonts_dir="${HOME}/.local/share/fonts"
  if [ "${MACHINE_OS}" == "Darwin" ]; then
    fonts_dir="${HOME}/Library/Fonts"
  fi

  [[ -d "${fonts_dir}" ]] || mkdir -p "${fonts_dir}"

  local -r nerd_fonts_repo="https://github.com/ryanoasis/nerd-fonts/blob/master"
  local -r nerd_fonts_patched_fonts="${nerd_fonts_repo}/patched-fonts"
  local -r microsoft_vscode_fonts_repo="https://github.com/microsoft/vscode-codicons/blob/main"

  download_file "${fonts_dir}/codicon.ttf" "${microsoft_vscode_fonts_repo}/dist/codicon.ttf?raw=true"

  download_file \
    "${fonts_dir}/Hack Regular Nerd Font Complete.ttf" \
    "${nerd_fonts_patched_fonts}/Hack/Regular/HackNerdFont-Regular.ttf?raw=true"

  download_file \
    "${fonts_dir}/Inconsolata Nerd Font Complete.otf" \
    "${nerd_fonts_patched_fonts}/Inconsolata/Regular/InconsolataNerdFont-Regular.ttf?raw=true"

  download_file \
    "${fonts_dir}/Fira Code Regular Nerd Font Complete.ttf" \
    "${nerd_fonts_patched_fonts}/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf?raw=true"

  if [ "${MACHINE_OS}" == "Linux" ]; then
    fc-cache -f -v
    if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 11'" ]; then
      gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
    fi
  fi
}
