"""Check the finale audit and assemble a board of the target views."""
import json
from pathlib import Path
import runpy
import sys

from PIL import Image

HERE = Path(__file__).resolve().parent
audit = runpy.run_path(str(HERE.parent / 'epic-finale-landmarks-20261123' / 'audit.py'))
comparison = runpy.run_path(str(HERE.parent / 'epic-finale-route-profiles-20261121' / 'compare.py'))
counts = {'NorthernWindgapStrata': (10, 10), 'FreightSledLanding': (15, 15)}
views = audit['camera_ids']() + [shot['id'] for shot in json.loads((HERE / 'cameras.json').read_text())]
work = Path(sys.argv[1])
build = HERE / 'build.json'
comparison['compare'](work / 'baseline.log', work / 'candidate.log',
                      counts=counts, build_path=build, output=work, camera_ids=views)

selected = [
    'GW-07_route_start', 'GW-07_goal_side', 'GW-07_detail', 'GW-07_rear_diagnostic',
    'FV-07_reunion_eye', 'FV-07_detail', 'FV-07_rear_diagnostic',
    'DW-07_detail', 'EC-07_goal_side', 'HG-07_rear_diagnostic',
]
with Image.open(work / 'comparison.jpg') as full:
    board = Image.new('RGB', (full.width, 30 + 250 * len(selected)), '#171c20')
    board.paste(full.crop((0, 0, full.width, 30)))
    for index, name in enumerate(selected):
        y = 30 + 250 * views.index(name)
        board.paste(full.crop((0, y, full.width, y + 250)), (0, 30 + 250 * index))
    board.save(work / 'selected.jpg', quality=93, optimize=True)
