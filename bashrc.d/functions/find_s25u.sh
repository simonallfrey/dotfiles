#!/bin/bash
# ~/.bashrc.d/functions/find_s25u.sh

find_s25u() {
    local verbose=false
    [[ "$1" == "-v" || "$1" == "--verbose" ]] && verbose=true
    
    local cache_file="$HOME/.config/s25u_last_ip"
    local wire_interface="enx56b3c8e69dc6"
    local port=8022

    # --- 1. THE WIRE (Safe: Targeted Probe) ---
    if [ -d "/sys/class/net/$wire_interface" ]; then
        local operstate=$(<"/sys/class/net/$wire_interface/operstate")
        if [[ "$operstate" == "up" ]]; then
            local usb_ip=$(ip route show dev "$wire_interface" 2>/dev/null | grep default | awk '{print $3}')
            if [[ -n "$usb_ip" ]] && nc -z -w1 "$usb_ip" "$port" 2>/dev/null; then
                [ "$verbose" = true ] && echo >&2 "Connection Nature: High-speed Wire detected ($usb_ip)"
                echo "$usb_ip" > "$cache_file"
                echo "$usb_ip"
                return 0
            fi
        fi
    fi

    # --- 2. THE CACHE (Safe: Targeted Probe) ---
    if [ -f "$cache_file" ]; then
        local cached_ip=$(<"$cache_file")
        if nc -z -w1 "$cached_ip" "$port" 2>/dev/null; then
            [ "$verbose" = true ] && echo >&2 "Connection Nature: Verified Cache ($cached_ip)"
            echo "$cached_ip"
            return 0
        fi
    fi

    # --- 3. THE LAN SCAN (Legal Guard Required) ---
    echo -e >&2 "\n\033[1;33m--- LEGAL DISCLAIMER ---\033[0m"
    echo >&2 "Unauthorized port scanning may violate local laws (CFAA in US, CMA in UK) or"
    echo >&2 "ISP Terms of Service. Indiscriminate scanning can trigger IDS alerts, fill"
    echo >&2 "security logs, or crash fragile IoT devices."
    echo -e >&2 "Do you have explicit authorization to scan 192.168.1.0/24? [y/N] "
    
    # read -n 1 from /dev/tty ensures it works inside a $(...) subshell
    read -n 1 -r confirmation < /dev/tty
    echo >&2 # move to a new line
    
    if [[ ! $confirmation =~ ^[Yy]$ ]]; then
        echo >&2 "Scan aborted by user."
        return 1
    fi

    [ "$verbose" = true ] && echo >&2 "Proceeding with authorized LAN scan..."
    local lan_ip=$(nmap -n -p "$port" --open 192.168.1.0/24 2>/dev/null | grep "Nmap scan report" | awk '{print $NF}')
    
    if [ -n "$lan_ip" ]; then
        [ "$verbose" = true ] && echo >&2 "Connection Nature: Found via LAN scan ($lan_ip)"
        echo "$lan_ip" > "$cache_file"
        echo "$lan_ip"
        return 0
    fi

    return 1
}
