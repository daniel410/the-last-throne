"""Assemble the shared landmark audit with fixed Gloamwood route views."""
from pathlib import Path
import sys

evidence = Path(__file__).resolve().parent
previous = evidence.parent / 'epic-third-chapter-rescue-routes-20261124'
setup = (previous / 'camera-setup.luau').read_text()
setup = setup.replace('local shots = {}', '''
local profiles = require(World.EpicThirdChapterRouteLandmarks)
local shots = {}
''', 1)
setup = setup.replace('local against = at + right * side', '''
    local against = at + right * profiles[id].side
    local aim = id == 'GW-03' and at or against
''', 1)
setup = setup.replace('{against.X, against.Y + 1, against.Z}', '{aim.X, aim.Y + 1, aim.Z}')
setup = setup.replace("front * math.min(20, delta.Magnitude * .8)", "front * math.min(id == 'GW-03' and 34 or 20, delta.Magnitude * .8)")
setup = setup.replace(".Unit * 16", ".Unit * (id == 'GW-03' and 34 or 16)")
setup = setup.replace("local id, theme, index, side, name, goalIndex", "local id, theme, index, _, name, goalIndex")
sources = [
    evidence.parent / 'epic-fourth-chapter-maintenance-routes-20261125' / 'check-landmark-overlap.luau',
    evidence / 'check-shelter-sightlines.luau',
    evidence.parent / 'epic-approach-readability-20261118' / 'capture-approaches.luau',
    evidence.parent / 'epic-second-chapter-landmarks-20261120' / 'walk-approaches.luau',
]
Path(sys.argv[1]).write_text('\n'.join([setup, *(source.read_text() for source in sources)]))
