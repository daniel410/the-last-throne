"""Compare fixed-camera images, route checks, and landmark geometry."""
import argparse
import json
from pathlib import Path
import re
import runpy

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
audit = runpy.run_path(str(HERE.parent / 'epic-finale-readability-20261120' / 'compare.py'))
rows = audit['rows']
by_name = audit['by_name']
captures = audit['captures']

parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
parser.add_argument('--baseline-sightline', type=Path,
                    help='Earlier baseline probe carrying the corrected left-of-Suri frame')
args = parser.parse_args()
before, after = (path.read_text() for path in (args.baseline, args.candidate))

stable = ('ROUTE_COMPILE', 'ROUTE_NAV_ORIGINAL', 'ROUTE_NAV_EASY', 'CONTOUR', 'STATION', 'RESCUE_SOLID')
for tag in stable:
    assert rows(before, tag) and rows(before, tag) == rows(after, tag), tag

walks = []
for log in (before, after):
    assert 'TLT_ROUTE_FINAL' in log and 'TLT_RESCUE_DONE' in log
    assert by_name(log, 'ROUTE_MODEL') == by_name(log, 'ROUTE_DIRECT')
    route_walks = by_name(log, 'ROUTE_WALK')
    assert len(route_walks) == 23
    assert all(walk['approach']['arrived'] and walk['retreat']['arrived'] for walk in route_walks.values())
    walks.append(route_walks)

assert walks[0].keys() == walks[1].keys()
models = by_name(after, 'ROUTE_MODEL')
previous_models = by_name(before, 'ROUTE_MODEL')
cradle = models.pop('DispatchCarrierCradle')
previous_cradle = previous_models.pop('DispatchCarrierCradle')
assert models == previous_models
assert previous_cradle['parts'] == 11 and cradle['parts'] == 15
for key in ('story', 'goal', 'ground', 'approach', 'bounds', 'footprintHeightDeltas'):
    assert cradle[key] == previous_cradle[key], key
old_images, new_images = (captures(log) for log in (before, after))
sightline_baseline = before
if args.baseline_sightline:
    sightline_baseline = args.baseline_sightline.read_text()
    scanlines = {int(y): bytes.fromhex(pixels) for y, pixels in re.findall(
        r'^TLT_APPROACH_FRAME EC-07_leftOfSuri (\d+) ([a-f0-9]+)$', sightline_baseline, re.M)}
    assert set(scanlines) == set(range(225))
    old_images['EC-07_goal_side'] = Image.frombytes(
        'RGB', (400, 225), b''.join(scanlines[y] for y in range(225)))

sightlines = [rows(log, 'EC_DISPATCH') for log in (sightline_baseline, after)]
for entries in sightlines:
    views = {entry['view']: entry for entry in entries}
    assert len(views) == 6
    assert all(view['samples'] == 27 for view in views.values())
    assert views['goal']['visible'] == 0
    assert views['goal']['blockers']['Workspace.DeepwoodCampaign.NPCActors.Suri.BodyMesh']['count'] == 27
    assert all(views[name]['visible'] == 27 for name in ('leftOfSuri', 'rightOfSuri', 'detail', 'middle'))
    assert views['overShoulder']['visible'] == 24
assert 'TLT_DISPATCH_ROLLERS_OK 6 2' in after
shots = ['EC-07_detail', 'EC-07_mid_approach', 'EC-07_goal_side']
assert all(old_images[name].tobytes() != new_images[name].tobytes() for name in shots)
board = Image.new('RGB', (836, 30 + 250 * len(shots)), '#171c20')
draw = ImageDraw.Draw(board)
for x, label, images in ((12, '0.114.21', old_images), (424, '0.114.22', new_images)):
    draw.text((x, 8), label, fill='white')
    for index, name in enumerate(shots):
        y = 30 + 250 * index
        board.paste(images[name], (x, y))
        draw.text((x, y + 229), name, fill='white')
board.save(HERE / 'comparison.jpg', quality=92, optimize=True)
results = {
    'compiled': rows(after, 'ROUTE_COMPILE')[0],
    'navigation': {tag: rows(after, tag)[0] for tag in stable if tag.startswith('ROUTE_NAV')},
    'matchingLandmarks': len(models),
    'dispatchCradle': {'baseline': previous_cradle, 'candidate': cradle},
    'roundTripsPerBuild': [len(entries) for entries in walks],
    'auditedViews': list(old_images),
    'comparedViews': shots,
    'sightlines': {'baseline': sightlines[0], 'candidate': sightlines[1]},
    'rollerCount': 6,
}
(HERE / 'studio-results.json').write_text(json.dumps(results, indent=2) + '\n')
