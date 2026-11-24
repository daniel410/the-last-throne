"""Verify both Studio runs and assemble a board from the original capture pixels."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent

def rows(path, tag):
    return [json.loads(value) for value in re.findall(rf'^{tag} (.+)$', path.read_text(), re.M)]

def index(records):
    mapped = {row['story']: row for row in records}
    assert len(mapped) == len(records)
    return mapped

def images(path, cameras):
    log = path.read_text()
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    frames = {}
    for name, y, pixels in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        lines = frames.setdefault(name, {})
        assert int(y) not in lines
        lines[int(y)] = bytes.fromhex(pixels)
    assert list(frames) == [shot['id'] for shot in cameras]
    result = {}
    for name, lines in frames.items():
        assert set(lines) == set(range(225))
        assert all(len(line) == 1200 for line in lines.values())
        result[name] = Image.frombytes('RGB', (400, 225), b''.join(lines[y] for y in range(225)))
    return result

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('logs', type=Path)
args = parser.parse_args()
build = json.loads((HERE / 'build.json').read_text())
versions = ['0.115.87', build['version']]
audits = [args.logs / f'{label}-audit.log' for label in ('baseline', 'candidate')]
old, current = (index(rows(path, 'TLT_FINALE_EXISTING')) for path in audits)
assert old == current and len(old) == 5
assert not rows(audits[0], 'TLT_FINALE_FIXTURE')
fixtures = index(rows(audits[1], 'TLT_FINALE_FIXTURE'))
assert fixtures.keys() == old.keys()
for story, fixture in fixtures.items():
    assert fixture['approach'] == old[story]['approach']
    assert fixture['routeClearance'] >= 8
    assert fixture['landmarkClearance'] >= 1.99
    assert len(fixture['footprintHeightDeltas']) == 5
walks = [index(rows(path, 'TLT_ROUTE_WALK')) for path in audits]
for walk in walks:
    assert walk.keys() == old.keys()
    assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in walk.values())
for story in old:
    for key in ('from', 'target', 'goal'):
        assert walks[0][story][key] == walks[1][story][key]
reports = []
for label in ('baseline', 'candidate'):
    report, = rows(args.logs / f'{label}-expansion.log', 'CAMPAIGN_EXPANSION_NATIVE')
    assert not report['blockers']
    assert tuple(report[key] for key in ('incidents', 'steps', 'samples', 'checks')) == (82, 246, 3981, 9310)
    reports.append(report)
assert reports[1]['parts'] - reports[0]['parts'] == sum(row['parts'] for row in fixtures.values())

cameras, = rows(audits[1], 'TLT_FINALE_CAMERAS')
assert len(cameras) == 10
panels = [images(args.logs / 'baseline-capture.log', cameras), images(audits[1], cameras)]
board = Image.new('RGB', (824, 28 + 250 * len(cameras)), '#171c20')
draw = ImageDraw.Draw(board)
hashes = {}
for index, shot in enumerate(cameras):
    name = shot['id']
    y = 28 + 250 * index
    hashes[name] = [hashlib.sha256(frames[name].tobytes()).hexdigest() for frames in panels]
    for x, panel in zip((6, 418), panels):
        board.paste(panel[name], (x, y))
    draw.text((6, y + 229), name, fill='white')
for x, version in zip((6, 418), versions):
    draw.text((x, 6), version, fill='white')
board.save(HERE / 'comparison.jpg', quality=92, optimize=True)
(HERE / 'cameras.json').write_text(json.dumps(cameras, indent=2) + '\n')
(HERE / 'studio-results.json').write_text(json.dumps({
    'fixtures': fixtures, 'existingFinaleModels': old,
    'walks': dict(zip(versions, walks)), 'expansionRegression': dict(zip(versions, reports)),
    'frameSHA256': hashes,
}, indent=2) + '\n')
