# -----------------------------------------------------------------------------
# utility functions 
# -----------------------------------------------------------------------------

# path_prepend: Force a directory to the front of PATH.
# Destructive: Moves the directory if it is already elsewhere in the list.
path_prepend() {
    [ -z "$1" ] && return 1             # Fail on empty arg
    local dir="${1%/}"                  # Normalize: strip trailing slash
    [ -d "$dir" ] || return 1           # Fail if dir doesn't exist
    # 1. Wrap PATH in colons for safe matching
    local p=":$PATH:"
    # 2. Remove all existing instances of the dir
    p="${p//:$dir:/:}"
    # 3. Clean up leading/trailing colons
    p="${p#:}"
    p="${p%:}"
    # 4. Prepend safely (handles empty PATH edge case)
    export PATH="${dir}${p:+:$p}"
}
alias pp='path_prepend'  # High Priority (My tools)

# path_append: Ensure a directory exists at the end of PATH.
# Conservative: If the directory is ALREADY in PATH (even at the front),
# it does nothing. This preserves existing priority overrides.
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
alias pa='path_append'   # Low Priority  (System fallbacks)
# Function to add a directory to PATH only if it exists and isn't already there
alias path_add='path_append'
# Debugging: Visualize PATH
# -----------------------------------------------------------------------------
path_check() {
    echo "$PATH" | tr ':' '\n' | nl
}

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}
