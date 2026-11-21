"""Save matched Studio frames and check the original floor and prop placement."""
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
        for key, tag in [('roads', 'ROAD_SHOULDERS'), ('carrier', 'ROAD_CARRIER'),
                         ('walk', 'OVERLAND_CASE')]
    }
    stats['compiled'] = int(re.search(r'^ROAD_COMPILED\s+(\d+)$', log, re.M)[1])
    assert len(stats['walk']) == 8
    assert all(row['arrived'] and row['jumps'] == row['corrections'] == 0 for row in stats['walk'])
    return images, stats


before, baseline = read(args.baseline)
after, candidate = read(args.candidate)
assert before.keys() == after.keys() and len(before) == 5
assert 'ROAD_CARRIER_COLOR_PASS 18' in args.candidate.read_text()
candidate['carrierColorsChecked'] = 18
assert len(baseline['roads']) == len(candidate['roads']) == 4
for old, new in zip(baseline['roads'], candidate['roads']):
    for key in ('id', 'floorSize', 'floorTransform'):
        assert old[key] == new[key], key
    assert old['count'] == 0 and new['count'] == new['buried'] == 12
old, = baseline['carrier']
new, = candidate['carrier']
assert old['pivot'] == new['pivot']
assert all(abs(a - b) < .005 for a, b in zip(old['size'], new['size']))
sheet = Image.new('RGB', (800, 26 + 250 * len(before)), '#111622')
draw = ImageDraw.Draw(sheet)
draw.text((8, 7), '0.114.27  BEFORE', fill='white')
draw.text((408, 7), '0.114.28  AFTER', fill='white')
for i, name in enumerate(before):
    y = 26 + 250 * i
    sheet.paste(before[name], (0, y))
    sheet.paste(after[name], (400, y))
    draw.text((8, y + 229), name, fill='white')
sheet.save(HERE / 'comparison.jpg', quality=91)
(HERE / 'studio-results.json').write_text(json.dumps({'baseline': baseline, 'candidate': candidate}, indent=2) + '\n')
