# bashrc.d

These are my Bash rc fragments, synced from `~/.bashrc.d`.

- `00-variables.sh`: core environment/paths.
- `70-functions.sh`: helper functions and CLI utilities (e.g., `codexlog`, history viewer).
- `80-starship.sh`: Starship prompt and terminal tweaks.
- `90-history.sh`: history settings and per-session history file setup.

Update by copying from `~/.bashrc.d/`:
```bash
rsync -a --delete ~/.bashrc.d/ /home/s/Code/dotfiles/bashrc.d/
```
