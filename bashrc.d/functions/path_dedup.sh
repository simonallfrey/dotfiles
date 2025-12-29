path_dedup() {
    # Associative array to track seen paths (requires Bash 4.0+)
    local -A seen
    local new_path=""
    local IFS=:
    
    # Loop through current PATH
    for dir in $PATH; do
        # If directory is not empty and hasn't been seen yet
        if [[ -n "$dir" && -z "${seen[$dir]}" ]]; then
            seen[$dir]=1
            # Append to new_path (handling the leading colon correctly)
            new_path="${new_path:+$new_path:}$dir"
        fi
    done
    
    export PATH="$new_path"
}
