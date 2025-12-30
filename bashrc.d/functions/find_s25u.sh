find_s25u() {
    # 1. Check for the USB wire gateway IP
    # We look for the 'default via' address specifically on your S25U interface
    local usb_ip=$(ip route show dev enx56b3c8e69dc6 2>/dev/null | grep default | awk '{print $3}')
    
    if [ -n "$usb_ip" ]; then
        echo "$usb_ip"
        return 0
    fi

    # 2. Fallback: Scan LAN for the S25U's SSH port
    # Adjust the IP range 192.168.1.0/24 to match your home network
    # -n (no DNS), -p (port), --open (only successful hits)
    local lan_ip=$(nmap -n -p 8022 --open 192.168.1.0/24 2>/dev/null | grep "Nmap scan report" | awk '{print $NF}')
    
    if [ -n "$lan_ip" ]; then
        echo "$lan_ip"
        return 0
    fi

    return 1
}

# The Alias: Integrates with your nvim/dev workflow
alias s25u='target=$(find_s25u); [ -n "$target" ] && ssh u0_a671@$target -p 8022 || echo "S25U not found on wire or LAN."'
