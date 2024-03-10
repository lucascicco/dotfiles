#!/bin/bash

readonly DOTFILES_DIR="$HOME/dotfiles"
readonly GET_OS_SCRIPT="$DOTFILES_DIR/scripts/utils/get_os.sh"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo -e "Dotfiles directory not found at $DOTFILES_DIR"
  exit 1
fi

if [[ ! -f "$GET_OS_SCRIPT" ]]; then
  echo -e "get_os.sh not found at $GET_OS_SCRIPT"
  exit 1
fi

source "$GET_OS_SCRIPT"

function bootstrap {
  local -r current_os=$(get_os)
  echo -e "Bootstrapping using $current_os"
  bootstrap_file="$DOTFILES_DIR/scripts/bootstrapping/$current_os.sh"
  if [[ ! -f "$bootstrap_file" ]]; then
    echo -e "No bootstrap supported for the OS ($OS). "
    echo -e "Please try again on Linux or MacOs."
    exit 1
  fi
  bash "$bootstrap_file" "${@}"
}

bootstrap "${@}"

exit 0
