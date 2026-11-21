"""Create a same-camera comparison and a loop of sampled engine-rendered frames."""
import argparse
from pathlib import Path
import json
import re
from PIL import Image, ImageChops, ImageDraw

HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
parser.add_argument('--baseline-version', default='0.114.35')
parser.add_argument('--candidate-version', default='0.114.39')
parser.add_argument('--output-dir', type=Path, default=HERE)
parser.add_argument('--motion-candidate', type=Path, help='Separate candidate capture for the motion plate')
parser.add_argument('--motion-version', help='Build used for a separate motion capture')
args = parser.parse_args()
args.output_dir.mkdir(parents=True, exist_ok=True)


def read(path):
    log = path.read_text()
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    frames = {}
    for key, y, row in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([0-9a-f]{2400})$', log, re.M):
        frames.setdefault(key, {})[int(y)] = bytes.fromhex(row)
    images = {key: Image.frombytes('RGB', (400, 225), b''.join(rows[y] for y in range(225)))
              for key, rows in frames.items()}
    routes = json.loads(re.search(r'^EPIC_MAP_NAVIGATION (.+)$', log, re.M)[1])
    return images, routes


def plate(pairs, before_label, after_label):
    image = Image.new('RGB', (800, 26 + 248 * len(pairs)), '#111823')
    draw = ImageDraw.Draw(image)
    draw.text((8, 8), before_label, fill='white')
    draw.text((408, 8), after_label, fill='white')
    for row, (name, old, new) in enumerate(pairs):
        y = 26 + row * 248
        image.paste(old, (0, y))
        image.paste(new, (400, y))
        draw.text((8, y + 227), name, fill='white')
    return image


before, old_routes = read(args.baseline)
after, routes = read(args.candidate)
assert bool(args.motion_candidate) == bool(args.motion_version)
motion, motion_routes = read(args.motion_candidate) if args.motion_candidate else (after, routes)
for key in ('epics', 'blockers', 'floors', 'routeFailures', 'corrections'):
    assert routes[key] == old_routes[key] == motion_routes[key], key
track_stats = json.loads(re.search(r'^TLT_LIQUID_TRACKS (.+)$', args.candidate.read_text(), re.M)[1])
views = {'creek': 'Creekside Cargo', 'falls': 'Waterfall Quarry', 'lava': 'Mine Fracture'}
extra = {'falls_oblique': 'Waterfall Quarry - oblique', 'lava_oblique': 'Mine Fracture - oblique'}
extra = {view: label for view, label in extra.items() if f'{view}_01' in after}
assert len(before) in (len(views) + len(extra), len(views) * 10 + len(extra))
assert len(after) in (len(views) + len(extra), len(views) * 10 + len(extra))
assert all(f'{view}_{n:02}' in motion for view in views for n in range(1, 11))

changed = {}
for view in views:
    first = motion[f'{view}_01'].convert('L')
    changed[view] = max(sum(ImageChops.difference(first, motion[f'{view}_{n:02}'].convert('L')).histogram()[12:])
                        for n in range(2, 11))
    assert changed[view] > 10, f'timed samples did not visibly change: {view}'

comparison = plate([(label, before[f'{view}_01'], after[f'{view}_01'])
                    for view, label in (views | extra).items()],
                   f'{args.baseline_version}  BEFORE', f'{args.candidate_version}  AFTER')
comparison.save(args.output_dir / 'comparison.jpg', quality=94)

loop = []
for n in range(20):
    water_index = n % 10 + 1
    lava_index = n // 2 + 1
    frame = Image.new('RGB', (800, 510), '#111823')
    draw = ImageDraw.Draw(frame)
    for col, view in enumerate(('falls', 'lava')):
        index = lava_index if view == 'lava' else water_index
        frame.paste(motion[f'{view}_{index:02}'], (400 * col, 26))
        draw.text((400 * col + 8, 8), views[view], fill='white')
    frame.paste(motion[f'creek_{water_index:02}'], (200, 262))
    draw.text((208, 490), views['creek'], fill='white')
    loop.append(frame)
loop[0].save(args.output_dir / 'motion.gif', save_all=True, append_images=loop[1:], duration=115, loop=0)

(args.output_dir / 'studio-results.json').write_text(json.dumps({
    'flowTracks': track_stats, 'routes': routes['epics'],
    'motionVersion': args.motion_version or args.candidate_version, 'changedPixels': changed,
}, indent=2) + '\n')
