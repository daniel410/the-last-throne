"""Assemble the entrance audit with the shared Studio camera and R15 walker."""
import argparse
from pathlib import Path

evidence = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
args = parser.parse_args()

sources = [
    evidence / 'audit-entrances.luau',
    evidence.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau',
    evidence.parent / 'epic-second-chapter-landmarks-20261120' / 'walk-approaches.luau',
]
args.output.write_text('\n'.join(source.read_text() for source in sources) + '\n')
