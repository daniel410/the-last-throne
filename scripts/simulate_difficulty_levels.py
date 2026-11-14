#!/usr/bin/env python3
"""Estimate sequential difficulty levels from an immutable runtime source commit."""
import argparse
import csv
import io
import json
from pathlib import Path
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--source', required=True)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
commit = subprocess.check_output(['git', 'rev-parse', '--verify', args.source + '^{commit}'], cwd=ROOT, text=True).strip()
archive = subprocess.check_output(['git', 'archive', commit, 'src/shared'], cwd=ROOT)
with tempfile.TemporaryDirectory(prefix='tlt-level-estimate-') as directory:
    with tarfile.open(fileobj=io.BytesIO(archive)) as source:
        source.extractall(directory, filter='data')
    run = subprocess.run(['lua', str(ROOT / 'scripts/simulate_difficulty_levels.lua')], cwd=directory, capture_output=True, text=True, check=True)
rows = list(csv.DictReader(io.StringIO(run.stdout), delimiter='\t'))
for row in rows:
    for key in row:
        if key not in ('scenario', 'mode', 'epic', 'mission'):
            row[key] = int(float(row[key]))
summaries = [row for row in rows if row['mission'] == 'SUMMARY']
for row in summaries:
    if row['scenario'].endswith('_p1'):
        party = next(x for x in summaries if x['scenario'] == row['scenario'][:-1] + '4' and x['mode'] == row['mode'])
        assert all(row[key] == party[key] for key in ('killXP', 'questXP', 'totalXP', 'level', 'xpInLevel'))
result = {
    'sourceCommit': commit,
    'assumptions': {
        'startLevel': 1,
        'startXP': 0,
        'modeOrder': ['Easy', 'Hard', 'Insane', 'Hell'],
        'classes': ['knight', 'dwarf', 'elf', 'mage'],
        'main': '35 main chapters, required encounters only',
        'side_once': 'all optional main encounters on each mode; 12 side quests once on Easy',
        'all_each_mode': 'all optional main encounters and side quests on each mode',
        'excluded': 'deaths, extra replays, respawns, boosts, tutorial planning-only awards',
        'totalXP': 'potential cumulative XP before Lv80 cap; XP at Lv80 is discarded in game',
        'limits': 'calculation, not observed client play or measured clear time',
    },
    'summaries': summaries,
    'rows': rows,
}
args.output.parent.mkdir(parents=True, exist_ok=True)
detail_rows = result.pop('rows')
header = json.dumps(result, ensure_ascii=False, indent=2).rstrip()
args.output.write_text(header[:-1] + ',\n  "rows": [\n' + ',\n'.join('    ' + json.dumps(row, separators=(',', ':')) for row in detail_rows) + '\n  ]\n}\n')
print(json.dumps({'sourceCommit': commit, 'summaries': [r for r in summaries if r['scenario'].endswith('_p1')]}, ensure_ascii=False, indent=2))
