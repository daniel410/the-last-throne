"""Prepare fixed-camera captures and extend the established Studio map audit."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

EVIDENCE = Path(__file__).resolve().parent
PRIOR = EVIDENCE.parent / 'epic-approach-contours-20261119'
CAPTURE = EVIDENCE.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau'

parser = argparse.ArgumentParser()
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()

program = ''
if not args.baseline:
    subprocess.run([sys.executable, PRIOR / 'prepare-studio.py', '--audit', '--output', args.output], check=True)
    inherited = args.output.read_text()
    program, marker, _ = inherited.rpartition('\ndo\nlocal existingWorld = reviewWorld\nlocal cameraPlan = ')
    assert marker
    rows = """
local finaleRows = {
    {epic = 1, story = 'DW-07', goal = 'core_record', name = 'ConvoyRoadLoadingSill'},
    {epic = 2, story = 'GW-07', goal = 'exit', name = 'NorthernWindgapStrata'},
    {epic = 3, story = 'FV-07', goal = 'reunion', name = 'FreightSledLanding'},
    {epic = 4, story = 'EC-07', goal = 'courier', name = 'DispatchCarrierCradle'},
    {epic = 5, story = 'HG-07', goal = 'portal', name = 'AlliedReturnParapet'},
}
local finaleContent = require(game.ReplicatedStorage.Shared.CampaignContent)
for _, row in ipairs(finaleRows) do
    local hasGoal = false
    for _, goal in ipairs(finaleContent.byId[row.story].goals) do
        if goal.id == row.goal then hasGoal = true break end
    end
    assert(hasGoal, row.story .. ' missing authored goal ' .. row.goal)
    table.insert(expected, row)
end
"""
    program = program.replace('local function asArray(point)', rows + '\nlocal function asArray(point)', 1)
    source = (EVIDENCE.parents[2] / 'src/server/World/EpicFinaleScenery.luau').read_text()
    program = 'assert(game.ServerScriptService.Server.World.EpicFinaleScenery.Source == '+ json.dumps(source) + ')\n' + program

cameras = (EVIDENCE / 'cameras.json').read_text()
world = 'nil' if args.baseline else 'reviewWorld'
args.output.write_text(program + f'\ndo\nlocal existingWorld = {world}\n'
                       + f'local cameraPlan = {json.dumps(cameras)}\n' + CAPTURE.read_text() + '\nend\n')
