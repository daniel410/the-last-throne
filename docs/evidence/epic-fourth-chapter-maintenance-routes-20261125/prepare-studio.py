"""Reuse the established campaign placement, camera and R15 traversal audit."""
from pathlib import Path
import re
import sys

evidence = Path(__file__).resolve().parent
previous = evidence.parent / 'epic-third-chapter-rescue-routes-20261124'
source = (previous / 'camera-setup.luau').read_text()
setup, replacements = re.subn(r'local sites = \{\n.*?\n\}', (evidence / 'sites.luau').read_text().strip(),
                              source, count=1, flags=re.S)
assert replacements == 1

sources = [
    evidence / 'check-landmark-overlap.luau',
    evidence.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau',
    evidence.parent / 'epic-second-chapter-landmarks-20261120' / 'walk-approaches.luau',
]
Path(sys.argv[1]).write_text('\n'.join([setup, *(source.read_text() for source in sources)]))
