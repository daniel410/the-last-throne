"""Verify paired Studio results and assemble the fixed-camera board."""
import importlib.util
import json
from pathlib import Path
import re
import sys

from PIL import Image, ImageDraw

evidence = Path(__file__).resolve().parent
previous = evidence.parent / 'epic-third-chapter-rescue-routes-20261124' / 'compare.py'
spec = importlib.util.spec_from_file_location('rescue_route_capture', previous)
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
records = capture.records

work = Path(sys.argv[1])
before, after = [(work / f'{tag}-audit.log').read_text() for tag in ('before', 'after')]
plan, = records(before, 'INFRASTRUCTURE_CAMERA_PLAN')
assert records(after, 'INFRASTRUCTURE_CAMERA_PLAN') == [plan]
left, right = capture.frames(before), capture.frames(after)
assert list(left) == list(right) == [shot['id'] for shot in plan]
assert len(left) == 10

names = {'OutpostSightRest', 'RefugeLanternReturn', 'RavineSupplyBank',
         'MineRescueRailSeat', 'FortressStoneRailSeat'}
models = {}
walks = {}
sightlines = {}
regression = {}
for tag, log in (('before', before), ('after', after)):
    rows = records(log, 'INFRASTRUCTURE_LANDMARK')
    models[tag] = {row['model']: row for row in rows}
    assert len(models[tag]) == len(rows) and names <= models[tag].keys()
    overlaps = re.findall(r'^FOURTH_CHAPTER_LANDMARK_OVERLAP_CLEAR (\S+)$', log, re.M)
    assert sorted(overlaps) == sorted(names)
    walks[tag] = sorted(records(log, 'SECOND_CHAPTER_WALK'), key=lambda row: row['chapter'])
    assert len(walks[tag]) == 5
    assert {row['chapter'] for row in walks[tag]} == {models[tag][name]['chapter'] for name in names}
    assert all(row['inbound'] < 2.5 and row['outbound'] < 2.5 for row in walks[tag])
    sightlines[tag], = records(log, 'GW_SHELTER_SIGHTLINES')
    regression[tag], = records((work / f'{tag}-regression.log').read_text(), 'CAMPAIGN_EXPANSION_NATIVE')
    assert regression[tag]['blockers'] == [] and regression[tag]['checks'] == 9310

assert models['before'].keys() == models['after'].keys()
unchanged = sorted(models['before'].keys() - names)
assert all(models['before'][name] == models['after'][name] for name in unchanged)
for name in sorted(names):
    old, new = models['before'][name], models['after'][name]
    assert new['anchor'] == old['anchor'] and new['maxFloorError'] < .2 and new['routeClearance'] >= 3
    assert (new['ground'] != old['ground']) == (name == 'RefugeLanternReturn')
for field in ('incidents', 'steps', 'samples', 'checks'):
    assert regression['before'][field] == regression['after'][field]
assert regression['after']['parts'] - regression['before']['parts'] == 13
assert sum(row['blocked'] for row in sightlines['before']['fromNext']) > 0
assert all(row['blocked'] == 0 for direction in sightlines['after'].values() for row in direction)

board = Image.new('RGB', (824, 28 + 250 * len(left)), '#171c20')
labels = ImageDraw.Draw(board)
labels.text((6, 6), '0.115.113', fill='white')
labels.text((418, 6), '0.115.114', fill='white')
for index, name in enumerate(left):
    y = 28 + 250 * index
    board.paste(left[name], (6, y))
    board.paste(right[name], (418, y))
    labels.text((6, y + 229), name, fill='white')
board.save(evidence / 'comparison.jpg', quality=92, optimize=True)
(evidence / 'studio-results.json').write_text(json.dumps({
    'landmarks': {tag: [rows[name] for name in sorted(names)] for tag, rows in models.items()},
    'unchangedLandmarks': unchanged,
    'landmarkOverlapClear': sorted(names),
    'walks': walks,
    'gloamwoodShelterSightlines': sightlines,
    'framePairs': list(left),
    'campaignRegression': regression,
}, indent=2) + '\n')
