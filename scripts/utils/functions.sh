#!/bin/bash

function debug {
  echo "~ ${1} ~"
}

function info {
  echo -e "[INFO] ${1}"
}

function task {
  local -r task_name=$(echo "${1}" | tr '[:lower:]' '[:upper:]')
  local -r task_description="${2}"

  echo -e "[TASK] ${task_name} - ${task_description}"
}

function warning {
  echo -e "[WARN] ${1}"
}

function fatal {
  echo -e "[FATAL] ${1}"
}

function git_clone_or_pull {
  set +x
  local -r dir=${1}
  local -r repo=${2}
  local -r branch=${3}
  set -x

  if [ ! -d "${dir}" ]; then
    git clone -b "${branch}" "${repo}" "${dir}"
  fi
  (
    cd "${dir}" || return 1
    git pull origin "${branch}"
    git submodule update --init --recursive
  )
}

function download_file {
  set +x
  local -r dest=${1}
  local -r url=${2}
  set -x

  local -r tmp=$(mktemp)
  curl -4 -sSL -o "${tmp}" "${url}"

  if [ -f "${dest}" ]; then
    local -r old_md5=$(md5sum "${dest}" | cut -d ' ' -f 1)
    local -r new_md5=$(md5sum "${tmp}" | cut -d ' ' -f 1)
    if [ "${old_md5}" != "${new_md5}" ]; then
      local -r tmp2=$(mktemp)
      mv "${dest}" "${tmp2}"
    fi
  fi

  mv "${tmp}" "${dest}"
}

function download_executable {
  set +x
  local -r dest=${1}
  local -r url=${2}
  set -x

  if [ -z "${dest}" ] || [ -z "${url}" ]; then
    fatal "dest and url must be provided"
    return 1
  fi

  local -r tmp=$(mktemp)
  curl -sSL -o "${tmp}" "${url}"
  chmod +x "${tmp}"

  if [ -f "${dest}" ]; then
    local -r old_md5=$(md5sum "${dest}" | cut -d ' ' -f 1)
    local -r new_md5=$(md5sum "${tmp}" | cut -d ' ' -f 1)
    if [ "${old_md5}" != "${new_md5}" ]; then
      local -r tmp2=$(mktemp)
      mv "${dest}" "${tmp2}"
    fi
  fi

  mv "${tmp}" "${dest}"
}

function create_symlink {
  set +x
  local -r source_file=${1}
  local -r dest_file=${2}

  if [ -z "${source_file}" ] || [ -z "${dest_file}" ]; then
    fatal "source_file and dest_file must be provided"
    return 1
  fi

  if [ ! -f "$source_file" ] && [ ! -d "$source_file" ]; then
    warning "${source_file} is missing"
    return 1
  fi

  local -r os="$(uname)"
  local dest_symlink_path
  dest_symlink_path="$(readlink "$dest_file")"
  if [ "$os" == "Linux" ]; then
    dest_symlink_path="$(readlink -f "$dest_file")"
  fi

  if [ "$dest_symlink_path" != "$source_file" ]; then
    debug "updating symlink ${dest_file} -> ${source_file}"
    ln -f -s "$source_file" "$dest_file"
  fi

  set -x
}

function dynamic_batch_source {
  local -ra scripts=("$@")
  for s in "${scripts[@]}"; do
    if [ ! -s "$s" ]; then
      debug "Skipping $s. It does not exist."
      continue
    fi
    # shellcheck disable=1090
    source "$s"
  done
}

function _generate_dynamic_path {
  local -r paths=("$@")
  local new_path=""
  for p in "${paths[@]}"; do
    if [ ! -e "$p" ]; then
      continue
    fi
    new_path="$new_path:$p"
  done
  echo "$new_path"
}

function load_dynamic_paths() {
  local -ra paths=("$@")
  local -r dynamic_paths=$(_generate_dynamic_path "${paths[@]}")

  if [ -n "$dynamic_paths" ]; then
    PATH="$PATH$dynamic_paths"
  fi
}

function reload_zsh {
  local -r zshrc_path="$HOME/.zshrc"
  if [ -s "$zshrc_path" ]; then
    # shellcheck disable=1090
    source "$zshrc_path"
  fi
}

function switch_git_user() {
  local -r git_users_dir="$1"
  local -r gitconfig_file="$2"

  if [ ! -d "$git_users_dir" ]; then
    fatal "The directory $git_users_dir does not exist"
    return 1
  fi

  local -r target_config=$(
    find "$git_users_dir" -type f -name "*.cfg" | fzf --preview "cat {}"
  )
  if [ -z "$target_config" ]; then
    fatal "No file selected"
    return 1
  fi

  local -r target_config_file="$target_config"
  if [ ! -f "$target_config_file" ]; then
    fatal "The file $target_config_file does not exist"
    return 1
  fi

  info "Switching to $target_config"
  cp -f "$target_config_file" "$gitconfig_file"
  ln -f -s "$gitconfig_file" "$HOME/.gitconfig"
  info "Switched to $target_config with success!"

  info "Git user: $(git config user.name)"
  info "Git email: $(git config user.email)"

  local -r git_signingkey="$(git config user.signingkey)"
  local -r gpgsign_enabled="$(git config commit.gpgsign)"

  if [ -n "$git_signingkey" ]; then
    info "Git signingkey: $git_signingkey"
    info "GPG sign is enabled: $gpgsign_enabled"
  fi
}

function get_mise_binary_path() {
  local -r os="$(uname)"
  local mise_binary

  if [ "${os}" = "Darwin" ]; then
    mise_binary="/opt/homebrew/bin/mise"
  elif [ "${os}" = "Linux" ]; then
    mise_binary="${HOME}/.local/bin/mise"
  else
    fatal "Unsupported OS: ${os}"
    return 1
  fi

  echo "$mise_binary"
}

function get_fonts_directory() {
  local -r os="$(uname)"
  local fonts_dir

  if [ "${os}" = "Darwin" ]; then
    fonts_dir="${HOME}/Library/Fonts"
  elif [ "${os}" = "Linux" ]; then
    fonts_dir="${HOME}/.local/share/fonts"
  else
    fatal "Unsupported OS: ${os}"
    return 1
  fi

  echo "$fonts_dir"
}

function get_packages() {
  local -r packages_dir="${1}"
  local -r packages_file="${2}"

  local -r package_file_path="${packages_dir}/${packages_file}"
  if [ ! -f "$package_file_path" ]; then
    fatal "The file $package_file_path does not exist"
    return 1
  fi

  local -r package_list=$(tr '\n' ' ' <"$package_file_path")
  echo "$package_list"
}

function recursive_load_scripts() {
  local -r root_scripts_dir="${1}"

  if [ -d "$root_scripts_dir" ]; then
    find "$root_scripts_dir" -type f -name "*.sh" -print0 | while IFS= read -r -d '' file; do
      # shellcheck disable=1090
      source "$file"
    done
  fi
}
