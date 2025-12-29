# $HOME/.bashrc.d/functions/cmd_exists

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}
