#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/sync-items.sh"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

log() {
  printf '==> %s\n' "$*"
}

sync_to_home() {
  local repo_rel="$1"
  local dest="$2"
  local src="$REPO_ROOT/$repo_rel"

  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    log "Syncing directory $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "$src/" "$dest/"
  elif [[ -e "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    log "Syncing file $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "$src" "$dest"
  else
    echo "Skipping missing repository path: $src" >&2
    return
  fi
}

main() {
  require_command git
  require_command rsync

  cd "$REPO_ROOT"

  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree has local changes; commit or stash before pulling." >&2
    exit 1
  fi

  git pull --rebase --autostash

  RSYNC_OPTS=(--archive --delete --human-readable)

  for pair in "${SYNC_ITEMS[@]}"; do
    IFS="|" read -r live_path repo_rel <<<"$pair"
    sync_to_home "$repo_rel" "$live_path"
  done
}

main "$@"
