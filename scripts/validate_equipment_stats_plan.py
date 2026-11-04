"""Validate authored equipment proposals. Does not register or grant runtime items."""
import json
from collections import Counter
from decimal import Decimal as D
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / 'assets/balance/equipment-stats-plan-2026-11-04.json'
p = json.loads(PLAN.read_text())
m = json.loads((ROOT / p['sourceManifest']).read_text())
manifest = {f['id']: f for f in m['families']}
families = {f['familyId']: f for f in p['families']}
assert len(families) == len(manifest) == 40 and families.keys() == manifest.keys()
assert len(p['items']) == 120
assert p['setThresholds'] == [2, 4, 5]
assert len({i['proposalId'] for i in p['items']}) == 120
assert len({i['candidateDefinitionId'] for i in p['items']}) == 120
assert len({i['name'] for i in p['items']}) == 120
assert {i['proposalId'] for i in p['items']} <= {v['proposalId'] for v in m['variants']}
assert Counter(i['rarity'] for i in p['items']) == {'Rare': 40, 'Epic': 40, 'Legendary': 40}
by_family = {}
for f in families.values():
    budget = sum(D(str(p['budgetWeights'][k])) * D(str(v)) for k, v in f['commonEquivalentStats'].items())
    assert budget == D(str(p['slotBudgets'][f['slot']])) == D(str(f['normalizedBudget']))
for i in p['items']:
    f = families[i['familyId']]; mf = manifest[i['familyId']]
    assert i['classId'] == mf['classId'] and i['slot'] == mf['slot']
    assert i['requiredLevel'] == i['equipmentTier'] == 10
    assert i['levelStatus'] == 'trial-only-not-rarity-minimum'
    assert i['status'] == 'proposed-not-runtime'
    assert i['icon'] == mf['iconVariants'][i['rarity']]
    assert (ROOT / 'assets/concepts/2026-11-04-equipment-icons' / i['icon']).is_file()
    assert Path(i['icon']).stem == i['name']
    assert i['stats'].keys() == f['commonEquivalentStats'].keys() == i['statsAtEnhancement9'].keys()
    assert set(i['stats']) <= set(p['budgetWeights'])
    factor = D(str(p['rarityBudgetRatios'][i['rarity']])) * D(str(f['setBudgetFactor']))
    for key, value in i['stats'].items():
        assert D(str(value)) > 0
        assert D(str(value)) == D(str(f['commonEquivalentStats'][key])) * factor
        multiplier = D('1.27') if key in ('power', 'armor', 'health') else D(1)
        assert D(str(i['statsAtEnhancement9'][key])) == D(str(value)) * multiplier
    assert i['enhancementSupported'] == any(k in ('power', 'armor', 'health') for k in i['stats'])
    assert i['uniqueGroup'] == (i['familyId'] if i['slot'] == 'accessory' else None)
    assert bool(i['setId']) == bool(f['setName'])
    if i['setId']:
        assert i['slot'] in ('weapon', 'head', 'body', 'hands', 'feet')
        assert f['setBudgetFactor'] == .97
        assert i['setPieceId'] == i['slot']
    else:
        assert f['setBudgetFactor'] == 1
    by_family.setdefault(i['familyId'], []).append(i)
sets = {}
for i in p['items']:
    if i['setId']: sets.setdefault(i['setId'], set()).add(i['slot'])
assert len(sets) == 12 and all(s == {'weapon', 'head', 'body', 'hands', 'feet'} for s in sets.values())
for rows in by_family.values():
    rows.sort(key=lambda i: p['rarityBudgetRatios'][i['rarity']])
    for key in rows[0]['stats']:
        assert rows[0]['stats'][key] < rows[1]['stats'][key] < rows[2]['stats'][key]
assert Counter(i['classId'] or 'shared' for i in p['items']) == {'shared': 33, 'knight': 24, 'elf': 21, 'dwarf': 21, 'mage': 21}
assert sum(not i['enhancementSupported'] for i in p['items']) == 3
print('PASS: 40 family budgets, 120 item stat plans, 12 five-piece sets; IDs/icons/grades/levels, exact multipliers, MP unchanged at +9 and enhancement eligibility')
