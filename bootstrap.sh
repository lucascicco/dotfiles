#!/bin/bash

set -e

# Dotfiles' project root directory
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Main playbook
PLAYBOOK="$ROOTDIR/local.yml"

# Runs Ansible playbook using our user.
ansible-playbook "$PLAYBOOK" -e user=$USER --ask-become-pass

# Build neovim
# FIXME: Ansible fails the execution of this script
~/dotfiles/tasks/files/build/neovim.sh 

exit 0
