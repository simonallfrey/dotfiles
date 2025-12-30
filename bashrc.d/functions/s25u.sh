s25u() {
    local target
    local verbose=false
    local args=()

    # Separate our flags from SSH commands
    for arg in "$@"; do
        if [[ "$arg" == "-v" || "$arg" == "--verbose" ]]; then
            verbose=true
        else
            args+=("$arg")
        fi
    done

    if [ "$verbose" = true ]; then
        target=$(find_s25u -v)
    else
        target=$(find_s25u)
    fi

    if [ -n "$target" ]; then
        ssh u0_a671@"$target" -p 8022 "${args[@]}"
    else
        return 1
    fi
}
