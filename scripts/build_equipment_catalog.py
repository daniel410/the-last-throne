"""Build the 160-icon equipment catalog from the existing authored metadata."""
import html
import json
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
ROOT = REPO / 'assets/concepts/2026-11-04-equipment-icons'
GRADES = {'Rare':'generated-rare-v1','Epic':'generated-v1','Legendary':'generated-legendary-v1','Unique':'generated-unique-v1'}
CLASSES = {None:'공통 · 모든 영웅', 'knight':'Knight · 기사 전용', 'elf':'Elf Archer · 엘프 궁수 전용', 'dwarf':'Dwarf Axe Thrower · 드워프 전용', 'mage':'Mage · 마법사 전용'}
SLOTS = {'weapon':'무기','offhand':'방패','head':'머리','body':'몸통','hands':'손','feet':'발','accessory':'장신구'}
manifest = json.loads((ROOT/'manifest.json').read_text())
families = sorted(manifest['families'], key=lambda f: (list(CLASSES).index(f['classId']), list(SLOTS).index(f['slot']), f['name']))
items = []
for grade, folder in GRADES.items():
    records = {r['familyId']:r for r in json.loads((ROOT/folder/'generation.json').read_text())['records']}
    for f in families:
        r=records[f['id']];d=r['displayMetadata'];assert d['rarity']==grade
        item={'number':len(items)+1,'rarity':grade,'classId':f['classId'],'classRestriction':CLASSES[f['classId']],'name':d['name'],'baseName':d['baseName'],'slot':f['slot'],'requiredLevel':d['requiredLevel'],'levelStatus':d['levelStatus'],'familyId':f['id'],'icon':folder+'/'+r['file'],'sha256':r['sha256']}
        assert (ROOT/item['icon']).is_file() and Path(item['icon']).stem==item['name']
        items.append(item)
assert len(items)==len({i['name'] for i in items})==160
assert Counter(i['rarity'] for i in items)=={g:40 for g in GRADES}
assert Counter(i['classId'] or 'shared' for i in items)=={'shared':44,'knight':32,'elf':28,'dwarf':28,'mage':28}
(ROOT/'catalog-160.json').write_text(json.dumps({'date':'2026-11-05','scope':'generated-art-catalog-not-runtime-item-count','counts':{'total':160,'byRarity':dict(Counter(i['rarity'] for i in items)),'byClass':dict(Counter(i['classId'] or 'shared' for i in items))},'items':items},ensure_ascii=False,indent=2)+'\n')
rows=[]
for i in items:
    e=html.escape;level='Lv60 · 확정' if i['rarity']=='Unique' else 'Lv10 · 시험안'
    rows.append(f'<tr data-rarity="{i["rarity"]}" data-class="{i["classId"] or "shared"}"><td>{i["number"]:03}</td><td><a href="{i["icon"]}" target="_blank" rel="noopener"><img loading="lazy" src="{i["icon"]}" alt="{e(i["baseName"])}"></a></td><td><span class="grade {i["rarity"]}">{i["rarity"]}</span></td><td>{e(i["classRestriction"])}</td><td><a class="name" href="{i["icon"]}" target="_blank" rel="noopener">{e(i["name"])}</a><small>{e(i["baseName"])}</small></td><td>{SLOTS[i["slot"]]}</td><td>{level}</td></tr>')
style='''*{box-sizing:border-box}body{margin:0;background:#14202c;color:#edf3fa;font:14px/1.5 system-ui}main{max-width:1500px;padding:24px;margin:auto}h1{margin:0 0 10px;font-size:28px}p{color:#c3d0df}a{color:#c2e0ff}.toolbar{display:flex;flex-wrap:wrap;gap:12px;align-items:center;background:#203245;padding:14px;border-radius:10px;margin:18px 0}select,input,button{padding:9px;border:1px solid #7188a1;border-radius:5px;background:#112231;color:#f2f6ff;font:inherit}input[type=search]{min-width:240px;flex:1}button{cursor:pointer}.summary{display:flex;flex-wrap:wrap;gap:8px}.summary span{padding:5px 12px;border:1px solid #526b86;border-radius:6px}table{width:100%;border-collapse:collapse;background:#1b2b3c}thead th{position:sticky;top:0;background:#293d51;z-index:1;text-align:left;white-space:nowrap}td,th{padding:10px 12px;border-bottom:1px solid #34495e}tbody tr:nth-child(even){background:#203246}tbody tr:hover{background:#2b435b}td:first-child{color:#a7bbce;font-variant-numeric:tabular-nums}td:nth-child(4),td:last-child{white-space:nowrap}img{width:48px;height:48px;object-fit:contain;vertical-align:middle}.name{display:block;overflow-wrap:anywhere;font-weight:600}small{display:block;color:#b5c7db}.grade{font-weight:700;padding:4px 9px;border:1px solid currentColor;border-radius:5px;white-space:nowrap}.Rare{color:#87bdff}.Epic{color:#c99aff}.Legendary{color:#ffbd77}.Unique{color:#ffe18a}.table-wrap{overflow-x:auto}#empty{padding:24px}[hidden]{display:none!important}@media print{body,table,tbody tr:nth-child(even){background:white;color:black}.toolbar,.intro-links{display:none}thead th{position:static;background:#eee;color:black}a,small,p,td:first-child{color:black}.grade{color:black}img{width:30px;height:30px}td,th{padding:4px;font-size:9px}main{padding:0}tr{break-inside:avoid}}'''
script='''const grade=document.querySelector('#rarity'),cls=document.querySelector('#class'),query=document.querySelector('#search'),common=document.querySelector('#common');const rows=[...document.querySelectorAll('tbody tr')];function apply(){let n=0;const q=query.value.trim().toLocaleLowerCase();for(const r of rows){const matchesGrade=grade.value==='all'||r.dataset.rarity===grade.value;const matchesClass=cls.value==='all'||r.dataset.class===cls.value||(common.checked&&cls.value!=='shared'&&r.dataset.class==='shared');r.hidden=!(matchesGrade&&matchesClass&&r.textContent.toLocaleLowerCase().includes(q));if(!r.hidden)n++}document.querySelector('#count').textContent=n+' / 160종 표시';document.querySelector('#empty').hidden=n!==0}for(const c of [grade,cls,common])c.addEventListener('change',apply);query.addEventListener('input',apply);document.querySelector('#reset').addEventListener('click',()=>{grade.value=cls.value='all';query.value='';common.checked=false;apply()});apply();'''
options=''.join(f'<option value="{g}">{g} · 40종</option>' for g in GRADES)
classOptions=''.join(f'<option value="{c or "shared"}">{label}</option>' for c,label in CLASSES.items())
page='<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>장비160종 · 등급 / 클래스 제한 / 이름</title><style>'+style+'</style><main><h1>장비 160종 통합 목록</h1><p>생성된 Rare·Epic·Legendary·Unique 각40종을 모두 펼친 목록입니다. 공통품은 네 플레이어 클래스 모두, 전용품은 표시된 기본 클래스에 종속됩니다. Common·Uncommon 기존 런타임 품목은 별도입니다.</p><p>Unique 최소 착용Lv60은 확정입니다. 다른 세 등급의Lv10은 시험값이며 등급별 최소레벨 확정이 아닙니다. 이미지 제작 목록과 실제 게임 등록·장착/효과 구현 수는 구분합니다.</p><p class="intro-links"><a href="comparison.html">등급별 이미지 비교</a> · <a href="catalog-160.json">동일 목록 JSON</a> · <a href="../../../docs/production/equipment-catalog-160-2026-11-05.md">문서 표</a></p><div class="summary"><span>Rare 40</span><span>Epic 40</span><span>Legendary 40</span><span>Unique 40</span><span>공통 44</span><span>Knight 32</span><span>Elf 28</span><span>Dwarf 28</span><span>Mage 28</span></div><div class="toolbar"><label>등급 <select id="rarity"><option value="all">전체 등급</option>'+options+'</select></label><label>클래스 제한 <select id="class"><option value="all">전체 클래스</option>'+classOptions+'</select></label><label><input type="checkbox" id="common"> 공통품도 포함</label><input type="search" id="search" aria-label="아이템 이름 검색" placeholder="아이템 이름·클래스 검색"><button id="reset">전체 보기</button><strong id="count" aria-live="polite">160 / 160종 표시</strong></div><div class="table-wrap"><table><caption hidden>장비160종의 등급, 영웅 클래스 제한, 이름과 이미지</caption><thead><tr><th scope="col">번호</th><th scope="col">아이콘</th><th scope="col">등급</th><th scope="col">영웅 클래스 제한</th><th scope="col">아이템 이름</th><th scope="col">부위</th><th scope="col">착용Lv</th></tr></thead><tbody>'+''.join(rows)+'</tbody></table><p id="empty" hidden>일치하는 아이템이 없습니다.</p></div></main><script>'+script+'</script></html>'
(ROOT/'catalog-160.html').write_text(page)
doc='''# 장비 160종 등급과 영웅 클래스 제한 목록

2026-11-05 · TLT-028/029/052/084 · PLAN/DES → ENG/QA

[160종 통합 화면](../../assets/concepts/2026-11-04-equipment-icons/catalog-160.html)에서 이미지·등급·클래스 제한·이름을 한 표로 확인하고 검색/필터할 수 있다. [동일 JSON](../../assets/concepts/2026-11-04-equipment-icons/catalog-160.json)은 generation.json과 manifest의 실제 메타데이터에서 생성했다. 아래 목록은 생성한 아이콘160종이며 게임에160종이 모두 구현됐다는 뜻은 아니다. 기존 Common/Uncommon 및 대장간의 별도 런타임 품목은 이160종에 합산하지 않는다.

| 구분 | Rare | Epic | Legendary | Unique | 합계 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 공통 · 모든 영웅 | 11 | 11 | 11 | 11 | 44 |
| Knight 전용 | 8 | 8 | 8 | 8 | 32 |
| Elf Archer 전용 | 7 | 7 | 7 | 7 | 28 |
| Dwarf Axe Thrower 전용 | 7 | 7 | 7 | 7 | 28 |
| Mage 전용 | 7 | 7 | 7 | 7 | 28 |
| 합계 | 40 | 40 | 40 | 40 | 160 |

클래스 전용은 기본 클래스 조건이며 두 전직 계열 중 하나만의 전용품이라는 뜻은 아니다. 공통 MP품은 착용 가능 클래스와 MP 보너스 적용 자격을 구분한다. Unique 착용Lv60은 사용자 확정이며 다른 세 등급의Lv10은 기존 시험안이다. Unique의 Lv60 능력치 재산정·게임 등록/효과/드롭 수용은 후속이다.

| 번호 | 등급 | 영웅 클래스 제한 | 이름 | 부위 | 착용Lv |
| --- | --- | --- | --- | --- | --- |
'''
for i in items:
    level='60 · 확정' if i['rarity']=='Unique' else '10 · 시험안'
    doc+=f'| {i["number"]:03} | {i["rarity"]} | {i["classRestriction"]} | `{i["name"]}` | {SLOTS[i["slot"]]} | {level} |\n'
doc+='''
검증: `python3 scripts/build_equipment_catalog.py`로160개 고유 이름·등급별40·클래스44/32/28/28/28·아이콘 파일과의 일치를 확인한다. `python3 scripts/validate_equipment_icon_assets.py`로 원본 이미지·해시·기존 보드 링크도 검사한다. 이 목록은 기존 아이템/이미지를 수정하지 않는 조회용 산출물이다. 실제 Roblox/실기기 검증은 이 작업 범위가 아니며 VERSION/빌드/릴리스 태그를 만들지 않는다. 다음 담당은 PLAN/DES의 품목 비교와 ENG의 실제 카탈로그 연결이다.
'''
(REPO/'docs/production/equipment-catalog-160-2026-11-05.md').write_text(doc)
print('PASS: 160 rows; Rare/Epic/Legendary/Unique 40 each; shared44/Knight32/Elf28/Dwarf28/Mage28; HTML/JSON/document generated')
