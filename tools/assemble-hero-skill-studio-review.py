"""Index untouched Studio screenshots, with CSS clipping for individual skill rows."""
from pathlib import Path
import csv,html,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'docs/evidence/hero-skills-studio-20261104'
rows=list(csv.DictReader((ROOT/'docs/evidence/hero-skills-20261104/skill-review.tsv').open(),delimiter='\t'))
notes={
 'knight':{'thrust':'검 축을 실제 전방으로 정렬. Play 전방 일치도0.998 / 검 끝은 발 위.','shield':'검·방패 소켓 검증을 마친 Shield Bash 곡선을 기술 시간에 맞춤. 회수 때 방패 팔 들림 보정.','counter':'기존 검 소켓에 맞춘 준비·접촉·회수 곡선으로 교체.','spin':'상체만360도 비트는 대신 시각 루트로 몸·다리를 함께 회전.','default':'검 끝이 발 아래로 떨어지던 고정 Euler 자세를 검증된 검 곡선으로 교체.'},
 'dwarf':{'shoot':'총구가 정면을 향하도록 손 소켓과 총신 축 보정. Play 전방 일치도0.989. 반동은 발사 뒤.','mortar':'포신/총구 축·나무 개머리판·금속 약실·가늠쇠·손잡이와 발사 후 반동.','lob':'폭탄을 든 손 자세와 투척/회수 구분. 장식 소품은 취소 시 제거.','shield':'도끼를 방어 자세로 거두고 어깨를 전방으로 기울임. 기사 방패 동작을 혼용하지 않음.','default':'도끼 전용 저작 곡선을 실제 접촉 시각에 맞춤. 지면 강타/투척/내려찍기 구분.'},
 'elf':{'rain':'지면 기술을25~40도 위로 겨냥해 곡사 준비/화살비 구분. 손·활·무기 회수를 함께 보정.','default':'기존 직선 사격/시위·노크·서버 확정 재장전을 검토하고 유지.'},
 'mage':{'default':'기존 지팡이6가족·원소 초점·반복 방출을 실제 모델/Play에서 검토하고 유지. 별도 신규 모션 수정 없음.'}}
sections=[];review=[]
for cls in ['knight','dwarf','elf','mage']:
 for i,row in enumerate(r for r in rows if r['class']==cls):
  index=i+1;first=(i//8)*8+1;local=i%8
  motion=row['motion'];note=notes[cls].get(motion,notes[cls]['default'])
  if row['geometry_review']=='retained':note='기존 기본 기술을 준비·접촉·회수 및 Play에서 검토. 이번 변경은 보존.'
  key=f'{cls}-{index:02d}';figs=[]
  for stage,title in [('before','수정 전'),('after','수정 후')]:
   image=f'{cls}-{first:02d}-{stage}.jpg';assert(folder/image).exists(),image
   # Original screenshots are preserved. Only the page viewport clips a row.
   figs.append(f'<figure><figcaption>{title} · 준비 / 접촉 / 회수</figcaption><div class="strip"><img loading="lazy" src="{image}" style="left:-660px;top:-{max(0,local*126+37)}px" alt="{html.escape(row["name"])} {title}"></div><a href="{image}">원본 전체 보기</a></figure>')
  sections.append(f'<article data-class="{cls}" id="{key}"><h2>{cls.upper()} {index:02d} · {html.escape(row["name"])}</h2><code>{row["skill_id"]}</code><p>{note}</p><div class="pair">'+''.join(figs)+'</div></article>')
  review.append(dict(classId=cls,index=index,id=row['skill_id'],name=row['name'],motion=motion,note=note,review='Studio native ready/contact/recovery + scripted Play',finalAcceptance='pending real combat/device/user art acceptance'))
style='''body{margin:0;background:#17202c;color:#e9edf2;font:16px/1.5 system-ui}main{max-width:1280px;margin:auto;padding:24px}nav{display:flex;gap:10px;position:sticky;top:0;background:#17202c;padding:12px;z-index:2}button{padding:10px 20px;background:#2c3d53;color:white;border:1px solid #69839c;border-radius:6px;cursor:pointer}article{padding:20px;margin:24px 0;background:#243247;border-radius:12px}h2{margin:0}code{color:#bdcce0}p{max-width:80ch}.pair{display:flex;gap:16px;flex-wrap:wrap}figure{margin:0}.strip{position:relative;width:590px;height:130px;overflow:hidden;background:#98d2e3}.strip img{position:absolute;width:1920px;height:1080px;max-width:none}figcaption{margin:8px 0}a{color:#a6d6ff}@media(max-width:650px){main{padding:8px}.strip{width:560px}.pair{overflow:auto}article{padding:10px}}'''
page='<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>영웅128스킬 Studio 개별 리뷰</title><style>'+style+'</style><main><h1>128개 스킬 · Studio 개별 비교</h1><p>0.69.1 대비 로컬 개선. 실제 R15 관절/무기 메시를 Studio에서 준비·접촉·회수 시점으로 평가한 화면입니다. 각 영웅32기술을 모두 순차 Play했습니다. 일반 아바타에 TD 색/무기를 적용한 검토 모델이며 최종 캐릭터 미술·일반 전투/모바일 수용과 구분합니다. 일부 섬광/예고는 촬영 시점에 따라 다릅니다.</p><nav>'+''.join(f'<button onclick="filterRows(\'{c}\')">{c.upper()}</button>' for c in ['all','knight','dwarf','elf','mage'])+'</nav>'+''.join(sections)+"</main><script>function filterRows(c){document.querySelectorAll('article').forEach(a=>a.hidden=c!=='all'&&a.dataset.class!==c)}filterRows('knight')</script></html>"
(folder/'index.html').write_text(page)
(folder/'individual-review.json').write_text(json.dumps(review,ensure_ascii=False,indent=2)+'\n')
(folder/'capture-manifest.json').write_text(json.dumps({'kind':'untouched native Studio viewport screenshots','baselineSource':'5bee9810904fa9206ffdead40028c8a343ec22b9','skills':128,'phases':3,'stageCount':2,'images':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(folder.glob('*.jpg'))}},indent=2)+'\n')
print('Indexed128skills /32 original Studio screenshots / CSS row views')
