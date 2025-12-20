{ pkgs, sonori, ... }:

{
  # Specific packages for voice-to-text
  home.packages = with pkgs; [
    ydotool        # To inject keystrokes in Wayland
    wtype          # Alternative wayland-native light-weight typer
    vulkan-loader  # GPU acceleration for Whisper models
    pipewire       # Ensure the audio stack is available
    sonori.packages.${pkgs.system}.default
  ];

  home.sessionVariables = {
    # REQUIRED: Tells Sonori (and ydotool client) where the daemon is listening
    YDOTOOL_SOCKET = "/run/user/1000/.ydotool_socket";
  };

  # The background daemon required for ydotool to work
  systemd.user.services.ydotoold = {
    Unit = {
      Description = "Virtual Input Device Daemon (Voice Typing)";
    };
    Service = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold --socket-path=%t/.ydotool_socket";
      Restart = "always";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  # You can add voice-specific environment variables here later
  home.sessionVariables = {
    # Example: Telling a Rust tool where to find its model
    # WHISPER_MODEL_PATH = "${config.home.homeDirectory}/models/base.bin";
  };
}
