#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

source "$DOTFILES_DIR/scripts/utils/get_os.sh"

function bootstrap {
  OS=$(get_os)
  BOOTSTRAP_SCRIPT="$DOTFILES_DIR/scripts/bootstraping/$OS.sh"
  if [[ -f "$BOOTSTRAP_SCRIPT" ]]; then
    bash  "$BOOTSTRAP_SCRIPT" ${@}
  else
      echo "No bootstrap supported for the OS ($OS). "
      echo "Please try again on Linux or MacOs."
      exit 1
  fi
}

bootstrap ${@}

exit 0