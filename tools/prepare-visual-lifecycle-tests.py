"""고정 빌드 원문을 확인하고 계정 없는 외형/VFX 수명 회귀 스크립트를 만든다."""
import argparse
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--place', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=True)
tree = ET.parse(a.place)
modules = {n.findtext('./Properties/string[@name="Name"]'): n.findtext('./Properties/ProtectedString[@name="Source"]') for n in tree.iter('Item') if n.get('class') == 'ModuleScript'}
changed = ['src/client/AdvancedSkillVisual.luau', 'src/client/ElfQuiverVisual.luau', 'src/client/EnemyPatternEffects.luau', 'src/client/K0SwordVisual.luau', 'src/client/WindLanceVisual.luau', 'src/server/Cosmetics/ArmorAppearance.luau', 'src/shared/ElfBowGeometry.luau', 'src/shared/FourFamilyArmorVisuals.luau']
for name in changed:
    path = root / name
    assert modules[path.stem] == path.read_text(), f'Build source mismatch: {name}'

def lua(value):
    if isinstance(value, dict):
        return '{' + ','.join('[' + json.dumps(k) + ']=' + lua(v) for k, v in value.items()) + '}'
    if isinstance(value, list):
        return '{' + ','.join(map(lua, value)) + '}'
    return json.dumps(value)

tests = ['projectile-vfx-timing-native', 'dwarf-axe-throw-native', 'four-family-weapons-native', 'armor-fit-native', 'headgear-hair-native', 'four-family-armor-native', 'hero-vfx-native', 'wind-lance-visual-native', 'monster-spell-vfx-native', 'elf-basic-tempo-native', 'mixamo-elf-native', 'k0-elf-bow-native', 'elf-quiver-native', 'elf-straight-shot-native']
code = 'assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"Private empty fixture required")\n'
inputs = changed + ['tests/' + n + '.luau' for n in tests] + ['tests/elf-bow-golden.luau', 'assets/animations/mixamo-elf-v1/blender-golden.json']
for name in tests:
    prefix = ''
    if name == 'mixamo-elf-native':
        prefix = 'local elfGolden=' + lua(json.loads((root / inputs[-1]).read_text())) + '\n'
    if name == 'k0-elf-bow-native':
        prefix = 'local BowGolden=(function()\n' + (root / 'tests/elf-bow-golden.luau').read_text() + '\nend)()\n'
    code += '\ndo\n' + prefix + (root / ('tests/' + name + '.luau')).read_text() + '\nend\n'
code += "print('VISUAL_LIFECYCLE_ALL_PASS')\n"
(a.output / 'probe.luau').write_text(code)
manifest = {'place': str(a.place.resolve()), 'sha256': hashlib.sha256(a.place.read_bytes()).hexdigest(), 'sourceEquality': changed, 'inputs': {n: hashlib.sha256((root / n).read_bytes()).hexdigest() for n in inputs}}
(a.output / 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(f'run-in-roblox --place {a.place} --script {a.output / "probe.luau"}')
