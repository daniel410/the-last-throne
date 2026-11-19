"""Summarize the fixed Studio trial and assemble both builds' camera frames."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
WIDTH, HEIGHT = 400, 225
TAG = re.compile(r'\bTLT_(?:ROUTE|APPROACH)_([A-Z_]+)\s*(.*)')
parser = argparse.ArgumentParser()
parser.add_argument('candidate', type=Path)
parser.add_argument('baseline', type=Path)
parser.add_argument('--before-frames', type=Path, required=True)
parser.add_argument('--after-frames', type=Path, required=True)
args = parser.parse_args()


def results(path):
    records = {}
    for line in path.read_text().splitlines():
        match = TAG.search(line)
        if match:
            key, payload = match.groups()
            if key not in ('FRAME', 'FRAMES_DONE'):
                records.setdefault(key, []).append(json.loads(payload) if payload else True)
    assert records['FINAL'] == [True], path
    return records


def frames(path):
    panels = {}
    complete = False
    for line in path.read_text().splitlines():
        match = TAG.search(line)
        if match:
            key, payload = match.groups()
            if key == 'FRAMES_DONE':
                complete = True
            elif key == 'FRAME':
                name, row, color = payload.split()
                panels.setdefault(name, {})[int(row)] = bytes.fromhex(color)
    assert complete, path
    return panels


after, before = results(args.candidate), results(args.baseline)
assert after['COMPILE'] == before['COMPILE'] == [543]
for mode in ('NAV_ORIGINAL', 'NAV_EASY'):
    for old, new in zip(before[mode], after[mode], strict=True):
        assert sorted(row['label'] for row in old['blockers']) == [
            'DW-02:survivors:shelter', *(['DW-Q1:marsh_report'] * 3)]
        assert not new['blockers'], new['blockers']
        assert old['epics'].keys() == new['epics'].keys()
        for epic, values in new['epics'].items():
            assert all(value == old['epics'][epic][key]
                       for key, value in values.items() if key != 'blockers')
            assert values['corrections'] == values['floors'] == values['routeFailures'] == 0

assert len(after['DIRECT']) == len(after['MODEL']) == 7
assert {row['name']: row['parts'] for row in after['DIRECT']} == {
    row['name']: row['parts'] for row in after['MODEL']}
assert len(after['PLACEMENT']) == len(before['PLACEMENT']) == 9
assert len(after['WALK']) == len(before['WALK']) == 12
for row in after['WALK']:
    assert row['approach']['arrived'] and row['retreat']['arrived'], row
    if row['name'] == 'DeepwoodMarshPriorOverlap':
        for walk in ('approach', 'retreat'):
            distances = row[walk]['closestToContacts']
            assert len(distances) == 3 and max(distances) < 6, row
for row in before['WALK']:
    assert row['approach']['arrived'] == (row['name'] != 'DeepwoodMarshPriorOverlap'), row
    assert row['retreat']['arrived'], row
for data in (after, before):
    data['WALK'].sort(key=lambda row: row['name'])

cameras = json.loads((ROOT / 'cameras.json').read_text())
gutter, header, caption = 12, 32, 28
board = Image.new('RGB', (2 * WIDTH + gutter * 3, header + len(cameras) * (HEIGHT + caption)), '#161a20')
draw = ImageDraw.Draw(board)
font = ImageFont.load_default(size=15)
for column, label in enumerate(('0.113.11', '0.113.12')):
    draw.text((gutter + column * (WIDTH + gutter), 8), label, font=font, fill='white')
for column, images in enumerate((frames(args.before_frames), frames(args.after_frames))):
    assert len(images) == len(cameras)
    for index, camera in enumerate(cameras):
        y = header + index * (HEIGHT + caption)
        rows = images[camera['id']]
        assert len(rows) == HEIGHT and all(len(row) == WIDTH * 3 for row in rows.values())
        panel = Image.frombytes('RGB', (WIDTH, HEIGHT), b''.join(rows[i] for i in range(HEIGHT)))
        board.paste(panel, (gutter + column * (WIDTH + gutter), y))
        draw.text((gutter, y + HEIGHT + 5), camera['id'].replace('_', ' '), font=font, fill='white')
board.save(ROOT / 'comparison.jpg', quality=91, optimize=True)
(ROOT / 'studio-results.json').write_text(
    json.dumps({'baseline': before, 'candidate': after}, indent=2) + '\n')
