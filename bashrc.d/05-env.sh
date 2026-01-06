# ~/.bashrc.d/05-env.sh

## Scrub inherited PATH before we start adding our own
if type path_dedup >/dev/null 2>&1; then
    path_dedup
fi

#  --- Editor (Prioritize nvim) ---
any_empty "$FINAL_EDITOR" "$VISUAL" "$EDITOR" "$SUDO_EDITOR" && {
  if cmd_exists nvim; then 
    FINAL_EDITOR="nvim"
  elif [ -n "$EDITOR" ]; then 
    FINAL_EDITOR="$EDITOR"
  else 
    FINAL_EDITOR="vi";
  fi
  export FINAL_EDITOR
  export EDITOR="$FINAL_EDITOR"
  export SUDO_EDITOR="$FINAL_EDITOR"
  export VISUAL="$FINAL_EDITOR"
}

# --- Paths ---
path_append "$HOME/bin"
path_append -m "$HOME/.local/bin" # move it to the bottom of the list
[ -d "$HOME/.cargo/bin" ] && path_append "$HOME/.cargo/bin"
if cmd_exists go; then path_append "$(go env GOPATH)/bin"; fi

# --- NVM (Single Source) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export NNN_OPTS="Hdae"

#SJA fix below
export GCM_CREDENTIAL_STORE=secretservice

# Move Chrome's massive profile out of .config
export CHROME_USER_DATA_DIR="$HOME/.local/share/chrome-profile"



# --- XDG BASE DIRECTORY SPEC ---
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# --- THE CHROMIUM ESCAPE (XDG Style) ---
export CHROME_USER_DATA_DIR="$XDG_DATA_HOME/google-chrome"
export BRAVE_USER_DATA_DIR="$XDG_DATA_HOME/brave"
export EDGE_USER_DATA_DIR="$XDG_DATA_HOME/microsoft-edge"

# --- THE VS CODE FIX ---
# Note: Code is stubborn, so we point it to DATA_HOME
export VSCODE_APPDATA="$XDG_DATA_HOME/vscode-data"
export VSCODE_LOGS="$HOME/.local/share/vscode-logs"
