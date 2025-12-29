# "$HOME/.bashrc.d/functions/choose_term_bg

choose_term_bg() {
  local color channel="r" step=1 key r g b orig

  # start from override or simple default
  color="${_TERM_BG_OVERRIDE:-#000000}"
  orig="$color"

  parse_rgb() {
    local hex=${color#\#}
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
  }

  rebuild_color() {
    color=$(printf '#%02X%02X%02X' "$r" "$g" "$b")
  }

  apply_color() {
    printf '\e]11;%s\a' "$color"
  }

  parse_rgb
  apply_color
  
  echo "Adjust background: r/g/b to select channel, j/k to -/+ $step, Enter accept, q to cancel, host to reset."
  
  while true; do
    printf '\r\033[K[%s] %s > ' "$channel" "$color"
    IFS= read -rsn1 key || break
  
    # Enter accepts
    if [[ -z "$key" ]]; then
      _TERM_BG_OVERRIDE="$color"
      echo
      return 0
    fi
  
    case "$key" in
      q)
        color="$orig"
        _TERM_BG_OVERRIDE="$orig"
        apply_color
        echo
        return 1
        ;;
      r|g|b)
        channel="$key"
        ;;
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
        rebuild_color
        apply_color
        printf '\r'
        ;;
      h)
        echo "Commands: r/g/b select channel, j dec, k inc, Enter accept, q cancel, type 'host' to reset."
        ;;
      *)
        # allow typing 'host' quickly
        if [[ "$key" == "h" ]]; then
          :
        fi
        # read rest of line to see if user typed 'host'
        IFS= read -rs line
        line="$key$line"
        if [[ "$line" == "host" ]]; then
          _TERM_BG_OVERRIDE=""
          set_term_bg_by_host
          echo
          return 0
        fi
        ;;
    esac
  done
}
