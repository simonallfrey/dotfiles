#!/usr/bin/env bash 

#bootstrapping w/o path_append function

FDIR="$HOME/.bashrc.d/functions"

[ -z "$FDIR" ] && return 1
dir="${FDIR%/}"
[ -d "$dir" ] || return 1
# Only add if strictly not present
if [[ ":$PATH:" != *":$dir:"* ]]; then
  # ${PATH:+"$PATH:"} -> If PATH set, print "$PATH:", else nothing
  export PATH="${PATH:+"$PATH:"}$dir"
fi
