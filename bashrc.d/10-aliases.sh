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

# $HOME/.local/bin

# $HOME/bin

# elsewhere
alias bashtrace="BASH_XTRACEFD=7 PS4='+ $:${LINENO}: ' bash -xlc 'exit' 7>/tmp/bash-startup.log; less /tmp/bash-startup.log"
alias bat='batcat'
alias g=tgpt
alias lan-mouse='/usr/local/bin/lan-mouse'
alias sv='sudoedit'
alias v='nvim'

