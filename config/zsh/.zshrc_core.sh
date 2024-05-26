#!/bin/bash

export DOTFILES_DIR="$HOME/dotfiles"
export RC_SCRIPTS_DIR="$DOTFILES_DIR/config/bash"

readonly -a ANTIGEN_PATHS=(
  "${HOME}/antigen.zsh"
  "${HOME}/.antigen.zsh"
  "/opt/homebrew/share/antigen/antigen.zsh"
  "/usr/share/zsh-antigen/antigen.zsh"
)

function load_bashrc() {
  local -r current_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  local -r rc_file="$RC_SCRIPTS_DIR/rc_${current_os}.sh"

  if [ ! -s "$rc_file" ]; then
    echo -e "[RC] ERROR: $rc_file not found" >&2
    return 1
  fi

  # shellcheck disable=1090
  source "$rc_file"
}

function find_antigen() {
  for antigen_path in "${ANTIGEN_PATHS[@]}"; do
    if [ -s "$antigen_path" ]; then
      echo "$antigen_path"
      return 0
    fi
  done
  return 1
}

function kube-toggle() {
  if (( ${+POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND} )); then
    unset POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND
  else
    export POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold'
  fi
  p10k reload
  if zle; then
    zle push-input
    zle accept-line
  fi
}
