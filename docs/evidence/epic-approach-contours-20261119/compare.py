"""Compare the Studio result with fixed route contracts and assemble paired frames."""
import argparse
import hashlib
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

EVIDENCE = Path(__file__).resolve().parent
PRIOR = EVIDENCE.parent / 'epic-return-readability-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
parser.add_argument('--extra-cameras', type=Path)
parser.add_argument('--output-dir', type=Path, default=EVIDENCE)
parser.add_argument('--versions', metavar=('BASELINE', 'CANDIDATE'), nargs=2, default=('0.113.22', '0.113.23'))
args = parser.parse_args()
before, after = (path.read_text() for path in (args.baseline, args.candidate))


def rows(tag):
    return [json.loads(value) for value in re.findall(r'^TLT_' + tag + r' (.+)$', after, re.M)]


def frames(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    shots = {}
    for name, scanline, pixels in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        shots.setdefault(name, {})[int(scanline)] = bytes.fromhex(pixels)
    cameras = json.loads((EVIDENCE / 'cameras.json').read_text())
    if args.extra_cameras:
        cameras.extend(json.loads(args.extra_cameras.read_text()))
    expected = [shot['id'] for shot in cameras]
    assert list(shots) == expected, list(shots)
    images = {}
    for name, scanlines in shots.items():
        assert set(scanlines) == set(range(225)) and all(len(line) == 1200 for line in scanlines.values()), name
        images[name] = Image.frombytes('RGB', (400, 225), b''.join(scanlines[y] for y in range(225)))
    return images


assert 'TLT_ROUTE_FINAL' in after and 'TLT_RESCUE_DONE' in after
prior = json.loads((PRIOR / 'studio-results.json').read_text())
compile_count, = rows('ROUTE_COMPILE')
assert compile_count == prior['compileCount'] + 1
navigation = {mode: rows('ROUTE_' + mode)[0] for mode in prior['navigation']}
assert navigation == prior['navigation']
walks = rows('ROUTE_WALK')
assert {row['name'] for row in walks} == {row['name'] for row in prior['walks']}
assert all(row['approach']['arrived'] and row['retreat']['arrived'] for row in walks)
contours = rows('CONTOUR')
assert len({row['name'] for row in contours}) == len(contours) == 5
placements = rows('APPROACH_PLACEMENT')
previous_placements = json.loads((EVIDENCE.parent / 'epic-landmark-material-contrast-20261119' /
                                  'studio-results.json').read_text())['investigationPlacements']
assert len(placements) == len(previous_placements) == 12
for current, previous in zip(placements, previous_placements, strict=True):
    assert all(current[key] == previous[key] for key in ('name', 'ground', 'approach')), current
stations = rows('STATION')
assert stations == prior['stations']
solids = rows('RESCUE_SOLID')
assert len(solids) == len(prior['collisionModels']) == 2
for current in solids:
    previous = next(row for row in prior['collisionModels'] if row['name'] == current['name'])
    shapes = sorted(current.pop('placement'), key=lambda part: (part['name'], part['at']))
    current['shapeSHA256'] = hashlib.sha256(json.dumps(shapes, sort_keys=True).encode()).hexdigest()
    assert current == previous

args.output_dir.mkdir(parents=True, exist_ok=True)
(args.output_dir / 'studio-results.json').write_text(json.dumps({
    'compileCount': compile_count,
    'navigation': navigation,
    'walks': walks,
    'collisionModels': solids,
    'stations': stations,
    'investigationPlacements': placements,
    'contours': contours,
}, indent=2) + '\n')

original, candidate = frames(before), frames(after)
board = Image.new('RGB', (836, 30 + 250 * len(original)), '#171c20')
draw = ImageDraw.Draw(board)
for x, label, images in ((12, args.versions[0], original), (424, args.versions[1], candidate)):
    draw.text((x, 8), label, fill='white')
    for index, (name, image) in enumerate(images.items()):
        y = 30 + 250 * index
        board.paste(image, (x, y))
        draw.text((x, y + 229), name, fill='white')
board.save(args.output_dir / 'comparison.jpg', quality=92, optimize=True)
