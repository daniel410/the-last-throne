"""Compare fixed Studio cameras and the existing opening-landmark placement audit."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw


def records(log, prefix):
    return [json.loads(value) for value in re.findall(rf'^{prefix} (.+)$', log, re.M)]


def frames(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    rows = {}
    for name, y, data in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        frame = rows.setdefault(name, {})
        assert int(y) not in frame, (name, y)
        frame[int(y)] = bytes.fromhex(data)
    images = {}
    for name, frame in rows.items():
        assert set(frame) == set(range(225))
        assert all(len(row) == 1200 for row in frame.values())
        images[name] = Image.frombytes('RGB', (400, 225), b''.join(frame[y] for y in range(225)))
    return images


parser = argparse.ArgumentParser(description=__doc__)
for label in ('baseline', 'candidate', 'regression'):
    parser.add_argument(label, type=Path)
args = parser.parse_args()
before, after, regression = (path.read_text() for path in (args.baseline, args.candidate, args.regression))
camera_plan, = records(before, 'OPENING_CAMERA_PLAN')
assert records(after, 'OPENING_CAMERA_PLAN') == [camera_plan]
left, right = frames(before), frames(after)
assert list(left) == list(right) == [shot['id'] for shot in camera_plan]
assert len(left) == 10

baseline = {row['chapter']: row for row in records(before, 'OPENING_LANDMARK')}
candidate = {row['chapter']: row for row in records(after, 'OPENING_LANDMARK')}
assert len(baseline) == 10 and baseline.keys() == candidate.keys()
opening = {'DW-01', 'GW-01', 'FV-01', 'EC-01', 'HG-01'}
for chapter, original in baseline.items():
    model = candidate[chapter]
    if chapter in opening:
        for key in ('model', 'anchor', 'ground', 'goal', 'step', 'version'):
            assert original[key] == model[key], (chapter, key)
    else:
        assert original == model, chapter
report, = records(regression, 'CAMPAIGN_EXPANSION_NATIVE')
assert not report['blockers']

directory = Path(__file__).resolve().parent
version = json.loads((directory / 'build.json').read_text())['version']
board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
labels = ImageDraw.Draw(board)
labels.text((6, 6), '0.114.5', fill='white')
labels.text((418, 6), version, fill='white')
for index, name in enumerate(left):
    y = 28 + 250 * index
    board.paste(left[name], (6, y))
    board.paste(right[name], (418, y))
    labels.text((6, y + 229), name, fill='white')
board.save(directory / 'comparison.jpg', quality=92, optimize=True)
(directory / 'studio-results.json').write_text(json.dumps({
    'models': {chapter: {'before': baseline[chapter], 'after': candidate[chapter]}
               for chapter in sorted(opening)},
    'unchangedModels': sorted(baseline.keys() - opening),
    'framePairs': list(left),
    'expansionRegression': report,
}, indent=2) + '\n')
