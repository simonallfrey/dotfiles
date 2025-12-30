find_s25u() {
    # 1. Check the USB wire first (Fastest)
    local usb_ip=$(ip route show dev enx56b3c8e69dc6 2>/dev/null | grep default | awk '{print $3}')
    
    if [ -n "$usb_ip" ]; then
        echo "$usb_ip"
        return
    fi

    # 2. Check the local Wi-Fi subnet (Fallback)
    # This assumes your local network is 192.168.1.0/24; adjust as needed.
    # We use nmap for a fast port scan on 8022
    local lan_ip=$(nmap -p 8022 --open -n 192.168.1.0/24 | grep "Nmap scan report" | awk '{print $NF}')
    
    echo "$lan_ip"
}

# The Guru's SSH command
alias s25u_ssh='ssh u0_a671@$(find_s25u) -p 8022'
