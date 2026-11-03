"""Decode the authoring GLB independently and assemble native Selene acceptance."""
from pathlib import Path
import argparse,json,struct
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);args=p.parse_args()
raw=(ROOT/'assets/animations/selene-repair-v1/Selene-repaired.glb').read_bytes()
size=struct.unpack_from('<I',raw,12)[0];d=json.loads(raw[20:20+size]);binary=raw[28+size:]
skin=d['skins'][0];a=d['accessors'][skin['inverseBindMatrices']];v=d['bufferViews'][a['bufferView']]
fixtures=[]
for i,node in enumerate(skin['joints']):
 m=struct.unpack_from('<16f',binary,v.get('byteOffset',0)+a.get('byteOffset',0)+i*64)
 r=[[m[row*4+col] for col in range(3)] for row in range(3)]
 pos=[-sum(r[row][col]*m[12+col]for col in range(3))for row in range(3)]
 flip=[-1,1,-1]
 cf=[pos[j]*flip[j]for j in range(3)]+[r[row][col]*flip[row]*flip[col]for row in range(3)for col in range(3)]
 fixtures.append({'name':d['nodes'][node]['name'],'cf':cf})
text='local fixtures=game.HttpService:JSONDecode([==['+json.dumps(fixtures)+']==])\n'
for name in ['bones','motion','size']:
 text+='do\n'+(ROOT/f'tests/selene-{name}-native.luau').read_text()+'\nend\n'
args.output.write_text(text)
print(args.output)
