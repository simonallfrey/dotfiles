# ~/.bashrc.d/90-theme.sh

# 1. Apply Dynamic Background (uses functions/set_term_bg.sh)
# Only applies in interactive mode
if [[ $- == *i* ]]; then
    set_term_bg
fi

# 2. Initialize Starship
# Ensure Starship plays nice with Vi mode
export STARSHIP_VI_MODE_INDICATOR_REPLACE=1-
eval "$(starship init bash)"

# 3. Hook window title and background logic into Starship
export STARSHIP_WIN_TITLE=set_win_title
starship_precmd_dispatch() {
  eval "${STARSHIP_WIN_TITLE}"
  set_term_bg
}
starship_precmd_user_func="starship_precmd_dispatch"
