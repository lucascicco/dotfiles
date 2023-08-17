#!/bin/bash

PLUGIN_BASE_DIR="/opt/cisco/anyconnect/bin/plugins"
PLUGIN_DISABLED_DIR="$PLUGIN_BASE_DIR/disabled"
DISABLED_PLG_OFF_FILE="$PLUGIN_DISABLED_DIR/.off"

PLUGINS=(
  libacumbrellaplugin
  libacswgplugin
  libacumbrellaapi
  libacumbrellactrl
)

function check_status {
  [[ -f "$DISABLED_PLG_OFF_FILE" ]] || echo "on" && echo "off"
}

function switch() {
  ACTION=$1 # on/off
  echo "[INFO] Switching umbrella related plugins $ACTION"
  for P in "${PLUGINS[@]}"; do
    set -x
    PLG="$P.dylib"
    PLG_FP="$PLUGIN_BASE_DIR/$PLG"
    PLG_DISABLED_FP="$PLUGIN_DISABLED_DIR/$PLG"
    if [[ "$ACTION" == "off" ]]; then
      sudo mv -f "$PLG_FP" "$PLG_DISABLED_FP"
    else
      sudo mv -f "$PLG_DISABLED_FP" "$PLG_FP"
    fi
    set +x
  done
}

function main() {
  [[ -d "$PLUGIN_DISABLED_DIR" ]] || sudo mkdir -p "$PLUGIN_DISABLED_DIR"
  CURRENT_STATUS="$(check_status)"
  ACTION="on"
  if [[ "$1" == "-d" ]]; then
    ACTION="off"
  fi
  if [[ "$ACTION" == "$CURRENT_STATUS" ]]; then
    echo "[WARN] the umbrella is already $CURRENT_STATUS"
    exit 0
  fi
  if [[ "$ACTION" == "off" ]]; then
    switch off && sudo touch "$DISABLED_PLG_OFF_FILE"
    exit 0
  fi
  switch on && sudo rm -rf "$DISABLED_PLG_OFF_FILE"
}

main "${@}"

exit 0
