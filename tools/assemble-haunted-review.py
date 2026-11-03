"""Assemble unchanged pose renders into per-monster before/after review plates."""
from pathlib import Path
from PIL import Image,ImageDraw
import json,html,hashlib
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'docs/evidence/haunted-monster-review-20261103';records=json.load(open(folder/'before.json'))
notes={
 'Zombie':('도끼/오크용 큰 한팔 예고와 낮은 다리 대비 보폭.','작은 교차 보폭·어깨축과 짧은 손 뻗기/회수.','발 위쪽은 몸통에 포함되어 완전한 무릎 보행은 후속.'),
 'Skeleton':('검은 ArmL에 있는데 방패 팔을 크게 들어 공격.','검 팔/검 끝 소켓·해부학 어깨축·방패 가드·교차 보행.','기존 절단면/갑옷 조각의 완전 리스킨은 후속.'),
 'Ghoul':('팔·다리가 Body 한 조각인데 Ogre 동작을 참조해 준비와 타격의 차이가 작음.','낮은 전신 예고·전방 할퀴기 이동·실제 바닥 표면 기반 접지.','독립 팔다리/척추 리깅 없이 전신 동작 범위에서 개선.'),
 'Mummy':('다리가 몸통과 하나이며 팔 예고가 크고 체형과 맞지 않음.','짧은 양팔 뻗기·조심스러운 몸통 흔들기·실제 밑면 접지.','다리/붕대 독립 리그는 후속.'),
 'Hellhound':('Ice Wolf 피벗/보폭을 재사용해 체형·발 위치가 맞지 않음.','실제 네 다리 축·체형별 대각 보행·낮은 물기 준비/접촉/회수.','독립 목/턱/꼬리와 경사 IK는 후속.'),
 'SkeletonKnight':('검이 고정된 채 방패/보라 천이 크게 회전함.','검 팔로 내려베기·정확한 검 끝·낮은 방패 가드·짧은 지지 보폭.','같은 메시 안의 천/팔 분리와 절단면 최종 미술 수용은 후속.'),
 'DeathKnight':('팔/검이 Body에 있는데 Orc의 팔 공격을 참조해 무기가 거의 고정됨.','분리된 다리만 교차 보행·중량감 있는 상체 준비/접촉/회수.','팔/대검의 독립 관절은 원본에 없어 새 리깅 후속.'),
 'Lich':('지팡이·작은 손 조각과 몸통이 다른 앵커로 움직일 수 있음.','같은 몸통 축으로 접합 보존·몸통 시전·실제 지팡이 끝 충전 초점.','팔/손목/지팡이 완전 소유 메시 재제작은 후속.'),
 'LichSovereign':('시전 중 지팡이/옷 조각이 몸통에서 벌어짐.','팔 조각 고정·몸통 예고/시전·지팡이 끝 초점·실제 밑면 접지.','새 완전 팔/손목 리그를 만들었다고 주장하지 않음.'),
 'DreadCommander':('전신 일체형에 기존 Enraged Warlord의 작은 흔들림만 적용.','큰 체형에 맞춘 무거운 전신 예고·전방 타격·짧은 회수.','전신 일체형 원본을 유지하여 팔/발의 독립 동작은 후속.'),
 'Veyr':('Dread Commander와 같은 원본/동작으로 최종전 예고 구별이 약함.','같은 TD 외형을 보존하며 별도 더 넓은 회전 예고/회수 프로필.','보스 AI/서버 경고/단계 시각은 그대로이며 독립 전신 리그는 후속.'),
}
frames=[('Walk','0.25'),('Walk','0.75'),('Attack','0.4'),('Attack','0.62'),('Attack','0.78')];cards=[]
for row in records:
 kind=row['kind'];out=Image.new('RGB',(1500,660),'#182028');draw=ImageDraw.Draw(out)
 for stage_i,stage in enumerate(['before','after']):
  for i,(clip,phase)in enumerate(frames):
   im=Image.open(folder/kind/f'{stage}-{clip}-{phase}.png').convert('RGB').resize((300,300));out.paste(im,(i*300,stage_i*330));draw.text((i*300+6,stage_i*330+304),f'{kind} {stage} {clip} {phase}',fill='white')
 out.save(folder/f'{kind}-comparison.png');a,b,c=notes[kind]
 cards.append(f'<article id="{kind}"><h2>{kind}</h2><p>발견: {a}<br>개선: {b}<br>남은 한계: {c}</p><img src="{kind}-comparison.png" loading="lazy" alt="{kind} 수정 전후 보행과 공격"><p>위: 수정 전 / 아래: 수정 후. 보행0.25·0.75 / 준비0.4·서버 접촉0.62·회수0.78.</p></article>')
style='body{font:16px/1.6 system-ui;background:#182028;color:#eaf0f6;max-width:1550px;margin:auto;padding:24px}img{width:100%;height:auto}article{margin:30px 0;padding:16px;background:#26333f}a{color:#a8d9ff}nav{display:flex;gap:12px;flex-wrap:wrap}'
(folder/'index.html').write_text('<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Haunted Graveyard 몬스터 개별 동작 리뷰</title><style>'+style+'</style><h1>Haunted Graveyard 몬스터 개별 동작 리뷰</h1><p>2026-11-03 · TD 원본10종과 Dread Commander 외형을 공유하는 Veyr. 실제 로컬 Roblox MeshPart/Motor6D 행렬을 원본 GLB에 적용한 Blender 비교이며 직접 플레이 영상/실기기 수용과 구분합니다. 서버 타격·피해·보상·AI는 유지합니다.</p><nav>'+''.join(f'<a href="#{r["kind"]}">{r["kind"]}</a>'for r in records)+'</nav>'+''.join(cards)+'</html>')
files=['before.json','after.json','index.html']+[r['kind']+'-comparison.png'for r in records]
raw=sorted(folder.glob('*/*.png'))
(folder/'manifest.json').write_text(json.dumps({'capture':'actual local TD MeshParts + K0EnemyMotion Motor6D matrices; GLB vertices normalized to native bounds','species':10,'runtimeKinds':11,'rawPoseRenders':len(raw),'comparisonPlates':11,'published':False,'files':{str((folder/f).relative_to(folder)):hashlib.sha256((folder/f).read_bytes()).hexdigest()for f in files},'rawRenders':{str(p.relative_to(folder)):hashlib.sha256(p.read_bytes()).hexdigest()for p in raw}},indent=2)+'\n')
(folder/'review-notes.json').write_text(json.dumps(notes,ensure_ascii=False,indent=2)+'\n')
print('11 individual plates /',len(raw),'unchanged source renders')
