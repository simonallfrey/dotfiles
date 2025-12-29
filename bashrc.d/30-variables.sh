if cmd_exists go; then
  path_append "$(go env GOPATH)/bin"
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
path_append "$HOME/.local/bin"

