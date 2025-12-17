export PATH="$PATH:$(go env GOPATH)/bin"
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim
export GCM_CREDENTIAL_STORE=secretservice
#we now use starship for PROMPT_COMMAND stuff
#export PROMPT_COMMAND='echo -ne "\033]0; $USER@$(hostname) $(basename "$PWD") \007"'

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
