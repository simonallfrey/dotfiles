# $HOME/.bashrc.d/functions/codex_log.sh

codex_log() {
  local follow=0 out=
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--follow) follow=1; shift ;;
      -o|--out) out=$2; shift 2 ;;
      *) break ;;
    esac
  done
  
  local dir="$HOME/.codex/sessions" file
  shopt -s globstar nullglob
  local logs=("$dir"/**/*.jsonl)
  shopt -u globstar nullglob
  (( ${#logs[@]} )) || { echo "No codex session logs in $dir" >&2; return 1; }
  
  IFS=$'\n' logs=($(printf '%s\n' "${logs[@]}" | sort -r))
  local total=${#logs[@]} sel=0 window=5 key
  
    draw_menu() {
      tput clear
      echo "Select codex log (j/down, k/up, Enter open, q quit)"
      local start=$(( sel - window/2 )); (( start < 0 )) && start=0
      local end=$(( start + window )); (( end > total )) && end=$total
      (( end - start < window && start > 0 )) && start=$(( end - window ))
      (( start < 0 )) && start=0
      local i
      for (( i=start; i<end; i++ )); do
        printf "%s %3d %s\n" $([[ $i == $sel ]] && echo ">" || echo " ") $((i+1)) "${logs[i]}"
      done
    }
  
  draw_menu
  while IFS= read -rsn1 key; do
    case "$key" in
      ""|$'\r'|$'\n') break ;;
      q) return 1 ;;
      j) (( sel < total-1 )) && (( sel++ )) ;;
      k) (( sel > 0 )) && (( sel-- )) ;;
    esac
    draw_menu
  done
  
  file=${logs[sel]}
  tput clear
  printf 'Opening: %s\n\n' "$file"
  
  local filter='
  select(
    (.type=="event_msg" and .payload.type=="agent_message") or
    (.type=="response_item" and .payload.type=="message" and .payload.role=="user")
  )
  | {ts:.timestamp, role:(.payload.role // "agent"),
  text:(.payload.message // (.payload.content[]?.text // empty))}
  | "\(.ts) [\(.role)]:\n\(.text)\n\n-----\n"
  '
  
  if (( follow )); then
    # stream existing content, then follow updates (unbuffered)
    if [[ -n "$out" ]]; then
      ( cat "$file"; tail -f "$file" ) | jq -r --unbuffered "$filter" >> "$out"
    else
      ( cat "$file"; tail -f "$file" ) | jq -r --unbuffered "$filter"
    fi
  else
    if [[ -n "$out" ]]; then
      jq -r "$filter" "$file" > "$out"
    else
      jq -r "$filter" "$file"
    fi
  fi
}
