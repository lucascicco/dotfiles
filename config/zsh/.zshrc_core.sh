#!/bin/bash

readonly GET_OS_SCRIPT="$DOTFILES_DIR/scripts/utils/get_os.sh"

if [ -s "${GET_OS_SCRIPT}" ]; then
  source "${GET_OS_SCRIPT}"
fi

# Load bashrc default settings based on the current OS
function load_bashrc() {
  local -r current_os="$(get_current_os_in_lowercase)"
  local -r settings_file="$DOTFILES_DIR/config/bash/rc_$current_os.sh"
  if [ ! -s "$settings_file" ]; then
    echo -e "ERROR: $settings_file not found"
    return 1
  fi
  source "$settings_file"
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
