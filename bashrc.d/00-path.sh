#!/usr/bin/env bash 

# Load custom function definitions
if [ -d "$HOME/.bashrc.d/functions" ]; then
    for func_file in "$HOME/.bashrc.d/functions"/*.sh; do
        [ -r "$func_file" ] && source "$func_file"
    done
fi

if cmd_exists go; then
  path_append "$(go env GOPATH)/bin"
fi

path_append "$HOME/.local/bin"
