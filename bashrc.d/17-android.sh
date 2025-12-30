# --- Android / S25U Guru Setup ---

# High-performance Vision (scrcpy) for USB 3.2
# --stay-awake: prevents lock screen death
# --turn-screen-off: saves phone battery/OLED
alias vision='target=$(find_s25u); scrcpy --tcpip=$target:5555 --stay-awake --turn-screen-off --video-bit-rate=16M --max-fps=120 --video-codec=h265'

# Fast file push using your path_append style logic
alias s25u-push='adb push'
alias s25u-pull='adb pull'
