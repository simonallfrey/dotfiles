# ~/.bashrc.d/15-nix.sh

# 1. Source the main Nix profile
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# 2. Hook up the Command-Not-Found handler (Manual Integration)
# This provides the "Divine Intent" to suggest Nix packages for missing commands
if [ -e "$HOME/.nix-profile/etc/profile.d/command-not-found.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/command-not-found.sh"
fi

# 3. Add Nix profile bins to your path using your custom function
# Your path_append function handles deduping and validation [cite: 114, 115]
if [ -d "$HOME/.nix-profile/bin" ]; then
    path_append "$HOME/.nix-profile/bin"
fi
