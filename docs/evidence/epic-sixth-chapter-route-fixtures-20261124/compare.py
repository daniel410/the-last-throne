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
for label in ('baseline', 'candidate', 'baseline_regression', 'candidate_regression'):
    parser.add_argument(label, type=Path)
parser.add_argument('--output-dir', type=Path, default=Path(__file__).resolve().parent)
args = parser.parse_args()
before, after = args.baseline.read_text(), args.candidate.read_text()
camera_plan, = records(before, 'SIXTH_CHAPTER_CAMERA_PLAN')
assert records(after, 'SIXTH_CHAPTER_CAMERA_PLAN') == [camera_plan]
left, right = frames(before), frames(after)
assert list(left) == list(right) == [shot['id'] for shot in camera_plan]
assert len(left) == 10

def landmarks(log):
    return {row['model']: row for row in records(log, 'SIXTH_CHAPTER_LANDMARK')}


baseline, candidate = landmarks(before), landmarks(after)
expected = {
    'ShelterMarkRootPocket', 'RearguardRopeTurnFooting', 'VillageRelayWindbreak',
    'ColdSideRailSaddle', 'RoyalRecordWallRecess',
}
assert len(baseline) == 35
assert set(candidate) == set(baseline) | expected and not set(baseline) & expected
assert all(candidate[name] == row for name, row in baseline.items())
added = [candidate[name] for name in sorted(expected)]
for model in added:
    assert model['clearance'] >= 3 and model['maxFloorError'] < .2, model
    assert model.get('actorClearance', 3) >= 3, model
chapters = {model['chapter'] for model in added}
walks = {}
for label, log in (('baseline', before), ('candidate', after)):
    rows = records(log, 'SIXTH_CHAPTER_WALK')
    assert len(rows) == 5 and {row['chapter'] for row in rows} == chapters
    assert all(row.get('inbound', 2.5) < 2.5 and row.get('outbound', 2.5) < 2.5 for row in rows), rows
    walks[label] = sorted(rows, key=lambda row: row['chapter'])

def expansion_report(log):
    report, = records(log, 'CAMPAIGN_EXPANSION_NATIVE')
    assert report['blockers'] == []
    totals = tuple(report[field] for field in ('incidents', 'steps', 'samples', 'checks'))
    assert totals == (82, 246, 3981, 9310), totals
    return report


baseline_report = expansion_report(args.baseline_regression.read_text())
candidate_report = expansion_report(args.candidate_regression.read_text())
assert candidate_report['parts'] - baseline_report['parts'] == sum(model['parts'] for model in added)

directory = args.output_dir
version = json.loads((directory / 'build.json').read_text())['version']
board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
labels = ImageDraw.Draw(board)
labels.text((6, 6), '0.115.78', fill='white')
labels.text((418, 6), version, fill='white')
for index, name in enumerate(left):
    y = 28 + 250 * index
    board.paste(left[name], (6, y))
    board.paste(right[name], (418, y))
    labels.text((6, y + 229), name, fill='white')
board.save(directory / 'comparison.jpg', quality=92, optimize=True)
(directory / 'studio-results.json').write_text(json.dumps({
    'addedModels': added,
    'unchangedModels': sorted(baseline),
    'walks': walks,
    'framePairs': list(left),
    'expansionRegression': {'baseline': baseline_report, 'candidate': candidate_report},
}, indent=2) + '\n')
