#!/bin/bash

DOTFILES_DIR="${HOME}/dotfiles"
NVM_DIR="$HOME/.nvm"

source "${DOTFILES_DIR}/tasks/files/scripts/functions.sh"

if [ ! -d $NVM_DIR ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  set -e
  nvm install 16
  nvm use 16
  nvm alias default 16
  set -x
  exit 0
fi

