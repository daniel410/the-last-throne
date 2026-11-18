"""Compare Studio output with 0.113.10 and assemble the fixed-camera board."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageChops, ImageDraw, ImageFont

EVIDENCE = Path(__file__).resolve().parent
WIDTH, HEIGHT = 480, 270


def decode_log(path):
    output = {}
    frames = {}
    complete = False
    for line in path.read_text().splitlines():
        match = re.search(r'\bTLT_ROUTE_([A-Z_]+)\s*(.*)', line)
        if not match:
            continue
        key, payload = match.groups()
        if key == 'FINAL':
            complete = True
        elif key == 'FRAME':
            name, variant, y, rgb = payload.split()
            rows = frames.setdefault((name, variant), {})
            rows[int(y)] = bytes.fromhex(rgb)
        elif key == 'COMPILE' or payload.startswith('{'):
            output.setdefault(key, []).append(json.loads(payload))
    assert complete, f'Studio did not reach the final marker in {path}'
    return output, frames


def render_board(cameras, frames, path):
    label, gutter = 35, 14
    board = Image.new('RGB', (2 * WIDTH + gutter * 3, label + len(cameras) * (HEIGHT + label)), '#161a20')
    draw = ImageDraw.Draw(board)
    header = ImageFont.load_default(size=17)
    small = ImageFont.load_default(size=15)
    draw.text((gutter, 8), 'CONTROL', font=header, fill='#d6dadf')
    draw.text((2 * gutter + WIDTH, 8), 'CANDIDATE', font=header, fill='#d6dadf')
    deltas = {}
    for i, camera in enumerate(cameras):
        name = camera['model']
        y = label + i * (HEIGHT + label)
        panels = []
        for side, variant in enumerate(('control', 'candidate')):
            rows = frames[(name, variant)]
            assert len(rows) == HEIGHT and all(len(row) == WIDTH * 3 for row in rows.values()), name
            panel = Image.frombytes('RGB', (WIDTH, HEIGHT), b''.join(rows[j] for j in range(HEIGHT)))
            panels.append(panel)
            board.paste(panel, (gutter + side * (WIDTH + gutter), y))
        diff = ImageChops.difference(*panels).split()
        strongest = ImageChops.lighter(ImageChops.lighter(diff[0], diff[1]), diff[2])
        deltas[name] = sum(strongest.histogram()[17:])
        assert deltas[name] > 200, f'No meaningful frame difference for {name}'
        draw.text((gutter, y + HEIGHT + 6), f"{camera['story']}  {name.replace('__side', '  /  Side view')}", font=small, fill='white')
    board.save(path, quality=90, optimize=True)
    return deltas


parser = argparse.ArgumentParser()
parser.add_argument('log', type=Path)
parser.add_argument('--side-log', type=Path)
parser.add_argument('--baseline-log', type=Path)
parser.add_argument('--output', type=Path, default=EVIDENCE)
args = parser.parse_args()
data, frames = decode_log(args.log)
reference = json.loads((EVIDENCE.parent / 'epic-story-landmarks-20261118' / 'studio-results.json').read_text())
routes = {}
for mode in ('ORIGINAL', 'EASY'):
    candidate, = data[f'NAV_{mode}']
    prior = reference[f'EPIC_STORY_NAV_{mode}']
    assert candidate == prior, f'{mode} route differs from 0.113.10'
    routes[mode] = candidate
models = data['MODEL']
assert len(models) == len(data['DIRECT']) == 7
assert {row['name'] for row in models} == {row['name'] for row in data['DIRECT']}
assert len(data['WALK']) == 9 and all('error' not in row for row in data['WALK']), data['WALK']
cameras = data.get('CAMERA', [])
if args.side_log:
    side_data, side_frames = decode_log(args.side_log)
    assert len(side_data['CAMERA']) == 4
    cameras += side_data['CAMERA']
    frames.update(side_frames)
deltas = render_board(cameras, frames, args.output / 'comparison.jpg') if cameras else {}
result = {
    'baselineVersion': '0.113.10',
    'candidateVersion': json.loads((EVIDENCE / 'build.json').read_text())['version'],
    'compiled': data['COMPILE'][0],
    'models': models,
    'directEntry': data['DIRECT'],
    'navigationMatchesBaseline': True,
    'navigation': routes,
    'walking': data['WALK'],
    'cameras': cameras,
    'changedPixelsOver16': deltas,
}
if args.baseline_log:
    base, _ = decode_log(args.baseline_log)
    for mode, route in routes.items():
        assert base[f'NAV_{mode}'] == [route]
    baseline_walk = {row['name']: row for row in base['WALK']}
    result['baselineWalking'] = [baseline_walk[name] for name in
        ('DeepwoodShelterPriorOverlap', 'DeepwoodMarshPriorOverlap')]
(args.output / 'studio-results.json').write_text(json.dumps(result, indent=2) + '\n')
