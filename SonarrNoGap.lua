#!/usr/bin/env python3
import os
import re
import sys
from collections import defaultdict

event_type = os.environ.get('sonarr_eventtype')
series_path = os.environ.get('sonarr_series_path')

if event_type == 'Test':
    print("Test successful!")
    sys.exit(0)

if not series_path or not os.path.isdir(series_path):
    print("Error: Series path not found.")
    sys.exit(1)

VIDEO_EXTS = ('.mkv', '.mp4', '.avi', '.m4v')
PATTERN = re.compile(r'S(\d+)E(\d+)', re.IGNORECASE)

seasons = defaultdict(lambda: {'eps': set(), 'folder': None})

for root, dirs, files in os.walk(series_path):
    for f in files:
        if f.lower().endswith(VIDEO_EXTS):
            m = PATTERN.search(f)
            if m:
                s, e = int(m.group(1)), int(m.group(2))
                if s == 0:
                    continue
                seasons[s]['eps'].add(e)
                seasons[s]['folder'] = root

for season_num, data in seasons.items():
    eps = sorted(data['eps'])
    folder = data['folder']

    if not eps or not folder:
        continue

    max_ep = eps[-1]
    first_missing = next((i for i in range(1, max_ep) if i not in data['eps']), None)

    ignore_lines = ["# Episodes hidden for plex by sonarr_no_gap"]

    if first_missing:
        for e in eps:
            if e > first_missing:
                ignore_lines.append(f"*S{season_num:02d}E{e:02d}*")

    ignore_path = os.path.join(folder, '.plexignore')

    if len(ignore_lines) > 1:
        with open(ignore_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(ignore_lines) + '\n')
        print(f"Season {season_num:02d}: gap detected → .plexignore updated.")
    else:
        if os.path.exists(ignore_path):
            os.remove(ignore_path)
            print(f"Season {season_num:02d}: no gap → .plexignore removed.")
        else:
            print(f"Season {season_num:02d}: no gap → nothing to do.")

print("Done.")
sys.exit(0)
