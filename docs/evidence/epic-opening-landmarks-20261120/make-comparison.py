"""Validate paired opening-area captures and record measured model placement."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw


def records(prefix, log):
    return [json.loads(row) for row in re.findall(r'^' + prefix + r' (.+)$', log, re.M)]


def frames(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    scans = {}
    for name, row, data in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        scans.setdefault(name, {})[int(row)] = bytes.fromhex(data)
    assert len(scans) == 10
    images = {}
    for name, rows in scans.items():
        assert set(rows) == set(range(225)) and all(len(row) == 1200 for row in rows.values()), name
        images[name] = Image.frombytes('RGB', (400, 225), b''.join(rows[y] for y in range(225)))
    return images


parser = argparse.ArgumentParser(description=__doc__)
for name in ('baseline', 'candidate', 'regression'):
    parser.add_argument(name, type=Path)
args = parser.parse_args()
baseline, candidate, regression = (path.read_text() for path in (args.baseline, args.candidate, args.regression))
assert records('OPENING_CAMERA_PLAN', baseline) == records('OPENING_CAMERA_PLAN', candidate)
left, right = frames(baseline), frames(candidate)
assert list(left) == list(right)

original = {model['chapter']: model for model in records('OPENING_LANDMARK', baseline)}
updated = {model['chapter']: model for model in records('OPENING_LANDMARK', candidate)}
assert len(original) == 5 and all(updated[key] == model for key, model in original.items())
new = [model for key, model in updated.items() if key not in original]
assert {model['chapter'] for model in new} == {'DW-01', 'GW-01', 'FV-01', 'EC-01', 'HG-01'}
assert all(model['step'] for model in new)
report, = records('CAMPAIGN_EXPANSION_NATIVE', regression)
assert not report['blockers']

out = Path(__file__).resolve().parent
board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
draw = ImageDraw.Draw(board)
draw.text((6, 6), '0.114.4', fill='white')
draw.text((418, 6), '0.114.5', fill='white')
for i, (name, before) in enumerate(left.items()):
    y = 28 + i * 250
    board.paste(before, (6, y))
    board.paste(right[name], (418, y))
    draw.text((6, y + 229), name, fill='white')
board.save(out / 'comparison.jpg', quality=92, optimize=True)
(out / 'studio-results.json').write_text(json.dumps({
    'newModels': new,
    'unchangedModels': list(original),
    'framePairs': list(left),
    'expansionRegression': report,
}, indent=2) + '\n')
