"""Merge only the two reviewed Blender profiles and keep other HG curves intact."""
from pathlib import Path
import json
import math
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/animations/haunted-graveyard-v1'
for filename, incoming in [('authoring-keys.json', '/tmp/tlt-undead-motion-keys.json'),
                           ('clips.json', '/tmp/tlt-undead-motion-evaluated.json')]:
    data = json.loads((BASE / filename).read_text())
    new = json.loads(Path(incoming).read_text())
    assert set(new['models']) == {'Zombie', 'Ghoul'}
    for kind, model in new['models'].items():
        if filename == 'clips.json':
            for clip in model['clips'].values():
                for ch in ['weapon', 'off']:
                    for row in clip[ch]:
                        # Bound the complete angular vector, not each axis alone.
                        assert math.sqrt(sum(math.radians(x)**2 for x in row)) <= model['armLimitRadians']+1e-6
        data['models'][kind] = model
    (BASE / filename).write_text(json.dumps(data, separators=(',', ':'))+'\n')
subprocess.run(['python3', str(ROOT / 'tools/export-haunted-motion.py')], check=True)
print('Applied only Zombie/Ghoul individual motion profiles.')
