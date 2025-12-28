if cmd_exists go; then
  path_add "$(go env GOPATH)/bin"
fi

export PATH

editor_set=""
if [ -n "$EDITOR" ]; then
  if [[ "$EDITOR" = /* ]]; then
    if [ -x "$EDITOR" ]; then
      editor_set="$EDITOR"
    fi
  elif cmd_exists "$EDITOR"; then
    editor_set="$EDITOR"
  fi
fi

if [ -z "$editor_set" ]; then
  if [ -x "$HOME/.local/bin/nvim" ]; then
    editor_set="$HOME/.local/bin/nvim"
  elif cmd_exists nvim; then
    editor_set="nvim"
  elif cmd_exists vim; then
    editor_set="vim"
  elif cmd_exists vi; then
    editor_set="vi"
  elif cmd_exists nano; then
    editor_set="nano"
  fi
fi

if [ -n "$editor_set" ]; then
  export EDITOR="$editor_set"
  export VISUAL="$editor_set"
  export SUDO_EDITOR="$editor_set"
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export GCM_CREDENTIAL_STORE=secretservice
#we now use starship for PROMPT_COMMAND stuff
#export PROMPT_COMMAND='echo -ne "\033]0; $USER@$(hostname) $(basename "$PWD") \007"'
path_add "$HOME/.local/bin"




if [[ $- == *i* ]]; then
  # set -o emacs
  # --- Zshy Vi-Insert Setup ---
  set -o vi
  # Use vi keybindings
  # Esc v will open current command in $VISUAL(=nvim)

    # Since ^D is delete in vi-insert
    set -o ignoreeof

    # --- THE GREAT COMPROMISE ---
    # Vi Purists will tell you that if your hands leave the 'hjkl' zone, 
    # you've already lost. They believe Ctrl-a is a relic of the "Emacsian 
    # Heresy"—an admission that you are too lazy to tap Esc and 0.
    #
    # But for those of us with Caps-as-Ctrl, we know the truth: 
    # Efficiency beats ideology. We move like Emacs in Insert Mode 
    # and strike like Vim in Normal Mode.

    # This lets you navigate history while Ctrl-j/k handles menus
    bind -m vi-insert '"\C-n": next-history' # muscle memory says this must be so
    bind -m vi-insert '"\C-p": previous-history' # muscle memory says this must be so

    # Optional: Make Tab enter the menu immediately (very zsh-like)
    bind -m vi-insert '"\C-i": menu-complete'
    # Kill (delete) from cursor to the end of the line
    bind -m vi-insert '"\C-k": kill-line'


    # backwards & ur forwards, forwards & ur backwards eezer is a geezer who should never be abused.
    bind -m vi-insert '"\C-a": beginning-of-line'
    bind -m vi-insert '"\C-e": end-of-line'

    # Character movement
    bind -m vi-insert '"\C-f": forward-char'
    bind -m vi-insert '"\C-b": backward-char'

    # Word movement (Alt-f and Alt-b)
    bind -m vi-insert '"\ef": forward-word'
    bind -m vi-insert '"\eb": backward-word'

    # Delete character forward (like the Delete key)
    bind -m vi-insert '"\C-d": delete-char'

    # Deletes from cursor to start of line (Emacs style, but oh so useful)
    bind -m vi-insert '"\C-u": unix-line-discard'

    # Insert a literal newline (Control-j)
    # This allows you to start a new line without executing the command
    bind -m vi-insert '"\C-j": "\C-v\C-j"'

    # --- CURSOR COLOR INDICATORS ---
    # --- Enable mode strings (Crucial!) --
    ## --- BLINKING MODE CURSORS ---

    # 1. Enable mode strings
    bind 'set show-mode-in-prompt on'

    # 2. Insert Mode: Blinking Bar + Green
    # \e[5 q = Blinking Bar (use \e[1 q for Blinking Block)
    bind 'set vi-ins-mode-string \1\e[5 q\e]12;green\a\2'

    # 3. Command Mode: Blinking Block + Red
    # \e[1 q = Blinking Block
    bind 'set vi-cmd-mode-string \1\e[1 q\e]12;darkred\a\2'

    # --- RESTORE THE 'GEEZER' CLEAR ---
    # Bind Ctrl-L to clear the screen in both Vi modes
    bind -m vi-insert '"\C-l": clear-screen'
    bind -m vi-command '"\C-l": clear-screen'

    # Ensure Starship plays nice
    export STARSHIP_VI_MODE_INDICATOR_REPLACE=1-

    # --- replace menu-complete with fzf ---
    if cmd_exists fzf; then
      eval "$(fzf --bash)"
      source <(fzf --bash)
    fi

    # Source fzf completion if present (keep fuzzy for **<Tab>)
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    # Or system one: /usr/share/doc/fzf/examples/completion.bash etc.
    # === Restore classic Tab cycling behavior ===
    # Unbind the fzf double-tab trigger
    bind -r '\C-i' 2>/dev/null  # Remove any existing Tab binding temporarily

    # Re-enable normal menu-complete cycling
    bind 'TAB:menu-complete'                  # First Tab: complete up to ambiguity
    bind 'set menu-complete-display-prefix on' # Show common prefix
    bind 'set colored-completion-prefix on'   # Color the prefix (nice)
    bind 'set show-all-if-ambiguous on'       # Show list only if still ambiguous after one Tab
    bind 'set completion-query-items 200'     # Don't ask "Display all X possibilities?"

    # Optional: backward cycling with Shift-Tab
    bind '"\e[Z": menu-complete-backward'

    # This forces the bash completion engine to use fzf as a popup
    #bind -x '"\t": fzf-completion'

    # --- sync LINES and COLUMNS with window size  ---
    #
    # check the window size after each command and, if necessary, 
    # update the values of LINES and COLUMNS.

    shopt -s checkwinsize
fi
