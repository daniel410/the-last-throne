"""Compare shared floor transforms, route outcomes and matched Studio frames."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
parser.add_argument('--output-dir', type=Path, default=HERE)
parser.add_argument('--baseline-version', default='0.115.10')
parser.add_argument('--candidate-version', default='0.115.11')
args = parser.parse_args()


def read(path):
    log = path.read_text()
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    rows = {}
    for name, y, data in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([0-9a-f]+)$', log, re.M):
        assert len(data) == 2400
        rows.setdefault(name, {})[int(y)] = bytes.fromhex(data)
    images = {
        name: Image.frombytes('RGB', (400, 225), b''.join(lines[y] for y in range(225)))
        for name, lines in rows.items()
    }
    stats = {
        key: [json.loads(line) for line in re.findall(r'^' + tag + r' (.+)$', log, re.M)]
        for key, tag in [('geometry', 'BOUNDARY_GEOMETRY'), ('walk', 'OVERLAND_CASE')]
    }
    stats['walk'].sort(key=lambda row: row['id'])
    assert len(stats['walk']) == 8
    assert all(row['arrived'] and row['jumps'] == row['corrections'] == 0 for row in stats['walk'])
    return images, stats


before, baseline = read(args.baseline)
after, candidate = read(args.candidate)
assert before.keys() == after.keys() and len(before) == 9
assert len(baseline['geometry']) == len(candidate['geometry']) == 4
for old, new in zip(baseline['geometry'], candidate['geometry']):
    assert all(old[key] == new[key] for key in ('id', 'floor', 'size', 'parts'))

sheet = Image.new('RGB', (800, 26 + 250 * len(before)), '#111622')
draw = ImageDraw.Draw(sheet)
draw.text((8, 7), f'{args.baseline_version}  BEFORE', fill='white')
draw.text((408, 7), f'{args.candidate_version}  AFTER', fill='white')
for index, name in enumerate(before):
    y = 26 + 250 * index
    sheet.paste(before[name], (0, y))
    sheet.paste(after[name], (400, y))
    draw.text((8, y + 229), name, fill='white')
args.output_dir.mkdir(parents=True, exist_ok=True)
sheet.save(args.output_dir / 'comparison.jpg', quality=91)
(args.output_dir / 'studio-results.json').write_text(json.dumps({'baseline': baseline, 'candidate': candidate}, indent=2) + '\n')
