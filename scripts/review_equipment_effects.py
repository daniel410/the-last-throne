"""Read-only audit of the current proposal; write evidence only to --output."""
import argparse
import collections
import hashlib
import itertools
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
source = 'assets/balance/equipment-recalculated-2026-11-05.json'
plan = json.loads((ROOT / source).read_text())
items = plan['items']
assert len(items) == 160
assert collections.Counter(i['rarity'] for i in items) == dict.fromkeys(plan['requiredLevels'], 40)
assert not plan['runtimeEnabled'] and all(not i['runtimeEnabled'] for i in items)
unique = [i for i in items if i['rarity'] == 'Unique']
assert all(i['requiredLevel'] == 60 and i['allowedDifficulties'] == ['Hell'] for i in unique)
assert all(i['allowedDifficulties'] == ['Insane', 'Hell'] for i in items if i['rarity'] == 'Legendary')

def compatible(a, b):
    return (not (a['classId'] and b['classId'] and a['classId'] != b['classId'])
            and (a['slot'] != b['slot'] or a['slot'] == 'accessory')
            and not (a.get('uniqueGroup') and a['uniqueGroup'] == b.get('uniqueGroup')))

shared = []
identical = []
for a, b in itertools.combinations(unique, 2):
    if not compatible(a, b) or a['effect']['cooldownGroup'] != b['effect']['cooldownGroup']:
        continue
    shared.append({'items': [a['name'], b['name']], 'category': a['effect']['kind'],
                   'events': [a['effect']['event'], b['effect']['event']]})
    if all(a['effect'][k] == b['effect'][k] for k in ('kind', 'event', 'conditions')):
        identical.append([a['name'], b['name']])
assert not identical
ids = ','.join(json.dumps(i['candidateDefinitionId']) for i in items)
lua = '''
local G=dofile('src/shared/HeroProgression.luau')
local D=dofile('src/shared/Difficulty.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local count,gear,mana=0,0,0
for _,d in pairs(C.items)do
 count=count+1
 if d.category=='Equipment'then gear=gear+1 end
 if d.stats and d.stats.maxMana then mana=mana+1 end
end
print('catalog|'..count..'|'..gear..'|'..mana)
for _,id in ipairs({IDS})do assert(not C.items[id],id)end
local ok,err=pcall(R.stats,{items={{definitionId='probe',location={kind='equipped',heroId='probe'}}}},'probe',{items={probe={stats={maxMana=10}}}})
assert(not ok and tostring(err):find('arithmetic'))
print('mpProbe|'..tostring(err))
print('version|'..D.version)
for _,cls in ipairs({'knight','elf','dwarf','mage'})do
 for _,level in ipairs({60,80})do
  local mode=level==80 and 'Hell' or 'Insane'
  local d=G.derived(cls,G.new(level))
  for party=1,4 do
   for _,v in ipairs({3,D.version})do
    local _,normal=D.stats('Orc',10,party,false,mode,v)
    local _,boss=D.stats('KingOgre',10,party,true,mode,v)
    print(table.concat({'fixture',cls,level,mode,party,v,d.health,d.armor,d.mana,normal,boss},'|'))
   end
  end
 end
end
'''.replace('IDS', ids)
result = subprocess.run(['lua', '-'], input=lua, capture_output=True, text=True, cwd=ROOT, check=True)
fixtures = []
catalog = {}
for line in result.stdout.splitlines():
    fields = line.split('|')
    if fields[0] == 'catalog':
        catalog = dict(zip(('definitions', 'equipment', 'mpDefinitions'), map(int, fields[1:])))
    elif fields[0] == 'mpProbe':
        probe = '|'.join(fields[1:])
    elif fields[0] == 'version':
        version = int(fields[1])
    else:
        _, cls, level, mode, party, rules, hp, armor, mana, normal, boss = fields
        kit = [i for i in unique if i['classId'] == cls]
        assert len(kit) == (8 if cls == 'knight' else 7)
        gear = {k: sum(i['stats'].get(k, 0) for i in kit) for k in ('power', 'armor', 'health', 'maxMana')}
        fixtures.append({'classId': cls, 'level': int(level), 'mode': mode, 'humans': int(party),
                         'rulesVersion': int(rules), 'maxHealth': float(hp) + gear['health'],
                         'normalDamage': max(1, float(normal) - float(armor) - gear['armor']),
                         'bossDamage': max(1, float(boss) - float(armor) - gear['armor']),
                         'baseMana': float(mana), 'gear': gear})
assert len(fixtures) == 64
mana_cases = []
for level, mp in ((60, 336), (60, 600), (60, 1044), (80, 700)):
    cap = 12 + int(.2 * level)
    mana_cases.append({'level': level, 'maxMana': mp, 'missingManaAssumed': mp, 'cap': cap,
                       'fourPercent': min(cap, max(6, .04 * mp)),
                       'sixPercent': min(cap, max(6, .06 * mp))})
paths = [source, 'src/shared/ItemCatalog.luau', 'src/shared/Difficulty.luau',
         'src/shared/HeroProgression.luau', 'src/shared/BossCombatTuning.luau',
         'src/server/Inventory/InventoryRules.luau', 'src/shared/EquipmentImpact.luau',
         'src/shared/SkillStatPreview.luau', 'src/server/Combat/CombatService.luau']
report = {
    'date': '2026-11-05', 'sourceCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
    'kind': 'static-proposal-and-pure-lua-synthetic-audit-not-engine-combat',
    'hashes': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths},
    'runtimeRulesVersion': version, 'runtimeCatalog': catalog, 'currentCandidateIdsRegistered': 0,
    'mpInjectionError': probe, 'gradeCounts': dict(collections.Counter(i['rarity'] for i in items)),
    'effectCounts': dict(collections.Counter(i['effect']['kind'] for i in unique)),
    'identicalCompatibleTriggers': identical,
    'compatibleSharedCategoryPairs': shared,
    'pairCaveat': 'Potential competition, not proven simultaneous failures; each pair is legal, not all pairs in one build.',
    'manaCapExamples': mana_cases,
    'fixtures': fixtures,
    'excluded': ['live combat', 'effect engine', 'sets', 'block/dodge', 'enemy attack skill multipliers',
                 'attack cadence and movement', 'AI', 'stat allocation', 'enhancement', 'DataStore', 'devices'],
    'uniqueItems': [{'name': i['name'], 'classId': i['classId'], 'effect': i['effect'],
                     'descriptionKoDev': i['descriptionKoDev']} for i in unique],
}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(f'PASS: 160 proposals; 40 Unique effects; identical pairs=0; potential shared-category pairs={len(shared)}; pure Lua fixtures=64; rules={version}; runtime MP blocker reproduced')
