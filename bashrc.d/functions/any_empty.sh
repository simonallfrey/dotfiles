# "$HOME/.bashrc.d/functions/any_empty.sh"

# Returns 0 (true) if any argument is empty, 1 (false) otherwise
any_empty() {
    [[ -z "$1" ]] || { shift; [[ $# -gt 0 ]] && any_empty "$@"; }
}

# Usage
# any_empty "$VAR1" "$VAR2" "$VAR3" && nvim setup.sh
