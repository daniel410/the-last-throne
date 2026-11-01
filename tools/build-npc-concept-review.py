"""Generate the local review gallery; concept images remain unchanged."""
from pathlib import Path
import json,struct,hashlib

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/evidence/npc-heads-v4'
catalog=json.loads((ROOT/'assets/npcs/cast-v1/catalog.json').read_text())['characters']
profiles=json.loads((ROOT/'assets/npcs/heads-v4/profiles.json').read_text())
# Square inspection windows in the six original concept boards, in pixels.
crops={
 'aldric':(110,110,230),'mira':(365,105,235),'rowan':(610,75,235),'tessa':(860,100,250),'oren':(1115,105,245),'nia':(1700,245,230),
 'eryn':(90,0,260),'liora':(480,0,260),'tobin':(860,0,270),'pip':(1200,70,340),'fen':(1650,0,290),
 'freya':(80,30,270),'haldor':(475,110,290),'nessa':(845,25,280),'ivo':(1175,20,280),'ylva':(1510,35,300),
 'brann':(90,55,310),'dagna':(450,25,300),'orik':(865,55,300),'ketta':(1260,35,300),'suri':(1630,20,310),
 'maeve':(75,0,340),'finn':(520,15,300),'tali':(950,15,300),'wispkeeper':(1345,0,400),
 'lumi':(70,15,350),'garrick':(450,0,460),'elowen':(920,20,340),'rook':(1360,20,340),
}
changes={
 'aldric':'드워프 얼굴 폭, 높게 넘긴 붉은 머리, 연결된 긴 수염과 표면 결을 조정했습니다.',
 'mira':'짙은 옆가르마 단발의 길이와 옆면 웨이브, 금빛 귀걸이를 추가했습니다.',
 'rowan':'회색 짧은 머리와 가까이 깎은 수염으로 분리했습니다. 튀어나온 턱 부품은 제거했습니다.',
 'tessa':'높은 붉은 포니테일과 얼굴 옆으로 내려오는 곡선 가닥을 만들었습니다.',
 'oren':'민머리와 얇은 회색 옆머리, 짧고 연결된 흰 수염을 조정했습니다.',
 'nia':'아이 얼굴 비율과 옆가르마, 앞쪽으로 이어지는 세 갈래 땋기를 조정했습니다.',
 'eryn':'갈색 중간 길이 레이어와 뾰족한 엘프 귀의 길이/폭을 조정했습니다.',
 'liora':'은빛 굵은 땋은 머리를 어깨 앞쪽으로 옮겨 칼라에 끊기지 않게 했습니다.',
 'tobin':'균일한 앞머리 대신 불규칙한 검은 왕관 컬과 느슨한 끝가닥을 만들었습니다.',
 'pip':'사람형 헤어를 제거하고 넓고 낮은 녹색 얼굴과 큰 삼각 귀로 바꿨습니다.',
 'fen':'뒤로 물러난 흰 옆머리와 짧고 연결된 수염, 머릿결 표면을 조정했습니다.',
 'freya':'양쪽 흰 앞땋기와 곡선 가르마를 만들고 땋기를 가슴 앞쪽으로 연결했습니다.',
 'haldor':'회색 긴 수염에 앞쪽 땋기와 금빛 묶음을 추가하고 얼굴 폭을 조정했습니다.',
 'nessa':'높게 묶은 어두운 곱슬 번과 양쪽 느슨한 관자놀이 가닥을 추가했습니다.',
 'ivo':'짧고 풍성한 검은 윗머리 컬과 불규칙한 앞가닥을 추가했습니다.',
 'ylva':'금발 옆가르마와 굵은 앞땋기, 뾰족한 귀를 조정했습니다.',
 'brann':'높은 붉은 가르마와 긴 수염, 앞쪽 땋기 및 금빛 묶음을 추가했습니다.',
 'dagna':'높은 검은 번, 고글, 느슨한 양옆 가닥과 금빛 귀걸이를 추가했습니다.',
 'orik':'안전모와 작업등을 만들고 모자 착용 높이 및 닫힌 정수리 형상을 교정했습니다.',
 'ketta':'짧은 공통 헤어를 짙은 웨이브 단발과 옆가르마, 귀걸이로 바꿨습니다.',
 'suri':'은빛 단발의 길이와 웨이브 및 귀걸이를 조정했습니다.',
 'maeve':'은빛 옆가르마 단발과 뾰족한 귀의 비율을 조정했습니다.',
 'finn':'붉은 머리에 불규칙한 컬과 느슨한 앞가닥을 추가했습니다.',
 'tali':'높은 검은 번과 긴 관자놀이 가닥, 엘프 귀를 조정했습니다.',
 'wispkeeper':'긴 은빛 레이어를 어깨 앞으로 이어 붙이고 갈라진 가지/잎 관을 만들었습니다.',
 'lumi':'짧은 공통 헤어를 높은 흰 곱슬 번과 양쪽 느슨한 가닥으로 바꿨습니다.',
 'garrick':'높은 모자와 넓은 챙을 만들고 이마에 맞도록 착용 높이를 교정했습니다.',
 'elowen':'굵은 은빛 앞땋기와 금빛 잎 서클릿, 귀걸이를 추가했습니다.',
 'rook':'풍성한 검은 컬과 얕은 수염을 적용하고 점처럼 튀어나온 턱 부품을 제거했습니다.',
}
entries=[]
for c in catalog:
 if c['id']=='selene':continue
 ident=c['id'];region=c['region'];board=ROOT/f'assets/concepts/2026-10-31-npc-cast-v1/{region}.png'
 width,height=struct.unpack('>II',board.read_bytes()[16:24])
 assert (OUT/'portraits'/f'{ident}.png').is_file()
 entries.append({'id':ident,'name':c['name'],'region':region,'crop':crops[ident],'boardSize':[width,height],
  'concept':f'../../../assets/concepts/2026-10-31-npc-cast-v1/{region}.png','portrait':f'portraits/{ident}.png',
  'previous':f'../npc-faces-v3/after/page-{len(entries)//5+1}.png','previousColumn':len(entries)%5,
  'change':changes[ident],'profile':profiles[ident],
  'reviewed':['concept board','isolated front','isolated 60 degree'],
  'remaining':'매끈한 분할 형상과 일부 연결선/원화의 미세 모발 표현 차이는 남아 있습니다. 최종 사용자 수용 및 실기기 성능은 후속입니다.'})
(OUT/'review.json').write_text(json.dumps({'version':4,'characters':entries,'userAccepted':False,'excluded':['selene']},ensure_ascii=False,indent=2)+'\n')
page='''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>NPC 컨셉 대조 v4</title>
<style>*{box-sizing:border-box}body{margin:0;background:#151922;color:#e9edf4;font:16px/1.6 system-ui}main{max-width:1500px;margin:auto;padding:26px}h1{font-size:28px;margin:0}small,.muted{color:#aab6c9}nav{display:flex;flex-wrap:wrap;gap:7px;margin:22px 0}button{border:1px solid #596277;background:#242c3a;color:#edf1f6;border-radius:8px;padding:8px 13px;cursor:pointer}button.active{border-color:#e3b96f;background:#4a3b27}.layout{display:grid;grid-template-columns:minmax(240px,1fr) minmax(480px,2fr);gap:20px}.panel{background:#202734;border:1px solid #364256;border-radius:12px;padding:16px;overflow:hidden}h2{margin:0 0 8px}.crop{position:relative;aspect-ratio:1;overflow:hidden;background:#333}.crop img{position:absolute;max-width:none;height:auto}#portrait{display:block;width:100%;height:auto}.bar{display:flex;justify-content:space-between;align-items:center;gap:15px}.change{padding:16px;border-left:3px solid #dbb66d;background:#282a30;margin-top:18px}details{margin-top:18px}#previous{margin-top:10px;max-width:520px}a{color:#f4cf87}@media(max-width:800px){.layout{grid-template-columns:1fr}main{padding:14px}}</style>
<main><h1>NPC 29명 · 컨셉 대조 v4</h1><small>셀린느 제외 · 블록 몸체 유지 · 로컬 교정본 / 미게시 · 정면과 60도 측면</small><nav id="nav"></nav><div class="bar"><h2 id="name"></h2><div><button id="prev">← 이전</button> <button id="next">다음 →</button></div></div>
<div class="layout"><section class="panel"><h2>기존 컨셉</h2><div class="crop" id="conceptCrop"><img id="concept" alt="기존 컨셉 얼굴 확대"></div><a id="boardLink" target="_blank">전체 컨셉 보기</a></section><section class="panel"><h2>현재 Blender 교정본</h2><img id="portrait" alt="현재 NPC 정면 및 측면"><small>몸체는 위치 확인용 어깨 셸입니다. 실제 게임은 기존 복장과 소품을 유지합니다.</small></section></div><p class="change" id="change"></p><p class="muted" id="remaining"></p>
<details><summary>수정 전 v3 정면 보기</summary><div class="crop" id="previous"><img id="previousImage" alt="수정 전 얼굴"></div></details><p><a href="README.md">검증 기록</a> · 방향키로 인물 이동</p></main>
<script>const data=__DATA__;let current=0;const nav=document.getElementById('nav');data.forEach((e,i)=>{const b=document.createElement('button');b.textContent=e.name;b.onclick=()=>show(i);nav.append(b)});function show(i){current=(i+data.length)%data.length;const e=data[current];document.getElementById('name').textContent=`${current+1} / ${data.length} · ${e.name} · ${e.region}`;[...nav.children].forEach((b,i)=>b.classList.toggle('active',i===current));const image=document.getElementById('concept');image.src=e.concept;const [x,y,size]=e.crop;image.style.width=(e.boardSize[0]/size*100)+'%';image.style.left=(-x/size*100)+'%';image.style.top=(-y/size*100)+'%';document.getElementById('boardLink').href=e.concept;document.getElementById('portrait').src=e.portrait;document.getElementById('change').textContent=e.change;document.getElementById('remaining').textContent=e.remaining;const old=document.getElementById('previousImage');old.src=e.previous;old.style.width='500%';old.style.left=(-e.previousColumn*100)+'%';old.style.top='-16.66%';history.replaceState(null,'','#'+e.id)}document.getElementById('prev').onclick=()=>show(current-1);document.getElementById('next').onclick=()=>show(current+1);document.addEventListener('keydown',e=>{if(e.key==='ArrowLeft')show(current-1);if(e.key==='ArrowRight')show(current+1)});show(Math.max(0,data.findIndex(e=>e.id===location.hash.slice(1))));</script></html>'''
(OUT/'index.html').write_text(page.replace('__DATA__',json.dumps(entries,ensure_ascii=False)))
asset=ROOT/'assets/npcs/heads-v4'
files={str(p.relative_to(ROOT)):{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in sorted(asset.iterdir()) if p.is_file() and p.name not in ('manifest.json',) and not p.name.endswith('.blend1')}
(asset/'manifest.json').write_text(json.dumps({'version':4,'sourceConceptManifest':'assets/concepts/2026-10-31-npc-cast-v1/manifest.json','hairSurface':'rbxassetid://100424123930098','faceOverrides':{'rowan':'rbxassetid://80058755053302','rook':'rbxassetid://123904750786988'},'hairTextureGenerator':'built-in image_gen','faces':'original v3 crops; Rowan/Rook stubble painted with Blender pixels','geometry':'Blender-authored curve segment frames and accessory triangles','files':files},indent=2)+'\n')
print('Wrote 29-person concept/current/previous review gallery and provenance manifest')
