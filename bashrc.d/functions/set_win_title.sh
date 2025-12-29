# "$HOME/.bashrc.d/functions/set_win_title"

set_win_title() {
  # printf '\033]0;%s@%s: %s \007' "$USER" "${HOSTNAME%%.*}" "$(reverse_pwd ${PWD})"
  local HN=${TERM_HOSTNAME%%.*} 
  HN=${HN^^} # to upper case
  printf '\033]0;%s %s \007' "${HN}" "$(reverse_pwd ${PWD})"
}

