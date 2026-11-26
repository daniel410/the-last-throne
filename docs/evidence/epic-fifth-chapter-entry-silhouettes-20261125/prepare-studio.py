"""Assemble the entrance audit with the shared Studio camera and R15 walker."""
import argparse
from pathlib import Path

evidence = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
parser.add_argument('--near-snow', action='store_true', help='Capture the closer Frozen Vale approach')
args = parser.parse_args()

audit = (evidence / 'audit-entrances.luau').read_text()
capture = (evidence.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau').read_text()
walk = (evidence.parent / 'epic-second-chapter-landmarks-20261120' / 'walk-approaches.luau').read_text()

if args.near_snow:
    camera = """local route = approaches['FV-05']
local inward = (route.target - route.from) * V(1, 0, 1)
local entry = route.from + inward / 2
local eye = route.from + V(0, 6, 0)
cameraPlan = game.HttpService:JSONEncode({{
    id = 'FV-05-near-approach', theme = 'FrozenVale',
    origin = tuple(eye), aim = tuple(entry + V(0, 6, 0)),
}})
print('ENTRY_NEAR_CAMERA ' .. cameraPlan)
"""
    args.output.write_text('\n'.join((audit, camera, capture)))
else:
    args.output.write_text('\n'.join((audit, capture, walk)))
