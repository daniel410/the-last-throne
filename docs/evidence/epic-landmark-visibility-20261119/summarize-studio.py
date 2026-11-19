"""Compare fixed-build Studio output against the recorded 0.113.17 measurements."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

evidence = Path(__file__).resolve().parent
previous = evidence.parent / 'epic-rescue-infrastructure-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('audit', type=Path)
parser.add_argument('before_frames', type=Path)
parser.add_argument('after_frames', type=Path)
args = parser.parse_args()

before = json.loads((previous / 'studio-results.json').read_text())['candidate']
after = {}
for tag, payload in re.findall(
    r'\bTLT_(?:ROUTE|APPROACH|RESCUE)_([A-Z_]+)[ \t]*([^\r\n]*)', args.audit.read_text()
):
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
    for key in ('name', 'ground', 'approach', 'parts'):
        assert original[key] == revised[key], (key, original, revised)

# Canonical hashes from the 0.113.17 TLT_RESCUE_SOLID output.
solid_shapes = {
    'AvalancheSnowFence': 'fbd3eefcc667a59a4914a602645b6f36122c5987262dea685f5dcb8610fac4b5',
    'KeeperDrainCulvert': '7e93ee19afe66d7f0eed5241f00e63e4896fe1e508bd0f90208a4281f5b0aa12',
}
for solid in after['SOLID']:
    shapes = sorted(solid.pop('placement'), key=lambda part: (part['name'], part['at']))
    digest = hashlib.sha256(json.dumps(shapes, sort_keys=True).encode()).hexdigest()
    assert digest == solid_shapes[solid['name']], (solid['name'], digest)
for original, revised in zip(before['SOLID'], after['SOLID'], strict=True):
    for key in ('name', 'solid', 'pivot'):
        assert original[key] == revised[key], (key, original, revised)

cameras = json.loads((previous / 'cameras.json').read_text())
width, height, gap, caption = 400, 225, 12, 25
board = Image.new('RGB', (2 * width + 3 * gap, 30 + len(cameras) * (height + caption)), '#171c20')
draw = ImageDraw.Draw(board)
for column, (version, path) in enumerate(
    zip(('0.113.17', '0.113.18'), (args.before_frames, args.after_frames), strict=True)
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
after['SOLID_SHAPE_SHA256'] = solid_shapes
(evidence / 'studio-results.json').write_text(json.dumps(after, indent=2) + '\n')
