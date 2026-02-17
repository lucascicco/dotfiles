#!/bin/bash

# Dotfiles Configuration System
# Controls mise environments and AI tool plugins.
#
# Mise tools are controlled via MISE_ENV (set profile in dotfiles.yaml)
# Zsh/Neovim plugins are controlled via individual tool flags
#
# Priority (highest to lowest):
#   1. Environment variables: DOTFILES_PROFILE, DOTFILES_AI_<TOOL>=1|0
#   2. Local config: ~/.config/dotfiles/dotfiles.yaml
#   3. Repo config: $DOTFILES_DIR/config/dotfiles.yaml
#   4. Default: all disabled

DOTFILES_CONFIG_LOCAL="${HOME}/.config/dotfiles/dotfiles.yaml"
DOTFILES_CONFIG_REPO="${DOTFILES_DIR:-${HOME}/dotfiles}/config/dotfiles.yaml"
AI_TOOLS=(copilot opencode codecompanion wakatime)

# Resolve yq binary for YAML config parsing; without it, only env vars are used
# Resolved lazily since yq/mise may not be on PATH when this file is sourced
_YQ_BIN=""
_yq_resolved=false

_resolve_yq() {
  [[ "$_yq_resolved" == true ]] && return
  _yq_resolved=true
  if command -v yq &>/dev/null; then
    _YQ_BIN="yq"
  elif command -v mise &>/dev/null; then
    _YQ_BIN=$(mise which yq 2>/dev/null) || _YQ_BIN=""
  fi
}

_ensure_dotfiles_config_dir() {
  local config_dir
  config_dir="$(dirname "$DOTFILES_CONFIG_LOCAL")"
  [[ ! -d "$config_dir" ]] && mkdir -p "$config_dir"
}

_to_upper() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

_get_env_value() {
  printenv "$1" 2>/dev/null || echo ""
}

_parse_bool() {
  local value
  value=$(echo "$1" | tr '[:upper:]' '[:lower:]' | xargs)
  [[ "$value" == "true" || "$value" == "1" || "$value" == "yes" ]]
}

# Get a YAML value using yq: _get_yaml_value <file> <key> [section]
# Returns 1 if yq is unavailable, file missing, or key not found/null
_get_yaml_value() {
  local file="$1" key="$2" section="${3:-tools}"
  _resolve_yq
  [[ -z "$_YQ_BIN" ]] && return 1
  [[ ! -f "$file" ]] && return 1

  local value
  value=$("$_YQ_BIN" ".${section}.${key}" "$file" 2>/dev/null)
  [[ -z "$value" || "$value" == "null" ]] && return 1
  echo "$value"
}

is_ai_enabled() {
  local tool="$1"
  local env_var
  env_var="DOTFILES_AI_$(_to_upper "$tool")"
  env_var="${env_var//-/_}"

  local env_value
  env_value=$(_get_env_value "$env_var")
  [[ -n "$env_value" ]] && { _parse_bool "$env_value" && return 0 || return 1; }

  local local_value
  local_value=$(_get_yaml_value "$DOTFILES_CONFIG_LOCAL" "$tool") && { _parse_bool "$local_value" && return 0 || return 1; }

  local repo_value
  repo_value=$(_get_yaml_value "$DOTFILES_CONFIG_REPO" "$tool") && { _parse_bool "$repo_value" && return 0 || return 1; }

  return 1
}

any_ai_enabled() {
  for tool in "${AI_TOOLS[@]}"; do
    is_ai_enabled "$tool" && return 0
  done
  return 1
}

_get_ai_tool_zsh_plugins() {
  case "$1" in
  wakatime) echo "wbingli/zsh-wakatime kind:defer" ;;
  esac
}

generate_zsh_plugins() {
  local base_file="$1"
  [[ ! -f "$base_file" ]] && echo "Error: $base_file not found" >&2 && return 1

  cat "$base_file"
  local ai_plugins="" p
  for tool in "${AI_TOOLS[@]}"; do
    if is_ai_enabled "$tool"; then
      p=$(_get_ai_tool_zsh_plugins "$tool")
      [[ -n "$p" ]] && ai_plugins="${ai_plugins}${p}"$'\n'
    fi
  done
  [[ -n "$ai_plugins" ]] && echo -e "\n# AI tools (auto-generated)\n${ai_plugins}"
}

write_zsh_plugins() {
  local content
  content=$(generate_zsh_plugins "$1")
  [[ -n "$content" ]] && echo "$content" >"$2" && echo "Generated: $2"
}

print_dotfiles_status() {
  echo "============================================"
  echo "  Dotfiles Configuration"
  echo "============================================"
  echo "  Local:  ${DOTFILES_CONFIG_LOCAL}"
  [[ -f "$DOTFILES_CONFIG_LOCAL" ]] && echo "  Status: Found" || echo "  Status: Not found (using repo defaults)"

  local profile
  profile=$(get_dotfiles_profile)
  if [[ -n "$profile" ]]; then
    echo "  Profile: ${profile} (MISE_ENV)"
  else
    echo "  Profile: (none)"
  fi
  echo ""

  for tool in "${AI_TOOLS[@]}"; do
    local tool_status="DISABLED" config_source="default" env_var
    env_var="DOTFILES_AI_$(_to_upper "$tool")"
    env_var="${env_var//-/_}"

    if [[ -n "$(_get_env_value "$env_var")" ]]; then
      config_source="env"
    elif _get_yaml_value "$DOTFILES_CONFIG_LOCAL" "$tool" &>/dev/null; then
      config_source="local"
    elif _get_yaml_value "$DOTFILES_CONFIG_REPO" "$tool" &>/dev/null; then
      config_source="repo"
    fi

    is_ai_enabled "$tool" && tool_status="ENABLED"
    printf "  %-15s %s (%s)\n" "$tool:" "$tool_status" "$config_source"
  done
  echo "============================================"
}

export_dotfiles_config() {
  local env_var tool
  for tool in "${AI_TOOLS[@]}"; do
    env_var="DOTFILES_AI_$(_to_upper "$tool")"
    env_var="${env_var//-/_}"
    is_ai_enabled "$tool" && export "${env_var}=1" || export "${env_var}=0"
  done

  # Export MISE_ENV based on profile setting
  local profile
  profile=$(get_dotfiles_profile)
  if [[ -n "$profile" ]]; then
    export MISE_ENV="$profile"
  fi
}

# Get the dotfiles profile from dotfiles.yaml
# Priority: env var > local config > repo config
get_dotfiles_profile() {
  # Check environment variable first
  local env_value
  env_value=$(_get_env_value "DOTFILES_PROFILE")
  [[ -n "$env_value" ]] && echo "$env_value" && return 0

  # Check local config
  local local_value
  local_value=$(_get_yaml_value "$DOTFILES_CONFIG_LOCAL" "profile" "dotfiles")
  [[ -n "$local_value" ]] && echo "$local_value" && return 0

  # Check repo config
  local repo_value
  repo_value=$(_get_yaml_value "$DOTFILES_CONFIG_REPO" "profile" "dotfiles")
  [[ -n "$repo_value" ]] && echo "$repo_value" && return 0

  return 1
}
