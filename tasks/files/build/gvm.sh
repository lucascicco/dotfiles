#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/tasks/files/scripts/functions.sh"

GO_DEFAULT_VERSION="go1.18"

if [ -d "$HOME/.gvm" ]; then
  set +x
  info "installing golang v1.18 with gvm"
  [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
  gvm install go1.4 -B
  gvm use go1.4
  export GOROOT_BOOTSTRAP=$GOROOT
  gvm install $GO_DEFAULT_VERSION
  gvm use $GO_DEFAULT_VERSION --default
  set -x
fi

exit 0
