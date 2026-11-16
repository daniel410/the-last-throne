"""현재 Lua 보상과 미승인 감액안의 읽기 전용 비교. 저장소 루트에서 실행한다."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()

# 현행 배율/반올림/유한 웨이브를 재사용한다. 제안은 런타임 테이블에 쓰지 않는다.
bridge = r"""
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,D,B,S,E,Shop=load('CampaignContent'),load('Difficulty'),load('DeepwoodEncounterBalance'),load('EncounterSummary'),load('Enhancement'),load('EconomyCatalog')
local function out(...)local t={};for i=1,select('#',...)do t[i]=tostring(select(i,...))end;print(table.concat(t,'\t'))end
out('rules',D.version)
for _,c in ipairs(C.chapters)do for _,mode in ipairs(D.order)do for players=1,4 do
 local kills,requiredKills,proposalKills,requiredProposalKills,count,zero,proposalZero=0,0,0,0,0,0,0
 for _,goal in ipairs(c.goals)do
  for _,wave in ipairs(B.encounterWaves(c,goal,players,mode,D.version))do for _,unit in ipairs(wave)do
   local _,gold=B.rewards(unit,mode,D.version)
   local base=(3+math.floor(unit.level/2))*(B.isBoss(unit.kind)and 10 or 1)
   local whole=math.floor(math.floor(base*3/4)*D.goldMultiplier(unit.level,mode,D.version))
   local copies,index=unit.rewardCopies or 1,unit.rewardIndex or 1
   local proposed=math.floor(whole/copies)+(index<=whole%copies and 1 or 0)
   kills=kills+gold;proposalKills=proposalKills+proposed;count=count+1
   if gold==0 then zero=zero+1 end;if proposed==0 then proposalZero=proposalZero+1 end
   if not goal.optional then requiredKills=requiredKills+gold;requiredProposalKills=requiredProposalKills+proposed end
  end end
 end
 local projection=S.mission(c,mode,players,D.version)
 assert(kills==projection.gold and count==projection.count,'Projection mismatch '..c.id)
 local r=D.completion(c,mode,D.version)
 out('mission',c.id,c.epic,c.side and 'side' or 'main',mode,players,c.reward.coins,r.gold,kills,requiredKills,math.floor(c.reward.coins*7/10),math.floor(r.gold/2),proposalKills,requiredProposalKills,count,zero,proposalZero,r.gems,r.stones,r.cache)
end end end
for _,target in ipairs({3,6,9})do
 local gold,gems,stones,attempts=0,0,0,0
 for n=1,target do local cost=E.cost({},n);local p=E.successPercent(n)/100
  gold=gold+cost.gold/p;gems=gems+cost.gems/p;stones=stones+cost.stones/p;attempts=attempts+1/p
 end
 out('enhancement',target,gold,gems,stones,attempts)
end
for _,o in ipairs(Shop.offers)do if o.currency=='gold'then out('offer',o.id,o.price)end end
for _,mode in ipairs(D.order)do out('diamonds',mode,Shop.storyDiamondsByMode[mode])end
local daily=load('DailyLogin');local total=0;for _,v in ipairs(daily.rewards)do total=total+v end;out('daily',total)
"""

columns = ['id', 'epic', 'kind', 'mode', 'players', 'first_fixed', 'repeat_fixed',
           'kill_gold', 'kill_gold_without_optional_goals', 'proposal_first_fixed',
           'proposal_repeat_fixed', 'proposal_kill_gold',
           'proposal_kill_gold_without_optional_goals', 'enemy_count',
           'zero_gold_enemies', 'proposal_zero_gold_enemies', 'gems', 'stones', 'cache_progress']
missions, enhancement, offers, diamonds = [], {}, {}, {}
for line in subprocess.check_output(['lua', '-'], input=bridge, text=True).splitlines():
    tag, *values = line.split('\t')
    if tag == 'mission':
        row = dict(zip(columns, values, strict=True))
        for key in columns:
            if key not in ('id', 'kind', 'mode'):
                row[key] = int(row[key])
        missions.append(row)
    elif tag == 'enhancement':
        enhancement[values[0]] = dict(zip(
            ['gold', 'gems', 'stones', 'attempts'], map(float, values[1:]), strict=True))
    elif tag == 'offer':
        offers[values[0]] = int(values[1])
    elif tag == 'diamonds':
        diamonds[values[0]] = int(values[1])
    elif tag == 'daily':
        daily_gold = int(values[0])
    elif tag == 'rules':
        rules_version = int(values[0])
    else:
        raise ValueError(line)

assert len(missions) == 47 * 4 * 4
assert len({(r['id'], r['mode'], r['players']) for r in missions}) == len(missions)
for r in missions:
    assert 0 <= r['proposal_kill_gold'] <= r['kill_gold']
    assert r['kill_gold_without_optional_goals'] <= r['kill_gold']
    assert r['proposal_first_fixed'] <= r['first_fixed']
    assert r['proposal_repeat_fixed'] <= r['repeat_fixed']


def aggregate(rows):
    keys = [k for k in columns[5:] if k not in ('gems', 'stones', 'cache_progress')]
    total = {k: sum(r[k] for r in rows) for k in keys}
    for prefix in ('', 'proposal_'):
        for clear in ('first', 'repeat'):
            total[prefix + clear + '_gross'] = total[prefix + clear + '_fixed'] + total[prefix + 'kill_gold']
            total[prefix + clear + '_gross_without_optional_goals'] = (
                total[prefix + clear + '_fixed'] + total[prefix + 'kill_gold_without_optional_goals'])
    return total


totals = {}
for mode in diamonds:
    totals[mode] = {}
    for players in range(1, 5):
        totals[mode][str(players)] = {}
        for kind in ('main', 'side'):
            rows = [r for r in missions if r['mode'] == mode and r['players'] == players and r['kind'] == kind]
            assert len(rows) == (35 if kind == 'main' else 12)
            summary = aggregate(rows)
            summary['epics'] = {str(epic): aggregate([r for r in rows if r['epic'] == epic]) for epic in range(1, 6)}
            totals[mode][str(players)][kind] = summary

# 승인된 32구간 중 캠페인에 포함된 28구간의 초회 Gold 정합성.
canonical = json.loads(Path('assets/balance/story-reward-budget.json').read_text())
current = {r['id']: r['first_fixed'] for r in missions}
matched = [r for r in canonical['rows'] if r['id'] in current]
assert len(matched) == 28
assert all(r['quest_coins'] == current[r['id']] for r in matched)
validation = dict(projection_comparisons=len(missions), canonical_first_gold_matches=len(matched))
paths = [
    'assets/balance/story-reward-budget.json', 'src/shared/CampaignContent.luau',
    'src/shared/DeepwoodContent.luau', 'src/shared/LateEpicContent.luau',
    'src/shared/FrozenValeContent.luau', 'src/shared/EmberCalderaContent.luau',
    'src/shared/CampaignCombatRoutes.luau', 'src/shared/CampaignCombatPacing.luau',
    'src/shared/EasyCampaignTuning.luau',
    'src/shared/Difficulty.luau', 'src/shared/RewardEconomy.luau',
    'src/shared/AdventureRepeatRewards.luau', 'src/shared/QuestCompletionRewards.luau',
    'src/shared/DeepwoodEncounterBalance.luau', 'src/shared/EncounterPopulation.luau',
    'src/shared/EncounterSummary.luau', 'src/shared/Enhancement.luau',
    'src/shared/EquipmentPricing.luau', 'src/shared/EconomyCatalog.luau',
    'src/shared/DailyLogin.luau', 'src/shared/SupportPassRules.luau',
    'src/shared/EconomyRules.luau', 'src/shared/AdventureRules.luau',
    'src/server/Inventory/InventoryRules.luau', 'src/server/Inventory/StudioTestRules.luau',
    'scripts/review_gold_rewards.py',
]
hashes = {p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in paths}
result = dict(
    scope='정적 총유입 비교. 선택 표시 교전 포함/제외를 분리. 모든 유한 웨이브 처치 가정. '
          '클리어 시간/실제 지출/드롭 판매/다이아 교환/Studio 초기잔액/운영 지급은 총액에서 제외. '
          '필수 교전 제외 경로의 실제 통행 가능성과 플레이 수용은 미검증.',
    source_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(),
    version=Path('VERSION').read_text().strip(), rules_version=rules_version,
    proposal='미승인. 초회 고정액 floor(기존*0.7), 처치 원본 전체 예산 floor(기존*0.75) 후 '
             '현행 난이도/경제구간 배율 및 복제체 분배, 반복 완료 최종액 floor(기존*0.5). '
             'XP/재료/상자/장비/가격/기존 지급은 유지하는 민감도 비교.',
    validation=validation, source_hashes=hashes, totals=totals, missions=missions,
    expected_enhancement_cost=enhancement, gold_offers=offers,
    first_story_diamonds=diamonds, seven_day_login_gold=daily_gold,
)
args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
for mode in diamonds:
    t = totals[mode]['1']['main']
    print(mode, 'first', t['first_gross'], 'repeat', t['repeat_gross'],
          'proposal_first', t['proposal_first_gross'], 'proposal_repeat', t['proposal_repeat_gross'])
print(validation)
