#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

source "$DOTFILES_DIR/scripts/utils/get_os.sh"

function bootstrap {
  OS=$(get_os)
  BOOTSTRAP_FILE="$OS"
  if [[ -f "/etc/fedora-release" ]]; then
    BOOTSTRAP_FILE="${BOOTSTRAP_FILE}_fedora"
  fi
  echo "Bootstrapping using $BOOTSTRAP_FILE"
  BOOTSTRAP_SCRIPT="$DOTFILES_DIR/scripts/bootstrapping/$BOOTSTRAP_FILE.sh"
  if [[ -f "$BOOTSTRAP_SCRIPT" ]]; then
    bash "$BOOTSTRAP_SCRIPT" "${@}"
  else
    echo "No bootstrap supported for the OS ($OS). "
    echo "Please try again on Linux or MacOs."
    exit 1
  fi
}

bootstrap "${@}"

exit 0
