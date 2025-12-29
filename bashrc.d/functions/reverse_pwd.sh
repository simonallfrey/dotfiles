# "$HOME/.bashrc.d/functions/reverse_pwd"

reverse_pwd() {
  pwd=$1
  reversed=$(echo "$pwd" | tr '/' '\n' | tac | tr '\n' '/')
  echo "${reversed%/}"
}
