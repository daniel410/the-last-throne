"""Compare fixed Studio cameras and the fifth-chapter landmark placement audit."""
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
camera_plan, = records(before, 'FIFTH_CHAPTER_CAMERA_PLAN')
assert records(after, 'FIFTH_CHAPTER_CAMERA_PLAN') == [camera_plan]
left, right = frames(before), frames(after)
assert list(left) == list(right) == [shot['id'] for shot in camera_plan]
assert len(left) == 10

def landmarks(log):
    return {row['model']: row for row in records(log, 'FIFTH_CHAPTER_LANDMARK')}


baseline, candidate = landmarks(before), landmarks(after)
assert len(baseline) == 25 and len(candidate) == 30
assert all(candidate[name] == row for name, row in baseline.items()), 'Existing landmark moved or changed'
added = [row for name, row in candidate.items() if name not in baseline]
expected = {
    'DW-05': ('BarracksFreightBreach', 'exp_2', 'step2'),
    'GW-05': ('ScoutLandingStoneAbutment', 'exp_2', 'step2'),
    'FV-05': ('BuriedConvoyWheelTrace', 'exp_1', 'step1'),
    'EC-05': ('CircuitModelCatchBasin', 'exp_2', 'step1'),
    'HG-05': ('EasternGalleryConduitSaddle', 'exp_2', 'step2'),
}
assert {row['chapter']: (row['model'], row['goal'], row['step']) for row in added} == expected
assert all(row['clearance'] >= 3 and 1 <= row['parts'] <= 15 for row in added)
walks = {}
for label, log in (('baseline', before), ('candidate', after)):
    rows = records(log, 'FIFTH_CHAPTER_WALK')
    assert len(rows) == 5 and {row['chapter'] for row in rows} == {row['chapter'] for row in added}
    assert all(row.get('inbound', 2.5) < 2.5 and row.get('outbound', 2.5) < 2.5 for row in rows), rows
    walks[label] = sorted(rows, key=lambda row: row['chapter'])

report, = records(regression, 'CAMPAIGN_EXPANSION_NATIVE')
assert not report['blockers']
assert report['incidents'] == 82 and report['steps'] == 246 and report['samples'] == 3968

directory = Path(__file__).resolve().parent
version = json.loads((directory / 'build.json').read_text())['version']
board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
labels = ImageDraw.Draw(board)
labels.text((6, 6), '0.114.14', fill='white')
labels.text((418, 6), version, fill='white')
for index, name in enumerate(left):
    y = 28 + 250 * index
    board.paste(left[name], (6, y))
    board.paste(right[name], (418, y))
    labels.text((6, y + 229), name, fill='white')
board.save(directory / 'comparison.jpg', quality=92, optimize=True)
(directory / 'studio-results.json').write_text(json.dumps({
    'placedModels': sorted(added, key=lambda row: row['chapter']),
    'unchangedModels': sorted(baseline),
    'walks': walks,
    'framePairs': list(left),
    'expansionRegression': report,
}, indent=2) + '\n')
