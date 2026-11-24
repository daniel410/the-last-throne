"""Prepare the finale geometry and R15 audit or the fixed Studio cameras."""
import argparse
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WALK = HERE.parent / 'epic-route-landmarks-20261118'
CAPTURE = HERE.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau'

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--source', required=True)
mode = parser.add_mutually_exclusive_group(required=True)
mode.add_argument('--baseline', action='store_true')
mode.add_argument('--candidate', action='store_true')
mode.add_argument('--cameras', type=Path)
args = parser.parse_args()

def source_pin(module):
    source = subprocess.check_output(
        ['git', 'show', f'{args.source}:src/server/World/{module}.luau'], cwd=ROOT, text=True)
    return f'assert(game.ServerScriptService.Server.World.{module}.Source == {json.dumps(source)})\n'

program = "assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated place only')\n"
program += source_pin('EpicStoryLandmarks')
if args.candidate:
    program += source_pin('EpicFinaleReturnFixtures')
if args.cameras:
    cameras = json.loads(args.cameras.read_text())
    program += f'local cameraPlan = {json.dumps(json.dumps(cameras))}\n' + CAPTURE.read_text()
else:
    common = (WALK / 'check-landmarks.luau').read_text()
    common = common[:common.index('if not baseline and not sideFrames')]
    expected_start = common.index('local expected =')
    expected_end = common.index('local function asArray')
    program += common[:expected_start] + common[expected_end:]
    program += f'local candidate = {str(args.candidate).lower()}\n' + (HERE / 'review.luau').read_text()
    walk = (WALK / 'walk-landmarks.luau').read_text()
    # These two prior overlap cases use an unrelated map audit's overlapLanes.
    program += '\n'.join(
        line for line in walk.splitlines() if 'table.insert(walking,' not in line or 'lane = ' not in line
    ) + '\n'
    if args.candidate:
        program += '\ndo\nlocal existingWorld = reviewWorld\n'
        program += 'local cameraPlan = game.HttpService:JSONEncode(shots)\n'
        program += CAPTURE.read_text() + '\nend\n'
args.output.write_text(program)
