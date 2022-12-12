#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/tasks/files/scripts/functions.sh"

# NVM & NODE
NVM_DIR="$HOME/.nvm"
NODE_DEFAULT_VERSION="18.12.1"

if [ -d "$NVM_DIR" ]; then
  set +x
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  nvm install $NODE_DEFAULT_VERSION
  nvm use $NODE_DEFAULT_VERSION
  nvm alias default $NODE_DEFAULT_VERSION
  set -x
fi

exit 0
