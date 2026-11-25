"""Compare fixed Studio cameras and the fifth chapter route fixture placement audit."""
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
for label in ('baseline', 'candidate', 'baseline_regression', 'candidate_regression'):
    parser.add_argument(label, type=Path)
parser.add_argument('--baseline-version', default='0.115.99')
parser.add_argument('--output-dir', type=Path, default=Path(__file__).resolve().parent)
args = parser.parse_args()
before, after = args.baseline.read_text(), args.candidate.read_text()
camera_plan, = records(before, 'INFRASTRUCTURE_CAMERA_PLAN')
assert records(after, 'INFRASTRUCTURE_CAMERA_PLAN') == [camera_plan]
left, right = frames(before), frames(after)
assert list(left) == list(right) == [shot['id'] for shot in camera_plan]
assert len(left) == 10

def landmarks(log):
    rows = records(log, 'INFRASTRUCTURE_LANDMARK')
    by_name = {row['model']: row for row in rows}
    assert len(rows) == len(by_name)
    return by_name


baseline, candidate = landmarks(before), landmarks(after)
targets = {
    'PrisonWalkwayWheelStop': 'exp_1',
    'HuntingBankShaleCut': 'exp_1',
    'TunnelHandrailFooting': 'exp_2',
    'EmergencyReturnFlume': 'exp_1',
    'WesternConduitWallSleeve': 'exp_1',
}
assert candidate.keys() - baseline.keys() == targets.keys()
assert baseline.keys() <= candidate.keys()
unchanged = sorted(baseline)
assert all(candidate[name] == baseline[name] for name in unchanged)
assert all(candidate[name]['goal'] == targets[name] and candidate[name]['routeClearance'] >= 3
           for name in targets)
chapters = {candidate[name]['chapter'] for name in targets}
walks = {}
for label, log in (('baseline', before), ('candidate', after)):
    rows = records(log, 'SECOND_CHAPTER_WALK')
    assert len(rows) == 5 and {row['chapter'] for row in rows} == chapters
    assert all(row.get('inbound', 2.5) < 2.5 and row.get('outbound', 2.5) < 2.5 for row in rows), rows
    walks[label] = sorted(rows, key=lambda row: row['chapter'])

expansion = {}
for label in ('baseline', 'candidate'):
    report, = records(getattr(args, label + '_regression').read_text(), 'CAMPAIGN_EXPANSION_NATIVE')
    assert report['blockers'] == []
    assert report['checks'] > 0
    expansion[label] = report
for field in ('incidents', 'steps', 'samples', 'checks'):
    assert expansion['baseline'][field] == expansion['candidate'][field], field
assert expansion['candidate']['parts'] - expansion['baseline']['parts'] == sum(
    candidate[name]['parts'] for name in targets
)

directory = args.output_dir
version = json.loads((directory / 'build.json').read_text())['version']
board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
labels = ImageDraw.Draw(board)
labels.text((6, 6), args.baseline_version, fill='white')
labels.text((418, 6), version, fill='white')
for index, name in enumerate(left):
    y = 28 + 250 * index
    board.paste(left[name], (6, y))
    board.paste(right[name], (418, y))
    labels.text((6, y + 229), name, fill='white')
board.save(directory / 'comparison.jpg', quality=92, optimize=True)
(directory / 'studio-results.json').write_text(json.dumps({
    'models': [
        candidate[name] for name in sorted(targets)
    ],
    'unchangedModels': unchanged,
    'walks': walks,
    'framePairs': list(left),
    'expansionRegression': expansion,
}, indent=2) + '\n')
