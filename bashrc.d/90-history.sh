init_history() {
  # only for interactive shells
  case $- in *i*) ;; *) return ;; esac

  histdir="$HOME/.bash_history.d"
  mkdir -p "$histdir"

  # per-shell history file: YYYYmmdd-HHMMSS.$PID.hist
  ts=$(date +%Y%m%d-%H%M%S%z)
  export HISTFILE="$histdir/${ts}.$$.hist"

  # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=99999
  HISTFILESIZE=99999

  # include timestamps in history lines
  HISTTIMEFORMAT='%F %T '

  # don't put duplicate lines in the history. See bash(1) for more options
  # ... or force ignoredups and ignorespace
  HISTCONTROL=ignoredups:ignorespace
  # append to the history file, don't overwrite it
  shopt -s histappend

  # start with an empty session file
  : >"$HISTFILE"

  # clear in-memory history
  history -c

  # load recent history files into memory (do not write them into this session file)
  shopt -s nullglob
  logs=("$histdir"/*.hist)
  shopt -u nullglob
  if (( ${#logs[@]} )); then
    IFS=$'\n' logs=($(printf '%s\n' "${logs[@]}" | sort))   # oldest first
    for f in "${logs[@]}"; do
      [[ $f == "$HISTFILE" ]] && continue
      history -r "$f"
    done
  fi

  # flush new commands from memory to this file at each prompt
  PROMPT_COMMAND='history -a'"${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

  # sanity check for large history (warn if approaching limits)
  _check_history_usage() {
    local count file_size
    count=$(history | wc -l)
    file_size=$(stat -c%s "$HISTFILE" 2>/dev/null || echo 0)
    if (( count > HISTSIZE * 9 / 10 )); then
      echo "Warning: history entries approaching HISTSIZE ($count / $HISTSIZE)" >&2
      echo "Consider pruning old .hist files in $histdir if needed." >&2
    fi
    if (( file_size > HISTFILESIZE * 9 / 10 )); then
      echo "Warning: history file size approaching HISTFILESIZE ($file_size / $HISTFILESIZE bytes)" >&2
      echo "Consider archiving/removing old .hist files in $histdir." >&2
    fi
  }

  PROMPT_COMMAND='_check_history_usage'"${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
}

# run history init once; call init_history manually to reinit in-session
if [[ -z $_HIST_INIT_DONE ]]; then
  init_history
  _HIST_INIT_DONE=1
fi
