import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

root = Path(__file__).resolve().parents[1]
kinds = {
    'Orc': 'orc', 'Ogre': 'ogre', 'KingOgre': 'king_ogre',
    'IceWolf': 'ice_wolf', 'IceBear': 'ice_bear', 'IceElf': 'ice_elf',
    'IceTroll': 'ice_troll', 'IceGolem': 'ice_golem', 'IceTrollKing': 'ice_troll_king',
    'KingIceBear': 'king_ice_bear', 'KingIceGolem': 'king_ice_golem',
    'QueenIceElf': 'queen_ice_elf', 'AncientGlacierKing': 'ancient_glacier_king',
    'Imp': 'imp', 'LavaSlime': 'lava_slime', 'Golem': 'golem',
    'MagmaWorm': 'magma_worm', 'VolcanoShaman': 'volcano_shaman',
    'MagmaImp': 'magma_imp', 'MagmaGolem': 'magma_golem',
    'InfernoOverlord': 'inferno_overlord', 'CalderaTitan': 'caldera_titan',
    'KingVolcanoShaman': 'king_volcano_shaman',
}
heights = {}
for item in ET.parse(root / 'assets/shared/td-monsters/runtime.rbxmx').iter('Item'):
    if item.get('class') != 'Model':
        continue
    props = item.find('Properties')
    if props is None:
        continue
    name = next((p.text for p in props if p.get('name') == 'Name'), None)
    for child in item.findall('Item'):
        if child.get('class') == 'NumberValue':
            values = {p.get('name'): p.text for p in child.find('Properties')}
            if values.get('Name') == 'TargetHeight':
                heights[name] = float(values['Value'])

lua = "local s=dofile('src/server/World/StoryMonsterSizing.luau'); "
lua += '; '.join(f"do local a,b=s.forStory('{k}',false); print('{k}',a,b) end" for k in kinds)
output = subprocess.check_output(['lua', '-e', lua], cwd=root, text=True)
scales = {p[0]: (float(p[1]), float(p[2])) for line in output.splitlines() if (p := line.split())}
visual = {kind: heights[name] * scales[kind][1] for kind, name in kinds.items()}
training = (root / 'src/server/World/TrainingField.luau').read_text()
assert re.search(r'makeEnemy\(enemies, "Orc",[^\n]*1\.65, 1\.5\)', training)
assert re.search(r'makeEnemy\(enemies, "Ogre",[^\n]*2\.475, 2\.475 / 1\.45\)', training)
assert scales['Orc'] == (1.65, 1.5)
assert abs(scales['Ogre'][0] - 2.475) < 1e-6
assert abs(scales['Ogre'][1] - 2.475 / 1.45) < 1e-6
assert visual['Ogre'] > visual['Orc'] and visual['KingOgre'] > visual['Ogre']
for kind in ('IceWolf', 'IceBear', 'IceElf', 'Imp', 'LavaSlime', 'MagmaWorm'):
    assert visual[kind] < visual['Orc'], kind
for kind in ('IceTroll', 'IceGolem', 'Golem', 'IceTrollKing', 'KingIceGolem', 'MagmaGolem', 'CalderaTitan', 'AncientGlacierKing'):
    assert visual[kind] > visual['Orc'], kind
assert visual['IceTrollKing'] > visual['IceTroll']
assert visual['KingIceGolem'] > visual['IceGolem']
assert visual['MagmaGolem'] > visual['Golem']
service = (root / 'src/server/Story/DeepwoodService.luau').read_text()
assert 'Sizing.forStory(kind,boss)' in service and 'scale,visual)' in service
print(f'Story monster sizing: {len(kinds)} TD templates compared; Training sizes and regional proportions passed')
