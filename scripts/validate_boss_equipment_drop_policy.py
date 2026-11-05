"""Validate the approved rarity/mode gates and proposed boss drop weights."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = 'assets/balance/boss-equipment-drop-policy-2026-11-05.json'
p = json.loads((ROOT / PATH).read_text())
a = p['allowedDifficultiesByRarity']
assert a['Legendary'] == ['Insane', 'Hell']
assert a['Unique'] == ['Hell']
assert p['minimumEquipLevelByRarity']['Unique'] == 60
assert p['unknownModeOrRarity'] == 'reject' and not p['runtimeEnabled']
for mode, table in p['trialBasisPointsByDifficulty'].items():
    assert set(table) == set(a) and sum(table.values()) == 10000
    for rarity, weight in table.items():
        assert isinstance(weight, int) and weight >= 0
        assert (weight > 0) == (mode in a[rarity]), (mode, rarity)
protection = p['protection']
assert protection['appliesSameDifficultyGate'] and protection['progressEarnedOnlyOnEligibleMode']
assert protection['grantOnlyOnEligibleMode'] and not protection['allowLowerModeProgressConversion']
assert protection['preserveExistingOwnedItemsAndReceipts']
count = 0
for name in ['equipment-stats-plan-2026-11-04.json', 'unique-equipment-plan-2026-11-05.json']:
    d = json.loads((ROOT / 'assets/balance' / name).read_text())
    assert d['dropPolicyRef'] == PATH
    for i in d['items']:
        drop = i.get('dropEligibility', i.get('drop'))
        assert drop['allowedDifficulties'] == a[i['rarity']] and drop['policyRef'] == PATH
        count += 1
m = json.loads((ROOT / 'assets/concepts/2026-11-04-equipment-icons/manifest.json').read_text())
for v in m['variants']:
    assert v['dropEligibility']['allowedDifficulties'] == a[v['rarity']]
    assert v['dropEligibility']['policyRef'] == PATH
assert count == 160 and len(m['variants']) == 240
print('PASS: Legendary Insane/Hell, Unique Hell only; 4 trial tables sum to 100%; prohibited weights zero; protection gates, 160 stat plans and 240 variant references')
