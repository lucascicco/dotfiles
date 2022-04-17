#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/tasks/files/scripts/functions.sh"

NVM_DIR="$HOME/.nvm"

if [ -d $NVM_DIR ]; then
  set +x
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 16
  nvm use 16
  nvm alias default 16
  set -x
fi

exit 0
