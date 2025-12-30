#!/usr/bin/env bash

# List of paths to keep in sync between the live system and this repo.
# Each entry is formatted as:
#   /absolute/live/path|relative/path/inside/repo
# Extend this list when new dotfiles are added.
SYNC_ITEMS=(
  "$HOME/.bashrc|bashrc"
  "$HOME/.bashrc.d|bashrc.d"
  "$HOME/.config/nvim|config/nvim"
  "$HOME/.config/home-manager|config/home-manager"
  "$HOME/.config/starship.toml|config/starship.toml"
  "$HOME/.config/zellij|config/zellij"
  # binaries need to be specific to x86_64 (thiant) or aarch64 (s25u)
)
