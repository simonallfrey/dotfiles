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

    # --- Desktop & UI ---
    bibata-cursors
    hyprpaper
    gtk3
    gsettings-desktop-schemas
    libcanberra-gtk3
  ];
  programs.home-manager.enable = true;

  programs.bash = {
    # enabling this will have nix overwrite existing .bashrc .profile (etc?)
    enable = false;
    enableCompletion = true;

    # 1. Your Global Variables & PATH (from 00-variables.sh)
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      GCM_CREDENTIAL_STORE = "secretservice";
      PATH = "$PATH:~/.local/bin";
      STARSHIP_VI_MODE_INDICATOR_REPLACE = "1-";
    };

    # 2. Your Aliases (from 70-functions.sh)
    shellAliases = {
      hms = "home-manager switch --flake ~/.config/home-manager#s";
      timestamp = "date +'%Y%m%d%H%M'";
      ts = "date +'%Y%m%d%H%M'";
      timestamp_with_seconds = "date +'%Y%m%d%H%M%S'";
      v = "nvim";
      g = "tgpt";
      lan-mouse = "/usr/local/bin/lan-mouse";
      bashtrace = "BASH_XTRACEFD=7 PS4='+ \${BASH_SOURCE}:\${LINENO}: ' bash -xlc 'exit' 7>/tmp/bash-startup.log; less /tmp/bash-startup.log";
    };

    # 3. Shell Options & Inputrc (The "Vi Purist" bindings)
    shellOptions = [
      "checkwinsize"
      "histappend"
      "globstar"
      "dotglob"
    ];

    # This replaces your 'bind' commands cleanly
    initExtra = ''
      # --- Vi Mode & Bindings (from 00-variables.sh) ---
      set -o vi
      set -o ignoreeof

      # Emacs-style movement in Insert Mode
      bind -m vi-insert '"\C-n": next-history'
      bind -m vi-insert '"\C-p": previous-history'
      bind -m vi-insert '"\C-a": beginning-of-line'
      bind -m vi-insert '"\C-e": end-of-line'
      bind -m vi-insert '"\C-f": forward-char'
      bind -m vi-insert '"\C-b": backward-char'
      bind -m vi-insert '"\C-k": kill-line'
      bind -m vi-insert '"\C-u": unix-line-discard'
      bind -m vi-insert '"\C-l": clear-screen'
      bind -m vi-command '"\C-l": clear-screen'

      # Cursor Mode Indicators
      bind 'set show-mode-in-prompt on'
      bind 'set vi-ins-mode-string \1\e[5 q\e]12;green\a\2'
      bind 'set vi-cmd-mode-string \1\e[1 q\e]12;darkred\a\2'

      # --- function definitions are outsourced ---
      ${builtins.readFile ./bash-functions.sh}

      # Tell Starship to run our background/title dispatch
      export starship_precmd_user_func="starship_precmd_dispatch"

      # --- FORCE FZF TO USE FD FOR **<TAB> COMPLETION ---
      export FZF_COMPLETION_TRIGGER='**'

      # Use fd (with hidden files) for file completion
      _fzf_compgen_path() {
        fd --hidden --follow --exclude ".git" . "$1"
      }

      # Use fd (with hidden files) for directory completion (cd **<tab>)
      _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude ".git" . "$1"
      }

      # --- History Logic ---
      # (Calling the function defined in bash-functions.sh)
      if [[ -z $_HIST_INIT_DONE ]]; then
        init_history
        _HIST_INIT_DONE=1
      fi
    '';
  };

  # Enable Starship & FZF natively
  programs.starship.enable = true;

  # Optimized FZF Configuration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    # Use 'fd' instead of 'find' for lightning-fast file searching
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    # Apply 'fd' to Ctrl-T (files)
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    # Apply 'fd' to Alt-C (directories) and cd **<tab>
    changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
  };
}
