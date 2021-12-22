#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

export DOTFILES_DIR="${HOME}/bootstrap"

export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects

export GOBIN=$HOME/.local/bin
export NVM_DIR="$HOME/.nvm"

# Pyenv
export PYENV_VERSION="3.9.6"
export PYENV_ROOT="$HOME/.pyenv"

# Paths
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"
PATH="$PYENV_ROOT/bin:$PATH"

if [ -f ${PYENV_ROOT} ]; then
  eval "$(pyenv init --path)" # This load pyenv
fi

if [ -f "${HOME}/.nvm/nvm.sh" ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

export PATH

function bootstrap { 
  set -e
  echo "Bootstraping your scripts..."
  cd "${DOTFILES_DIR}"
  bash "${DOTFILES_DIR}/packages/bootstrap.sh" "${@}" || return 1
  bash "${DOTFILES_DIR}/nvim/setup.sh" "${@}" || return 1
}

export _DEFAULTS_SOURCED="1"