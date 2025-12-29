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

usage() {
  cat <<'EOF'
Usage: dotfiles-sync-down.sh [--delete]

  --delete   Remove files in the live destination that are not present in the repo.
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

preview_deletions() {
  local src="$1"
  local dest="$2"
  local delete_lines

  [[ -d "$src" ]] || return 0

  delete_lines=$(rsync "${RSYNC_OPTS_BASE[@]}" --delete "${DRY_RUN_OPTS[@]}" \
    "$src/" "$dest/" 2>/dev/null | grep -E '(^\\*deleting |^deleting )' || true)
  if [[ -n "$delete_lines" ]]; then
    printf '==> Deletions disabled for %s. Use --delete to apply:\n' "$dest"
    printf '%s\n' "$delete_lines"
  fi
}

sync_to_home_preview() {
  local repo_rel="$1"
  local dest="$2"
  local src="$REPO_ROOT/$repo_rel"

  if [[ -d "$src" ]]; then
    log "Previewing directory $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "${DRY_RUN_OPTS[@]}" "$src/" "$dest/"
  elif [[ -e "$src" ]]; then
    log "Previewing file $src -> $dest"
    rsync "${RSYNC_OPTS[@]}" "${DRY_RUN_OPTS[@]}" "$src" "$dest"
  else
    echo "Skipping missing repository path: $src" >&2
    return
  fi
}

stash_current_config() {
  local stash_root="${DOTFILES_STASH_ROOT:-${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-stash}"
  local timestamp
  local stash_dir
  local rsync_opts=(--archive --human-readable)

  timestamp="$(date +%Y%m%d-%H%M%S)"
  stash_dir="$stash_root/$timestamp"

  mkdir -p "$stash_dir"
  log "Stashing current config to $stash_dir"

  for pair in "${SYNC_ITEMS[@]}"; do
    local live_path
    local repo_rel
    local dest

    IFS="|" read -r live_path repo_rel <<<"$pair"
    dest="$stash_dir/$repo_rel"

    if [[ -d "$live_path" ]]; then
      mkdir -p "$dest"
      rsync "${rsync_opts[@]}" "$live_path/" "$dest/"
    elif [[ -e "$live_path" ]]; then
      mkdir -p "$(dirname "$dest")"
      rsync "${rsync_opts[@]}" "$live_path" "$dest"
    else
      echo "Skipping missing live path: $live_path" >&2
    fi
  done

  log "Stash complete: $stash_dir"
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

  cd "$REPO_ROOT"

  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree has local changes; commit or stash before pulling." >&2
    exit 1
  fi

  git pull --rebase --autostash

  RSYNC_OPTS_BASE=(--archive --human-readable --exclude ".git")
  RSYNC_OPTS=("${RSYNC_OPTS_BASE[@]}")
  (( delete_requested )) && RSYNC_OPTS+=(--delete)
  DRY_RUN_OPTS=(--dry-run --itemize-changes)

  log "Previewing changes (dry-run)"
  for pair in "${SYNC_ITEMS[@]}"; do
    IFS="|" read -r live_path repo_rel <<<"$pair"
    sync_to_home_preview "$repo_rel" "$live_path"
  done

  if (( ! delete_requested )); then
    log "Deletions disabled (use --delete to apply)."
    for pair in "${SYNC_ITEMS[@]}"; do
      IFS="|" read -r live_path repo_rel <<<"$pair"
      preview_deletions "$REPO_ROOT/$repo_rel" "$live_path"
    done
  fi

  if ! confirm "Proceed with sync from repo to live (stash will be created)? [y/N]"; then
    log "Sync cancelled."
    exit 1
  fi

  stash_current_config

  for pair in "${SYNC_ITEMS[@]}"; do
    IFS="|" read -r live_path repo_rel <<<"$pair"
    sync_to_home "$repo_rel" "$live_path"
  done
}

main "$@"
