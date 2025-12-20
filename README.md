My .config files etc

## Sync helpers

- `scripts/dotfiles-sync-up.sh` rsyncs live files into the repo, then commits and pushes (`COMMIT_MSG` overrides the default message).
- `scripts/dotfiles-sync-down.sh` pulls latest changes and rsyncs them into place on the machine; it refuses to run with a dirty worktree.
- Paths tracked are listed in `scripts/sync-items.sh` (`live_path|repo_relative_path`); extend that list as new dotfiles are added.
