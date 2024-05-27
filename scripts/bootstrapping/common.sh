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

# Fonts
readonly NERD_FONTS_REPO="https://github.com/ryanoasis/nerd-fonts/blob/master"
readonly NERD_FONTS_PATCHED_FONTS="${NERD_FONTS_REPO}/patched-fonts"
readonly MICROSOFT_VSCODE_FONTS_REPO="https://github.com/microsoft/vscode-codicons/blob/main"
FONTS_DIR="$(get_fonts_directory)"
readonly FONTS_DIR

# Symlinks
readonly -a SYMLINKS=(
  "$DOTFILES_CONFIG_DIR/git/gitattributes $HOME/.gitattributes"
  "$DOTFILES_CONFIG_DIR/git/gitconfig $HOME/.gitconfig"
  "$DOTFILES_CONFIG_DIR/git/gitignore $HOME/.gitignore"

  "$DOTFILES_CONFIG_DIR/mise/config.toml $HOME/.config/mise/config.toml"
  "$DOTFILES_CONFIG_DIR/mise/rust-packages $HOME/.default-cargo-crates"
  "$DOTFILES_CONFIG_DIR/mise/gcloud-components ${HOME}/.default-cloud-sdk-components"

  "$NVIM_SOURCE_DIR ${HOME}/.config/nvim"

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
  "${FONTS_DIR}"
)

MACHINE_OS="$(uname -s)"
readonly MACHINE_OS

function _create_core_dirs {
  task "Core directories" "creating core directories"

  for dir in "${CORE_DIRS[@]}"; do
    if [ ! -d "${dir}" ]; then
      info "Creating directory: ${dir}"
      mkdir -p "${dir}"
    fi
  done
}

function _symlinks {
  task "Symlinks" "creating symlinks"

  for sfile in "${SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${sfile}
  done
}

function _mise {
  task "Mise" "installing mise"

  if [ "${MACHINE_OS}" = "Linux" ]; then
    if [ ! -f "${MISE_BINARY}" ]; then
      curl https://mise.run | sh
    fi
  fi

  eval "$("$MISE_BINARY" activate bash)"

  local -r today=$(date +%Y-%m-%d)
  local -r marker_file="${HOME}/.cache/mise-last-cache-clear"
  local -r last_run_date=$(cat "$marker_file")
  if [ ! -e "$marker_file" ] || [ "$last_run_date" != "$today" ]; then
    "${MISE_BINARY}" cache clear
    echo "$today" >"$marker_file"
  fi

  if [ "${MACHINE_OS}" = "Linux" ]; then
    "${MISE_BINARY}" self-update || true
  fi

  "$MISE_BINARY" plugins update -y || true
  "$MISE_BINARY" install -y
  "$MISE_BINARY" upgrade -y
  "$MISE_BINARY" prune -y

  mkdir -p "${HOME}/.local/share/zsh/site-functions"
  "$MISE_BINARY" complete -s zsh >"${ZSH_SITE_FUNCTIONS_DIR}/_mise"
}

function _mise_reshim {
  task "Mise" "Reshimming mise"

  "$MISE_BINARY" reshim
}

function _gh {
  task "Git Hub" "installing gh extensions"

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
  task "Python" "installing python libraries"

  if [ ! -f "${HOME}/.debugpy/bin/python3" ]; then
    python3 -m venv "${HOME}/.debugpy"
  fi

  "${HOME}/.debugpy/bin/pip" install -U pip
  "${HOME}/.debugpy/bin/pip" install -U git+https://github.com/microsoft/debugpy.git@main
}

function _neovim_spell_check {
  task "Neovim" "downloading spell check files"

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

    set -x
    wget -N -nv "${spell_url}" --directory-prefix="${spell_dir}" --timeout=5
    set +x
    return $?
  }

  if [ ! -f "${DOWNLOADED_SPELL_FILE}" ]; then
    info "Downloaded spell files not found, downloading..."

    (
      _download_spell_files en || exit 1
      _download_spell_files pt || exit 1
      touch "${DOWNLOADED_SPELL_FILE}"
    )
  fi
}

function _fonts {
  task "Fonts" "downloading fonts"

  info "Fonts directory: ${FONTS_DIR}"
  info "Nerd fonts patched fonts: ${NERD_FONTS_PATCHED_FONTS}"
  info "Microsoft vscode fonts repo: ${MICROSOFT_VSCODE_FONTS_REPO}"

  download_file "${FONTS_DIR}/codicon.ttf" "${MICROSOFT_VSCODE_FONTS_REPO}/dist/codicon.ttf?raw=true"

  download_file \
    "${FONTS_DIR}/Hack Regular Nerd Font Complete.ttf" \
    "${NERD_FONTS_PATCHED_FONTS}/Hack/Regular/HackNerdFont-Regular.ttf?raw=true"

  download_file \
    "${FONTS_DIR}/Inconsolata Nerd Font Complete.otf" \
    "${NERD_FONTS_PATCHED_FONTS}/Inconsolata/InconsolataNerdFont-Regular.ttf?raw=true"

  download_file \
    "${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf" \
    "${NERD_FONTS_PATCHED_FONTS}/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf?raw=true"

  if [ "${MACHINE_OS}" == "Linux" ]; then
    fc-cache -f -v >/dev/null 2>&1
    if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 11'" ]; then
      gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
    fi
  fi
}
