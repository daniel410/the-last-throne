"""Compare identical Studio audits on the 0.114.19 and 0.114.20 builds."""
import argparse
import json
from pathlib import Path
import runpy

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
PREVIOUS = HERE.parent / 'epic-finale-readability-20261120'
audit = runpy.run_path(str(PREVIOUS / 'compare.py'))
rows, named, captures = (audit[name] for name in ('rows', 'by_name', 'captures'))

parser = argparse.ArgumentParser()
parser.add_argument('baseline', type=Path)
parser.add_argument('candidate', type=Path)
args = parser.parse_args()
before, after = args.baseline.read_text(), args.candidate.read_text()

stable = ('ROUTE_COMPILE', 'ROUTE_NAV_ORIGINAL', 'ROUTE_NAV_EASY', 'CONTOUR', 'STATION', 'RESCUE_SOLID')
for tag in stable:
    assert rows(before, tag) and rows(before, tag) == rows(after, tag), tag
for log in (before, after):
    assert 'TLT_ROUTE_FINAL' in log and 'TLT_RESCUE_DONE' in log
    assert named(log, 'ROUTE_MODEL') == named(log, 'ROUTE_DIRECT')

old_models, new_models = (named(log, 'ROUTE_MODEL') for log in (before, after))
assert old_models.keys() == new_models.keys()
changes = {'FV-07', 'EC-07', 'HG-07'}
finales = {}
for name, model in new_models.items():
    previous = old_models[name]
    if model['story'] not in changes:
        assert model == previous, name
        continue
    for key in ('goal', 'approach', 'parts', 'ground'):
        assert model[key] == previous[key], (name, key)
    assert len(model['footprintHeightDeltas']) == 5
    assert max(map(abs, model['footprintHeightDeltas'])) <= .12
    finales[model['story']] = model
assert finales.keys() == changes
walks = [named(log, 'ROUTE_WALK') for log in (before, after)]
assert len(walks[0]) == len(walks[1]) == 23 and walks[0].keys() == walks[1].keys()
for entries in walks:
    assert all(walk['approach']['arrived'] and walk['retreat']['arrived'] for walk in entries.values())

old_images, new_images = (captures(log) for log in (before, after))
shots = [name for name in old_images if name[:5] in changes]
board = Image.new('RGB', (836, 30 + 250 * len(shots)), '#171c20')
draw = ImageDraw.Draw(board)
for x, label, images in ((12, '0.114.19', old_images), (424, '0.114.20', new_images)):
    draw.text((x, 8), label, fill='white')
    for index, name in enumerate(shots):
        y = 30 + 250 * index
        board.paste(images[name], (x, y))
        draw.text((x, y + 229), name, fill='white')
board.save(HERE / 'comparison.jpg', quality=92, optimize=True)
results = {
    'compiled': rows(after, 'ROUTE_COMPILE')[0],
    'navigation': {tag: rows(after, tag)[0] for tag in stable if tag.startswith('ROUTE_NAV')},
    'landmarks': len(new_models),
    'refinedFinales': finales,
    'roundTripsPerBuild': [len(entries) for entries in walks],
    'comparedViews': shots,
}
(HERE / 'studio-results.json').write_text(json.dumps(results, indent=2) + '\n')
