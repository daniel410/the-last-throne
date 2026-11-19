"""Run the current route regression and sample five changed landmarks."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

EVIDENCE = Path(__file__).resolve().parent
ROOT = EVIDENCE.parents[2]
PRIOR = EVIDENCE.parent / 'epic-approach-readability-20261118'
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--cameras', type=Path)
args = parser.parse_args()
if args.cameras:
    cameras = json.loads(args.cameras.read_text())
    capture = (PRIOR / 'capture-approaches.luau').read_text()
    args.output.write_text(f'local cameraPlan = {json.dumps(json.dumps(cameras))}\n{capture}')
    sys.exit()

command = [sys.executable, PRIOR / 'prepare-studio.py', '--output', args.output]
if args.baseline:
    command.append('--baseline')
subprocess.run(command, check=True)
program = args.output.read_text()
rows = '''{
    {epic = 1, story = 'DW-05', goal = 'prisoners', name = 'RuinedPrisonPalisade', theme = 'Deepwood'},
    {epic = 2, story = 'GW-05', goal = 'rope', name = 'VenomcoilScouredBank', theme = 'Gloamwood'},
    {epic = 4, story = 'EC-05', goal = 'crew', name = 'VaultCircuitPrototype', theme = 'EmberCaldera'},
}'''
# Keep the inherited full-campaign, standalone, cache, and R15 checks.
marker = 'local function asArray(point)'
program = program.replace(marker, f'''local rescueRows = {rows}
if not baseline then
    for _, row in ipairs(rescueRows) do table.insert(expected, row) end
end
{marker}''', 1)
marker = 'table.insert(walking, {story = \'DW-Q1\', goal = \'exp_1\''
program = program.replace(marker, '''if baseline then
    for _, row in ipairs(rescueRows) do table.insert(walking, row) end
end
''' + marker, 1)
if not args.baseline:
    source = (ROOT / 'src/server/World/RescueRouteLandmarks.luau').read_text()
    program = (
        'assert(game.ServerScriptService.Server.World.RescueRouteLandmarks.Source == '
        f'{json.dumps(source)})\n' + program
    )
program += '''
for _, row in ipairs(rescueRows) do
    if baseline then continue end
    local model = findModel(reviewWorld, row)
    local pivot = model:GetPivot()
    local function shot(suffix, eye, aim)
        print('TLT_RESCUE_CAMERA '..game.HttpService:JSONEncode({
            id = row.story..'_'..suffix, theme = row.theme,
            origin = asArray(pivot:PointToWorldSpace(eye)),
            aim = asArray(pivot:PointToWorldSpace(aim)),
        }))
    end
    shot('front', V(-14, 7.5, -24), V(0, 2.6, 0))
    shot('side', V(22, 8, 14), V(0, 2.5, 0))
end
for _, row in ipairs({
    {epic = 3, story = 'FV-03', goal = 'west_beacon', name = 'AvalancheSnowFence', theme = 'FrozenVale'},
    {epic = 5, story = 'HG-03', goal = 'crypt', name = 'KeeperDrainCulvert', theme = 'HauntedGraveyard'},
}) do
    local model = findModel(reviewWorld, row)
    local pivot = model:GetPivot()
    local solid = 0
    local placement = {}
    for _, part in ipairs(model:GetChildren()) do
        if part.CanCollide then
            solid += 1
            table.insert(placement, {name = part.Name, at = {part.CFrame:GetComponents()}, size = asArray(part.Size)})
        end
    end
    print('TLT_RESCUE_SOLID '..game.HttpService:JSONEncode({
        name = row.name, solid = solid, pivot = {pivot:GetComponents()},
        radius = model:GetAttribute('PlacementRadius'), placement = placement,
    }))
    if baseline then continue end
    local z = row.epic == 3 and -48 or 23
    print('TLT_RESCUE_CAMERA '..game.HttpService:JSONEncode({
        id = row.story..(z < 0 and '_fence' or '_rear'), theme = row.theme,
        origin = asArray(pivot:PointToWorldSpace(V(12, 7, z))),
        aim = asArray(pivot:PointToWorldSpace(V(0, 3.5, 0))),
    }))
end
print('TLT_RESCUE_DONE')
'''
args.output.write_text(program)
