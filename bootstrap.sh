#!/bin/bash

set -e

ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK="$ROOTDIR/local.yml"
BUILD_FOLDER="$ROOTDIR/tasks/files/build"

ansible-playbook "$PLAYBOOK" -e user="$USER" --ask-become-pass -v

# Build neovim
"$BUILD_FOLDER/neovim.sh"
"$BUILD_FOLDER/lvim.sh"

set -x

exit 0
