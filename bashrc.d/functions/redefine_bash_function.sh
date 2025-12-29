# .bashrc.d/functions/redefine_bash_function.sh

redefine_bash_function() {
  local func_name=$1
  local tmp_file=$(mktemp)

  # 1. Dump the function definition to a temp file
  declare -f "$func_name" > "$tmp_file"

  # 2. Open in nvim
  nvim "$tmp_file"

  # 3. Source the modified file back into the current shell
  if [ -s "$tmp_file" ]; then
    source "$tmp_file"
    echo "Function '$func_name' redefined."
  fi

  rm "$tmp_file"
}
