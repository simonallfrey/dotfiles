# $HOME.bashrc.d/functions/init_hostname.sh

init_hostname() {
  # Hostname Logic: User Preference > Cached File > System Default
  if [ -z "$TERM_HOSTNAME" ]; then
    local config_file="$HOME/.config/my_hostname"

    # 1. If config doesn't exist, bootstrap it with the system default
    if [ ! -f "$config_file" ]; then
        mkdir -p "$(dirname "$config_file")"
        # Sanitize: output of hostname might contain newlines/spaces
        hostname | tr -d '[:space:]' > "$config_file"
    fi

    # 2. Read the config into the environment
    # We use a custom variable to avoid fighting the shell's auto-setting of $HOSTNAME
    export TERM_HOSTNAME="$(<"$config_file")"
  fi
}
