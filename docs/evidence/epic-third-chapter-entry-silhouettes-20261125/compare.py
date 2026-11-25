"""Verify paired entrance audits and compile the ten fixed Studio camera pairs."""
import argparse
import importlib.util
import json
from pathlib import Path

from PIL import Image, ImageDraw

evidence = Path(__file__).resolve().parent
shared = evidence.parent / 'epic-third-chapter-rescue-routes-20261124' / 'compare.py'
spec = importlib.util.spec_from_file_location('route_capture', shared)
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
records = capture.records

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('work', type=Path)
parser.add_argument('baseline_version')
parser.add_argument('candidate_version')
args = parser.parse_args()

sites = {'DW-03_exp_2', 'GW-03_exp_1', 'FV-03_exp_1', 'EC-03_exp_1', 'HG-03_exp_2'}
chapters = {site.split('_')[0] for site in sites}


def keyed(log, prefix, field):
    rows = records(log, prefix)
    result = {row[field]: row for row in rows}
    assert len(result) == len(rows), prefix
    return result


def read(tag):
    audit = (args.work / f'{tag}-audit.log').read_text()
    regression_log = (args.work / f'{tag}-regression.log').read_text()
    camera, = records(audit, 'INFRASTRUCTURE_CAMERA_PLAN')
    regression, = records(regression_log, 'CAMPAIGN_EXPANSION_NATIVE')
    assert regression['checks'] == 9310 and regression['blockers'] == []
    routes = keyed(audit, 'ENTRY_ROUTE', 'scene')
    models = keyed(audit, 'ENTRY_MODEL', 'scene')
    walks = keyed(audit, 'SECOND_CHAPTER_WALK', 'chapter')
    assert set(routes) == sites and sites <= models.keys()
    assert len(models) == regression['incidents']
    assert all(row['samples'] == 65 and row['floorError'] < 1
               and abs(row['distance'] - 32) < .01 for row in routes.values())
    assert set(walks) == chapters
    assert all(row.get('inbound', 2.5) < 2.5 and row.get('outbound', 2.5) < 2.5
               and abs(row['distance'] - 32) < .01 for row in walks.values()), walks
    frames = capture.frames(audit)
    assert len(frames) == 10 and list(frames) == [shot['id'] for shot in camera]
    return camera, routes, models, walks, regression, frames


old_camera, old_routes, old_models, old_walks, old_regression, old_frames = read('before')
new_camera, new_routes, new_models, new_walks, new_regression, new_frames = read('after')
assert old_camera == new_camera
assert old_routes == new_routes
assert old_models.keys() == new_models.keys()
changed = {name for name in old_models if old_models[name] != new_models[name]}
assert changed == sites, changed
for field in ('incidents', 'steps', 'samples', 'checks'):
    assert old_regression[field] == new_regression[field], field
part_delta = sum(len(new_models[name]['parts']) - len(old_models[name]['parts']) for name in sites)
assert new_regression['parts'] - old_regression['parts'] == part_delta

board = Image.new('RGB', (824, 28 + 250 * len(old_frames)), '#171c20')
labels = ImageDraw.Draw(board)
labels.text((6, 6), args.baseline_version, fill='white')
labels.text((418, 6), args.candidate_version, fill='white')
for index, name in enumerate(old_frames):
    y = 28 + 250 * index
    board.paste(old_frames[name], (6, y))
    board.paste(new_frames[name], (418, y))
    labels.text((6, y + 229), name, fill='white')
board.save(evidence / 'comparison.jpg', quality=92, optimize=True)


def summary(models):
    return {name: {**models[name], 'parts': len(models[name]['parts'])} for name in sorted(sites)}


(evidence / 'studio-results.json').write_text(json.dumps({
    'versions': {'before': args.baseline_version, 'after': args.candidate_version},
    'models': {'before': summary(old_models), 'after': summary(new_models)},
    'unchangedEntrances': sorted(old_models.keys() - changed),
    'entryRoutes': new_routes,
    'walks': {'before': old_walks, 'after': new_walks},
    'framePairs': list(old_frames),
    'partDelta': part_delta,
    'campaignRegression': {'before': old_regression, 'after': new_regression},
}, indent=2) + '\n')
