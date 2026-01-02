# Return immediately if we are not in an interactive shell
[[ $- != *i* ]] && return

# --- Zshy Vi-Insert Setup ---
set -o vi
set -o ignoreeof

# Navigation & Editing Bindings
bind -m vi-insert '"\C-n": next-history' 
bind -m vi-insert '"\C-p": previous-history'
bind -m vi-insert '"\C-k": kill-line'
bind -m vi-insert '"\C-a": beginning-of-line'
bind -m vi-insert '"\C-e": end-of-line'
bind -m vi-insert '"\C-f": forward-char'
bind -m vi-insert '"\C-b": backward-char'
bind -m vi-insert '"\ef": forward-word'
bind -m vi-insert '"\eb": backward-word'
bind -m vi-insert '"\C-d": delete-char'
bind -m vi-insert '"\C-u": unix-line-discard'
bind -m vi-insert '"\C-j": "\C-v\C-j"'

# Optional: Make Tab enter the menu immediately (very zsh-like)
bind -m vi-insert '"\C-i": menu-complete'

# --- CURSOR COLOR INDICATORS ---
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[5 q\e]12;green\a\2'
bind 'set vi-cmd-mode-string \1\e[1 q\e]12;darkred\a\2'
bind -m vi-insert '"\C-l": clear-screen'
bind -m vi-command '"\C-l": clear-screen'

# --- SMART FZF & WILDCARD EXPANSION ---

export FZF_COMPLETION_OPTS='--height 40% --layout=reverse --border --info=inline'

_fzf_smart_tab() {
    # --- STEP A: Parse Context ---
    local text_before_cursor="${READLINE_LINE:0:READLINE_POINT}"
    local cur="${text_before_cursor##* }"
    
    local clean_line="${READLINE_LINE#"${READLINE_LINE%%[![:space:]]*}"}"
    local cmd_name="${clean_line%% *}"

    # --- STEP B: Generate Matches ---
    local matches=""
    # Flag to decide if we should pass the query to FZF
    local use_fzf_query=1

    # Check if the word contains glob characters (* or ?)
    if [[ "$cur" == *[*?]* ]]; then
        # It's a glob! Bash will filter the list for us.
        # We should NOT pass the query to FZF, or FZF will try to match 
        # the literal '*' character against the filenames and fail.
        use_fzf_query=0
    fi

    # 1. Define generator based on context
    if [[ "$cmd_name" == "cd" || "$cmd_name" == "pushd" ]]; then
        # CD Context: Standard dirs OR Globbed dirs
        local standard=$(compgen -d -- "$cur")
        local globs=""
        if [[ "$use_fzf_query" -eq 0 ]]; then
            # Manually filter compgen -G for directories
            for f in $(compgen -G -- "$cur"); do
                [ -d "$f" ] && globs+="$f"$'\n'
            done
        fi
        matches="$standard"$'\n'"$globs"
    else
        # Normal Context: Standard files OR Globbed files
        local standard=$(compgen -f -- "$cur")
        local globs=""
        if [[ "$use_fzf_query" -eq 0 ]]; then
            globs=$(compgen -G -- "$cur")
        fi
        matches="$standard"$'\n'"$globs"
    fi

    # Cleanup: Remove empty lines and duplicates
    matches=$(echo "$matches" | grep -v '^$' | sort -u)

    # Safety: Stop if nothing found
    if [ -z "$matches" ]; then return; fi

    # --- STEP C: Count & Handle Matches ---
    local match_count=$(echo "$matches" | grep -c -v '^$')

    if [ "$match_count" -eq 1 ]; then
        # --- CASE 1: Exact Match (Auto-Expand) ---
        local completion=$(echo "$matches" | head -n1)
        if [ -d "$completion" ]; then completion="$completion/"; fi
        
        # Robust Replacement
        local cur_len=${#cur}
        local cut_point=$(( READLINE_POINT - cur_len ))
        local pre_word="${READLINE_LINE:0:cut_point}"
        local post_cursor="${READLINE_LINE:$READLINE_POINT}"
        
        READLINE_LINE="${pre_word}${completion}${post_cursor}"
        READLINE_POINT=$(( ${#pre_word} + ${#completion} ))

    else
        # --- CASE 2: Ambiguous (FZF Popup) ---
        
        # Determine the query string for FZF
        local fzf_query="$cur"
        if [[ "$use_fzf_query" -eq 0 ]]; then
            fzf_query=""  # Clear query if it was a glob
        fi

        local selected=$(echo "$matches" | fzf \
            --bind 'tab:down,btab:up' \
            --cycle \
            --query="$fzf_query" \
            --select-1 \
            --exit-0)
        
        if [ -n "$selected" ]; then
            if [ -d "$selected" ]; then selected="$selected/"; fi
            
            local cur_len=${#cur}
            local cut_point=$(( READLINE_POINT - cur_len ))
            local pre_word="${READLINE_LINE:0:cut_point}"
            local post_cursor="${READLINE_LINE:$READLINE_POINT}"
            
            READLINE_LINE="${pre_word}${selected}${post_cursor}"
            READLINE_POINT=$(( ${#pre_word} + ${#selected} ))
        fi
    fi
}

# Ensure fzf is loaded first
if cmd_exists fzf; then eval "$(fzf --bash)"; fi

# First Tab: normal bash completion
bind -m vi-insert '"\C-i": complete'
bind '"\C-i": complete'

# Double-Tab: trigger fzf completion (uses ** + Tab)
bind -m vi-insert '"\C-i\C-i": "**\C-i"'
bind '"\C-i\C-i": "**\C-i"'

# Keep the wait short so single-Tab feels instant
bind 'set keyseq-timeout 120'

# Overwrite the Tab binding
# bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
# bind '"\C-i": complete' # This binds the 'complete' to the Tab key (Ctrl + i is equivalent to Tab)
# cind -m vi-insert -x '"\C-i": _fzf_smart_tab'
# cind -x '"\C-i": _fzf_smart_tab'

# bind '"\e[Z": menu-complete-backward' # This binds Shift + Tab to cycle backwardbind -x '"\t": _fzf_smart_tab'

shopt -s checkwinsize
