#re-run and capture output of last command
cap() {
  local quiet=0
  # parse flags: -q / --quiet
  while [[ $# -gt 0 ]]; do
    case $1 in
      -q|--quiet) quiet=1; shift ;;
      *) break ;;
    esac
  done

  local cmd
  cmd=$(fc -ln -1) || return 1   # get previous command text
  (( quiet == 0 )) && printf 'Re-running: %s\n' "$cmd" >&2
  out=$({ eval "$cmd"; } 2>&1)   # capture stdout+stderr
  (( quiet == 0 )) && printf '$out = %s\n' "$out" >&2
  cap_status=$?                         # exit code
  (( quiet == 0 )) && printf '$cap_status = %s\n' "$cap_status" >&2
}

#aliases
alias timestamp='date +"%Y%m%d%H%M"'
alias timestamp_with_seconds='date +"%Y%m%d%H%M%S"'
alias v='nvim'
alias g=tgpt
alias lan-mouse='/usr/local/bin/lan-mouse'
alias bashtrace="BASH_XTRACEFD=7 PS4='+ ${BASH_SOURCE}:${LINENO}: ' bash -xlc 'exit' 7>/tmp/bash-startup.log; less /tmp/bash-startup.log"

# view codex conversation logs with timestamps (default: latest)
codexlog() {
  local dir="$HOME/.codex/sessions"
  local file
  # gather logs recursively
  shopt -s globstar nullglob
  local logs=("$dir"/**/*.jsonl)
  shopt -u globstar nullglob
  if (( ${#logs[@]} == 0 )); then
    echo "No codex session logs found under $dir" >&2
    return 1
  fi
  # sort reverse-chronological by path
  IFS=$'\n' logs=($(printf '%s\n' "${logs[@]}" | sort -r))
  local total=${#logs[@]}
  local sel=0
  local window=5
  local key input

  draw_menu() {
    tput clear
    echo "Select codex log (j/down, k/up, Enter to open, q to quit)"
    local start=$(( sel - window/2 ))
    (( start < 0 )) && start=0
    local end=$(( start + window ))
    (( end > total )) && end=$total
    (( end - start < window && start > 0 )) && start=$(( end - window ))
    (( start < 0 )) && start=0
    local i
    for (( i=start; i<end; i++ )); do
      local mark=" "
      (( i == sel )) && mark=">"
      printf "%s %3d %s\n" "$mark" "$((i+1))" "${logs[i]}"
    done
  }

  draw_menu
  while IFS= read -rsn1 key; do
    case "$key" in
      ""|$'\r'|$'\n') break ;;
      q) return 1 ;;
      j) (( sel < total-1 )) && (( sel++ )) ;;
      k) (( sel > 0 )) && (( sel-- )) ;;
      *) ;;
    esac
    draw_menu
  done
  file=${logs[sel]}
  tput clear
  printf 'Opening: %s\n\n' "$file"
  jq -r '
    select(
      (.type=="event_msg" and .payload.type=="agent_message") or
      (.type=="response_item" and .payload.type=="message" and .payload.role=="user")
    )
    | {ts:.timestamp, role:(.payload.role // "agent"),
       text:(.payload.message // (.payload.content[]?.text // empty))}
    | "\(.ts) [\(.role)]:\n\(.text)\n\n-----\n"
  ' "$file" | less
}
