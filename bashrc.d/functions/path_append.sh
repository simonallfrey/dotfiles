# "$HOME/.bashrc.d/functions/path_append.sh"

path_append() {
  [ -z "$1" ] && return 1
  local dir="${1%/}"
  [ -d "$dir" ] || return 1
  
  # Only add if strictly not present
  if [[ ":$PATH:" != *":$dir:"* ]]; then
    # ${PATH:+"$PATH:"} -> If PATH set, print "$PATH:", else nothing
    export PATH="${PATH:+"$PATH:"}$dir"
  fi
}
