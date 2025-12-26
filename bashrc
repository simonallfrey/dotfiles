# ~/.bashrc

for f in ~/.bashrc.d/*.sh; do   # ordered if you prefix 00-,10-,20-
  [ -r "$f" ] && . "$f"
done

host=$(hostname -s)
[ -r ~/.bashrc.d/host/$host.sh ] && . ~/.bashrc.d/host/$host.sh
[ -r ~/.bashrc.d/work.sh ] && . ~/.bashrc.d/work.sh  # optional per-context


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
