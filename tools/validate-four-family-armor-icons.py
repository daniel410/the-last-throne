"""Read-only pixel/provenance inspection. Run: uv run --with pillow python tools/validate-four-family-armor-icons.py"""
from pathlib import Path
from collections import Counter
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];base=ROOT/'assets/ui/four-family-armor-icons-v1'
m=json.loads((base/'manifest.json').read_text());rows=m['records'];up=json.loads((base/'uploaded.json').read_text())
assert len(rows)==32 and len({r['sha256']for r in rows})==32 and len(up)==32
assert Counter(r['family']for r in rows)=={'traveler':8,'tempered':8,'veteran':8,'sentinel':8}
assert len({r['definitionId']for r in rows})==24 and sum(r['visualClassId']is not None for r in rows)==8
report=[]
for r in rows:
 f=base/r['file'];assert hashlib.sha256(f.read_bytes()).hexdigest()==r['sha256']
 assert hashlib.sha256((ROOT/r['reference']).read_bytes()).hexdigest()==r['referenceSha256']
 u=next(u for u in up if u['id']==r['id']);assert u['done']and u['operation']['response']['assetId']==r['assetId']and u['operation']['response']['moderationResult']['moderationState']=='Approved'
 im=Image.open(f);assert im.mode=='RGBA'and im.width==im.height and im.width>=1024
 a=im.getchannel('A');hist=a.histogram();w,h=im.size;bounds=a.point(lambda v:255 if v>=128 else 0).getbbox()
 edgeMax=max(a.crop(rect).getextrema()[1]for rect in [(0,0,w,1),(0,h-1,w,h),(0,0,1,h),(w-1,0,w,h)])
 assert a.getextrema()==(0,255)and hist[0]/(w*h)>.4 and edgeMax<=1,(r['id'],edgeMax)
 assert bounds[0]>8 and bounds[1]>8 and bounds[2]<w-8 and bounds[3]<h-8,(r['id'],bounds)
 report.append(dict(file=r['file'],sha256=r['sha256'],size=list(im.size),minAlpha=0,maxAlpha=255,transparentPct=round(hist[0]*100/(w*h),2),semiPct=round(sum(hist[1:255])*100/(w*h),2),subjectBoundsAlpha128=list(bounds),maxEdgeAlpha=edgeMax))
 assert 'rbxassetid://'+r['assetId']in(ROOT/'src/shared/ItemSpriteAtlas.luau').read_text()
(base/'alpha-report.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: 32 distinct RGBA icons; 24 definitions + 8 head variants; 32 Approved uploads; source hashes; subject padding; edge alpha <=1 preserved unedited')
