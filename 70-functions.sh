# re-run and capture output of last command


#redefine a bash function
redef() {
    local func_name=$1
    local tmp_file=$(mktemp)
    
    # 1. Dump the function definition to a temp file
    declare -f "$func_name" > "$tmp_file"
    
    # 2. Open in nvim
    nvim "$tmp_file"
    
    # 3. Source the modified file back into the current shell
    if [ -s "$tmp_file" ]; then
        source "$tmp_file"
        echo "Function '$func_name' redefined."
    fi
    
    rm "$tmp_file"
}

# A simple wrapper function
# comments output for cut and paste commands
function sc() {
  "$@" | sed 's/^/# /'
}

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

# aliases
alias timestamp='date +"%Y%m%d%H%M"'
alias ts='date +"%Y%m%d%H%M"'
alias ts2='date +"%Y-%m-%d_%H.%M.%S"'
alias timestamp_with_seconds='date +"%Y%m%d%H%M%S"'
alias v='nvim'
alias g=tgpt
alias lan-mouse='/usr/local/bin/lan-mouse'
alias bashtrace="BASH_XTRACEFD=7 PS4='+ ${BASH_SOURCE}:${LINENO}: ' bash -xlc 'exit' 7>/tmp/bash-startup.log; less /tmp/bash-startup.log"

# view codex conversation logs (default: latest)
codexlog() {
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

# view all bash history files (chronological, grouped by PID from filename)
all_history() {
  python3 - <<'PY'
import pathlib, re, time, sys

histdir = pathlib.Path.home() / ".bash_history.d"
files = sorted(histdir.glob("*.hist"))  # oldest -> newest
if not files:
    sys.exit("No history files in ~/.bash_history.d")

entries = []
for path in files:
    m = re.match(r"(\d{8})-(\d{6})\.(\d+)\.hist", path.name)
    pid_from_name = m.group(3) if m else "?"
    file_ts = None
    if m:
        try:
            file_ts = time.strftime(
                "%Y-%m-%d %H:%M:%S",
                time.strptime(m.group(1) + m.group(2), "%Y%m%d%H%M%S"),
            )
        except Exception:
            file_ts = None
    lines = path.read_text().splitlines()
    pending_time = None
    for line in lines:
        if line.startswith("#"):
            # accept both "# 123" and "#123" forms
            ts_str = line.lstrip("# ").strip()
            try:
                pending_time = time.strftime("%Y-%m-%d %H:%M:%S",
                                             time.localtime(int(ts_str)))
            except Exception:
                pending_time = None
            continue
        if not line.strip():
            continue
        stamp = pending_time or file_ts or "????-??-?? ??:??:??"
        entries.append((stamp, pid_from_name, line))

# sort by time string (ISO-like) then pid to stabilize
entries.sort(key=lambda x: (x[0], x[1]))

last_pid = None
for t, pid, cmd in entries:
    if pid != last_pid:
        sys.stdout.write(f"\n=== pid {pid} ===\n")
        last_pid = pid
    sys.stdout.write(f"{t} [{pid}] {cmd}\n")
PY
}
