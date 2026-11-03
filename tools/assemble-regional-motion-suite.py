"""Assemble isolated Studio regressions, explicitly selecting motion or full story coverage."""
from pathlib import Path
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--scope', choices=['motion', 'full'], default='motion')
args = parser.parse_args()
parts = []
for region in ['frozen-vale', 'ember-caldera']:
    source = (args.root / 'tests' / f'{region}-native.luau').read_text()
    if args.scope == 'motion':
        boundary = source.index(' -- Saved personal')
        source = source[:boundary] + source[source.rindex('end,debug.traceback)'):]
        source = source.replace("scope='motion-and-story'", "scope='motion-only'")
    source = source.replace(';return report', ";assert(report.pass,'regional regression failed')")
    parts.append('do\n' + source + '\nend')
for name in ['regional-individual-review-native.luau', 'deepwood-individual-review-native.luau',
             'enemy-streaming-presentation-native.luau', 'battle-bootstrap-native.luau']:
    source = (args.root / 'tests' / name).read_text()
    parts.append('do\n' + source + '\nend')
args.output.write_text('\n'.join(parts))
print(args.output)
