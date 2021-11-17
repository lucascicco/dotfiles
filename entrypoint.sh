#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

export DOTFILES_DIR="${HOME}/bootstrap"

export GIT_SSH=ssh
export PIP_REQUIRE_VIRTUALENV=true
export PROJECT_HOME=$HOME/dev
export WORKON_HOME=$HOME/.virtualenvs

export PERL_LOCAL_LIB_ROOT=$HOME/.local/perl

export GOBIN=$HOME/.local/bin


PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"

export PATH

bootstrap () { 
  set -e
  cd "${DOTFILES_DIR}"
  git pull origin master || true
  bash "${DOTFILES_DIR}/utils/bootstrap.sh" "${@}" || return 1
 }

export _DEFAULTS_SOURCED="1"