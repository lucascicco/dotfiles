#!/usr/bin/env zsh

GIT_SYNC_CONFIG_BASE="${DOTFILES_DIR:-$HOME/.dotfiles}/config/git-sync/repos.yaml"
GIT_SYNC_CONFIG_LOCAL="${XDG_CONFIG_HOME:-$HOME/.config}/git-sync/repos.yaml"

# Check if yq is available (required for YAML parsing)
_git_sync_check_deps() {
  if ! command -v yq &>/dev/null; then
    echo "Warning: yq is not installed. git-sync aliases will not be created." >&2
    echo "Install with: brew install yq (macOS) or mise use -g yq" >&2
    return 1
  fi
  return 0
}

_git_sync_check_internet() {
  local host="${1:-github.com}"
  # Try to list refs from a public repository (no auth required)
  if git ls-remote "https://$host/git/git.git" HEAD >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Auto-sync function: _git_sync_auto_sync <host> <branch1> <branch2> ...
_git_sync_auto_sync() {
  local -r host="${1:-github.com}"
  shift
  local -r current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  local -r current_status="$(git status --porcelain 2>/dev/null)"
  local -ri changed_file_count="$(echo "$current_status" | grep -v '^$' | wc -l | tr -d ' ')"
  local -a branches=("$@")

  # If no branches specified, default to current branch only
  if [[ ${#branches[@]} -eq 0 ]]; then
    branches=("$current_branch")
  fi

  # Fetch all branches (only if internet is up)
  if _git_sync_check_internet "$host"; then
    echo "Fetching all branches..."
    git fetch --all --jobs=3 --progress 2>&1
  else
    echo "No internet connection to $host. Skipping fetch."
    return 1
  fi

  # Check for uncommitted changes
  if [[ "$changed_file_count" -gt 0 ]]; then
    echo "[$current_branch] Skipping sync due to uncommitted changes."
    echo "Run 'git stash' to save your changes first."
    return 1
  fi

  # Checkout and pull each branch
  local branch
  for branch in "${branches[@]}"; do
    echo "Syncing branch: $branch"

    # Check if branch exists
    if ! git show-ref --verify --quiet "refs/heads/$branch" &&
      ! git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      echo "Warning: Branch '$branch' does not exist. Skipping."
      continue
    fi

    # Checkout the branch
    if ! git checkout "$branch" 2>/dev/null; then
      echo "Failed to checkout branch: $branch"
      continue
    fi

    # Pull with rebase (only if internet is up)
    if _git_sync_check_internet "$host"; then
      if ! git pull --rebase 2>&1; then
        echo "Failed to pull branch: $branch"
        git checkout "$current_branch" 2>/dev/null
        return 1
      fi
    fi
  done

  # Return to original branch
  if [[ "$current_branch" != "$(git rev-parse --abbrev-ref HEAD)" ]]; then
    git checkout "$current_branch" 2>/dev/null
  fi

  echo "Sync completed successfully."
}

# Create aliases from YAML config
_git_sync_create_aliases() {
  local config_file="$1"

  if [[ ! -f "$config_file" ]]; then
    return 1
  fi

  if ! _git_sync_check_deps; then
    return 1
  fi

  # Read repo aliases
  local -a repo_names
  repo_names=($(yq -r '.repos | keys | .[]' "$config_file" 2>/dev/null))

  for alias_name in "${repo_names[@]}"; do
    local dir_path branches_raw host
    dir_path=$(yq -r ".repos.\"$alias_name\".path" "$config_file" 2>/dev/null)
    dir_path="${dir_path/#\~/$HOME}" # Expand ~
    host=$(yq -r ".repos.\"$alias_name\".host // \"github.com\"" "$config_file" 2>/dev/null)

    if [[ -d "$dir_path" ]]; then
      # Get branches as space-separated string
      branches_raw=$(yq -r ".repos.\"$alias_name\".branches | .[]" "$config_file" 2>/dev/null | tr '\n' ' ')

      # Create the alias
      eval "alias $alias_name='cd \"$dir_path\" && _git_sync_auto_sync \"$host\" $branches_raw'"
    fi
  done

  # Read simple aliases (just cd, no sync)
  local -a simple_names
  simple_names=($(yq -r '.simple_aliases | keys | .[]' "$config_file" 2>/dev/null))

  for alias_name in "${simple_names[@]}"; do
    local dir_path
    dir_path=$(yq -r ".simple_aliases.\"$alias_name\"" "$config_file" 2>/dev/null)
    dir_path="${dir_path/#\~/$HOME}"

    if [[ -d "$dir_path" ]]; then
      eval "alias $alias_name='cd \"$dir_path\"'"
    fi
  done
}

# Sync all configured repos in parallel
# Usage: git-sync-all [config_file]
git-sync-all() {
  if ! _git_sync_check_deps; then
    return 1
  fi

  local -a configs
  if [[ -n "$1" ]]; then
    configs=("$1")
  else
    configs=("$GIT_SYNC_CONFIG_BASE" "$GIT_SYNC_CONFIG_LOCAL")
  fi

  local config_file dir_path host branches_raw
  local -a repo_names pids=() repos=()

  for config_file in "${configs[@]}"; do
    [[ ! -f "$config_file" ]] && continue

    repo_names=($(yq -r '.repos | keys | .[]' "$config_file" 2>/dev/null))

    for alias_name in "${repo_names[@]}"; do
      dir_path=$(yq -r ".repos.\"$alias_name\".path" "$config_file" 2>/dev/null)
      dir_path="${dir_path/#\~/$HOME}"

      [[ ! -d "$dir_path" ]] && continue

      host=$(yq -r ".repos.\"$alias_name\".host // \"github.com\"" "$config_file" 2>/dev/null)
      branches_raw=$(yq -r ".repos.\"$alias_name\".branches | .[]" "$config_file" 2>/dev/null | tr '\n' ' ')

      repos+=("$alias_name")
      (cd "$dir_path" && _git_sync_auto_sync "$host" $branches_raw) &
      pids+=($!)
    done
  done

  local -i success=0 failed=0 i=1
  for pid in "${pids[@]}"; do
    if wait "$pid"; then
      echo "[OK] ${repos[$i]}"
      ((success++))
    else
      echo "[FAIL] ${repos[$i]}"
      ((failed++))
    fi
    ((i++))
  done

  echo ""
  echo "Sync complete: $success succeeded, $failed failed"
}

# Initialize aliases from base config, then local config (local overrides base)
for _config in "$GIT_SYNC_CONFIG_BASE" "$GIT_SYNC_CONFIG_LOCAL"; do
  [[ -f "$_config" ]] && _git_sync_create_aliases "$_config"
done
unset _config

# --- Main function ---
pick_and_git_sync() {
  local projects_dir="$HOME/projects"
  local selected_rel="$1"

  # If no argument, show fzf picker
  if [[ -z "$selected_rel" ]]; then
    selected_rel=$(find "$projects_dir" -mindepth 2 -maxdepth 2 -type d | awk -F/ '{print $(NF-1) "/" $NF}' | fzf --prompt="Select project dir: ")
    if [[ -z "$selected_rel" ]]; then
      echo "No directory selected."
      return 1
    fi
  fi

  local full_path="$projects_dir/$selected_rel"

  if [[ ! -d "$full_path" ]]; then
    echo "Selected path does not exist: $full_path"
    return 1
  fi

  echo "Selected: $selected_rel"
  cd "$full_path" || return 1

  # Infer all local branches
  if [ ! -d .git ]; then
    echo "Not a git repository: $full_path"
    return 1
  fi

  all_branches=("${(@f)$(git branch --format='%(refname:short)')}")

  if [[ ${#all_branches[@]} -eq 0 ]]; then
    echo "No branches found in this repository."
    return 1
  fi

  local host="github.com"

  _git_sync_auto_sync "$host" "${all_branches[@]}"
}
