"""Prepare the existing route checks and fixed Studio comparison cameras."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

EVIDENCE = Path(__file__).resolve().parent
ROOT = EVIDENCE.parents[2]
PRIOR = EVIDENCE.parent / 'epic-return-readability-20261119'
CAPTURE = EVIDENCE.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau'

parser = argparse.ArgumentParser()
parser.add_argument('--audit', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()

program = ''
if args.audit:
    subprocess.run([sys.executable, PRIOR / 'prepare-studio.py', '--output', args.output], check=True)
    previous = args.output.read_text()
    program = previous.split('\ndo\nlocal existingWorld = reviewWorld\nlocal expectStations', 1)[0]
    assert program != previous
    source = (ROOT / 'src/server/World/EpicApproachContours.luau').read_text()
    inspect, world_checks = (EVIDENCE / 'inspect-contours.luau').read_text().split('-- WORLD READY\n')
    direct_marker = '        standalone.folder:Destroy()'
    assert program.count(direct_marker) == 1
    program = program.replace(direct_marker, '        inspectContours(standalone, epic)\n' + direct_marker)
    program = (
        f'assert(game.ServerScriptService.Server.World.EpicApproachContours.Source == {json.dumps(source)})\n'
        + inspect
        + program
        + world_checks
    )
    stations = (PRIOR / 'inspect-stations.luau').read_text()
    program += (
        '\ndo\nlocal existingWorld = reviewWorld\nlocal expectStations = true\n'
        'local extraCameras = {}\n' + stations + '\nend\n'
    )

cameras = (EVIDENCE / 'cameras.json').read_text()
world = 'reviewWorld' if args.audit else 'nil'
args.output.write_text(
    program + f'\ndo\nlocal existingWorld = {world}\nlocal cameraPlan = {json.dumps(cameras)}\n'
    + CAPTURE.read_text() + '\nend\n'
)
