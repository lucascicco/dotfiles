#!/bin/bash

ROOTDIR="$HOME/dotfiles"

function run_ansible_for_linux {
  [[ "$(command -v ansible)" ]] || sudo apt-get install ansible -y
  PLAYBOOK="$ROOTDIR/linux.yml"
  [[ -f "$PLAYBOOK" ]] || (echo "Playbook file not found" && exit 1)
  ansible-playbook "$PLAYBOOK" -e user="$USER" --ask-become-pass -v "${@}"
}

function run_macos_bootstrap {
  bash "$ROOTDIR/files/scripts/bootstrap_macos.sh" "${@}"
}

function bootstrap {
	chmod +x -R "$ROOTDIR/files/build"
  OS=$(uname)
  case $OS in
    'Linux')
      run_ansible_for_linux "${@}"
      ;;
    'Darwin')
      run_macos_bootstrap "${@}"
      ;;
    *)
      echo "No bootstrap supported for the OS ($OS). Please try again on Linux or MacOs."
      exit 1
      ;;
  esac
}

bootstrap

exit 0
