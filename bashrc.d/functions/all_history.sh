# integrated of bash_history of all previous sessions

all_history() {
  python3 - <<'PY'
import pathlib, re, time, sys

histdir = pathlib.Path.home() / ".bash_history.d"
files = sorted(histdir.glob("*.hist"))  # oldest -> newest
if not files:
    sys.exit("No history files in ~/.bash_history.d")

entries = []
for path in files:
    m = re.match(r"(\d{8})-(\d{6})\.(\d+)\.hist", path.name)
    pid_from_name = m.group(3) if m else "?"
    file_ts = None
    if m:
        try:
            file_ts = time.strftime(
                "%Y-%m-%d %H:%M:%S",
                time.strptime(m.group(1) + m.group(2), "%Y%m%d%H%M%S"),
            )
        except Exception:
            file_ts = None
    lines = path.read_text().splitlines()
    pending_time = None
    for line in lines:
        if line.startswith("#"):
            # accept both "# 123" and "#123" forms
            ts_str = line.lstrip("# ").strip()
            try:
                pending_time = time.strftime("%Y-%m-%d %H:%M:%S",
                                             time.localtime(int(ts_str)))
            except Exception:
                pending_time = None
            continue
        if not line.strip():
            continue
        stamp = pending_time or file_ts or "????-??-?? ??:??:??"
        entries.append((stamp, pid_from_name, line))

# sort by time string (ISO-like) then pid to stabilize
entries.sort(key=lambda x: (x[0], x[1]))

last_pid = None
for t, pid, cmd in entries:
    if pid != last_pid:
        sys.stdout.write(f"\n=== pid {pid} ===\n")
        last_pid = pid
    sys.stdout.write(f"{t} [{pid}] {cmd}\n")
PY
}
