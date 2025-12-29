# --- Termux Locate Functions ---

# Guard: Return immediately if we are not in a Termux environment
[[ "$PREFIX" != *"com.termux"* ]] && return 0

# Define database paths
export LOCATE_PATH_CONTAINER="$PREFIX/var/mlocate/mlocate.db"
export LOCATE_PATH_STORAGE="$PREFIX/var/mlocate/mlocate-storage.db"

# 1. Update Index for Termux Container only (Fast)
termux-updatedb-container() {
    echo "Indexing Termux container ($PREFIX)..."
    mkdir -p "$(dirname "$LOCATE_PATH_CONTAINER")"
    
    updatedb -U "$PREFIX" \
             --output="$LOCATE_PATH_CONTAINER" \
             --prunepaths="/proc /sys /dev /data/data/com.termux/files/usr/tmp"
    echo "Done. Saved to $LOCATE_PATH_CONTAINER"
}

# 2. Update Index for Internal Storage (Slower)
termux-updatedb-storage() {
    if [ ! -d "$HOME/storage" ]; then
        echo "Error: Storage not accessible. Run 'termux-setup-storage' first."
        return 1
    fi

    echo "Indexing Internal Storage ($HOME/storage)..."
    mkdir -p "$(dirname "$LOCATE_PATH_STORAGE")"

    updatedb -U "$HOME/storage" \
             --output="$LOCATE_PATH_STORAGE" \
             --prunepaths="$HOME/storage/Android" 
    echo "Done. Saved to $LOCATE_PATH_STORAGE"
}

# 3. Search wrapper (Searches BOTH databases)
tlocate() {
    local db_list=""
    
    # Dynamically build the list based on which DBs exist
    [ -f "$LOCATE_PATH_CONTAINER" ] && db_list="$LOCATE_PATH_CONTAINER"
    
    if [ -f "$LOCATE_PATH_STORAGE" ]; then
        if [ -n "$db_list" ]; then
            db_list="$db_list:$LOCATE_PATH_STORAGE"
        else
            db_list="$LOCATE_PATH_STORAGE"
        fi
    fi

    if [ -z "$db_list" ]; then
        echo "No databases found. Run 'termux-updatedb-container' or 'termux-updatedb-storage' first."
        return 1
    fi

    locate -d "$db_list" "$@"
}
