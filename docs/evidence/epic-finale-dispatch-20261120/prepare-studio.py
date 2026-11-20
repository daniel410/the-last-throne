"""Reuse the 13-view Studio audit with the goal-side camera outside Suri."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
AUDIT = HERE.parent / 'epic-finale-refinement-20261119'
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--candidate', action='store_true')
args = parser.parse_args()
subprocess.run([sys.executable, str(AUDIT / 'prepare-studio.py'), '--output', str(args.output)], check=True)
original = (AUDIT / 'cameras.json').read_text()
cameras = json.loads(original)
goal_side = next(shot for shot in cameras if shot['id'] == 'EC-07_goal_side')
goal_side['origin'] = [-913.416, 178, -14683.360]
source = args.output.read_text()
assert source.count(json.dumps(original)) == 1
source = source.replace(json.dumps(original), json.dumps(json.dumps(cameras)), 1)
sightline = (HERE / 'check-sightline.luau').read_text()
sightline = sightline.replace('require(game.ServerScriptService.Server.World.CampaignWorld).create()', 'reviewWorld', 1)
source += '\ndo\n' + sightline + '\nend\n'
if args.candidate:
    source += '\ndo\n' + (HERE / 'check-rollers.luau').read_text() + '\nend\n'
args.output.write_text(source)
