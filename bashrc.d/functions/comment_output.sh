# $HOME/.bashrc.d/functions/comment_output.sh

comment_output(){
  # comments output for cut and paste commands
  "$@" | sed 's/^/# /'
}
