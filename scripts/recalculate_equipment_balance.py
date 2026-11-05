"""Build the current 160-item balance proposal; leave historical inputs/runtime intact."""
import copy
import hashlib
import html
import itertools
import json
from collections import Counter
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets/concepts/2026-11-04-equipment-icons'
OLD = 'assets/balance/equipment-stats-plan-2026-11-04.json'
OLD_U = 'assets/balance/unique-equipment-plan-2026-11-05.json'
OUT = 'assets/balance/equipment-recalculated-2026-11-05.json'
base = json.loads((ROOT/OLD).read_text())
unique = json.loads((ROOT/OLD_U).read_text())
old = {(i['rarity'], i['familyId']): i for i in base['items']+unique['items']}
families = {f['familyId']: f for f in base['families']}
levels = {'Rare':10, 'Epic':20, 'Legendary':40, 'Unique':60}
ratios = {'Common':1, 'Uncommon':1.08, 'Rare':1.18, 'Epic':1.28, 'Legendary':1.4, 'Unique':1.6}
bases = {'knight':(250,15), 'dwarf':(200,13), 'elf':(150,10), 'mage':(100,8)}

def rounded(n):
    return float(Decimal(str(n)).quantize(Decimal('.0001'), rounding=ROUND_HALF_UP))

def health(level, cls):
    if cls:
        a,b = bases[cls]
        return a+b*(level-1)
    return sum(health(level,c) for c in bases)/4

def scale(key, level, cls):
    if key in ('power','armor'):
        return (0.45 if key=='armor' else 1)*(1+.006*(level-10))
    if key=='health':
        return health(level, cls)/health(10, cls)
    return (100+4*(level-1))/136  # Mage unallocated-INT reference; fixed item value.

def stats(f, grade, level, enhancement=0):
    return {k:rounded((max(v,24/ratios['Rare']) if k=='power' and f['slot']=='weapon' else v)*scale(k,level,f['classId'])*ratios[grade]*(1+.03*enhancement if k in ('power','armor','health') else 1))
            for k,v in f['commonEquivalentStats'].items()}

def compatible(a,b):
    return not (a['classId'] and b['classId'] and a['classId']!=b['classId']) and (a['slot']!=b['slot'] or a['slot']=='accessory') and not (a.get('uniqueGroup') and a['uniqueGroup']==b.get('uniqueGroup'))

def signature(e):
    return e['kind'], e['event'], json.dumps(e['conditions'], sort_keys=True)

def effect(kind,event,conditions,value,target=None):
    e={'kind':kind,'event':event,'conditions':conditions,'cooldownSeconds':15 if kind in ('bonus','mana') else 20,
       'durationSeconds':8 if kind=='bonus' else 4 if kind in ('shield','reduction') else 0,
       'maxStacks':1,'cooldownGroup':kind,'applyOncePerCast':True,'allowProcFromProc':False,'enhancementScaling':False}
    field={'shield':'maxHealthFraction','heal':'maxHealthFraction','reduction':'damageReductionFraction','bonus':'damageBonusFraction','mana':'maxManaFraction'}[kind]
    e[field]=value
    if kind=='bonus':
        e.update(charges=2 if target=='next_magic_skill_first_enemy' else 3,target=target or 'next_basic_attack_first_enemy',consumeOncePerAttackOrCast=True)
    if kind=='heal':e['requiresMissingHealth']=True
    if kind=='mana':
        e.update(requiresExistingManaPool=True,requiresMissingMana=True,flatFloor=6,levelCap={'base':12,'perLevel':.2,'round':'floor'})
    return e

# Remove identical compatible procs and strict skill/general-magic overlap.
overrides={
 'common_hands':effect('reduction','basic_attack_hit',{'requiredCount':3,'windowSeconds':8,'countPerAttack':1},.08),
 'dwarf_pendant_family':effect('bonus','enemy_hit_blocked',{},.24),
 'knight_pendant_family':effect('heal','enemy_hit_blocked',{},.03),
 'dwarf_feet_family':effect('reduction','enemy_hit_blocked',{},.08),
 'elf_hands_family':effect('bonus','dodge_avoided_enemy_hit',{},.20),
 'dwarf_hands_family':effect('shield','skill_hit',{'skillId':'dwarf.common.ground'},.10),
 'knight_body_family':effect('heal','enemy_damage_applied',{'crossHealthFractionBelow':.35},.03),
 'mage_body_family':effect('reduction','enemy_hit_blocked',{},.08),
 'mage_head_family':effect('mana','dodge_avoided_enemy_hit',{'requiresManaPool':True},.04),
 'mage_ring_family':effect('heal','dodge_avoided_enemy_hit',{},.025),
 'elf_ring_family':effect('shield','skill_hit',{'skillId':'elf.common.aimed'},.08),
 'mage_weapon_family':effect('bonus','skill_hit',{'skillId':'mage_wind_lance','requiresManaPool':True},.24,'next_magic_skill_first_enemy'),
 'mage_hands_family':effect('reduction','skill_hit',{'requiresMagicSkill':True,'requiresManaPool':True},.08),
}
triggers={
 'enemy_damage_applied':('after direct enemy damage is applied','적 직접 피해 적용 후'),
 'enemy_hit_blocked':('after blocking an enemy hit','적 타격 블록 후'),
 'dodge_avoided_enemy_hit':('after avoiding an enemy hit with a dodge','회피로 실제 적 타격을 피한 후'),
 'basic_attack_hit':('after 3 basic attacks hit within 8s','8초 안에 기본공격 3회 적중 후'),
 'mana_consumed_by_skill':('after a skill consumes at least 10 MP','스킬로 MP10 이상 소비 후'),
 'skill_hit':('after a magic skill hits','마법 스킬 적중 후')}

def describe(e):
    en,ko=triggers[e['event']]
    c=e['conditions']
    if c.get('skillId'):
        en='after '+c['skillId']+' hits';ko=c['skillId']+' 적중 후'
    if c.get('crossHealthFractionBelow'):
        v=c['crossHealthFractionBelow']*100
        en+=f', crossing below {v:g}% HP';ko+=f' HP{v:g}% 아래로 통과 시'
    kind=e['kind']
    if kind=='mana':
        text=f"restore {e['maxManaFraction']*100:g}% of pre-effect Max MP (floor 6 MP, cap 12 + floor(0.2 x level), missing MP only)"
        k=f"효과 전 최대MP의 {e['maxManaFraction']*100:g}% 회복 (최저6, 레벨상한12+floor(0.2×Lv), 부족MP 한도)"
    elif kind=='bonus':
        target='magic skill' if e['target']=='next_magic_skill_first_enemy' else 'basic attack'
        text=f"gain {e['charges']} charges: the next {target}'s first enemy takes +{e['damageBonusFraction']*100:g}% damage; expires after 8s; once per attack/cast after the trigger cast"
        k=f"다음 {'마법스킬' if target=='magic skill' else '기본공격'} 첫 대상 피해+{e['damageBonusFraction']*100:g}%, {e['charges']}회/8초; 발동 공격·시전 제외"
    elif kind=='reduction':
        text=f"reduce direct enemy damage by {e['damageReductionFraction']*100:g}% for 4s"
        k=f"적 직접 피해 {e['damageReductionFraction']*100:g}% 감소/4초"
    else:
        v=e['maxHealthFraction']*100
        text=f"{'gain a shield worth' if kind=='shield' else 'restore'} {v:g}% of pre-effect Max HP"+(' for 4s' if kind=='shield' else ' (missing HP only)')
        k=f"효과 전 최대HP {v:g}% "+('보호막/4초' if kind=='shield' else '회복/부족HP 한도')
    return f"While in active combat, {en}, {text}. Shared {kind} cooldown: {e['cooldownSeconds']}s. No proc chains or enhancement scaling.",ko+' → '+k+f"; 범주공유CD {e['cooldownSeconds']}초"

items=[]
for grade,level in levels.items():
    for f in base['families']:
        src=old[(grade,f['familyId'])]
        i={k:copy.deepcopy(src.get(k)) for k in ('proposalId','candidateDefinitionId','familyId','name','classId','slot','uniqueGroup','icon','setId','setPieceId')}
        i.update(rarity=grade,requiredLevel=level,equipmentTier=level,
                 levelStatus='user-approved-minimum-60' if grade=='Unique' else 'recalculated-trial-proposal',
                 statsStatus='level-scaled-recalculation-playtest-pending',statReferenceTier=level,
                 stats=stats(f,grade,level),statsAtEnhancement9=stats(f,grade,level,9),
                 runtimeEnabled=False,enhancementSupported=src['enhancementSupported'],
                 allowedDifficulties=src.get('drop',src.get('dropEligibility'))['allowedDifficulties'],
                 previous={'requiredLevel':src['requiredLevel'],'statReferenceTier':src.get('statReferenceTier',10),'stats':src['stats'],'statsAtEnhancement9':src['statsAtEnhancement9']},
                 status='current-balance-proposal-not-runtime',
                 personalLootRequiresExistingManaPool=bool(src['stats'].get('maxMana')),
                 personalLootMinimumLevel=level)
        if grade=='Unique':
            prev=src['effect'];kind=prev['kind']
            magnitude={'shield':.10 if prev.get('maxHealthFraction',0)>=.05 else .08 if prev.get('maxHealthFraction',0)>=.04 else .06,
                       'heal':.03 if prev.get('maxHealthFraction',0)>=.02 else .025,
                       'reduction':.10 if prev.get('damageReductionFraction',0)>=.06 else .08,
                       'bonus':.24 if prev.get('damageBonusFraction',0)>=.08 else .20,
                       'mana':.06 if prev.get('flatMana',0)>=6 else .04}.get(kind)
            e=copy.deepcopy(overrides.get(i['familyId']) or effect(kind,prev['event'],prev['conditions'],magnitude))
            e['effectId']=prev['effectId'];i['effect']=e
            i['previous']['effect']=prev
            i['descriptionEnUS'],i['descriptionKoDev']=describe(e)
            i['drop']=copy.deepcopy(src['drop'])
        else:
            i['descriptionEnUS']='No individual proc. Set bonuses apply only when their piece requirements are met.' if i['setId'] else 'No individual proc.'
            i['descriptionKoDev']='개별 발동 효과 없음'+(' / 2·4·5부위 세트 보너스' if i['setId'] else '')
        items.append(i)
new_by={(i['rarity'],i['familyId']):i for i in items}
unique_items=[i for i in items if i['rarity']=='Unique']
conflicts=[(a['name'],b['name']) for a,b in itertools.combinations(unique_items,2) if compatible(a,b) and signature(a['effect'])==signature(b['effect'])]
assert not conflicts,conflicts
assert len(items)==len({i['proposalId'] for i in items})==len({i['candidateDefinitionId'] for i in items})==160
assert Counter(i['rarity'] for i in items)==dict.fromkeys(levels,40)
changed=sum(i['stats']!=i['previous']['stats'] for i in items)
assert changed>=140
for i in unique_items:
    e=i['effect']
    assert all(ord(c)<128 for c in i['descriptionEnUS'])
    assert e['cooldownGroup']==e['kind'] and not e['enhancementScaling'] and not e['allowProcFromProc']
    if e['kind']=='bonus':
        assert e['charges']==(2 if e['target']=='next_magic_skill_first_enemy' else 3)
        assert e['damageBonusFraction']<=.24 and e['durationSeconds']==8
    if e['kind']=='mana': assert 0<e['maxManaFraction']<=.06 and e['requiresExistingManaPool'] and e['requiresMissingMana']
    if e['kind']=='shield': assert 0<e['maxHealthFraction']<=.12
    if e['kind']=='heal': assert 0<e['maxHealthFraction']<=.03 and e['requiresMissingHealth']
    if e['kind']=='reduction': assert 0<e['damageReductionFraction']<=.10
# Same-level, same-upgrade, including hypothetical grade peers, not cross-level sorting.
checks=0
for f in families.values():
    for level in (10,20,40,60,80):
        for upgrade in (0,5,9):
            rows=[stats(f,g,level,upgrade) for g in ratios]
            for a,b in zip(rows,rows[1:]):
                assert all(a[k]<b[k] for k in a)
                checks+=1
            legendary=stats(f,'Legendary',level,upgrade)
            u=stats(f,'Unique',level,upgrade)
            assert all(u[k]>legendary[k]*1.02 for k in u) # Full set's maximum stat multiplier.
for i in items:
    assert i['requiredLevel']==levels[i['rarity']]
    assert i['stats'].keys()==i['statsAtEnhancement9'].keys()
    for key,value in i['stats'].items():
        assert abs(i['statsAtEnhancement9'][key]-value*(1.27 if key in ('power','armor','health') else 1))<.00015
    assert i['allowedDifficulties']==(['Hell'] if i['rarity']=='Unique' else ['Insane','Hell'] if i['rarity']=='Legendary' else ['Easy','Hard','Insane','Hell'])

policy={
 'version':2,'date':'2026-11-05','status':'current-recalculated-proposal-playtest-and-runtime-pending',
 'supersedesNumericProposals':[OLD,OLD_U],
 'sourceHashes':{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in (OLD,OLD_U)},
 'rarityMultipliers':ratios,'requiredLevels':levels,'runtimeEnabled':False,
 'effectBudgetPolicy':'additional-fixed-effect-no-base-stat-deduction',
 'coefficients':{'referenceLevel':10,'powerPerLevel':.006,'armorPerLevel':.006,'armorNormalization':.45,'weaponRarePowerFloor':24,'healthBases':bases,'manaReference':'Mage MP=100+4*(level-1); Lv10=136; no INT/equipment'},
 'setBudgetFactor':1,'setBonuses':base['setBonuses'],
 'globalEffectRules':{**unique['globalRules'],'maxActiveShieldFraction':.12,'maxActiveReductionFraction':.10,'maxBonusFraction':.24,'maxHealFractionPerCooldown':.03,
   'maxManaRestoredPerCooldown':None,'maxManaRestoredFormula':'12+floor(0.2*level)',
   'bonusPolicy':'maximum 3 basic attacks or 2 magic casts; one first enemy each; 8s TTL; no refresh/charge accumulation',
   'categoryStrongestOnly':True,'categorySelectionScope':'eligible-triggers-only','bonusHitMustFollowTriggerCast':True},
 'staticValidation':{'sameLevelGradeComparisons':checks,'identicalCompatibleUniqueTriggerPairs':0,'changedStats':changed,'runtimeAcceptance':False},
 'items':items}
(ROOT/OUT).write_text(json.dumps(policy,ensure_ascii=False,indent=2)+'\n')

def fmt(s):
    return ' / '.join(f"{ {'power':'P','armor':'A','health':'HP','maxMana':'MP'}[k]} {v:g}" for k,v in s.items())
rows=[]
doc='''# 장비160종 재산정 전후 전체표

2026-11-05 · TLT-028/029/052/084 · [산정 근거·효과 계약](equipment-recalculation-2026-11-05.md)

현재 시험 제안: Rare10 / Epic20 / Legendary40 / Unique60. Unique60은 사용자 확정이며 나머지는 시험 기준이다. P=Power %p, A=고정 피해 차감. Unique의 이전 수치는 Lv10 참조이며 현재 수치는 Lv60 산정치다. 런타임 미반영.

| 이름 / 클래스 / 부위 | Lv 이전→현재 / 허용 난이도 | 기본 이전 → 재산정 | 재산정 +9 | 현재 효과 |
| --- | --- | --- | --- | --- |
'''
for i in items:
    cls=i['classId'] or 'shared'
    lv=f"{i['previous']['requiredLevel']} → {i['requiredLevel']}"
    effect_text=i['descriptionKoDev']
    doc+=f"| `{i['name']}` / {cls} / {i['slot']} | {lv} / {', '.join(i['allowedDifficulties'])} | {fmt(i['previous']['stats'])} → **{fmt(i['stats'])}** | {fmt(i['statsAtEnhancement9'])} | {effect_text} |\n"
    cells=[f'<img src="{i["icon"]}" loading="lazy" alt=""><b>{html.escape(i["name"])}</b><br>{cls} / {i["slot"]}',
           f'{lv}<br>'+', '.join(i['allowedDifficulties']),fmt(i['previous']['stats']),fmt(i['stats']),fmt(i['statsAtEnhancement9']),effect_text]
    rows.append('<tr>'+''.join('<td>'+c+'</td>' for c in cells)+'</tr>')
(ROOT/'docs/production/equipment-recalculated-160-2026-11-05.md').write_text(doc)
(ART/'recalculated-160.html').write_text('''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>장비160종 재산정</title><style>body{background:#172534;color:#eef4fa;font:14px/1.6 system-ui;margin:24px}a{color:#abd9ff}input{font:inherit;padding:10px;width:min(90%,600px)}table{border-collapse:collapse;min-width:1100px;width:100%;margin-top:16px}td,th{border:1px solid #526b82;text-align:left;vertical-align:top;padding:12px}td:first-child{min-width:220px;overflow-wrap:anywhere}td:last-child{min-width:350px}b{color:#ffdc91}img{width:56px;height:56px;object-fit:contain;float:left;margin-right:8px}</style><h1>장비160종 재산정 전후</h1><p>Rare Lv10 / Epic Lv20 / Legendary Lv40 / Unique Lv60 · Unique60은 확정, 나머지는 시험 제안. 현재 수치는 실전 테스트 대기이며 런타임 미반영입니다.</p><p>P: Power %p · A: 고정 피해 차감 · HP: 추가 체력 · MP: 최대 마나. 이전 Unique는 Lv10 참조치, 현재는 Lv60 재산정치. +9는 P/A/HP 27% 증가·MP 불변.</p><p><a href="../../../docs/production/equipment-recalculation-2026-11-05.md">산정 근거·효과·난이도·검증 한계</a> · <a href="catalog-160.html">이미지 목록</a></p><label>이름·등급·클래스·효과 검색 <input id="q" type="search" placeholder="Unique / mage / 보호막"></label> <span id="n" aria-live="polite"></span><div style="overflow:auto"><table><thead><tr><th>아이콘 / 이름 / 클래스</th><th>Lv 이전→현재 / 허용 난이도</th><th>이전 기본치</th><th>재산정 기본치</th><th>재산정 +9</th><th>재산정 효과</th></tr></thead><tbody>'''+''.join(rows)+'''</tbody></table></div><script>const q=document.querySelector('#q'),rows=[...document.querySelectorAll('tbody tr')];function apply(){let n=0;for(const r of rows){r.hidden=!r.textContent.toLowerCase().includes(q.value.trim().toLowerCase());if(!r.hidden)n++}document.querySelector('#n').textContent=n+' / 160'}q.addEventListener('input',apply);apply()</script></html>''')
print('PASS: recalculated 160; changed stats',changed,'; same-level comparisons',checks,'; compatible identical Unique triggers 0; runtime disabled')
