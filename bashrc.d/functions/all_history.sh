# integrated of bash_history of all previous sessions
all_history() {
  python3 - <<'PY'
import pathlib, re, time, sys
from datetime import datetime

histdir = pathlib.Path.home() / ".bash_history.d"
files = sorted(histdir.glob("*.hist"))  # oldest -> newest
if not files:
    sys.exit("No history files in ~/.bash_history.d")

entries = []
# Regex: Group 3 (Timezone) is now optional. Group 4 is the PID.
# Matches: 20251229-130000.123.hist  AND  20251229-130000+0000.123.hist
filename_pattern = re.compile(r"(\d{8})-(\d{6})([+-]\d{4})?\.(\d+)\.hist")

for path in files:
    m = filename_pattern.match(path.name)
    pid_from_name = m.group(4) if m else "?"
    file_ts = None
    if m:
        try:
            # Reconstruct datetime string: YYYYMMDDHHMMSS(+/-ZZZZ)
            dt_str = m.group(1) + m.group(2)
            if m.group(3):
                # New format with Timezone
                dt = datetime.strptime(dt_str + m.group(3), "%Y%m%d%H%M%S%z")
                file_ts = dt.strftime("%Y-%m-%d %H:%M:%S %z")
            else:
                # Old format (Naive)
                dt = datetime.strptime(dt_str, "%Y%m%d%H%M%S")
                file_ts = dt.strftime("%Y-%m-%d %H:%M:%S")
        except Exception:
            file_ts = None

    lines = path.read_text().splitlines()
    pending_time = None
    for line in lines:
        if line.startswith("#"):
            # accept both "# 123" and "#123" forms
            ts_str = line.lstrip("# ").strip()
            try:
                # Convert Unix timestamp to local time string, now with system offset (%z)
                pending_time = time.strftime("%Y-%m-%d %H:%M:%S %z",
                                      time.localtime(int(ts_str)))
            except Exception:
                pending_time = None
            continue
        if not line.strip():
            continue
        
        # Fallback priority: Line Timestamp > File Timestamp > Unknown
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
