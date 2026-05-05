#!/bin/bash

readonly BOOTSTRAP_COMMON_SCRIPT_PATH="$HOME/.dotfiles/scripts/bootstrapping/common.sh"
if [[ -s "$BOOTSTRAP_COMMON_SCRIPT_PATH" ]]; then
  # shellcheck disable=1090
  source "$BOOTSTRAP_COMMON_SCRIPT_PATH"
else
  echo "Error: $BOOTSTRAP_COMMON_SCRIPT_PATH not found" >&2
  exit 1
fi

readonly BREW_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

_contains_item() {
  local item="$1"
  shift
  local current
  for current in "$@"; do
    [[ "$current" == "$item" ]] && return 0
  done
  return 1
}

_parse_brew_packages() {
  local -a package_files=("$@")
  local -a formulas=() casks=()
  local package_file line item

  for package_file in "${package_files[@]}"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${line// /}" ]] && continue

      if [[ "$line" == cask:* ]]; then
        item="${line#cask:}"
        _contains_item "$item" "${casks[@]}" || casks+=("$item")
      else
        item="$line"
        _contains_item "$item" "${formulas[@]}" || formulas+=("$item")
      fi
    done <"$package_file"
  done

  BREW_PACKAGES="${formulas[*]}"
  BREW_CASKS="${casks[*]}"
}

BREW_CORE_PACKAGES_FILE="${PACKAGES_DIR}/brew.core"
BREW_EXTRA_PACKAGES_FILE="${PACKAGES_DIR}/brew"
BREW_CASKS_FILE="${PACKAGES_DIR}/brew.casks"

if [[ ! -f "$BREW_CORE_PACKAGES_FILE" ]]; then
  echo "Error: required brew package file not found: ${BREW_CORE_PACKAGES_FILE}" >&2
  exit 1
fi

_PROFILE="$(get_dotfiles_profile)"

if [[ "${_PROFILE}" == "restricted" ]]; then
  # Restricted: formulas from brew.core only — no extra overlay, no casks
  _parse_brew_packages "$BREW_CORE_PACKAGES_FILE"
  info "Using brew package source: brew.core (restricted profile — casks and extras skipped)"
elif [[ -f "$BREW_EXTRA_PACKAGES_FILE" ]] && [[ -f "$BREW_CASKS_FILE" ]]; then
  _parse_brew_packages "$BREW_CORE_PACKAGES_FILE" "$BREW_EXTRA_PACKAGES_FILE" "$BREW_CASKS_FILE"
  info "Using brew package sources: brew.core + brew + brew.casks"
elif [[ -f "$BREW_EXTRA_PACKAGES_FILE" ]]; then
  _parse_brew_packages "$BREW_CORE_PACKAGES_FILE" "$BREW_EXTRA_PACKAGES_FILE"
  info "Using brew package sources: brew.core + brew"
else
  _parse_brew_packages "$BREW_CORE_PACKAGES_FILE"
  info "Using brew package source: brew.core"
fi
readonly BREW_PACKAGES
readonly BREW_CASKS

# Libs
function _packages {
  task "Brew" "installing packages"

  if [[ "${_PROFILE}" == "restricted" ]]; then
    # On restricted (corporate) machines:
    # - Do NOT self-install Homebrew via curl | bash — IT manages it.
    # - Hard-fail with a clear message if brew is not found.
    # - Install formulas from brew.core only — no casks, no upgrade.
    if ! command -v brew &>/dev/null; then
      echo "[FATAL] Homebrew not found. On a restricted machine, install Homebrew via IT or manually." >&2
      echo "[FATAL] See: https://brew.sh" >&2
      return 1
    fi

    if [[ -n "${BREW_PACKAGES// /}" ]]; then
      # shellcheck disable=2086
      brew install ${BREW_PACKAGES}
    fi

    brew autoremove
    brew cleanup
  else
    # Personal profile: full behaviour — self-install brew, all packages + casks, upgrade.
    if ! command -v brew &>/dev/null; then
      curl -fsSL -o- "${BREW_INSTALL_SCRIPT_URL}" | bash
      eval "$(/opt/homebrew/bin/brew shellenv)"
      reload_zsh
    fi

    if [[ -n "${BREW_PACKAGES// /}" ]]; then
      # shellcheck disable=2086
      brew install ${BREW_PACKAGES}
    fi

    if [[ -n "${BREW_CASKS// /}" ]]; then
      # shellcheck disable=2086
      brew install --cask ${BREW_CASKS}
    fi

    brew update
    brew upgrade
    brew autoremove
    brew cleanup
  fi
}

function _neovim {
  task "Neovim" "installing neovim"

  # Always installs nightly — no SHA-256 verification is possible since GitHub
  # does not publish checksums for nightly builds and the binary changes every build.
  # The tar integrity check below guards against corrupt/truncated downloads.
  local -r file=${LOCAL_BUILD_DIR}/nvim.tar.gz
  local -r url=https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz

  if [ "$(download_file "${file}" "${url}")" == "1" ]; then
    if ! tar tzf "${file}" &>/dev/null; then
      rm -f "${file}"
      echo "[FATAL] Downloaded Neovim tarball failed integrity check — aborting install." >&2
      return 1
    fi
    rm -rf "${LOCAL_BUILD_DIR}/nvim-macos-arm64"
    tar xzf "${file}" -C "${LOCAL_BUILD_DIR}"
    ln -sf "${LOCAL_BUILD_DIR}/nvim-macos-arm64/bin/nvim" "${BIN_DIR}/nvim"
  fi
}

function _ {
  _create_core_dirs
  _symlinks
  _packages
  _neovim
  _symlinks
  _nvim_spell
  _groovyls
  _fonts
  _mise
  _python
  _agents
  _zsh
  _mise_reshim
}

echo
set -x
"_${1}" "$@"
