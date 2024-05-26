#!/bin/bash

readonly BASE_RC_CONFIG="$HOME/dotfiles/config/bash/rc.sh"
if [[ -s "$BASE_RC_CONFIG" ]]; then
  # shellcheck disable=1090
  source "$BASE_RC_CONFIG"
else
  echo "No base rc config found at $BASE_RC_CONFIG" >&2
  exit 1
fi
