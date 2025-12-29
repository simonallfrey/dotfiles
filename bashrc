# ~/.bashrc

for f in ~/.bashrc.d/*.sh; do   # ordered if you prefix 00-,10-,20-
  [ -r "$f" ] && . "$f"
done

host=$(hostname -s)
[ -r ~/.bashrc.d/host/$host.sh ] && . ~/.bashrc.d/host/$host.sh
[ -r ~/.bashrc.d/work.sh ] && . ~/.bashrc.d/work.sh  # optional per-context
