"""Check unchanged routes and assemble the fixed Studio camera pairs."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
PRIOR = HERE.parent / 'epic-contour-readability-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
args = parser.parse_args()
baseline, candidate = (log.read_text() for log in (args.baseline, args.candidate))
prior = json.loads((PRIOR / 'studio-results.json').read_text())
cameras = json.loads((HERE / 'cameras.json').read_text())
stories = {'DW-07', 'GW-07', 'FV-07', 'EC-07', 'HG-07'}


def rows(tag):
    return [json.loads(value) for value in re.findall(r'^TLT_' + tag + r' (.+)$', candidate, re.M)]


def captures(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    shots = {}
    for name, y, pixels in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        shots.setdefault(name, {})[int(y)] = bytes.fromhex(pixels)
    assert list(shots) == [shot['id'] for shot in cameras], list(shots)
    images = {}
    for name, scanlines in shots.items():
        assert set(scanlines) == set(range(225)) and all(len(line) == 1200 for line in scanlines.values()), name
        images[name] = Image.frombytes('RGB', (400, 225), b''.join(scanlines[y] for y in range(225)))
    return images


assert 'TLT_ROUTE_FINAL' in candidate and 'TLT_RESCUE_DONE' in candidate
compiled, = rows('ROUTE_COMPILE')
assert compiled == prior['compileCount'] + 1
navigation = {mode: rows('ROUTE_' + mode)[0] for mode in prior['navigation']}
assert navigation == prior['navigation']
alone, full = (
    [row for row in rows(tag) if row['story'] in stories]
    for tag in ('ROUTE_DIRECT', 'ROUTE_MODEL')
)
assert {row['story'] for row in full} == stories and len(full) == len(alone) == 5
assert {row['story']: row['parts'] for row in full} == {
    'DW-07': 9, 'GW-07': 6, 'FV-07': 8, 'EC-07': 9, 'HG-07': 10,
}
assert {row['name']: row for row in full} == {row['name']: row for row in alone}
walks = rows('ROUTE_WALK')
assert {row['name'] for row in walks} == {row['name'] for row in prior['walks']} | {row['name'] for row in full}
assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in walks), walks
assert rows('CONTOUR') == prior['contours']
assert rows('STATION') == prior['stations']
finale_names = {row['name'] for row in full}
placements = [row for row in rows('APPROACH_PLACEMENT') if row['name'] not in finale_names]
assert len(placements) == len(prior['investigationPlacements'])
for current, previous in zip(placements, prior['investigationPlacements'], strict=True):
    assert all(current[key] == previous[key] for key in ('name', 'ground', 'approach')), current
solids = rows('RESCUE_SOLID')
assert len(solids) == len(prior['collisionModels'])
for current in solids:
    previous = next(row for row in prior['collisionModels'] if row['name'] == current['name'])
    shapes = sorted(current.pop('placement'), key=lambda part: (part['name'], part['at']))
    current['shapeSHA256'] = hashlib.sha256(json.dumps(shapes, sort_keys=True).encode()).hexdigest()
    assert current == previous

before, after = captures(baseline), captures(candidate)
assert all(before[name].tobytes() != after[name].tobytes() for name in before)
board = Image.new('RGB', (836, 30 + 250 * len(cameras)), '#171c20')
draw = ImageDraw.Draw(board)
for x, label, images in ((12, '0.113.24', before), (424, '0.113.25', after)):
    draw.text((x, 8), label, fill='white')
    for index, (name, image) in enumerate(images.items()):
        y = 30 + 250 * index
        board.paste(image, (x, y))
        draw.text((x, y + 229), name, fill='white')
board.save(HERE / 'comparison.jpg', quality=92, optimize=True)
(HERE / 'studio-results.json').write_text(json.dumps({
    'compileCount': compiled, 'navigation': navigation, 'walks': walks,
    'standaloneFinaleModels': alone, 'fullFinaleModels': full,
    'collisionModels': solids,
}, indent=2) + '\n')
