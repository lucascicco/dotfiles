#!/bin/bash

# Corp functions

DEVOPS_SANTANDER_PT_REPO="$HOME/devops-santander-portugal-support"

function disable_umbrella () {
   "$DOTFILES_SCRIPTS_DIR/umbrella.sh" -d
}

function watch_issues() {
  cd $DEVOPS_SANTANDER_PT_REPO && watch -i 60 --clear gh issue list
}

function open_issues() {
  cd $DEVOPS_SANTANDER_PT_REPO && gh issue list -w
}
