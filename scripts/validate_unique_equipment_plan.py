"""Check Unique proposals without enabling runtime items or generating icons."""
import json
import re
from collections import Counter
from decimal import Decimal as D
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
p = json.loads((ROOT / 'assets/balance/unique-equipment-plan-2026-11-05.json').read_text())
base = json.loads((ROOT / p['baseStatsSource']).read_text())
families = {f['familyId']: f for f in base['families']}
m = json.loads((ROOT / p['sourceManifest']).read_text())
variants = {v['proposalId']: v for v in m['variants']}
items = p['items']; rules = p['globalRules']
assert len(items) == len(families) == 40
assert {i['familyId'] for i in items} == set(families)
for key in ['proposalId', 'candidateDefinitionId', 'name', 'nameKey', 'descriptionKey']:
    assert len({i[key] for i in items}) == 40, key
assert not ({i['candidateDefinitionId'] for i in items} & {i['candidateDefinitionId'] for i in base['items']})
assert Counter(i['classId'] or 'shared' for i in items) == {'shared': 11, 'knight': 8, 'elf': 7, 'dwarf': 7, 'mage': 7}
assert D(str(p['uniqueBaseBudgetRatio'])) + D(str(p['reservedEffectBudgetRatio'])) == D(str(p['legendaryBudgetRatio']))
boss_source = (ROOT / 'src/shared/DeepwoodEncounterBalance.luau').read_text()
boss_block = boss_source.split('local bosses={', 1)[1].split('}', 1)[0]
bosses = set(re.findall(r'(\w+)=true', boss_block))
skills = (ROOT / 'src/shared/K0Config.luau').read_text() + (ROOT / 'src/shared/AdvancedSkills.luau').read_text()
for i in items:
    f = families[i['familyId']]; v = variants[i['proposalId']]; e = i['effect']
    assert i['rarity'] == v['rarity'] == 'Unique'
    assert i['requiredLevel'] == i['equipmentTier'] == 10
    assert i['status'] == 'authored-proposal-not-runtime' and not i['runtimeEnabled']
    assert i['setId'] is None and i['setPieceId'] is None and not v['setCandidate']
    assert i['classId'] == f['classId'] and i['slot'] == f['slot']
    assert i['uniqueGroup'] == (i['familyId'] if i['slot'] == 'accessory' else None)
    assert i['stats'].keys() == f['commonEquivalentStats'].keys() == i['statsAtEnhancement9'].keys()
    for k, n in i['stats'].items():
        assert D(str(n)) == D(str(f['commonEquivalentStats'][k])) * D('1.26')
        assert D(str(i['statsAtEnhancement9'][k])) == D(str(n)) * (D('1.27') if k in ('power', 'armor', 'health') else D(1))
    assert i['enhancementSupported'] == any(k in ('power', 'armor', 'health') for k in i['stats'])
    assert e['cooldownSeconds'] == rules['categoryCooldownSeconds'][e['kind']]
    assert e['cooldownGroup'] == e['kind'] and e['maxStacks'] == 1
    assert e['applyOncePerCast'] and not e['allowProcFromProc'] and not e['enhancementScaling']
    if 'skillId' in e['conditions']: assert e['conditions']['skillId'] in skills
    if e['kind'] == 'shield': assert 0 < e['maxHealthFraction'] <= rules['maxActiveShieldFraction']
    if e['kind'] == 'heal': assert 0 < e['maxHealthFraction'] <= rules['maxHealFractionPerCooldown'] and e['requiresMissingHealth']
    if e['kind'] == 'reduction': assert 0 < e['damageReductionFraction'] <= rules['maxActiveReductionFraction']
    if e['kind'] == 'bonus': assert 0 < e['damageBonusFraction'] <= rules['maxBonusFraction'] and e['charges'] == 1
    if e['kind'] == 'mana': assert 0 < e['flatMana'] <= rules['maxManaRestoredPerCooldown'] and e['requiresExistingManaPool'] and e['requiresMissingMana']
    assert i['drop']['bossKind'] in bosses and i['drop']['probability'] is None and not i['drop']['enabled']
    assert i['art']['status'] == 'prompt-ready-not-generated' and i['art']['targetFile'] == i['name'] + '.png'
    assert (ROOT / 'assets/concepts/2026-11-04-equipment-icons' / i['art']['reference']).is_file()
    assert re.fullmatch(r'Unique_[A-Za-z0-9_]+', i['name'])
    assert all(ord(c) < 128 for c in i['descriptionEnUS'])
    assert v['name'] == i['name'] and v['statsPlanRef']['proposalId'] == i['proposalId']
assert len({i['effect']['effectId'] for i in items}) == 40
assert len(p['firstImplementationFamilyIds']) == 4
assert rules['requiresActiveCombat'] and rules['noProcChain'] and rules['noEquipRestore']
print('PASS: 40 Unique stat/effect/drop/art proposals; 4 existing skill IDs, boss kinds, budget/enhancement/MP invariants, no sets, no runtime/drop activation')
