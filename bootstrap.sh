#!/bin/bash

set -e

# Dotfiles' project root directory
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Main playbook
PLAYBOOK="$ROOTDIR/local.yml"
# Build folder
BUILD_FOLDER="$ROOTDIR/tasks/files/build"

# Runs Ansible playbook using our user.
ansible-playbook "$PLAYBOOK" -e user=$USER --ask-become-pass -v

# Build neovim
# FIXME: Ansible fails the execution of this script
${BUILD_FOLDER}/neovim.sh 
${BUILD_FOLDER}/lvim.sh 

set -x

exit 0
