#!/usr/bin/env bash
# -e: exit on error, -u: error on unset var, -o pipefail: fail on pipe errors
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

usage() {
  cat <<'EOF'
Usage: dotfiles-sync-up.sh [--delete]

  --delete   Remove files in the repo that are not present in the live source.
EOF
}

confirm() {
  local prompt="$1"
  local reply
  if [[ -t 0 ]]; then
    read -r -p "$prompt " reply
  else
    if [[ "${DOTFILES_SYNC_ASSUME_YES:-}" == "1" ]]; then
      return 0
    fi
    echo "Refusing to proceed without a TTY. Set DOTFILES_SYNC_ASSUME_YES=1 to override." >&2
    return 1
  fi
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

sync_to_repo_preview() {
  local src="$1"
  local dest_rel="$2"
  local dest="$REPO_ROOT/$dest_rel"

  if [[ -d "$src" ]]; then
    log "Previewing directory $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "${DRY_RUN_OPTS[@]}" "$src/" "$dest/"
  elif [[ -e "$src" ]]; then
    log "Previewing file $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "${DRY_RUN_OPTS[@]}" "$src" "$dest"
  else
    echo "Skipping missing source: $src" >&2
    return
  fi
}

preview_deletions() {
  local src="$1"
  local dest_rel="$2"
  local dest="$REPO_ROOT/$dest_rel"
  local delete_lines

  [[ -d "$src" ]] || return 0

  delete_lines=$(rsync "${RSYNC_OPTS_BASE[@]}" --delete "${DRY_RUN_OPTS[@]}" \
    "$src/" "$dest/" 2>/dev/null | grep -E '(^\\*deleting |^deleting )' || true)
  if [[ -n "$delete_lines" ]]; then
    printf '==> Deletions disabled for %s. Use --delete to apply:\n' "$dest"
    printf '%s\n' "$delete_lines"
  fi
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
  local delete_requested=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --delete) delete_requested=1; shift ;;
      -h|--help) usage; return 0 ;;
      *) break ;;
    esac
  done

  require_command git
  require_command rsync

  pushd "$REPO_ROOT"

  RSYNC_OPTS_BASE=(--archive --human-readable --exclude ".git")
  RSYNC_OPTS=("${RSYNC_OPTS_BASE[@]}")
  (( delete_requested )) && RSYNC_OPTS+=(--delete)
  DRY_RUN_OPTS=(--dry-run --itemize-changes)

  log "Previewing changes (dry-run)"
  for pair in "${SYNC_ITEMS[@]}"; do
    IFS="|" read -r live_path repo_rel <<<"$pair"
    sync_to_repo_preview "$live_path" "$repo_rel"
    if (( ! delete_requested )); then
      preview_deletions "$live_path" "$repo_rel"
    fi
  done

  if ! confirm "Proceed with sync? [y/N]"; then
    log "Sync cancelled."
    exit 1
  fi

  for pair in "${SYNC_ITEMS[@]}"; do
    IFS="|" read -r live_path repo_rel <<<"$pair"
    sync_to_repo "$live_path" "$repo_rel"
  done

  if [[ -z "$(git status --porcelain)" ]]; then
    log "No changes to commit."
    exit 0
  fi

  log "Changes detected:"
  git status --short
  if ! confirm "Commit these changes? [y/N]"; then
    log "Skipping commit and push."
    exit 0
  fi

  git add -A
  COMMIT_MSG="${COMMIT_MSG:-Update dotfiles $(date +%Y-%m-%d)}"
  git commit -m "$COMMIT_MSG"
  if confirm "Push to remote? [y/N]"; then
    git push
  else
    log "Skipping push."
  fi
  popd
  return
}

main "$@"
