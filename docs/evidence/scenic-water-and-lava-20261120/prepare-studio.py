"""Capture the same water and lava views in each isolated Studio build."""
import argparse
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--candidate', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
capture = (HERE.parent / 'epic-approach-readability-20261118/capture-approaches.luau').read_text()
navigation = (ROOT / 'tests/epic-map-navigation-native.luau').read_text()
entry = 'local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()'
assert navigation.count(entry) == 1
navigation = navigation.replace(entry, 'local world=world', 1).replace('for epic=2,5 do', 'for epic=1,5 do', 1)
review = (HERE / 'review.luau').read_text()
if args.candidate:
    sightline = (HERE / 'ash-spire-sightline.luau').read_text()
    review += '\ndo\n' + sightline + '\nend\n'
args.output.write_text(f'local candidate = {str(args.candidate).lower()}\n' + review
    + '\ndo\nlocal existingWorld = world\nlocal cameraPlan = game.HttpService:JSONEncode(cameras)\n'
    + capture + '\nend\n'
    + navigation)
