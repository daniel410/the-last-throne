"""Validate the local Studio logs and assemble the matching camera frames."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

EVIDENCE = Path(__file__).resolve().parent
BASELINE = EVIDENCE.parent / 'epic-landmark-material-contrast-20261119'
ROUTES = EVIDENCE.parent / 'epic-route-perspectives-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
args = parser.parse_args()
before, after = (path.read_text() for path in (args.baseline, args.candidate))


def rows(log, tag):
    return [json.loads(match) for match in re.findall(r'^TLT_' + tag + r' (.+)$', log, re.M)]


def frames(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    pixels = {}
    for name, line, color in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        pixels.setdefault(name, {})[int(line)] = bytes.fromhex(color)
    for name, lines in pixels.items():
        assert set(lines) == set(range(225)) and all(len(line) == 1200 for line in lines.values()), name
    return {
        name: Image.frombytes('RGB', (400, 225), b''.join(lines[index] for index in range(225)))
        for name, lines in pixels.items()
    }


original = json.loads((BASELINE / 'studio-results.json').read_text())
inherited = json.loads((ROUTES / 'studio-results.json').read_text())
assert 'TLT_ROUTE_FINAL' in after and 'TLT_RESCUE_DONE' in after
assert rows(after, 'ROUTE_COMPILE') == [original['compileCount']]
for mode in ('NAV_ORIGINAL', 'NAV_EASY'):
    assert rows(after, 'ROUTE_' + mode) == inherited[mode], mode

placements = rows(after, 'APPROACH_PLACEMENT')
assert len(placements) == len(original['investigationPlacements']) == 12
for old, new in zip(original['investigationPlacements'], placements, strict=True):
    assert all(old[key] == new[key] for key in ('name', 'ground', 'approach')), new

walks = sorted(rows(after, 'ROUTE_WALK'), key=lambda row: row['name'])
assert len(walks) == 18
assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in walks), walks
solids = rows(after, 'RESCUE_SOLID')
assert len(solids) == 2
for row in solids:
    shapes = sorted(row.pop('placement'), key=lambda part: (part['name'], part['at']))
    digest = hashlib.sha256(json.dumps(shapes, sort_keys=True).encode()).hexdigest()
    assert digest == original['collisionShapeSHA256'][row['name']], row
    row['shapeSHA256'] = digest

stations = rows(after, 'STATION')
for old, new in zip(rows(before, 'STATION'), stations, strict=True):
    assert old['parts'] == 0 and new['parts'] > 0
    assert all(old[key] == new[key] for key in ('name', 'scene', 'goals')), new
    if new['name'] == 'PassageDrainInspectionBox':
        assert new['angle'] < 24 and new['clearRay'], new
    else:
        assert old['site'] == new['site'], new
assert len(stations) == 4
base_views, views = (rows(log, 'ROUTE_VIEW') for log in (before, after))
assert len(base_views) == len(views) == 101
(EVIDENCE / 'studio-results.json').write_text(json.dumps({
    'compileCount': original['compileCount'],
    'navigation': {mode: rows(after, 'ROUTE_' + mode)[0] for mode in ('NAV_ORIGINAL', 'NAV_EASY')},
    'stations': stations,
    'collisionModels': solids,
    'walks': walks,
    'baselineRouteViews': base_views,
    'candidateRouteViews': views,
}, indent=2) + '\n')

old_images, new_images = (frames(log) for log in (before, after))
assert len(old_images) >= 6 and old_images.keys() == new_images.keys()
board = Image.new('RGB', (836, 30 + 250 * len(old_images)), '#171c20')
draw = ImageDraw.Draw(board)
for x, label, images in ((12, '0.113.20', old_images), (424, '0.113.21', new_images)):
    draw.text((x, 8), label, fill='white')
    for index, name in enumerate(old_images):
        y = 30 + 250 * index
        board.paste(images[name], (x, y))
        draw.text((x, y + 229), name, fill='white')
board.save(EVIDENCE / 'comparison.jpg', quality=92, optimize=True)
