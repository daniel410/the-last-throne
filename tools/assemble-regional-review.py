"""Native-matrix Blender contact sheets; generated PNGs are review evidence, not client acceptance."""
from pathlib import Path
from PIL import Image,ImageDraw
import json,html,hashlib
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'docs/evidence/regional-monster-review-20261103';records=json.loads((folder/'before.json').read_text());cards=[]
frames=[('Walk','0.25'),('Walk','0.75'),('Attack','0.4'),('Attack','0.62'),('Attack','0.78')]
for record in records:
 kind=record['kind'];out=Image.new('RGB',(1750,750),'#202830');draw=ImageDraw.Draw(out)
 for row,stage in enumerate(['before','after']):
  for col,(clip,phase)in enumerate(frames):
   im=Image.open(folder/kind/f'{stage}-{clip}-{phase}.png').convert('RGB').resize((350,350));out.paste(im,(col*350,row*375));draw.text((col*350+10,row*375+350),f'{kind} {stage} {clip} {phase}',fill='white')
 out.save(folder/f'{kind}-comparison.png');cards.append(f'<article id="{kind}"><h2>{html.escape(kind)}</h2><img loading="lazy" src="{kind}-comparison.png" alt="{kind} 수정 전후 보행·공격 비교"><p>윗줄: 수정 전 / 아랫줄: 수정 후. 보행 0.25·0.75, 공격 준비 0.4·접촉 0.62·회수 0.78.</p></article>')
style='body{background:#182028;color:#e8eef5;font:16px/1.6 system-ui;margin:auto;max-width:1500px;padding:24px}article{margin:32px 0;padding:16px;background:#26333f}img{width:100%;height:auto}a{color:#a8d9ff}select{font:inherit}'
(folder/'index.html').write_text('<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Frozen Vale · Ember Caldera 몬스터 동작 리뷰</title><style>'+style+'</style><h1>Frozen Vale · Ember Caldera 몬스터 20종</h1><p>2026-11-03 · 실제 로컬 리그 행렬을 적용한 Blender 자세 비교. 서버 판정·보상은 유지. 실기기·게시 클라이언트·최종 미술 수용은 미검증.</p><p>Queen Ice Elf·Volcano Shaman·King Volcano Shaman은 분할된 지팡이/옷 접합을 유지하도록 팔을 고정하고 몸통으로 시전합니다. 완전한 팔/손목 독립 리깅은 후속입니다. 임프 날개는 여전히 팔과 같은 원본 메시입니다.</p><label>종 선택 <select onchange="location.hash=this.value">'+''.join(f'<option>{r["kind"]}</option>'for r in records)+'</select></label>'+''.join(cards)+'</html>')
files=['before.json','after.json','index.html']+[r['kind']+'-comparison.png'for r in records]
(folder/'manifest.json').write_text(json.dumps({'capture':'actual local TD MeshParts and K0EnemyMotion motor matrices; original GLB vertices normalized to native sizes','reviewScript':'tools/review-deepwood-model-blender.py','species':20,'rawPoseRenders':280,'published':False,'files':{n:hashlib.sha256((folder/n).read_bytes()).hexdigest()for n in files}},indent=2)+'\n')
print('20 per-species comparisons / 280 source renders')
