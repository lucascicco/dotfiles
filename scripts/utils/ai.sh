#!/bin/bash

# AI Tools Feature Flag System
# Controls which AI tools are enabled/disabled across the dotfiles.
#
# Priority (highest to lowest):
#   1. Environment variables: DOTFILES_AI_<TOOL>=1|0|true|false
#   2. Local config: ~/.config/dotfiles/ai.toml
#   3. Repo config: $DOTFILES_DIR/config/ai/ai.toml
#   4. Default: all disabled

AI_CONFIG_DIR="${HOME}/.config/dotfiles"
AI_CONFIG_FILE="${AI_CONFIG_DIR}/ai.toml"
AI_REPO_CONFIG="${DOTFILES_DIR:-${HOME}/dotfiles}/config/ai/ai.toml"
AI_TOOLS=(copilot opencode codecompanion wakatime)

_ensure_ai_config_dir() {
  [[ ! -d "$AI_CONFIG_DIR" ]] && mkdir -p "$AI_CONFIG_DIR"
}

_to_upper() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

_get_env_value() {
  printenv "$1" 2>/dev/null || echo ""
}

_parse_toml_bool() {
  local value
  value=$(echo "$1" | tr '[:upper:]' '[:lower:]' | xargs)
  [[ "$value" == "true" || "$value" == "1" || "$value" == "yes" ]]
}

_get_toml_value() {
  local file="$1" tool="$2"
  [[ ! -f "$file" ]] && return 1

  local in_tools=false line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue

    if [[ "$line" == "["*"]" ]]; then
      [[ "$line" == "[tools]" ]] && in_tools=true || in_tools=false
      continue
    fi

    if [[ "$in_tools" == true ]] && [[ "$line" == *"="* ]]; then
      key="${line%%=*}" && key="${key// /}"
      value="${line#*=}" && value="${value## }" && value="${value%% }"
      [[ "$key" == "$tool" ]] && echo "$value" && return 0
    fi
  done <"$file"
  return 1
}

is_ai_enabled() {
  local tool="$1"
  local env_var="DOTFILES_AI_$(_to_upper "$tool")"
  env_var="${env_var//-/_}"

  local env_value
  env_value=$(_get_env_value "$env_var")
  [[ -n "$env_value" ]] && { _parse_toml_bool "$env_value" && return 0 || return 1; }

  local local_value
  local_value=$(_get_toml_value "$AI_CONFIG_FILE" "$tool") && { _parse_toml_bool "$local_value" && return 0 || return 1; }

  local repo_value
  repo_value=$(_get_toml_value "$AI_REPO_CONFIG" "$tool") && { _parse_toml_bool "$repo_value" && return 0 || return 1; }

  return 1
}

any_ai_enabled() {
  for tool in "${AI_TOOLS[@]}"; do
    is_ai_enabled "$tool" && return 0
  done
  return 1
}

_get_ai_tool_mise_config() {
  case "$1" in
  copilot)
    cat <<-'EOF'
			"npm:@github/copilot" = "latest"
			"npm:@github/copilot-language-server" = "latest"
		EOF
    ;;
  opencode)
    echo 'opencode = "latest"'
    ;;
  esac
}

_get_ai_tool_mise_env() {
  case "$1" in
  opencode)
    cat <<-'EOF'
			OPENCODE_EXPERIMENTAL_ICON_DISCOVERY = "true"
			OPENCODE_EXPERIMENTAL_FILEWATCHER = "true"
		EOF
    ;;
  esac
}

_get_ai_tool_mise_packages() {
  case "$1" in
  copilot) echo "npm:@github/copilot npm:@github/copilot-language-server" ;;
  opencode) echo "opencode" ;;
  esac
}

_get_ai_tool_zsh_plugins() {
  case "$1" in
  wakatime) echo "wbingli/zsh-wakatime kind:defer" ;;
  esac
}

generate_mise_ai_config() {
  local tools_section="" env_section="" has_tools=false cfg

  for tool in "${AI_TOOLS[@]}"; do
    if is_ai_enabled "$tool"; then
      has_tools=true
      cfg=$(_get_ai_tool_mise_config "$tool")
      [[ -n "$cfg" ]] && tools_section="${tools_section}
# ${tool}
${cfg}"
      cfg=$(_get_ai_tool_mise_env "$tool")
      [[ -n "$cfg" ]] && env_section="${env_section}
# ${tool}
${cfg}"
    fi
  done

  [[ "$has_tools" != true ]] && return 0

  echo "# AI Tools - mise configuration (auto-generated)"
  echo "# DO NOT EDIT - regenerate with: ai-reload"
  [[ -n "$env_section" ]] && echo -e "\n[env]${env_section}"
  [[ -n "$tools_section" ]] && echo -e "\n[tools]${tools_section}"
}

write_mise_ai_config() {
  local target_file="$1"
  if ! any_ai_enabled; then
    [[ -f "$target_file" ]] && rm -f "$target_file" && echo "Removed: $target_file"
    return 0
  fi
  local content
  content=$(generate_mise_ai_config)
  [[ -n "$content" ]] && echo "$content" >"$target_file" && echo "Generated: $target_file"
}

uninstall_disabled_ai_tools() {
  local pkgs="" p
  for tool in "${AI_TOOLS[@]}"; do
    is_ai_enabled "$tool" && continue
    p=$(_get_ai_tool_mise_packages "$tool")
    [[ -n "$p" ]] && pkgs="$pkgs $p"
  done
  # shellcheck disable=SC2086
  [[ -n "${pkgs// /}" ]] && echo "Uninstalling:$pkgs" && mise uninstall -y $pkgs 2>/dev/null || true
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

print_ai_status() {
  echo "============================================"
  echo "  AI Tools Configuration"
  echo "============================================"
  echo "  Config: ${AI_CONFIG_FILE}"
  [[ -f "$AI_CONFIG_FILE" ]] && echo "  Status: Found" || echo "  Status: Not found (using defaults)"
  echo ""

  for tool in "${AI_TOOLS[@]}"; do
    local tool_status="DISABLED" config_source="default"
    local env_var="DOTFILES_AI_$(_to_upper "$tool")"
    env_var="${env_var//-/_}"

    if [[ -n "$(_get_env_value "$env_var")" ]]; then
      config_source="env"
    elif _get_toml_value "$AI_CONFIG_FILE" "$tool" &>/dev/null; then
      config_source="local"
    elif _get_toml_value "$AI_REPO_CONFIG" "$tool" &>/dev/null; then
      config_source="repo"
    fi

    is_ai_enabled "$tool" && tool_status="ENABLED"
    printf "  %-15s %s (%s)\n" "$tool:" "$tool_status" "$config_source"
  done
  echo "============================================"
}

export_ai_config() {
  for tool in "${AI_TOOLS[@]}"; do
    local env_var="DOTFILES_AI_$(_to_upper "$tool")"
    env_var="${env_var//-/_}"
    is_ai_enabled "$tool" && export "${env_var}=1" || export "${env_var}=0"
  done
}
