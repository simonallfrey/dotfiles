#!/usr/bin/env bash

# List of paths to keep in sync between the live system and this repo.
# Each entry is formatted as:
#   /absolute/live/path|relative/path/inside/repo
# Extend this list when new dotfiles are added.
SYNC_ITEMS=(
  "$HOME/.config/home-manager|config/home-manager"
  "$HOME/.bashrc|bashrc"
  "$HOME/.bashrc.d|bashrc.d"
  "$HOME/.config/starship.toml|config/starship.toml"
  "$HOME/.config/zellij|config/zellij"
  "$HOME/.config/nvim|config/nvim"
)
