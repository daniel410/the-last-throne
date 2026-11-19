"""Run the campaign regression and identical route and station cameras in two local builds."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

EVIDENCE = Path(__file__).resolve().parent
PRIOR = EVIDENCE.parent / 'epic-rescue-infrastructure-20261119'
ROUTE = EVIDENCE.parent / 'epic-route-perspectives-20261119'
CAPTURE = EVIDENCE.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau'

parser = argparse.ArgumentParser()
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()

world = 'nil'
audit = ''
if not args.baseline:
    subprocess.run([sys.executable, PRIOR / 'prepare-studio.py', '--output', args.output], check=True)
    modules = ('CampaignIncidentScenes', 'EpicStoryLandmarks')
    for module in modules:
        source = (EVIDENCE.parents[2] / f'src/server/World/{module}.luau').read_text()
        audit += f'assert(game.ServerScriptService.Server.World.{module}.Source == {json.dumps(source)})\n'
    audit += args.output.read_text()
    anchor = 'for _, row in ipairs(walking) do\n    local from, to, contacts = endpoints(row)'
    assert anchor in audit
    stations_to_walk = """
for _, row in ipairs({
    {story = 'DW-Q1', goal = 'exp_1', step = 'step2', name = 'MarshDryPackShelf'},
    {story = 'GW-03', goal = 'exp_1', step = 'step2', name = 'RefugeScoutShelter'},
    {story = 'EC-06', goal = 'exp_2', step = 'step2', name = 'HeatworksProtectionManifold'},
}) do table.insert(walking, row) end
"""
    audit = audit.replace(anchor, stations_to_walk + anchor, 1)
    world = 'reviewWorld'

cameras = (EVIDENCE / 'cameras.json').read_text()
stations = (EVIDENCE / 'inspect-stations.luau').read_text()
route = (ROUTE / 'sample-route-views.luau').read_text()
args.output.write_text(
    audit + '\ndo\n' + f'local existingWorld = {world}\n'
    + f'local expectStations = {str(not args.baseline).lower()}\n'
    + f'local extraCameras = game.HttpService:JSONDecode({json.dumps(cameras)})\n'
    + stations + '\ndo\nlocal existingWorld = world\n' + route
    + '\nend\nlocal existingWorld = world\n' + CAPTURE.read_text() + '\nend\n'
)
