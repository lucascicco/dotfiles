#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
GET_OS_SCRIPT="$DOTFILES_DIR/scripts/utils/get_os.sh"


# Load bashrc default settings based on the current OS
function load_bashrc() {
  if [ -s "${GET_OS_SCRIPT}" ]; then
    OS="$(source "$GET_OS_SCRIPT")"
    if [ -n "$OS" ]; then
      SETTINGS_FILE="$DOTFILES_DIR/config/bash/rc_$OS.sh"
      if [ ! -f "$SETTINGS_FILE" ]; then
        echo "Error: $SETTINGS_FILE not found"
        return 1
      fi
      source "$SETTINGS_FILE"
    fi
    echo "Error: Failed to get OS"
    return 1
  fi
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
