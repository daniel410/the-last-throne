"""콘셉트 원본·Blender 기하/GLB·런타임 대응을 정적으로 검사한다."""
from pathlib import Path
import json,struct,zlib,hashlib,math,html
ROOT=Path(__file__).resolve().parents[1]
CONCEPT=ROOT/'assets/concepts/2026-11-13-regional-epic-stories-v1'
MODEL=ROOT/'assets/models/regional-architecture-blender-v1'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def png(p):
 data=p.read_bytes();assert data[:8]==b'\x89PNG\r\n\x1a\n';pos=8;packed=b'';header=None
 while pos<len(data):
  size=struct.unpack('>I',data[pos:pos+4])[0];kind=data[pos+4:pos+8];chunk=data[pos+8:pos+8+size];crc=struct.unpack('>I',data[pos+8+size:pos+12+size])[0]
  assert zlib.crc32(kind+chunk)&0xffffffff==crc
  if kind==b'IHDR':header=struct.unpack('>IIBBBBB',chunk)
  if kind==b'IDAT':packed+=chunk
  pos+=size+12
  if kind==b'IEND':break
 assert pos==len(data)and header
 w,h,depth,color,comp,filt,interlace=header;assert depth==8 and interlace==0
 channels={0:1,2:3,4:2,6:4}[color];raw=zlib.decompress(packed);stride=w*channels+1
 assert len(raw)==h*stride and all(raw[i*stride]<=4 for i in range(h))
 return [w,h]
request=json.loads((CONCEPT/'prompts.json').read_text());rows=json.loads((CONCEPT/'stories.json').read_text());assets=request['assets'];assert len(assets)==40
assert len({a['id']for a in assets})==40 and len(rows)==36
manifest={'date':'2026-11-13','task':'TLT-062/063/064/065/regional-concept-map','mode':'built-in image_gen','counts':{'epics':4,'main':28,'optional':8,'images':40,'physicalZones':34},'assets':[],'unverified':['최종 사용자 미술 수용','게시/실기기','콘셉트 전체 지형/높이의 일대일 구현']}
seen=set()
for a in sorted(assets,key=lambda a:(a['epic'],a['id'])):
 p=CONCEPT/(a['id']+'.png');dims=png(p);digest=sha(p);assert digest not in seen;seen.add(digest)
 refs=[{'file':str(Path(r).relative_to(ROOT)),'sha256':sha(Path(r))}for r in a.get('references',[])]
 if a['epic']==2:assert refs and 'gloamwood-environment.png'in refs[0]['file']
 manifest['assets'].append({'id':a['id'],'title':a['title'],'file':p.name,'kind':a['kind'],'dimensions':dims,'sha256':digest,'references':refs,'source':a['source'],'promptKey':a['id']})
(CONCEPT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
parts=json.loads((MODEL/'kit.json').read_text())['models'];assert len(parts)==34
max_error=0
for kind,items in parts.items():
 assert items
 for p in items:
  assert len(p['cf'])==12 and len(p['size'])==3 and all(math.isfinite(v)and v>0 for v in p['size'])
  R=[p['cf'][3+i*3:6+i*3]for i in range(3)]
  for i in range(3):
   for j in range(3):max_error=max(max_error,abs(sum(R[i][k]*R[j][k]for k in range(3))-(i==j)))
assert max_error<1e-6
raw=(MODEL/'RegionalStoryArchitecture.glb').read_bytes();magic,version,length=struct.unpack('<III',raw[:12]);assert magic==0x46546c67 and version==2 and length==len(raw)
size,kind=struct.unpack('<II',raw[12:20]);assert kind==0x4e4f534a;gltf=json.loads(raw[20:20+size]);assert len(gltf['meshes'])==sum(map(len,parts.values()))
model_report={'models':len(parts),'parts':sum(map(len,parts.values())),'byModel':{k:len(v)for k,v in parts.items()},'maxRotationOrthonormalError':max_error,'glbMeshes':len(gltf['meshes']),'glbSha256':sha(MODEL/'RegionalStoryArchitecture.glb'),'kitSha256':sha(MODEL/'kit.json'),'colorManagement':'Standard/sRGB/None/Exposure0/Gamma1/CurvesOff'}
(MODEL/'validation.json').write_text(json.dumps(model_report,indent=2)+'\n')
cards=[]
for a in manifest['assets']:
 cards.append('<article><a href="'+a['file']+'"><img loading="lazy" src="'+a['file']+'" alt="'+html.escape(a['title'])+'"></a><h2>'+a['id']+' · '+html.escape(a['title'])+'</h2></article>')
(CONCEPT/'index.html').write_text('<!doctype html><html lang="ko"><meta charset="utf-8"><title>Regional Story Concepts</title><style>body{margin:32px;background:#111b2b;color:#e7e3d3;font:16px system-ui}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(420px,1fr));gap:22px}img{width:100%;border-radius:8px}h2{font-size:17px}article{margin:0}a{color:#e5c178}</style><h1>다음 4개 에픽 · 스토리 콘셉트 40장</h1><p>Gloamwood는 기존 Silken Dark 원본 참조. 콘셉트와 실제 구현 화면은 별도 검증합니다.</p><main>'+''.join(cards)+'</main></html>')
print(json.dumps({'images':len(seen),'models':len(parts),'parts':model_report['parts'],'rotationError':max_error,'status':'PASS'}))
