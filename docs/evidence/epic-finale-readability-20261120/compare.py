"""Validate matching Studio audits and make an unaltered comparison board."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
CAMERAS = HERE.parent / 'epic-finale-refinement-20261119' / 'cameras.json'


def rows(log, tag):
    return [json.loads(value) for value in re.findall(r'^TLT_' + tag + r' (.+)$', log, re.M)]


def by_name(log, tag):
    result = rows(log, tag)
    indexed = {item['name']: item for item in result}
    assert len(result) == len(indexed), tag
    return indexed


def captures(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    shots = {}
    for name, y, pixels in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        shots.setdefault(name, {})[int(y)] = bytes.fromhex(pixels)
    assert list(shots) == [shot['id'] for shot in json.loads(CAMERAS.read_text())]
    images = {}
    for name, scanlines in shots.items():
        assert set(scanlines) == set(range(225))
        assert all(len(line) == 1200 for line in scanlines.values())
        images[name] = Image.frombytes('RGB', (400, 225), b''.join(scanlines[y] for y in range(225)))
    return images


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('baseline', type=Path)
    parser.add_argument('candidate', type=Path)
    args = parser.parse_args()
    baseline, candidate = (path.read_text() for path in (args.baseline, args.candidate))
    finales = {'DW-07': 11, 'GW-07': 7, 'FV-07': 9, 'EC-07': 11, 'HG-07': 10}
    for log in (baseline, candidate):
        assert 'TLT_ROUTE_FINAL' in log and 'TLT_RESCUE_DONE' in log
        assert by_name(log, 'ROUTE_MODEL') == by_name(log, 'ROUTE_DIRECT')
    stable_tags = ('ROUTE_COMPILE', 'ROUTE_NAV_ORIGINAL', 'ROUTE_NAV_EASY', 'CONTOUR', 'STATION', 'RESCUE_SOLID')
    for tag in stable_tags:
        assert rows(baseline, tag) and rows(baseline, tag) == rows(candidate, tag), tag

    before_models, after_models = (by_name(log, 'ROUTE_MODEL') for log in (baseline, candidate))
    assert before_models.keys() == after_models.keys()
    changed = []
    for name, model in after_models.items():
        previous = before_models[name]
        if model['story'] not in finales:
            assert model == previous, name
            continue
        for key in ('goal', 'approach', 'parts'):
            assert model[key] == previous[key], (name, key)
        if model['story'] == 'DW-07':
            assert math.dist(model['ground'], previous['ground']) < 7
            assert model['ground'][1] == previous['ground'][1]
        else:
            assert model['ground'] == previous['ground'], name
        assert model['parts'] == finales[model['story']]
        assert len(model['footprintHeightDeltas']) == 5
        assert max(map(abs, model['footprintHeightDeltas'])) <= .12
        changed.append(model)
    assert {model['story'] for model in changed} == set(finales) and len(changed) == 5
    finale_names = {model['name'] for model in changed}
    assert [row for row in rows(baseline, 'APPROACH_PLACEMENT') if row['name'] not in finale_names] == [
        row for row in rows(candidate, 'APPROACH_PLACEMENT') if row['name'] not in finale_names
    ]
    walks = [by_name(log, 'ROUTE_WALK') for log in (baseline, candidate)]
    assert len(walks[0]) == len(walks[1]) == 23 and walks[0].keys() == walks[1].keys()
    for entries in walks:
        for walk in entries.values():
            assert walk['approach']['arrived'] and walk['retreat']['arrived'], walk

    before, after = captures(baseline), captures(candidate)
    board = Image.new('RGB', (836, 30 + 250 * len(before)), '#171c20')
    draw = ImageDraw.Draw(board)
    for x, label, images in ((12, '0.114.18', before), (424, '0.114.19', after)):
        draw.text((x, 8), label, fill='white')
        for index, (name, image) in enumerate(images.items()):
            y = 30 + 250 * index
            board.paste(image, (x, y))
            draw.text((x, y + 229), name, fill='white')
    board.save(HERE / 'comparison.jpg', quality=92, optimize=True)
    results = {
        'compiled': rows(candidate, 'ROUTE_COMPILE')[0],
        'navigation': {tag: rows(candidate, tag)[0] for tag in stable_tags if tag.startswith('ROUTE_NAV')},
        'previousFinaleModels': [before_models[model['name']] for model in changed],
        'finaleModels': changed,
        'walks': {'baseline': list(walks[0].values()), 'candidate': list(walks[1].values())},
        'frameSHA256': {name: [hashlib.sha256(images[name].tobytes()).hexdigest() for images in (before, after)]
                        for name in before},
    }
    (HERE / 'studio-results.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    main()
