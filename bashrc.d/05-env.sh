# ~/.bashrc.d/05-env.sh

## Scrub inherited PATH before we start adding our own
if type path_dedup >/dev/null 2>&1; then
    path_dedup
fi

#  --- Editor (Prioritize nvim) ---
if [ -z "$FINAL_EDITOR" ]; then
  if cmd_exists nvim; then FINAL_EDITOR="nvim"
  elif [ -n "$EDITOR" ]; then FINAL_EDITOR="$EDITOR"
  else FINAL_EDITOR="vi"; fi
  export FINAL_EDITOR
  export EDITOR="$FINAL_EDITOR"
  export VISUAL="$FINAL_EDITOR"
fi

# --- Paths ---
path_append "$HOME/bin"
path_append -m "$HOME/.local/bin" # move it to the bottom of the list
[ -d "$HOME/.cargo/bin" ] && path_append "$HOME/.cargo/bin"
if cmd_exists go; then path_append "$(go env GOPATH)/bin"; fi

# --- NVM (Single Source) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export GCM_CREDENTIAL_STORE=secretservice
