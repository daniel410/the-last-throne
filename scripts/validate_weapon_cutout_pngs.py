"""Inspect RGBA pixels without altering images; validate modeling reference PNGs."""
import struct,zlib,json
from pathlib import Path

def alpha_stats(p):
 b=p.read_bytes();pos=8;compressed=[]
 while pos<len(b):
  n=struct.unpack('>I',b[pos:pos+4])[0];typ=b[pos+4:pos+8];data=b[pos+8:pos+8+n];pos+=12+n
  if typ==b'IHDR':w,h,depth,color,comp,fil,inter=struct.unpack('>IIBBBBB',data)
  elif typ==b'IDAT':compressed.append(data)
 assert depth==8 and color==6 and inter==0,(depth,color,inter)
 raw=zlib.decompress(b''.join(compressed));stride=w*4;prior=bytearray(stride);idx=0;counts=[0]*256;box=[w,h,-1,-1];solid=[w,h,-1,-1];edge=0
 for y in range(h):
  filt=raw[idx];idx+=1;row=bytearray(raw[idx:idx+stride]);idx+=stride
  if filt:
   for x in range(stride):
    a=row[x-4] if x>=4 else 0;c=prior[x-4] if x>=4 else 0;bb=prior[x]
    if filt==1:v=a
    elif filt==2:v=bb
    elif filt==3:v=(a+bb)//2
    elif filt==4:
     pp=a+bb-c;pa=abs(pp-a);pb=abs(pp-bb);pc=abs(pp-c);v=a if pa<=pb and pa<=pc else bb if pb<=pc else c
    else:raise ValueError(filt)
    row[x]=(row[x]+v)&255
  for x,a in enumerate(row[3::4]):
   counts[a]+=1
   if a:
    box=[min(box[0],x),min(box[1],y),max(box[2],x),max(box[3],y)]
    if x in (0,w-1) or y in (0,h-1):edge+=1
   if a>=250:solid=[min(solid[0],x),min(solid[1],y),max(solid[2],x),max(solid[3],y)]
  prior=row
 return {'size':[w,h],'minAlpha':next(i for i,n in enumerate(counts) if n),'maxAlpha':max(i for i,n in enumerate(counts) if n),'transparentPct':round(counts[0]/(w*h)*100,2),'semiPct':round(sum(counts[1:255])/(w*h)*100,2),'nonzeroBounds':box,'opaqueBounds':solid,'edgeNonzero':edge}

if __name__ == '__main__':
 import argparse,hashlib
 from collections import Counter
 root=Path(__file__).resolve().parents[1]
 folder=root/'assets/concepts/2026-11-09-weapon-cutouts-v1'
 parser=argparse.ArgumentParser();parser.add_argument('--write-report',action='store_true');args=parser.parse_args()
 manifest=json.loads((folder/'manifest.json').read_text())
 assert len(manifest['records'])==16
 assert Counter(r['classId'] for r in manifest['records'])=={'knight':4,'elf':4,'dwarf':4,'mage':4}
 assert Counter(r['rarity'] for r in manifest['records'])=={'Rare':4,'Epic':4,'Legendary':4,'Unique':4}
 assert hashlib.sha256((root/manifest['approvedBaseline']).read_bytes()).hexdigest()==manifest['approvedBaselineSha256']
 result=[];hashes=set()
 for record in manifest['records']:
  path=folder/record['file'];data=path.read_bytes();sha=hashlib.sha256(data).hexdigest()
  assert sha==record['sha256'] and sha not in hashes;hashes.add(sha)
  assert hashlib.sha256((root/record['reference']).read_bytes()).hexdigest()==record['referenceSha256']
  stats=alpha_stats(path)
  assert stats['size']==[1024,1536]
  assert stats['minAlpha']==0 and stats['maxAlpha']>=250 and stats['transparentPct']>40
  left,top,right,bottom=stats['opaqueBounds'];width,height=stats['size']
  assert left>4 and top>4 and right<width-5 and bottom<height-5,(path,stats)
  result.append({'file':record['file'],'sha256':sha,**stats})
 if args.write_report:(folder/'alpha-report.json').write_text(json.dumps(result,indent=2)+'\n')
 else:assert result==json.loads((folder/'alpha-report.json').read_text())
 if (folder/'package.json').exists():
  import zipfile
  package=json.loads((folder/'package.json').read_text())
  archive=folder/package['file']
  assert hashlib.sha256(archive.read_bytes()).hexdigest()==package['sha256']
  with zipfile.ZipFile(archive) as zipped:
   assert zipped.testzip() is None
   assert sum(name.endswith('.png') for name in zipped.namelist())==16
   for record in manifest['records']:
    assert hashlib.sha256(zipped.read(Path(record['file']).name)).hexdigest()==record['sha256']
 print('PASS: 16 distinct 1024x1536 RGBA PNGs; 4 classes x 4 rarities; real zero-alpha background, near-opaque objects, no opaque clipping, immutable approved references; ZIP CRC and embedded PNG hashes')
