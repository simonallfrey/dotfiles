# "$HOME/.bashrc.d/functions/cpv.sh"

# Copy directory with a visual progress bar using tar and pv
cpv() {
    if [ $# -lt 2 ]; then
        echo "Usage: cpv /source/dir /dest/parent/dir"
        return 1
    fi

    local src="${1%/}"     # Remove trailing slash
    local src_base=$(basename "$src")
    local src_parent=$(dirname "$src")
    local dest="$2"

    echo "Calculating size for $src_base..."
    local size=$(du -sb "$src" | awk '{print $1}')

    tar -cf - -C "$src_parent" "$src_base" | \
        pv -s "$size" -N "Copying" | \
        tar -xf - -C "$dest"
}
