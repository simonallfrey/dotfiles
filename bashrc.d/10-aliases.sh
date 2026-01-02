# $HOME/.bash.d/functions
alias cap='rerun_capture_last_command'
alias cdxlg='codex_log'
alias codexlog='codex_log'
alias ff='filter_fields'
alias pa='path_append'   
alias pp='path_prepend' 
alias redef='redefine_bash_function'
alias sc='comment_output'
alias tsss='time_stamp_with_seconds_and_separators'
alias tss='time_stamp_with_seconds'
alias ts='time_stamp'
alias tsv='time_stamp_verbose'


# $HOME/bin

# $HOME/.local/bin


# elsewhere
alias bashtrace="BASH_XTRACEFD=7 PS4='+ $:${LINENO}: ' bash -xlc 'exit' 7>/tmp/bash-startup.log; less /tmp/bash-startup.log"
command -v batcat >/dev/null && alias bat='batcat' # some call it batcat, some call it bat...
# Force the S25U to behave and the PC to grab the link
alias s25ux='/home/s/Code/scrcpy/scrcpy-linux-x86_64-v3.3.4/scrcpy --disable-screensaver --stay-awake --turn-screen-off --power-off-on-close'
alias fix-wire='
  adb shell svc usb setFunctions rndis; 
  sleep 1.2; 
  sudo nmcli device connect s25u0; 
  sudo nmcli connection modify "6cf88492-92f6-381f-93a3-1dd198106d45" ipv4.route-metric 100; 
  sudo nmcli connection up "6cf88492-92f6-381f-93a3-1dd198106d45"; 
  sleep 1.5; 
  ir; 
  /home/s/Code/scrcpy/scrcpy-linux-x86_64-v3.3.4/scrcpy --always-on-top --stay-awake --turn-screen-off --power-off-on-close &
'
alias g=tgpt
alias hg="tgpt<<'eof'"
#alias ir="ip route | awk '{dest=\$1; gw=\"-\"; if(\$2==\"via\") gw=\$3; dev=\"-\"; for(i=1;i<=NF;i++) if(\$i==\"dev\") dev=\$(i+1); met=\"-\"; for(i=1;i<=NF;i++) if(\$i==\"metric\") met=\$(i+1); printf \"%-20s %-15s %-10s %-6s\n\", dest, gw, dev, met}' | column -t"
alias ir="ip route | perl -lane '(\$g) = /via (\S+)/; (\$v) = /dev (\S+)/; (\$m) = /metric (\S+)/; printf \"%-18s %-15s %-10s %s\n\", \$F[0], \$g//\"-\", \$v//\"-\", \$m//\"-\"' | column -t"
alias lan-mouse='/usr/local/bin/lan-mouse'
alias sv='sudoedit'
alias v='nvim'
