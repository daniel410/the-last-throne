"""Check 0.113.20 against 0.113.19 and assemble the Studio views."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

evidence = Path(__file__).resolve().parent
previous = evidence.parent / 'epic-route-perspectives-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('candidate', type=Path)
parser.add_argument('baseline_frames', type=Path)
parser.add_argument('baseline_closeups', type=Path)
parser.add_argument('candidate_closeups', type=Path)
args = parser.parse_args()

before = json.loads((previous / 'studio-results.json').read_text())
source = args.candidate.read_text()
after = {}
for tag, payload in re.findall(r'\bTLT_(?:ROUTE|APPROACH|RESCUE)_([A-Z_]+)[ \t]*([^\r\n]*)', source):
    if tag not in {'CAMERA', 'FRAME', 'FRAMES_DONE', 'VIEW', 'VIEWS_DONE'}:
        after.setdefault(tag, []).append(json.loads(payload) if payload else True)

assert after['DONE'] == after['FINAL'] == [True]
for tag in ('COMPILE', 'NAV_ORIGINAL', 'NAV_EASY'):
    assert before[tag] == after[tag], tag
for tag in ('NAV_ORIGINAL', 'NAV_EASY'):
    assert not after[tag][0]['blockers']

assert len(after['PLACEMENT']) == len(before['PLACEMENT']) == 12
for original, updated in zip(before['PLACEMENT'], after['PLACEMENT'], strict=True):
    for key in ('name', 'ground', 'approach'):
        assert original[key] == updated[key], (key, original, updated)

for tag in ('WALK', 'DIRECT', 'MODEL', 'SOLID'):
    after[tag].sort(key=lambda row: row['name'])
assert len(after['WALK']) == len(before['WALK']) == 15
assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in after['WALK'])
assert after['DIRECT'] == after['MODEL']
assert len(after['MODEL']) == len(before['MODEL']) == 10
for original, updated in zip(before['MODEL'], after['MODEL'], strict=True):
    for key in ('name', 'ground', 'approach'):
        assert original[key] == updated[key], (key, original, updated)

for original, updated in zip(before['SOLID'], after['SOLID'], strict=True):
    for key in ('name', 'solid', 'pivot'):
        assert original[key] == updated[key], (key, original, updated)
    shapes = sorted(updated.pop('placement'), key=lambda part: (part['name'], part['at']))
    digest = hashlib.sha256(json.dumps(shapes, sort_keys=True).encode()).hexdigest()
    assert digest == before['SOLID_SHAPE_SHA256'][updated['name']], updated['name']

views = [json.loads(payload) for payload in re.findall(r'TLT_ROUTE_VIEW (\{[^\n]+\})', source)]
assert 'TLT_ROUTE_VIEWS_DONE' in source
assert before['ROUTE_VIEWS'] == views

results = {
    'compileCount': after['COMPILE'][0],
    'navigationMatches': ['NAV_ORIGINAL', 'NAV_EASY'],
    'routeViewsMatched': len(views),
    'groundedModels': after['MODEL'],
    'investigationPlacements': after['PLACEMENT'],
    'collisionModels': after['SOLID'],
    'collisionShapeSHA256': before['SOLID_SHAPE_SHA256'],
    'walks': after['WALK'],
}
(evidence / 'studio-results.json').write_text(json.dumps(results, indent=2) + '\n')

shots = [row['id'] for row in json.loads((previous / 'cameras.json').read_text())]
shots += ['FV-04_close', 'HG-03_front']
width, height, gap, caption = 400, 225, 12, 25
board = Image.new('RGB', (2 * width + 3 * gap, 30 + len(shots) * (height + caption)), '#171c20')
draw = ImageDraw.Draw(board)

for column, (version, paths) in enumerate((
    ('0.113.19', (args.baseline_frames, args.baseline_closeups)),
    ('0.113.20', (args.candidate, args.candidate_closeups)),
)):
    panels = {}
    for path in paths:
        log = path.read_text()
        assert 'TLT_APPROACH_FRAMES_DONE' in log, path
        for shot, row, rgb in re.findall(r'TLT_APPROACH_FRAME\s+(\S+)\s+(\d+)\s+([a-f0-9]+)', log):
            panels.setdefault(shot, {})[int(row)] = bytes.fromhex(rgb)
    assert set(panels) == set(shots)
    x = gap + column * (width + gap)
    draw.text((x, 8), version, fill='white')
    for index, shot in enumerate(shots):
        rows = panels[shot]
        assert len(rows) == height and all(len(row) == 3 * width for row in rows.values())
        y = 30 + index * (height + caption)
        board.paste(Image.frombytes('RGB', (width, height), b''.join(rows[j] for j in range(height))), (x, y))
        draw.text((x, y + height + 4), shot.replace('_', ' '), fill='white')
board.save(evidence / 'comparison.jpg', quality=91, optimize=True)
