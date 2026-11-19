"""Prepare the route regression and optional before/after Studio camera passes."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

EVIDENCE = Path(__file__).resolve().parent
ROOT = EVIDENCE.parents[2]
PRIOR = EVIDENCE.parent / 'epic-route-landmarks-20261118'
MODULES = ('ArchiveAndCanalLandmarks', 'CampaignExpansionWorld', 'CampaignRouteClearance',
           'EpicStoryLandmarks', 'ForestAndGraveyardLandmarks')
parser = argparse.ArgumentParser()
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--frames', action='store_true')
parser.add_argument('--with-frames', action='store_true')
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
if args.frames or args.with_frames:
    camera_plan = json.loads((EVIDENCE / 'cameras.json').read_text())
    capture = (EVIDENCE / 'capture-approaches.luau').read_text()
    capture = f'local cameraPlan = {json.dumps(json.dumps(camera_plan))}\n{capture}'
    if args.frames:
        args.output.write_text("local existingWorld = nil\n" + capture)
        sys.exit()

command = [sys.executable, PRIOR / 'prepare-studio.py', '--output', args.output]
if args.baseline:
    command.append('--baseline')
subprocess.run(command, check=True)
program = args.output.read_text()
if not args.baseline:
    checks = []
    for name in MODULES:
        source = (ROOT / 'src/server/World' / f'{name}.luau').read_text()
        checks.append(f'assert(game.ServerScriptService.Server.World.{name}.Source == '
                      f'{json.dumps(source, ensure_ascii=False)}, "source mismatch {name}")')
    program = program.replace('local baseline=false', '\n'.join(checks) + '\nlocal baseline=false')

# Test fixed coordinates in both builds. A cleared route no longer has blocker metadata.
program = program.replace('local function endpoints(row)\n', '''local function endpoints(row)
    if row.name == 'DeepwoodShelterPriorOverlap' then
        return V(-1085.7147, 6.08, -1228.0022), V(-1057.1442, 9.08, -1200.0066), {
            V(-1071.4294, 6.08, -1214.0044),
        }
    end
    if row.name == 'DeepwoodMarshPriorOverlap' then
        return V(-1535.0991, .08, -1139.6628), V(-1477.7175, 3.08, -1122.1342), {
            V(-1515.9719, .08, -1133.8199),
            V(-1504.4956, .08, -1130.3142),
            V(-1496.8447, 3, -1127.9771),
        }
    end
    if row.name == 'DeepwoodMarshConnector' then
        return V(-1542.75, 0, -1127), V(-1542.75, 0, -1188)
    end
''')
program = program.replace('local walking = table.clone(expected)', '''local walking = table.clone(expected)
table.insert(walking, {story = 'DW-Q1', goal = 'exp_1', name = 'DeepwoodMarshConnector'})
table.insert(walking, {story = 'HG-03', goal = 'crypt', name = 'KeeperDrainCulvert'})
table.insert(walking, {story = 'FV-03', goal = 'west_beacon', name = 'AvalancheSnowFence'})''')
extra = (EVIDENCE / 'inspect-approaches.luau').read_text()
program = program.replace('local Shared = game.ReplicatedStorage.Shared\nlocal CampaignContent', extra +
                          '\nlocal Shared = game.ReplicatedStorage.Shared\nlocal CampaignContent', 1)
if args.with_frames:
    program += "\ndo\nlocal existingWorld = reviewWorld\n" + capture + "\nend\n"
args.output.write_text(program)
