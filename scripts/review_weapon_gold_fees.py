"""Read-only enhancement fee sensitivity against actual Lua rules and rewards.

Usage: python3 scripts/review_weapon_gold_fees.py --output /tmp/tlt-weapon-fees.json
All fee curves are proposals. Does not modify runtime or canonical balance files.
"""
import argparse
import functools
import hashlib
import json
import math
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
bridge = r"""
local E=dofile('src/shared/Enhancement.luau')
local D=dofile('src/shared/Difficulty.luau')
local C=dofile('src/shared/CampaignContent.luau')
local S=dofile('src/shared/EncounterSummary.luau')
for n=1,9 do local c=E.cost({},n);print(table.concat({'step',n,E.successPercent(n),c.gold,c.gems,c.stones},'\t'))end
for _,id in ipairs({'DW-01','DW-05','DW-07','FV-07','EC-07','HG-07'})do
 local c=C.byId[id]
 for _,mode in ipairs(D.order)do
  local s=S.mission(c,mode,1,D.version);local r=D.completion(c,mode,D.version)
  print(table.concat({'mission',id,mode,s.gold+r.gold,r.gems,r.stones},'\t'))
 end
end
"""
raw = subprocess.check_output(['lua', '-e', bridge], text=True)
steps, missions = [], []
for line in raw.splitlines():
    row = line.split('\t')
    if row[0] == 'step':
        n, success, gold, gems, stones = map(int, row[1:])
        steps.append(dict(target=n, success=success / 100, current_gold=gold,
                          gems=gems, stones=stones))
    else:
        missions.append(dict(id=row[1], mode=row[2], repeat_gold=int(row[3]),
                             gems=int(row[4]), stones=int(row[5])))
assert len(steps) == 9 and all(s['current_gold'] == 0 for s in steps)


def distribution(prices, chances):
    """Exact discrete geometric convolution, with negligible truncated tail."""
    mean = sum(c / p for c, p in zip(prices, chances))
    variance = sum(c * c * (1 - p) / (p * p) for c, p in zip(prices, chances))
    unit = functools.reduce(math.gcd, prices)
    limit = math.ceil((mean + 40 * math.sqrt(variance)) / unit) + sum(prices) // unit
    probabilities = [1.] + [0.] * limit
    for price, chance in zip(prices, chances):
        cost = price // unit
        next_probabilities = [0.] * (limit + 1)
        for k in range(cost, limit + 1):
            next_probabilities[k] = (chance * probabilities[k - cost]
                                     + (1 - chance) * next_probabilities[k - cost])
        probabilities = next_probabilities
    quantiles, cumulative = {}, 0.
    for k, value in enumerate(probabilities):
        cumulative += value
        for q in (.5, .9, .95):
            if cumulative >= q and str(q) not in quantiles:
                quantiles[str(q)] = k * unit
    assert cumulative > 1 - 1e-10 and len(quantiles) == 3
    assert abs(sum(k * unit * p for k, p in enumerate(probabilities)) - mean) < 1e-5
    return dict(minimum=sum(prices), expected=mean, quantiles=quantiles,
                truncated_probability=max(0., 1 - cumulative))


curves = {
    'trial_25n': [25 * n for n in range(1, 10)],
    'trial_50n': [50 * n for n in range(1, 10)],
    'trial_10n_squared': [10 * n * n for n in range(1, 10)],
    'historical_20n_squared_T1': [20 * n * n for n in range(1, 10)],
    'historical_20n_squared_T6': [120 * n * n for n in range(1, 10)],
}
result = dict(scope='unapproved weapon-only fee sensitivity; independent attempts; '
                   'no measured clear time, inventory stocks, potion spending or player behavior',
              source_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(),
              steps=steps, missions=missions, curves={})
for name, prices in curves.items():
    result['curves'][name] = dict(attempt_fees=prices, targets={})
    for target in (3, 6, 9):
        selected = steps[:target]
        summary = distribution(prices[:target], [s['success'] for s in selected])
        summary['expected_attempts'] = sum(1 / s['success'] for s in selected)
        for material in ('gems', 'stones'):
            summary['expected_' + material] = sum(s[material] / s['success'] for s in selected)
        result['curves'][name]['targets'][str(target)] = summary

full = result['curves']['trial_25n']['targets']['9']
result['material_constrained_examples'] = []
for mission in missions:
    if mission['gems'] <= 0 or mission['stones'] <= 0:
        continue
    # Continuous expectation approximation, not expected stopping time of
    # random material acquisition/independent enhancement attempts.
    clears = max(full['expected_gems'] / mission['gems'],
                 full['expected_stones'] / mission['stones'])
    gross = clears * mission['repeat_gold']
    result['material_constrained_examples'].append(dict(
        **mission, approximate_clears=clears, approximate_gross_gold=gross,
        proposed_gold_share=full['expected'] / gross,
        note='zero starting materials; no exchanges, side rewards or other spending; '
             'ratio of expected budgets, NOT expected stopping time'))
paths = ['src/shared/Enhancement.luau', 'src/shared/Difficulty.luau',
         'src/shared/RewardEconomy.luau', 'src/shared/DeepwoodEncounterBalance.luau']
result['source_hashes'] = {p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in paths}
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({name: curve['targets'] for name, curve in result['curves'].items()}, indent=2))
