# "$HOME/.bashrc.d/functions/set_term_bg_by_host

set_term_bg_by_host() {
  case "${TERM_HOSTNAME}" in
    thiant)
      # pure black
      printf '\e]11;#000009\a'
      ;;
    s-Precision-Tower-7810)
      # very dark red (calm, not glaring)
      printf '\e]11;#000900\a'
      ;;
    *)
      # reset to GNOME Terminal profile default
      printf '\e]111\a'
      ;;
  esac
}
