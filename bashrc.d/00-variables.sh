# Function to add a directory to PATH only if it exists and isn't already there
path_add() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$PATH:$1"
    fi
}

path_add "$(go env GOPATH)/bin"

export PATH
export EDITOR=/home/s/.local/bin/nvim
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR
export GCM_CREDENTIAL_STORE=secretservice
#we now use starship for PROMPT_COMMAND stuff
#export PROMPT_COMMAND='echo -ne "\033]0; $USER@$(hostname) $(basename "$PWD") \007"'


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
eval "$(fzf --bash)"
source <(fzf --bash)

# This forces the bash completion engine to use fzf as a popup
#bind -x '"\t": fzf-completion'

# --- sync LINES and COLUMNS with window size  ---
#
# check the window size after each command and, if necessary, 
# update the values of LINES and COLUMNS.

shopt -s checkwinsize
