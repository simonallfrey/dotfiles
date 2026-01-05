eval $(keychain --eval --quiet --nogui --agents ssh --noask id_ed25519)

if ssh-add -l >/dev/null 2>&1; then
  : # key(s) available
else
  echo "🔐 SSH key not unlocked, consider:"
  echo "ssh-add ~/.ssh/id_ed25519"
fi
