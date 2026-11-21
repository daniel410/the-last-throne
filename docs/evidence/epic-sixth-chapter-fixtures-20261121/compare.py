"""Compare fixed Studio cameras and the sixth-chapter landmark placement audit."""
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
parser.add_argument('--baseline-version', default='0.115.15')
parser.add_argument('--output-dir', type=Path, default=Path(__file__).resolve().parent)
parser.add_argument('--allow-unchanged-summary', action='append', default=[])
args = parser.parse_args()
before, after, regression = (path.read_text() for path in (args.baseline, args.candidate, args.regression))
camera_plan, = records(before, 'SIXTH_CHAPTER_CAMERA_PLAN')
assert records(after, 'SIXTH_CHAPTER_CAMERA_PLAN') == [camera_plan]
left, right = frames(before), frames(after)
assert list(left) == list(right) == [shot['id'] for shot in camera_plan]
assert len(left) == 10

def landmarks(log):
    return {row['model']: row for row in records(log, 'SIXTH_CHAPTER_LANDMARK')}


baseline, candidate = landmarks(before), landmarks(after)
assert set(baseline) == set(candidate) and len(candidate) == 35
expected = {
    'RefugePathDrain', 'ScoutExtractionSkid', 'CitadelServiceCoping',
    'HeatworksObservationBaffle', 'AntechamberRailFooting',
}
optional = set(args.allow_unchanged_summary)
assert optional <= expected
changed = {name for name, row in candidate.items() if row != baseline[name]}
assert expected - optional <= changed <= expected
pairs = []
for name in sorted(expected):
    prior, current = baseline[name], candidate[name]
    for field in ('chapter', 'goal', 'step', 'ground', 'anchor', 'version'):
        assert current.get(field) == prior.get(field), (name, field)
    assert current['clearance'] >= 3 and current['maxFloorError'] < .2
    pairs.append({'before': prior, 'after': current})
chapters = {pair['after']['chapter'] for pair in pairs}
walks = {}
for label, log in (('baseline', before), ('candidate', after)):
    rows = records(log, 'SIXTH_CHAPTER_WALK')
    assert len(rows) == 5 and {row['chapter'] for row in rows} == chapters
    assert all(row.get('inbound', 2.5) < 2.5 and row.get('outbound', 2.5) < 2.5 for row in rows), rows
    walks[label] = sorted(rows, key=lambda row: row['chapter'])

report, = records(regression, 'CAMPAIGN_EXPANSION_NATIVE')
assert not report['blockers']
assert report['incidents'] == 82 and report['steps'] == 246 and report['samples'] == 3968

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
    'refinedModels': pairs,
    'unchangedModels': sorted(set(baseline) - expected),
    'walks': walks,
    'framePairs': list(left),
    'expansionRegression': report,
}, indent=2) + '\n')
