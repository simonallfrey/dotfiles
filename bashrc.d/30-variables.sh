# If EDITOR is set, non-empty, and executable (or a valid command), keep it.
# -z is zero length string
# -n is non-zero length string
# -x is executable
if [ -z "$FINAL_EDITOR" ]; then
  if [ -n "$EDITOR" ] && { [ -x "$EDITOR" ] || cmd_exists "$EDITOR"; }; then
      FINAL_EDITOR="$EDITOR"
  # Otherwise, look for fallbacks in order of preference
  elif cmd_exists nvim; then
      FINAL_EDITOR="nvim"
  elif [ -x "$HOME/.local/bin/nvim" ]; then
      FINAL_EDITOR="$HOME/.local/bin/nvim"
  elif cmd_exists vim; then
      FINAL_EDITOR="vim"
  elif cmd_exists vi; then
      FINAL_EDITOR="vi"
  elif cmd_exists nano; then
      FINAL_EDITOR="nano"
  fi
  
  # Export variables if a valid editor was found
  if [ -n "$FINAL_EDITOR" ]; then
      export FINAL_EDITOR # idempotency, will short circuit next time
      export EDITOR="$FINAL_EDITOR"
      export VISUAL="$FINAL_EDITOR"
      export SUDO_EDITOR="$FINAL_EDITOR"
  fi
fi

if [ -z "$NVM_DIR" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

export GCM_CREDENTIAL_STORE=secretservice

