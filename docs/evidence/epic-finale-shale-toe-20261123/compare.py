"""Verify the two Studio audits and produce the comparison data."""
import json
from pathlib import Path
import runpy
import sys

here = Path(__file__).resolve().parent
audit = runpy.run_path(str(here.parent / 'epic-finale-landmarks-20261123' / 'audit.py'))
profiles = runpy.run_path(str(here.parent / 'epic-finale-route-profiles-20261121' / 'compare.py'))
views = audit['camera_ids']()
for name in (
    'epic-finale-sightlines-20261123/cameras.json',
    'epic-finale-windgap-20261123/midpoint.json',
):
    views.extend(shot['id'] for shot in json.loads((here.parent / name).read_text()))

work = Path(sys.argv[1])
profiles['compare'](
    work / 'baseline.log', work / 'candidate.log',
    counts={'NorthernWindgapStrata': (10, 11)},
    build_path=here / 'build.json', output=work, camera_ids=views, burial_tolerance=.000001,
)
