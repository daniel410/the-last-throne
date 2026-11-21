"""Capture fixed views at repeatable liquid animation times in an isolated Place."""
import argparse
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--candidate', action='store_true')
parser.add_argument('--extra-views', action='store_true')
parser.add_argument('--static-only', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
capture = (HERE.parent / 'epic-approach-readability-20261118/capture-approaches.luau').read_text()
assert capture.count('    task.wait(1.25)') == 1
capture = capture.replace('    task.wait(1.25)', '''    if shot.first then task.wait(.75) end
    if presentation then presentation.update(shot.time, camera.CFrame.Position) end
    task.wait(.075)''')
navigation = (ROOT / 'tests/epic-map-navigation-native.luau').read_text()
entry = 'local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()'
assert navigation.count(entry) == 1
navigation = navigation.replace(entry, 'local world=world', 1).replace('for epic=2,5 do', 'for epic=1,5 do', 1)
review = (HERE / 'review.luau').read_text()
if args.static_only:
    review = review.replace('candidate and 10 or 1', '1')
if args.extra_views:
    review += "\nview('falls_oblique', V(-1180, 32, -1976), V(-1231, 31, -1976), 'Deepwood', 1, .115)"
    review += "\nview('lava_oblique', vent + V(95, 11, 48), vent + V(0, 3.5, 0), 'EmberCaldera', 1, .23)\n"
args.output.write_text(f'local candidate = {str(args.candidate).lower()}\n' + review
    + '\ndo\nlocal existingWorld = world\nlocal cameraPlan = game.HttpService:JSONEncode(cameras)\n'
    + capture + '\nend\n'
    + navigation)
