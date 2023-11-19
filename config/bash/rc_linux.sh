#!/bin/bash

BASE_CONFIG="$HOME/dotfiles/config/bash/rc.sh"
[[ -s "$BASE_CONFIG" ]] && source $BASE_CONFIG

LOCAL_BUILD_DIR="$HOME/.local_build"
GOOGLE_CLOUD_SDK_DIR="$LOCAL_BUILD_DIR/google-cloud-sdk"

GCLOUD_SDK_SOURCES=(
  "$GOOGLE_CLOUD_SDK_DIR/path.zsh.inc"
  "$GOOGLE_CLOUD_SDK_DIR/completion.zsh.inc"
)
dynamic_batch_source "${GCLOUD_SDK_SOURCES[@]}"

# Paths
# In case you need attach more paths, just add before the export
# E.g: PATH="$HOME/.local/bin:$PATH"
export PATH
