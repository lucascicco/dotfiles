#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/files/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source $BASE_CONFIG


if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

# Paths
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$HOME/.krew/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"
PATH="$PYENV_ROOT/bin:$PATH"
export PATH

[[ -d "$PYENV_ROOT" ]] && eval "$(pyenv init --path)"

# Functions
function bootstrap() { (
  set -e
  cd "$DOTFILES_DIR" || return
  git pull origin master || true
  bash "$DOTFILES_DIR/run_ansible.sh" "${@}" || return 1
); }

export _DEFAULTS_SOURCED="1"
