"""Compare fixed-build Studio output against the recorded 0.113.18 measurements."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

evidence = Path(__file__).resolve().parent
previous = evidence.parent / 'epic-landmark-visibility-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('audit', type=Path)
parser.add_argument('before_frames', type=Path)
parser.add_argument('after_frames', type=Path)
parser.add_argument('before_routes', type=Path)
parser.add_argument('after_routes', type=Path)
args = parser.parse_args()

before = json.loads((previous / 'studio-results.json').read_text())
after = {}
for tag, payload in re.findall(
    r'\bTLT_(?:ROUTE|APPROACH|RESCUE)_([A-Z_]+)[ \t]*([^\r\n]*)', args.audit.read_text()
):
    if tag not in {'FRAME', 'FRAMES_DONE', 'VIEW', 'VIEWS_DONE'}:
        after.setdefault(tag, []).append(json.loads(payload) if payload else True)

assert after['DONE'] == after['FINAL'] == [True]
assert after['COMPILE'] == before['COMPILE']
for tag in ('NAV_ORIGINAL', 'NAV_EASY'):
    assert after[tag] == before[tag]
    assert not after[tag][0]['blockers']

for tag in ('WALK', 'DIRECT', 'MODEL', 'SOLID'):
    after[tag].sort(key=lambda row: row['name'])
assert len(after['WALK']) == 15
assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in after['WALK'])
assert after['DIRECT'] == after['MODEL']
assert len(after['MODEL']) == len(before['MODEL']) == 10
for original, revised in zip(before['MODEL'], after['MODEL'], strict=True):
    for key in ('name', 'approach'):
        assert original[key] == revised[key], (key, original, revised)

# Canonical collision data from 0.113.18.
solid_shapes = before['SOLID_SHAPE_SHA256']
for solid in after['SOLID']:
    shapes = sorted(solid.pop('placement'), key=lambda part: (part['name'], part['at']))
    digest = hashlib.sha256(json.dumps(shapes, sort_keys=True).encode()).hexdigest()
    assert digest == solid_shapes[solid['name']], (solid['name'], digest)
for original, revised in zip(before['SOLID'], after['SOLID'], strict=True):
    for key in ('name', 'solid', 'pivot'):
        assert original[key] == revised[key], (key, original, revised)

cameras = json.loads((evidence / 'cameras.json').read_text())
width, height, gap, caption = 400, 225, 12, 25
board = Image.new('RGB', (2 * width + 3 * gap, 30 + len(cameras) * (height + caption)), '#171c20')
draw = ImageDraw.Draw(board)
for column, (version, path) in enumerate(
    zip(('0.113.18', '0.113.19'), (args.before_frames, args.after_frames), strict=True)
):
    source = path.read_text()
    assert 'TLT_APPROACH_FRAMES_DONE' in source, path
    panels = {}
    for shot, row, rgb in re.findall(r'TLT_APPROACH_FRAME\s+(\S+)\s+(\d+)\s+([a-f0-9]+)', source):
        panels.setdefault(shot, {})[int(row)] = bytes.fromhex(rgb)
    assert len(panels) == len(cameras)
    x = gap + column * (width + gap)
    draw.text((x, 8), version, fill='white')
    for index, camera in enumerate(cameras):
        rows = panels[camera['id']]
        assert len(rows) == height and all(len(row) == 3 * width for row in rows.values())
        y = 30 + index * (height + caption)
        board.paste(Image.frombytes('RGB', (width, height), b''.join(rows[j] for j in range(height))), (x, y))
        draw.text((x, y + height + 4), camera['id'].replace('_', ' '), fill='white')
board.save(evidence / 'comparison.jpg', quality=91, optimize=True)
after.pop('CAMERA')


def route_views(path):
    source = path.read_text()
    assert 'TLT_ROUTE_VIEWS_DONE' in source, path
    rows = [json.loads(payload) for payload in re.findall(r'TLT_ROUTE_VIEW (\{[^\n]+\})', source)]
    assert {row['story'] for row in rows} == {'FV-03', 'FV-04', 'HG-03'}
    return rows

baseline_routes = route_views(args.before_routes)
candidate_routes = route_views(args.after_routes)
assert len(baseline_routes) == len(candidate_routes)
for baseline, updated in zip(baseline_routes, candidate_routes, strict=True):
    for key in ('story', 'leg', 'sample', 'origin', 'aim'):
        assert baseline[key] == updated[key], (key, baseline, updated)

after['ROUTE_VIEWS'] = candidate_routes
after['ROUTE_VIEW_BASELINE'] = [
    {key: row[key] for key in ('story', 'leg', 'sample', 'angle', 'distance', 'clearRays')}
    for row in baseline_routes
]
after['SOLID_SHAPE_SHA256'] = solid_shapes
(evidence / 'studio-results.json').write_text(json.dumps(after, indent=2) + '\n')
