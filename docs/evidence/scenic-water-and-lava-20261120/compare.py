"""Save paired in-engine captures and compare the campaign route samples."""
import argparse
import json
from pathlib import Path
import re
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
args = parser.parse_args()


def read(path):
    log = path.read_text()
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    frames = {}
    for key, y, row in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([0-9a-f]{2400})$', log, re.M):
        frames.setdefault(key, {})[int(y)] = bytes.fromhex(row)
    images = {
        key: Image.frombytes('RGB', (400, 225), b''.join(rows[y] for y in range(225)))
        for key, rows in frames.items()
    }
    models = [json.loads(data) for data in re.findall(r'^TLT_FLOW_MODEL (.+)$', log, re.M)]
    routes = json.loads(re.search(r'^EPIC_MAP_NAVIGATION (.+)$', log, re.M)[1])
    return images, models, routes


before, old_models, old_routes = read(args.baseline)
after, models, routes = read(args.candidate)
assert len(before) == 6 and before.keys() == after.keys()
assert not old_models and len(models) == 6
for key in ('epics', 'blockers', 'floors', 'routeFailures', 'corrections'):
    assert old_routes[key] == routes[key], key
vision = [int(value) for value in re.findall(r'^ASH_VISION (\d+) ', args.candidate.read_text(), re.M)]
assert vision
sheet = Image.new('RGB', (800, 26 + 250 * len(before)), '#121723')
draw = ImageDraw.Draw(sheet)
draw.text((8, 7), '0.114.28  BEFORE', fill='white')
draw.text((408, 7), '0.114.35  AFTER', fill='white')
for i, name in enumerate(before):
    y = 26 + 250 * i
    sheet.paste(before[name], (0, y))
    sheet.paste(after[name], (400, y))
    draw.text((8, y + 229), name, fill='white')
sheet.save(HERE / 'comparison.jpg', quality=91)
(HERE / 'studio-results.json').write_text(json.dumps({
    'models': models, 'routes': routes['epics'],
    'ashSpireSightlines': {'viewCount': len(vision), 'viewsReachingVent': sum(v > 0 for v in vision), 'maxSamplesReached': max(vision)},
    'priorRoutes': old_routes['epics'],
}, indent=2) + '\n')
