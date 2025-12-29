# ~/.bashrc.d/00-init.sh
# Load all function definitions immediately
if [ -d "$HOME/.bashrc.d/functions" ]; then
    for func_file in "$HOME/.bashrc.d/functions"/*.sh; do
        [ -r "$func_file" ] && . "$func_file"
    done
fi
# Initialize Hostname logic early (used for terminal BG and Prompts)
init_hostname
