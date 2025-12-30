find_s25u() {
    local verbose=false
    [[ "$1" == "-v" || "$1" == "--verbose" ]] && verbose=true
    
    local cache_file="$HOME/.config/s25u_last_ip"
    mkdir -p "$(dirname "$cache_file")"

    # --- 0. The Fast Path: Check Cached IP ---
    if [ -f "$cache_file" ]; then
        local cached_ip=$(<"$cache_file")
        [ "$verbose" = true ] && echo "Checking cached IP: $cached_ip..."
        
        # nc -z -w1 checks if the port is open with a 1-second timeout
        if nc -z -w1 "$cached_ip" 8022 2>/dev/null; then
            [ "$verbose" = true ] && echo "Cache hit! S25U is alive at $cached_ip"
            echo "$cached_ip"
            return 0
        fi
        [ "$verbose" = true ] && echo "Cache miss: $cached_ip is unreachable."
    fi

    # --- 1. Check for the USB wire gateway IP ---
    [ "$verbose" = true ] && echo "Checking USB interface enx56b3c8e69dc6..."
    local usb_ip=$(ip route show dev enx56b3c8e69dc6 2>/dev/null | grep default | awk '{print $3}')
    
    if [ -n "$usb_ip" ]; then
        [ "$verbose" = true ] && echo "Found S25U on USB: $usb_ip"
        echo "$usb_ip" > "$cache_file"
        echo "$usb_ip"
        return 0
    fi

    # --- 2. Fallback: Scan LAN (192.168.1.0/24) ---
    [ "$verbose" = true ] && echo "Scanning LAN for port 8022..."
    local lan_ip=$(nmap -n -p 8022 --open 192.168.1.0/24 2>/dev/null | grep "Nmap scan report" | awk '{print $NF}')
    
    if [ -n "$lan_ip" ]; then
        [ "$verbose" = true ] && echo "Found S25U on LAN: $lan_ip"
        echo "$lan_ip" > "$cache_file"
        echo "$lan_ip"
        return 0
    fi

    [ "$verbose" = true ] && echo "Error: S25U not found."
    return 1
}
