"""Run the authored roads in an isolated Studio Place and capture matching views."""
import argparse
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--candidate', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
walk = (ROOT / 'tests/epic-overland-native.luau').read_text()
capture = (HERE.parent / 'epic-approach-readability-20261118/capture-approaches.luau').read_text()
assert walk.endswith('return world\n')
args.output.write_text(
    walk.removesuffix('return world\n') +
    f'\nlocal candidate = {str(args.candidate).lower()}\n' +
    (HERE / 'review.luau').read_text() +
    '\nlocal existingWorld = world\nlocal cameraPlan = game.HttpService:JSONEncode(cameras)\n' +
    capture
)
