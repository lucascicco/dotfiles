#!/bin/bash

ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=$(source "$ROOTDIR/files/scripts/get_os.sh")
PLAYBOOK="$ROOTDIR/$OS.yml"

function run_ansible {
  [ -f "$PLAYBOOK" ] || (echo "Playbook file not found" && exit 1)
  ansible-playbook "$PLAYBOOK" -e user="$USER" --ask-become-pass -v
}

run_ansible

exit 0
