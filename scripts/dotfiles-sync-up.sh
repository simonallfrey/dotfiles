#!/usr/bin/env bash
set -euo pipefail

# --- HACK 1: PRINT EVERY COMMAND (Trace mode) ---
set -x

# --- HACK 2: GLOBAL PAUSE ON EXIT (Keeps terminal open) ---
trap 'set +x; echo -e "\n\n==> Done. Press Enter to close terminal."; read' EXIT

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

sync_to_repo() {
  local src="$1"
  local dest_rel="$2"
  local dest="$REPO_ROOT/$dest_rel"

  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    log "Syncing directory $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "$src/" "$dest/"
  elif [[ -e "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    log "Syncing file $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "$src" "$dest"
  else
    echo "Skipping missing source: $src" >&2
    return
  fi
}

main() {
  require_command git
  require_command rsync

  pushd "$REPO_ROOT"

  RSYNC_OPTS=(--archive --delete --human-readable --exclude ".git")

  for pair in "${SYNC_ITEMS[@]}"; do
    IFS="|" read -r live_path repo_rel <<<"$pair"
    sync_to_repo "$live_path" "$repo_rel"
  done

  if [[ -z "$(git status --porcelain)" ]]; then
    log "No changes to commit."
    exit 0
  fi

  git add -A
  COMMIT_MSG="${COMMIT_MSG:-Update dotfiles $(date +%Y-%m-%d)}"
  git commit -m "$COMMIT_MSG"
  git push
  popd
  return
}

main "$@"ain "$@"
