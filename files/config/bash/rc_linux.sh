#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/files/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source $BASE_CONFIG

# Paths
# In case you need attach more paths, just add before the export
# E.g: PATH="$HOME/.local/bin:$PATH"
export PATH

# Evals
[[ -d "$PYENV_ROOT" ]] && eval "$(pyenv init --path)"
