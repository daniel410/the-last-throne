"""Compare the route and placement records and assemble matching Studio frames."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

EVIDENCE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
for name in ('baseline', 'candidate', 'before_frames', 'after_frames'):
    parser.add_argument(name, type=Path)
args = parser.parse_args()

def read_results(path):
    records = {}
    for tag, payload in re.findall(
        r'\bTLT_(?:ROUTE|APPROACH|RESCUE)_([A-Z_]+)[ \t]*([^\r\n]*)', path.read_text()
    ):
        records.setdefault(tag, []).append(json.loads(payload) if payload else True)
    assert records['DONE'] == records['FINAL'] == [True], path
    return records

def read_frames(path):
    source = path.read_text()
    assert 'TLT_APPROACH_FRAMES_DONE' in source, path
    panels = {}
    for shot, row, rgb in re.findall(r'TLT_APPROACH_FRAME\s+(\S+)\s+(\d+)\s+([a-f0-9]+)', source):
        panels.setdefault(shot, {})[int(row)] = bytes.fromhex(rgb)
    return panels

before, after = map(read_results, (args.baseline, args.candidate))
assert after['COMPILE'][0] == before['COMPILE'][0] + 1
for tag in ('NAV_ORIGINAL', 'NAV_EASY'):
    assert after[tag] == before[tag]
    assert not after[tag][0]['blockers']
    for stats in after[tag][0]['epics'].values():
        assert stats['floors'] == stats['corrections'] == stats['routeFailures'] == 0
for records in (before, after):
    for tag in ('WALK', 'DIRECT', 'MODEL', 'PLACEMENT', 'SOLID'):
        if tag in records:
            records[tag].sort(key=lambda row: row['name'])
    for row in records['SOLID']:
        row['placement'].sort(key=lambda part: (part['name'], part['at']))
    assert len(records['WALK']) == 15
    assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in records['WALK'])
assert before['SOLID'] == after['SOLID']
assert after['DIRECT'] == after['MODEL']
assert len(after['MODEL']) == 10

cameras = sorted(after.pop('CAMERA'), key=lambda row: row['id'])
(EVIDENCE / 'cameras.json').write_text(json.dumps(cameras, indent=2) + '\n')
width, height, gap, caption = 400, 225, 12, 25
board = Image.new('RGB', (2 * width + 3 * gap, 30 + len(cameras) * (height + caption)), '#171c20')
draw = ImageDraw.Draw(board)
for col, (version, path) in enumerate(zip(('0.113.16', '0.113.17'), (args.before_frames, args.after_frames), strict=True)):
    x = gap + col * (width + gap)
    draw.text((x, 8), version, fill='white')
    panels = read_frames(path)
    assert len(panels) == len(cameras)
    for i, camera in enumerate(cameras):
        rows = panels[camera['id']]
        assert len(rows) == height and all(len(row) == 3 * width for row in rows.values())
        y = 30 + i * (height + caption)
        board.paste(Image.frombytes('RGB', (width, height), b''.join(rows[j] for j in range(height))), (x, y))
        draw.text((x, y + height + 4), camera['id'].replace('_', ' '), fill='white')
board.save(EVIDENCE / 'comparison.jpg', quality=91, optimize=True)
# Keep measurements and the solid-geometry comparison result compact.
for records in (before, after):
    for row in records['SOLID']:
        del row['placement']
(EVIDENCE / 'studio-results.json').write_text(json.dumps({'baseline': before, 'candidate': after}, indent=2) + '\n')
