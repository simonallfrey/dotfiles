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

