# "$HOME/.bashrc.d/functions/set_term_bg

set_term_bg() {
  if [[ -n "$_TERM_BG_OVERRIDE" ]]; then
    printf '\e]11;%s\a' "$_TERM_BG_OVERRIDE"
  else
    set_term_bg_by_host
  fi
}
