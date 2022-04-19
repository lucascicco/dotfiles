#!/bin/bash

if [ "${_DEFAULTS_SOURCED}" = "1" ]; then
  return
fi

# Env variables
export DOTFILES_DIR="$HOME/dotfiles"
export GIT_SSH=ssh
export PROJECT_HOME=$HOME/projects
export GOBIN=$HOME/.local/bin
export NVM_DIR="$HOME/.nvm"
export KUBE_PS1_SH="$HOME/.local_build/kube-ps1/kube-ps1.sh"
export PYENV_VERSION="3.10-dev"
export PYENV_ROOT="$HOME/.pyenv"
export GVM_SCRIPTS="$HOME/.gvm/scripts/gvm"

# Paths
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"
PATH="$PYENV_ROOT/bin:$PATH"
PATH="$HOME/.krew/bin:$PATH"
export PATH

# Kubernetes
source <(kubectl completion zsh)
command -v kubecolor >/dev/null 2>&1 && alias kubectl="kubecolor"

# kube-ps1 
if [ -s $KUBE_PS1_SH ]; then 
  source $KUBE_PS1_SH
  PROMPT='$(kube_ps1)'$PROMPT
fi

# Gvm
[[ -s $GVM_SCRIPTS ]] && source $GVM_SCRIPTS

# Pyenv
if [ -f $PYENV_ROOT ]; then
  eval "$(pyenv init --path)" # This load pyenv
fi

# Nvm
if [ -f "$NVM_DIR/nvm.sh" ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Functions
function bootstrap() { (
  set -e
  cd $DOTFILES_DIR
  git pull origin master || true
  bash "$DOTFILES_DIR/bootstrap.sh" "${@}" || return 1
); }

export _DEFAULTS_SOURCED="1"
