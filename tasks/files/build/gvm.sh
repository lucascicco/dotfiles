#!/bin/bash

DOTFILES_DIR="${HOME}/dotfiles"

source "${DOTFILES_DIR}/tasks/files/scripts/functions.sh"

if [ -d "$HOME/.gvm" ]; then
  echo "Installing golang v1.18 with gvm"
  [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
  set -e
  gvm install go1.4 -B
  gvm use go1.4
  export GOROOT_BOOTSTRAP=$GOROOT
  gvm install go1.18
  gvm use go1.18 --default
  set -x
  exit 0
fi

