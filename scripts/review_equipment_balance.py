"""Read-only audit of the 160 authored icons; never changes gameplay inputs."""
import hashlib
import html
import itertools
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets/concepts/2026-11-04-equipment-icons'
SOURCES = ['assets/balance/equipment-stats-plan-2026-11-04.json',
           'assets/balance/unique-equipment-plan-2026-11-05.json',
           'assets/concepts/2026-11-04-equipment-icons/catalog-160.json']
base, unique, catalog = [json.loads((ROOT / p).read_text()) for p in SOURCES]
lookup = {(i['rarity'], i['familyId']): i for i in base['items'] + unique['items']}
assert len(lookup) == 160
families = {f['familyId']: f for f in base['families']}

# Same event/conditions/category only: a conservative subset of all shared-CD conflicts.
pairs = []
for a, b in itertools.combinations(unique['items'], 2):
    if a['classId'] and b['classId'] and a['classId'] != b['classId']:
        continue
    if a['slot'] == b['slot'] and a['slot'] != 'accessory':
        continue
    if a.get('uniqueGroup') and a['uniqueGroup'] == b.get('uniqueGroup'):
        continue
    x, y = a['effect'], b['effect']
    if all(x[k] == y[k] for k in ('kind', 'event', 'conditions')):
        magnitude = {'shield':'maxHealthFraction', 'heal':'maxHealthFraction',
                     'reduction':'damageReductionFraction', 'bonus':'damageBonusFraction', 'mana':'flatMana'}[x['kind']]
        pairs.append({'items':[a['name'], b['name']], 'kind':x['kind'],
                      'values':[x[magnitude], y[magnitude]],
                      'finding':'동일 발동 조건·공유 범주: 큰 효과 우선, 동률은 definitionId로 선택. 동시 착용 시 한쪽 효과 가치 소실 위험.'})
conflicts = {}
for pair in pairs:
    a, b = pair['items']
    conflicts.setdefault(a, []).append(b)
    conflicts.setdefault(b, []).append(a)

def stats_text(stats):
    labels = {'power':'P', 'armor':'A', 'health':'HP', 'maxMana':'MP'}
    return ' / '.join(f'{labels[k]} {v:g}' for k, v in stats.items()) or '없음'

items = []
for art in catalog['items']:
    i = lookup[(art['rarity'], art['familyId'])]
    assert i['name'] == art['name'] and i['requiredLevel'] == art['requiredLevel']
    flags, actions = [], []
    grade = i['rarity']
    if grade == 'Unique':
        verdict = 'Lv60 재산정·효과 검증 전 출시 보류'
        flags.append('U60')
        actions.append('Lv10 참조치를 실전값으로 사용하지 말고 Lv60 동일 부위 Legendary보다 높은 기본치와 추가 효과로 재산정')
    elif grade == 'Legendary':
        verdict = '고난이도 보상 세대 재검토'
        flags.append('L-TIER')
        actions.append('Insane/Hell 보스·지역 장비 세대 확정 후 착용레벨·기본치 재산정; Lv10은 시험값')
    else:
        verdict = '기본 배분 조건부 유지'
        flags.append('SHOP-MAP')
        actions.append('Lv10 시험 배분 유지 가능; 신규 품목ID·Diamonds 가격·무료 보스 획득 경로를 별도로 연결')
    if i['stats'].get('maxMana', 0):
        flags.append('MP-RUNTIME')
        actions.append('서버 MP 합산·전투 최대MP·비교 화면 연결 전 등록 보류')
        if i['classId'] is None:
            flags.append('MP-CLASS')
            actions.append('공통 착용 유지; Mage/마법궁수 MP 자격 표시와 유효 보상 필터 검증')
        if not i['enhancementSupported']:
            flags.append('MP-ENHANCE')
            actions.append('순수 MP품 강화 미지원과 +9 MP 불변을 상세 화면에 명시')
    if i.get('setId'):
        flags.append('SET')
        actions.append('세트 -3% 배분과 2/4/5세트 효과를 함께 평가; 혼합등급 중복 집계 방지')
        f = families[i['familyId']]
        peers = [p for p in base['families'] if p['classId'] is None and p['slot'] == f['slot'] and p['commonEquivalentStats'] == f['commonEquivalentStats']]
        if peers:
            flags.append('SET-SINGLE')
            actions.append('동일 등급 공통품보다 단품 수치가 3% 낮음: 세트 활성 전 교체 손해 표시')
    if grade == 'Unique':
        e = i['effect']
        if conflicts.get(i['name']):
            flags.append('PROC-CONFLICT')
            actions.append('동시 착용 시 효과 선택 충돌: ' + ', '.join(conflicts[i['name']]) + '; 공유 상한 유지하면서 역할 차별화')
        if e['kind'] == 'mana':
            flags.append('PROC-MANA')
            actions.append(f"회복 {e['flatMana']}MP/{e['cooldownSeconds']}초: Lv60 소모량·MP 대비 효용 재검토")
        elif e['kind'] == 'bonus':
            flags.append('PROC-BASIC')
            actions.append('다음 기본공격 첫 대상 1회만 강화: 실제 공격 주기·다중 대상 효율 측정')
        elif e['kind'] == 'reduction':
            flags.append('PROC-UPTIME')
            actions.append('피격 후/회피 후 발동의 실효 유지율과 보스 연타 생존 개선 측정')
        else:
            flags.append('PROC-SURVIVAL')
            actions.append('효과 전 최대HP 기준·오버힐/보호막 손실·즉사·주기적 피해 제외 검증')
        if e['conditions'].get('skillId'):
            flags.append('PROC-LOADOUT')
            actions.append('지정 기본 스킬 미편성 시 고유 효과가 비활성임을 표시; 두 전직 계열 편성률 검토')
        if i['familyId'] == 'mage_hands_family':
            actions.append('마법 적중 후 기본공격을 요구하므로 주문 중심 빌드 적합성 낮을 수 있음; 주문용 대안 효과 검토')
    if i['slot'] == 'weapon':
        actions.append('Power는 피해 고정값이 아닌 보너스 %p: 기본 공격·스킬 계수와 함께 검증')
    if i['stats'].get('armor', 0):
        actions.append('Armor는 타격당 고정 차감: 잡몹 연타/보스 강타를 분리 검증')
    if i['stats'].get('health', 0):
        actions.append('동일 레벨 영웅 HP·VIT 배분 대비 생존 증가량 확인')
    items.append({**art, 'proposalId':i['proposalId'], 'candidateDefinitionId':i['candidateDefinitionId'],
        'stats':i['stats'], 'statsAtEnhancement9':i['statsAtEnhancement9'],
        'statReferenceTier':i.get('statReferenceTier', i['equipmentTier']),
        'effect':i.get('descriptionKoDev', '개별 고유 효과 없음; 세트 대상' if i.get('setId') else '개별 고유 효과 없음'),
        'effectDefinition':i.get('effect'), 'setId':i.get('setId'),
        'targetBossProposal':i.get('drop', {}).get('bossKind'),
        'targetRegionProposal':i.get('drop', {}).get('region'),
        'allowedDifficulties':i.get('drop', i.get('dropEligibility'))['allowedDifficulties'],
        'verdict':verdict, 'flags':flags, 'recommendations':actions,
        'runtimeStatus':'제안 품목; 실제 등록·드롭·가격 수용과 별도'})

for f in families:
    for stage in ('stats', 'statsAtEnhancement9'):
        r, e, l = [lookup[(g, f)][stage] for g in ('Rare', 'Epic', 'Legendary')]
        assert r.keys() == e.keys() == l.keys()
        assert all(r[k] < e[k] < l[k] for k in r)
assert len(items) == len({i['name'] for i in items}) == 160
assert Counter(i['rarity'] for i in items) == dict.fromkeys(('Rare','Epic','Legendary','Unique'), 40)
assert all(i['requiredLevel'] == 60 and i['allowedDifficulties'] == ['Hell'] for i in items if i['rarity'] == 'Unique')
assert all(i['allowedDifficulties'] == ['Insane','Hell'] for i in items if i['rarity'] == 'Legendary')
flag_counts = Counter(f for i in items for f in i['flags'])
result = {'date':'2026-11-05', 'workIds':['TLT-028','TLT-029','TLT-052','TLT-084'],
          'scope':'static-review-of-160-authored-proposals-not-combat-acceptance',
          'sources':{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in SOURCES},
          'counts':dict(Counter(i['rarity'] for i in items)), 'flagCounts':dict(flag_counts),
          'sameTriggerCompatibleUniquePairs':pairs, 'items':items}
(ROOT/'assets/balance/equipment-review-160-2026-11-05.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
md = '''# 160종 아이템별 성능 리뷰 표

2026-11-05 · TLT-028/029/052/084 · PLAN/DES → ENG/QA

[종합 리뷰](equipment-balance-review-2026-11-05.md) · [검색 가능한 아이콘 표](../../assets/concepts/2026-11-04-equipment-icons/review-160.html)

P=Power 보너스 %p, A=타격당 Armor, HP=추가 체력, MP=최대 마나. Unique 수치는 **Lv10 비교 참조치**이며 착용Lv60 실전값으로 승인되지 않았다. 다른 등급 Lv10도 시험안이다. +9는 P/A/HP 27% 증가, MP 불변. 허용 난이도는 드롭 활성화·확률 확정과 다르다. R/E/L에는 개별 고유 효과가 없으며 SET 표시는 세트 구현을 전제로 한다.

| # / 이름 | 등급 / 클래스 / 부위 | 착용Lv / 허용 난이도 | 기본 수치 → +9 | 효과 / 판정 / 수정 제안 |
| --- | --- | --- | --- | --- |
'''
rows = []
for i in items:
    level = '60 확정 / 수치 Lv10 참조' if i['rarity']=='Unique' else '10 시험안'
    action = ' · '.join(i['recommendations'])
    effect = i['effect']
    if i['targetBossProposal']:
        effect += ' / 목표 보스(제안): ' + i['targetBossProposal'] + ' · ' + i['targetRegionProposal']
    md += f"| {i['number']:03} `{i['name']}` | {i['rarity']} / {i['classRestriction']} / {i['slot']} | {level} / {', '.join(i['allowedDifficulties'])} | {stats_text(i['stats'])} → {stats_text(i['statsAtEnhancement9'])} | {effect}<br>**{i['verdict']}**<br>{', '.join(i['flags'])}<br>{action} |\n"
    esc=html.escape
    cells = [str(i['number']), f'<img loading="lazy" src="{esc(i["icon"])}" alt=""><b>{esc(i["name"])}</b>',
             esc(i['rarity']+' / '+i['classRestriction']+' / '+i['slot']),
             esc(level)+'<br>'+esc(', '.join(i['allowedDifficulties'])),
             esc(stats_text(i['stats']))+'<br>+9: '+esc(stats_text(i['statsAtEnhancement9'])),
             esc(effect)+'<br><b>'+esc(i['verdict'])+'</b><br>'+esc(', '.join(i['flags']))+'<br>'+esc(action)]
    rows.append('<tr>'+''.join('<td>'+c+'</td>' for c in cells)+'</tr>')
(ROOT/'docs/production/equipment-review-160-2026-11-05.md').write_text(md)
page = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>160종 장비 성능 리뷰</title><style>body{font:14px/1.6 system-ui;background:#172534;color:#edf3fa;margin:24px}a{color:#b7daff}input{font:inherit;padding:12px;width:min(90%,600px);margin:12px 0}table{border-collapse:collapse;width:100%;min-width:1000px}td,th{padding:12px;border:1px solid #4d6275;text-align:left;vertical-align:top}th{background:#2a4055}td:nth-child(2){min-width:230px;overflow-wrap:anywhere}td:nth-child(6){min-width:400px}img{width:64px;height:64px;object-fit:contain;float:left;margin-right:8px}.table{overflow:auto}b{color:#ffdc91}</style><h1>160종 장비 성능 리뷰</h1><p>2026-11-05 · 제안 데이터 정적 리뷰. Unique 착용Lv60 확정 / 표시 능력치는 Lv10 참조치이므로 재산정 필요. 다른 등급 Lv10은 시험값.</p><p>P: Power 보너스 %p · A: 고정 피해 차감 · HP: 추가 체력 · MP: 최대 마나. +9의 MP는 불변. 허용 난이도는 드롭 구현/확률 확정이 아닙니다.</p><p><a href="catalog-160.html">기존 목록</a> · <a href="../../../docs/production/equipment-balance-review-2026-11-05.md">종합 리뷰·우선순위·수용 조건</a></p><label>등급·클래스·이름·문제 코드 검색 <input id="q" type="search" placeholder="Unique / mage / PROC-CONFLICT / MP-RUNTIME"></label> <span id="n" aria-live="polite"></span><div class="table"><table><thead><tr><th>#</th><th>아이콘 / 이름</th><th>등급 / 클래스 / 부위</th><th>착용Lv / 허용 난이도</th><th>기본 → +9</th><th>효과 / 판정 / 제안</th></tr></thead><tbody>'''+''.join(rows)+'''</tbody></table></div><script>const rows=[...document.querySelectorAll('tbody tr')],q=document.querySelector('#q');function apply(){let n=0;for(const r of rows){r.hidden=!r.textContent.toLowerCase().includes(q.value.trim().toLowerCase());if(!r.hidden)n++}document.querySelector('#n').textContent=n+' / 160'}q.addEventListener('input',apply);apply()</script></html>'''
(ART/'review-160.html').write_text(page)
print('PASS: 160 rows; grade order/gates; flag counts:', dict(flag_counts))
print('Compatible Unique pairs with identical trigger:',len(pairs),'; affected items:',len(conflicts))
