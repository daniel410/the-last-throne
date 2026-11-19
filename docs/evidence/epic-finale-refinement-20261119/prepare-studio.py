"""Reuse the finale audit with additional observation points on the goal side."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
PRIOR = HERE.parent / 'epic-finale-scenery-20261119'

parser = argparse.ArgumentParser()
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
command = [sys.executable, str(PRIOR / 'prepare-studio.py'), '--output', str(args.output)]
if args.baseline:
    command.append('--baseline')
subprocess.run(command, check=True)
previous = json.dumps((PRIOR / 'cameras.json').read_text())
cameras = json.dumps((HERE / 'cameras.json').read_text())
source = args.output.read_text()
assert source.count(previous) == 1
args.output.write_text(source.replace(previous, cameras, 1))
