# "$HOME/.bashrc.d/functions/path_append.sh"

path_append() {
    local move_if_present=false
    
    # Check for flag
    if [[ "$1" == "-m" ]]; then
        move_if_present=true
        shift
    fi

    local dir="$1"
    
    # 1. Validation
    if [[ -z "$dir" || ! -d "$dir" ]]; then
        return 1
    fi

    # 2. Check existence
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        if [[ "$move_if_present" == "true" ]]; then
            # Remove the existing entry to prepare for re-appending
            # Wrap PATH in colons to make matching robust
            local temp_path=":$PATH:"
            temp_path="${temp_path//:$dir:/:}"
            # Strip leading/trailing colons
            temp_path="${temp_path#:}"
            temp_path="${temp_path%:}"
            PATH="$temp_path"
        else
            # It's there, and we aren't forcing a move -> Do nothing
            return 0
        fi
    fi

    # 3. Append
    PATH="${PATH:+"$PATH:"}$dir"
}
