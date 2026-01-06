{ pkgs, sonori, ... }:

{
  home.username = "s";
  home.homeDirectory = "/home/s";
  home.stateVersion = "24.11";

  imports = [ ./voice-typing.nix ];

  home.packages = with pkgs; [
    # --- Core Dependencies for your Functions ---
    python3
    jq
    starship

    # --- Terminal & Editors ---
    neovim
    kitty
    fzf

    # --- System Utilities ---
    fd
    dua
    gdu
    nnn
    fdupes
    nix-index
    nix-search-cli
    nixfmt-rfc-style

    # --- Navigation & Launchers ---
    rofi
    wofi
    tofi
    walker

    # --- Graphics & Voice Prep ---
    vulkan-loader
    vulkan-tools # Run 'vkcube' or 'vulkaninfo' to test
    ydotool
    wtype
    sonori.packages.${pkgs.system}.default

    # --- Development / Build Tools ---
    nodejs  # for Quartz/npx

    # --- Desktop & UI ---
    bibata-cursors
    hyprpaper
    gtk3
    gsettings-desktop-schemas
    libcanberra-gtk3
  ];

  # Hybrid-friendly hms wrapper — keeps your manual bash config untouched
  home.file.".local/bin/hms" = {
    text = ''
      #!/bin/bash
      exec home-manager switch --flake ~/.config/home-manager#s "$@"
    '';
    executable = true;
  };

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  # Keep disabled to preserve your portable manual bash config across machines
  programs.bash = {
    enable = false;
    enableCompletion = true;  # harmless and useful
  };

  # Enable Starship & FZF natively
  programs.starship.enable = true;

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
  };
}
