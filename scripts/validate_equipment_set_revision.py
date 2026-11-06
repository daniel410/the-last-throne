"""Validate the set proposal and calculate examples, without running the game."""
import argparse
import collections
import hashlib
import json
import math
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
balance_path = 'assets/balance/equipment-recalculated-2026-11-05.json'
policy_path = 'assets/balance/equipment-set-bonuses-2026-11-05.json'
baseline = '9296775b8c1ba085bc14b378ae86dd1f60e1cdf9'
previous = json.loads(subprocess.check_output(['git', 'show', baseline + ':' + balance_path], cwd=ROOT))
plan = json.loads((ROOT / balance_path).read_text())
policy = json.loads((ROOT / policy_path).read_text())
assert plan['version'] == 3 and not plan['runtimeEnabled'] and not policy['runtimeEnabled']
assert plan['setBonuses'] == policy['bonuses']
assert plan['sourceHashes'][policy_path] == hashlib.sha256((ROOT / policy_path).read_bytes()).hexdigest()
old_by_id = {i['candidateDefinitionId']: i for i in previous['items']}
assert len(plan['items']) == len(old_by_id) == 160
sets = collections.defaultdict(list)
for item in plan['items']:
    old = old_by_id[item['candidateDefinitionId']]
    # Descriptions alone may change: stats, identity, ownership groups and Unique
    # definitions must survive the set revision byte-for-byte as JSON values.
    keys = set(item) | set(old)
    assert all(item.get(k) == old.get(k) for k in keys - {'descriptionEnUS', 'descriptionKoDev'})
    if item['rarity'] == 'Unique':
        assert item == old and not item['setId']
    if item['setId']:
        sets[item['setId']].append(item)
        assert '5 pieces:' in item['descriptionEnUS']
        assert item['slot'] in policy['countPolicy']['eligibleSlots']
assert len(sets) == 12
assert all(len(s) == 5 and len({i['setPieceId'] for i in s}) == 5 for s in sets.values())
assert policy['countPolicy']['multipleSetsAtSameThreshold'] == 'strongest-only-then-setId'
bonuses = policy['bonuses']
assert bonuses['2']['healthFractionOfPreSetMaxHealth'] == .05
assert bonuses['5']['finalDirectDamageFractionByRarity'] == {'Rare': .05, 'Epic': .06, 'Legendary': .08}
assert 'powerFractionOfEnhancedEquipmentPower' not in bonuses['5']
assert 'armorFractionOfEnhancedEquipmentArmor' not in bonuses['4']
assert policy['calculationPolicy']['noNewManaPoolOrPassiveRecovery']

transitions = []
for set_id, pieces in sets.items():
    for count in range(6):
        # Input fixtures for the downstream engine, not an engine count test.
        transitions.append({'setId': set_id, 'candidateIds': [i['candidateDefinitionId'] for i in pieces[:count]],
                            'distinctPieces': count, 'expectedThresholds': [n for n in (2, 4, 5) if count >= n]})

rows = []
for set_id, pieces in sets.items():
    cls, grade = pieces[0]['classId'], pieces[0]['rarity']
    level = pieces[0]['requiredLevel']
    health_base, health_gain = plan['coefficients']['healthBases'][cls]
    hero_hp = health_base + health_gain * (level - 1)
    kit = [i for i in plan['items'] if i['rarity'] == grade and i['classId'] == cls]
    assert len(kit) == (8 if cls == 'knight' else 7)
    for enhancement in (0, 9):
        field = 'statsAtEnhancement9' if enhancement else 'stats'
        power = sum(i[field].get('power', 0) for i in kit)
        health = hero_hp + sum(i[field].get('health', 0) for i in kit)
        old_damage = 1 + power * 1.02 / 100
        bare_damage = 1 + power / 100
        completion = bonuses['5']['finalDirectDamageFractionByRarity'][grade]
        basic = bare_damage * (1 + completion)
        skill = basic * (1.05 if cls in ('elf', 'dwarf') else 1)
        assert basic > old_damage
        rows.append({'setId': set_id, 'classId': cls, 'rarity': grade, 'level': level,
                     'enhancement': enhancement, 'equipmentPower': power,
                     'oldFullSetDamageMultiplier': old_damage, 'newBasicDamageMultiplier': basic,
                     'newEligibleSkillDamageMultiplier': skill,
                     'basicGainOverOldFullSetPercent': (basic / old_damage - 1) * 100,
                     'completionOnlyBasicGainPercent': completion * 100,
                     'newFourAndFiveEligibleSkillGainPercent': (skill / bare_damage - 1) * 100,
                     'oldTwoPieceMaxHealth': health * 1.02,
                     'newTwoPieceMaxHealth': health * 1.05})

mana = [{'baseCost': c, 'newCost': max(1, math.ceil(c * .92)) if c else 0} for c in (0, 1, 12, 14, 20, 80)]
assert [r['newCost'] for r in mana] == [0, 1, 12, 13, 19, 74]
report = {'date': '2026-11-05', 'kind': 'static-design-validation-not-runtime',
          'baselineCommit': baseline,
          'sourceHashes': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in (balance_path, policy_path)},
          'unchangedItemDefinitionsExceptDescriptions': 160, 'unchangedUniqueItems': 40,
          'sets': 12, 'setItems': 60, 'transitionFixtures': transitions,
          'calculatedFullKits': rows, 'mageManaCostExamples': mana,
          'roundingCaveat': 'Outgoing examples compare pre-rounding multipliers; per-hit integer damage may change the percentage.',
          'notRun': ['server set engine', 'actual equip counting', 'save/rejoin', 'UI', 'multiplayer', 'devices', 'Unique proc DPS']}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print('PASS: 12 sets/60 pieces, 160 base definitions and 40 Unique preserved; 72 transition fixtures; 24 full-kit calculations; 6 MP rounding cases; runtime disabled')
