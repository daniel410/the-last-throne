"""Build the paired Studio contact sheet and extract measured model placement."""

import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw


def frames(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    scans = {}
    for name, row, data in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        scans.setdefault(name, {})[int(row)] = bytes.fromhex(data)
    assert len(scans) == 13
    images = {}
    for name, rows in scans.items():
        assert set(rows) == set(range(225)) and all(len(row) == 1200 for row in rows.values()), name
        pixels = b''.join(rows[y] for y in range(225))
        images[name] = Image.frombytes('RGB', (400, 225), pixels)
    return images


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
parser.add_argument('regression', type=Path)
args = parser.parse_args()
baseline, candidate, regression = (path.read_text() for path in (args.baseline, args.candidate, args.regression))

sites = r'^QUEST_SITE (.+)$'
assert re.findall(sites, baseline, re.M) == re.findall(sites, candidate, re.M)
left, right = frames(baseline), frames(candidate)
assert list(left) == list(right)
models = [json.loads(row) for row in re.findall(r'^QUEST_LANDMARK (.+)$', candidate, re.M)]
out = Path(__file__).resolve().parent
previous = json.loads((out.parent / 'epic-quest-readability-20261119' / 'studio-results.json').read_text())
previous_models = previous['models']
assert len(models) == len(previous_models) == 5
for prior, updated in zip(previous_models, models):
    for key in ('id', 'model', 'ground', 'approach'):
        assert prior[key] == updated[key], (prior['id'], key)
report, = re.findall(r'^CAMPAIGN_EXPANSION_NATIVE (.+)$', regression, re.M)
report = json.loads(report)
assert not report['blockers']
for key in ('checks', 'incidents', 'samples', 'steps'):
    assert report[key] == previous['expansionRegression'][key], key

board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
draw = ImageDraw.Draw(board)
draw.text((6, 6), '0.114.2', fill='white')
draw.text((418, 6), '0.114.4', fill='white')
for i, (name, before) in enumerate(left.items()):
    y = 28 + i * 250
    board.paste(before, (6, y))
    board.paste(right[name], (418, y))
    draw.text((6, y + 229), name, fill='white')
board.save(out / 'comparison.jpg', quality=92, optimize=True)
(out / 'studio-results.json').write_text(json.dumps({
    'models': models,
    'partsBefore': sum(model['parts'] for model in previous_models),
    'partsAfter': sum(model['parts'] for model in models),
    'framePairs': list(left),
    'expansionRegression': report,
}, indent=2) + '\n')
