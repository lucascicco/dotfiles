#!/bin/bash

export DOTFILES_DIR="${HOME}/.dotfiles"
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

readonly DOTFILES_SCRIPTS="${DOTFILES_DIR}/scripts/utils/dotfiles.sh"
if [ -s "${DOTFILES_SCRIPTS}" ]; then
  # shellcheck source=scripts/utils/dotfiles.sh
  source "${DOTFILES_SCRIPTS}"
else
  echo "Error: ${DOTFILES_SCRIPTS} not found" >&2
  exit 1
fi

# Print dotfiles status at bootstrap start
print_dotfiles_status

# Export dotfiles config as environment variables for child processes
export_dotfiles_config

# Binaries directories
readonly BIN_DIR="${HOME}/bin"
readonly LOCAL_DIR="${HOME}/.local"
readonly LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
readonly LOCAL_BUILD_DIR="${HOME}/.local_build"

# Neovim
readonly NVIM_SOURCE_DIR="${DOTFILES_DIR}/nvim"

# Zsh plugins
readonly ZSH_PLUGINS_BASE="${DOTFILES_CONFIG_DIR}/zsh/zsh_plugins.base.txt"
readonly ZSH_PLUGINS_TARGET="${HOME}/.zsh_plugins.txt"

# Mise
MISE_BINARY="$(get_mise_binary_path)"
readonly MISE_BINARY

# ZSH
readonly ANTIDOTE_SCRIPT_PATH="${HOME}/.antidote"
readonly ZSH_SITE_FUNCTIONS_DIR="${HOME}/.local/share/zsh/site-functions"

# Fonts
FONTS_DIR="$(get_fonts_directory)"
readonly FONTS_DIR

# Symlinks - base symlinks (AI tools handled separately)
readonly -a BASE_SYMLINKS=(
  "$DOTFILES_CONFIG_DIR/git/gitattributes ${HOME}/.gitattributes"
  "$DOTFILES_CONFIG_DIR/git/gitconfig ${HOME}/.gitconfig"
  "$DOTFILES_CONFIG_DIR/git/gitignore ${HOME}/.gitignore"

  "$DOTFILES_CONFIG_DIR/mise/rust-packages ${HOME}/.default-cargo-crates"
  "$DOTFILES_CONFIG_DIR/mise/gcloud-components ${HOME}/.default-cloud-sdk-components"
  "$DOTFILES_CONFIG_DIR/mise/golang-packages ${HOME}/.default-go-packages"

  # Mise config directory (env-specific configs loaded via MISE_ENV)
  # AI tools written to config.local.toml (gitignored)
  "$DOTFILES_CONFIG_DIR/mise ${HOME}/.config/mise"

  "$NVIM_SOURCE_DIR ${HOME}/.config/nvim"

  "$DOTFILES_CONFIG_DIR/zsh/zshrc ${HOME}/.zshrc"
  "$DOTFILES_CONFIG_DIR/starship/starship.toml ${HOME}/.config/starship.toml"

  "$DOTFILES_CONFIG_DIR/ghostty ${HOME}/.config/ghostty"

  "$DOTFILES_CONFIG_DIR/vim/vimrc ${HOME}/.vimrc"
)

readonly -a CORE_DIRS=(
  "${BIN_DIR}"
  "${LOCAL_DIR}"
  "${LOCAL_BIN_DIR}"
  "${LOCAL_BUILD_DIR}"
  "${ZSH_SITE_FUNCTIONS_DIR}"
  "${FONTS_DIR}"
  "${HOME}/.config/dotfiles"
  "${HOME}/.config/opencode"
  "${HOME}/.claude"
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

  # Create base symlinks
  for sfile in "${BASE_SYMLINKS[@]}"; do
    # shellcheck disable=2086
    create_symlink ${sfile}
  done
}

function _nvim_spell {
  task "Neovim" "pre-fetching spell files (en_us, pt_br)"
  if command -v nvim &>/dev/null; then
    nvim --headless +"set spell spelllang=en_us,pt_br" +qa 2>/dev/null || true
  fi
}

function _groovyls {
  local jar_dir="${HOME}/.local/share/groovyls"
  local jar_path="${jar_dir}/groovy-language-server-all.jar"
  local src_dir="${HOME}/.local_build/groovy-language-server"

  if [ -f "${jar_path}" ]; then
    info "groovy-language-server already built, skipping"
    return 0
  fi

  task "Groovy" "building groovy-language-server"

  if ! command -v java &>/dev/null; then
    warn "java not found — skipping groovy-language-server build (install Java 11+ to enable)"
    return 0
  fi

  mkdir -p "${jar_dir}"
  if [ ! -d "${src_dir}" ]; then
    git clone --depth=1 https://github.com/prominic/groovy-language-server.git "${src_dir}" || {
      warn "Failed to clone groovy-language-server"
      return 0
    }
  fi

  (cd "${src_dir}" && ./gradlew shadowJar 2>&1) || {
    warn "Failed to build groovy-language-server"
    return 0
  }

  local built_jar
  built_jar="$(find "${src_dir}/build/libs" -name "groovy-language-server-all.jar" 2>/dev/null | head -1)"
  if [ -n "${built_jar}" ]; then
    cp "${built_jar}" "${jar_path}"
    info "groovy-language-server installed at ${jar_path}"
  else
    warn "Build succeeded but JAR not found in ${src_dir}/build/libs"
  fi
}

function _agents {
  if ! any_ai_enabled; then
    _agents_cleanup_restricted
    info "Agents step is a no-op (AI disabled)"
    return 0
  fi

  info "updating agents"
  local opencode_dir="${HOME}/.config/opencode"
  local claude_dir="${HOME}/.claude"

  # OpenCode-native symlinks
  create_symlink "${DOTFILES_CONFIG_DIR}/agents/AGENTS.md" "${opencode_dir}/AGENTS.md"
  create_symlink "${DOTFILES_CONFIG_DIR}/agents/opencode.json" "${opencode_dir}/opencode.json"

  # Claude Code compatibility symlinks (OpenCode Claude Code fallback)
  create_symlink "${DOTFILES_CONFIG_DIR}/agents/AGENTS.md" "${claude_dir}/CLAUDE.md"
  create_symlink "${DOTFILES_CONFIG_DIR}/agents/claude.json" "${claude_dir}/settings.json"
  create_symlink "${DOTFILES_CONFIG_DIR}/agents/hooks" "${claude_dir}/hooks"
  create_symlink "${DOTFILES_CONFIG_DIR}/agents/.claude-plugin" "${claude_dir}/.claude-plugin"

  rtk init -g --hook-only --auto-patch || true
  rtk init -g --hook-only --auto-patch --opencode || true
}

function _agents_cleanup_restricted {
  if command -v rtk &>/dev/null; then
    rtk init -g --uninstall || true
  else
    info "rtk not found; skipping rtk uninstall"
  fi
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
  local -r last_run_date=$(cat "$marker_file" 2>/dev/null)
  if [ ! -e "$marker_file" ] || [ "$last_run_date" != "$today" ]; then
    "${MISE_BINARY}" cache clear
    echo "$today" >"$marker_file"
  fi

  if [ "${MACHINE_OS}" = "Linux" ]; then
    "${MISE_BINARY}" self-update || true
  fi

  (
    if [ -f "${HOME}/.mise_secret_env.sh" ]; then
      # shellcheck disable=1091
      source "${HOME}/.mise_secret_env.sh"
    fi
    "$MISE_BINARY" plugins update -y || true
    "$MISE_BINARY" install -y || true

    local auto_upgrade="${DOTFILES_MISE_AUTO_UPGRADE:-1}"
    if _parse_bool "$auto_upgrade"; then
      info "Mise auto-upgrade enabled"
      "$MISE_BINARY" upgrade -y || true
    else
      info "Skipping mise upgrade (DOTFILES_MISE_AUTO_UPGRADE=${auto_upgrade})"
    fi

    "$MISE_BINARY" prune -y
  )
}

function _mise_reshim {
  task "Mise" "Reshimming mise"

  "$MISE_BINARY" reshim
}

function _python {
  task "Python" "configuring python environment"
  poetry config virtualenvs.in-project true
}

# Manage zsh plugins based on dotfiles.toml configuration
# Generates zsh_plugins.txt with base plugins + enabled AI tool plugins
function _manage_zsh_plugins {
  task "Zsh Plugins" "generating zsh plugins config"

  write_zsh_plugins "$ZSH_PLUGINS_BASE" "$ZSH_PLUGINS_TARGET"
}

function _zsh {
  task "Zsh" "Installing zsh"

  # Generate zsh_plugins.txt with AI tools
  _manage_zsh_plugins

  if [[ ! -s "$ANTIDOTE_SCRIPT_PATH" ]]; then
    (
      git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
    )
    reload_zsh
  fi
  zsh -i -c "antidote update -b"
}

function _fonts {
  info "installing fonts"

  # Font URLs are pinned to specific versions. Update the URL and SHA-256 together
  # when bumping a font. SHA-256 is verified before installation — bootstrap hard-fails
  # on mismatch to guard against supply chain tampering.
  #
  # To update: download the new file, run `shasum -a 256 <file>`, update both values.
  #
  # Versions in use:
  #   @vscode/codicons: 0.0.45
  #   nerd-fonts: v3.4.0

  download_file_verified \
    "${FONTS_DIR}/codicon.ttf" \
    "https://unpkg.com/@vscode/codicons@0.0.45/dist/codicon.ttf" \
    "2bb558cb693451e73c28c33fe64aa89bc19b1a4b70f95948322c243f93476920"

  download_file_verified \
    "${FONTS_DIR}/Hack Regular Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/v3.4.0/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf" \
    "7e6b5d86baee613984b10cef14c8d6aee86c976a3d1cbd87abffd424d6ec4c64"

  download_file_verified \
    "${FONTS_DIR}/Inconsolata Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/v3.4.0/patched-fonts/Inconsolata/InconsolataNerdFont-Regular.ttf" \
    "4ff8113774cc5eaf99ff1efdaff45d36de090a77b65cfe22d7939a80e4c5bde5"

  download_file_verified \
    "${FONTS_DIR}/Fira Code Regular Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/v3.4.0/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf" \
    "29b619655612cb273e034737408b9508a04beb63c1ddbdfaa9a6846c409c7a2e"

  download_file_verified \
    "${FONTS_DIR}/JetBrains Mono Nerd Font Complete.ttf" \
    "https://github.com/ryanoasis/nerd-fonts/raw/v3.4.0/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf" \
    "efd0c812226247ba45bb31a816ec63876fb0d8d930dbb0e633770965fcc81081"

  if [ "${MACHINE_OS}" = "Linux" ]; then
    if [ "$(gsettings get org.gnome.desktop.interface monospace-font-name)" != "'Hack Nerd Font 11'" ]; then
      gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font 11'
    fi
  fi
}
