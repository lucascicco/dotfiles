#!/bin/bash

# Corp functions

DEVOPS_SANTANDER_PT_REPO="$HOME/devops-santander-portugal-support"

function disable_umbrella() {
  "$DOTFILES_SCRIPTS_DIR/corp/umbrella.sh" -d
}

function sync_all_devopslibs() {
  cd "$HOME/projects/santander/others/devopslibs-local-pkg-manager" || exit 1
  devopslibs_installer sync_all --reset -c "$HOME/.devopslibs.cfg.yaml"
}

function watch_issues() {
  cd "$DEVOPS_SANTANDER_PT_REPO" && watch -i 60 --clear gh issue list
}

function open_issues() {
  cd "$DEVOPS_SANTANDER_PT_REPO" && gh issue list -w
}
