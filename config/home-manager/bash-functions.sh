# === CUSTOM UTILITIES ===

# Redefine a bash function on the fly
redef() {
    local func_name=$1
    local tmp_file=$(mktemp)
    declare -f "$func_name" > "$tmp_file"
    nvim "$tmp_file"
    if [ -s "$tmp_file" ]; then
        source "$tmp_file"
        echo "Function '$func_name' redefined."
    fi
    rm "$tmp_file"
}

# Wrapper to comment output for cut and paste
sc() {
  "$@" | sed 's/^/# /'
}

# Capture output of the last command
cap() {
  local quiet=0
  while [[ $# -gt 0 ]]; do
    case $1 in
      -q|--quiet) quiet=1; shift ;;
      *) break ;;
    esac
  done

  local cmd
  cmd=$(fc -ln -1) || return 1
  (( quiet == 0 )) && printf 'Re-running: %s\n' "$cmd" >&2
  out=$({ eval "$cmd"; } 2>&1)
  (( quiet == 0 )) && printf '$out = %s\n' "$out" >&2
  cap_status=$?
  (( quiet == 0 )) && printf '$cap_status = %s\n' "$cap_status" >&2
}

# === LOG VIEWERS & COMPLEX SCRIPTS ===

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
    ( cat "$file"; tail -f "$file" ) | jq -r --unbuffered "$filter" ${out:+ >> "$out"}
  else
    jq -r "$filter" "$file" ${out:+ > "$out"}
  fi
}

all_history() {
  python3 - <<'PY'
import pathlib, re, time, sys
histdir = pathlib.Path.home() / ".bash_history.d"
files = sorted(histdir.glob("*.hist"))
if not files: sys.exit("No history files in ~/.bash_history.d")
entries = []
for path in files:
    m = re.match(r"(\d{8})-(\d{6})\.(\d+)\.hist", path.name)
    pid_from_name = m.group(3) if m else "?"
    file_ts = None
    if m:
        try:
            file_ts = time.strftime("%Y-%m-%d %H:%M:%S", time.strptime(m.group(1) + m.group(2), "%Y%m%d%H%M%S"))
        except: file_ts = None
    lines = path.read_text().splitlines()
    pending_time = None
    for line in lines:
        if line.startswith("#"):
            ts_str = line.lstrip("# ").strip()
            try: pending_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(int(ts_str)))
            except: pending_time = None
            continue
        if not line.strip(): continue
        stamp = pending_time or file_ts or "????-??-?? ??:??:??"
        entries.append((stamp, pid_from_name, line))
entries.sort(key=lambda x: (x[0], x[1]))
last_pid = None
for t, pid, cmd in entries:
    if pid != last_pid:
        sys.stdout.write(f"\n=== pid {pid} ===\n")
        last_pid = pid
    sys.stdout.write(f"{t} [{pid}] {cmd}\n")
PY
}

# === TERMINAL BACKGROUND LOGIC ===

set_term_bg_by_host() {
  case "${HOSTNAME}" in
    thiant) printf '\e]11;#000009\a' ;;
    s-Precision-Tower-7810) printf '\e]11;#000900\a' ;;
    *) printf '\e]111\a' ;;
  esac
}

set_term_bg() {
  if [[ -n "$_TERM_BG_OVERRIDE" ]]; then
    printf '\e]11;%s\a' "$_TERM_BG_OVERRIDE"
  else
    set_term_bg_by_host
  fi
}

choose_term_bg() {
  local color channel="r" step=1 key r g b orig
  color="${_TERM_BG_OVERRIDE:-#000000}"
  orig="$color"
  parse_rgb() {
    local hex=${color#\#}
    r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
  }
  rebuild_color() { color=$(printf '#%02X%02X%02X' "$r" "$g" "$b"); }
  apply_color() { printf '\e]11;%s\a' "$color"; }
  parse_rgb; apply_color
  echo "Adjust background: r/g/b channel, j/k -/+ $step, Enter accept, q cancel, 'host' reset."
  while true; do
    printf '\r\033[K[%s] %s > ' "$channel" "$color"
    IFS= read -rsn1 key || break
    if [[ -z "$key" ]]; then _TERM_BG_OVERRIDE="$color"; echo; return 0; fi
    case "$key" in
      q) color="$orig"; _TERM_BG_OVERRIDE="$orig"; apply_color; echo; return 1 ;;
      r|g|b) channel="$key" ;;
      j|k)
        parse_rgb
        case "$channel" in
          r) if [[ "$key" == "j" ]]; then (( r-=step )); else (( r+=step )); fi ;;
          g) if [[ "$key" == "j" ]]; then (( g-=step )); else (( g+=step )); fi ;;
          b) if [[ "$key" == "j" ]]; then (( b-=step )); else (( b+=step )); fi ;;
        esac
        (( r<0 )) && r=0; (( r>255 )) && r=255
        (( g<0 )) && g=0; (( g>255 )) && g=255
        (( b<0 )) && b=0; (( b>255 )) && b=255
        rebuild_color; apply_color; printf '\r'
        ;;
      *)
        IFS= read -rs line
        line="$key$line"
        if [[ "$line" == "host" ]]; then
          _TERM_BG_OVERRIDE=""; set_term_bg_by_host; echo; return 0
        fi
        ;;
    esac
  done
}

# === STARSHIP & WINDOW TITLE DISPATCH ===

starship_precmd_dispatch() {
  printf '\033]0;%s@%s: %s STARSHIP\007' "$USER" "${HOSTNAME%%.*}" "$PWD"
  set_term_bg
}

# === HISTORY INITIALIZATION ===

init_history() {
  case $- in *i*) ;; *) return ;; esac
  histdir="$HOME/.bash_history.d"
  mkdir -p "$histdir"
  ts_file=$(date +%Y%m%d-%H%M%S)
  export HISTFILE="$histdir/${ts_file}.$$.hist"
  HISTSIZE=99999; HISTFILESIZE=99999; HISTTIMEFORMAT='%F %T '
  HISTCONTROL=ignoredups:ignorespace
  shopt -s histappend
  : >"$HISTFILE"; history -c
  shopt -s nullglob
  logs=("$histdir"/*.hist)
  shopt -u nullglob
  if (( ${#logs[@]} )); then
    IFS=$'\n' logs=($(printf '%s\n' "${logs[@]}" | sort))
    for f in "${logs[@]}"; do
      [[ $f == "$HISTFILE" ]] && continue
      history -r "$f"
    done
  fi
  # Note: PROMPT_COMMAND is managed by Starship/Home Manager, 
  # but we can append our history logic here.
  PROMPT_COMMAND='history -a; '"$PROMPT_COMMAND"
}
