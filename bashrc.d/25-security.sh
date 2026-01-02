if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    # Optionally auto-add keys (will prompt for passphrase in terminal)
    ssh-add ~/.ssh/id_ed25519 2>/dev/null || true
fi

# --- keychain: manage ssh-agent headlessly ---
eval $(keychain --eval --quiet --nogui --agents ssh id_ed25519)

