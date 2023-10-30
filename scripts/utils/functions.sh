#!/bin/bash

function debug {
  set +x
  echo "~ ${1} ~"
  set -x
}

function info {
  set +x
  echo
  echo "=== ${1} ==="
  echo
  set -x
}

function task {
  set +x
  echo
  echo "[TASK] ${1}"
  echo
  set -x
}

function warning {
  set +x
  echo
  echo "!!! ${1} !!!"
  echo
  set -x
}

function git_clone_or_pull {
  set +x
  DIR=${1}
  REPO=${2}
  BRANCH=${3}
  set -x

  if [ ! -d "${DIR}" ]; then
    git clone -b "${BRANCH}" "${REPO}" "${DIR}"
  fi
  (
    cd "${DIR}" || return 1
    git pull origin "${BRANCH}"
    git submodule update --init --recursive
  )
}

function download_executable {
  set +x
  DEST=${1}
  URL=${2}
  set -x

  TMP=$(mktemp)
  curl -sSL -o "${TMP}" "${URL}"
  chmod +x "${TMP}"

  if [ -f "${DEST}" ]; then
    OLD_MD5=$(md5sum "${DEST}" | cut -d ' ' -f 1)
    NEW_MD5=$(md5sum "${TMP}" | cut -d ' ' -f 1)
    if [ "${OLD_MD5}" != "${NEW_MD5}" ]; then
      TMP2=$(mktemp)
      mv "${DEST}" "${TMP2}"
    fi
  fi

  mv "${TMP}" "${DEST}"
}

function create_symlink {
  set +x
  SOURCE_FILE=${1}
  DEST_FILE=${2}

  if [ ! -f "$SOURCE_FILE" ] && [ ! -d "$SOURCE_FILE" ]; then
    warning "${SOURCE_FILE} is missing"
    return 1
  fi

  OS="$(uname)"
  DEST_SYMLINK_PATH="$(readlink "$DEST_FILE")"
  if [ "$OS" == "Linux" ]; then
    DEST_SYMLINK_PATH="$(readlink -f "$DEST_FILE")"
  fi

  if [ "$DEST_SYMLINK_PATH" != "$SOURCE_FILE" ]; then
    debug "updating symlink ${DEST_FILE} -> ${SOURCE_FILE}"
    ln -f -s "$SOURCE_FILE" "$DEST_FILE"
  fi
  set -x
}

function dynamic_batch_source {
  SCRIPTS=("$@")
  for SCRIPT in $SCRIPTS; do
    if [ ! -s "$SCRIPT" ]; then
      continue
    fi
    source "$SCRIPT"
  done
}

function dynamic_batch_load_path {
  PATHS=("$@")
  for P in ${PATHS}; do
    if [ ! -d "$P" ]; then
      continue
    fi
    PATH="$P:$PATH"
  done
}

function brew_install_or_upgrade {
  PKG="$1"
  ACTION="$(brew ls --versions bat | wc -l | xargs expr | sed 's/0/install/' | sed 's/1/upgrade/')"
  CMD="brew"
  CMD="$CMD $ACTION"
  if [[ "$2" == "cask" ]]; then
    shift 2
    CMD="$CMD --cask"
  else
    shift 1
  fi
  CMD="${CMD} ${PKG} ${*}"
  bash -c "$CMD"
}

function reload_zsh {
  ZSHRC_PATH="$HOME/.zshrc"
  [[ -s "$ZSHRC_PATH" ]] && source "${ZSHRC_PATH}"
}
