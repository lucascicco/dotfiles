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
export K8S_SCRIPTS="$DOTFILES_DIR/tasks/files/config/k8s/k8s.sh"

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
[[ -s $K8S_SCRIPTS ]] && source $K8S_SCRIPTS
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
