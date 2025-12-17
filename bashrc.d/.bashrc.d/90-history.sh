# in ~/.bashrc, for interactive shells only
case $- in *i*) ;; *) return ;; esac

histdir="$HOME/.bash_history.d"
mkdir -p "$histdir"

# per-shell history file: YYYYmmdd-HHMMSS.$PID.hist
ts=$(date +%Y%m%d-%H%M%S)
export HISTFILE="$histdir/${ts}.$$.hist"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=99999
HISTFILESIZE=99999

# optional: timestamp history entries
HISTTIMEFORMAT='%F %T '

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace
# append to the history file, don't overwrite it
shopt -s histappend

# seed this session’s file from existing histories (in order), skipping the new one
shopt -s nullglob
this_hist="$HISTFILE"
{
  for f in "$histdir"/*.hist; do
    [[ $f == "$this_hist" ]] && continue
    cat "$f"
  done
} >"$HISTFILE"
shopt -u nullglob
: >>"$HISTFILE"   # ensure it exists

# align in-memory history with the new file
history -c
history -r

# flush new commands from memory to this file at each prompt
PROMPT_COMMAND='history -a'"${PROMPT_COMMAND:+;$PROMPT_COMMAND}"



