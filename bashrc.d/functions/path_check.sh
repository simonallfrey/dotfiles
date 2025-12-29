# $HOME/.bashrc.d/functions/path_check.sh

path_check() {
  echo "$PATH" | tr ':' '\n' | nl
}
