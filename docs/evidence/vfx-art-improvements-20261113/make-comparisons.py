"""같은 장면 ID의 전후 접촉시트. 동일 시점/합성 수용을 대신하지 않는다."""
from pathlib import Path
import json,hashlib
from PIL import Image,ImageDraw,ImageFont
root=Path(__file__).resolve().parent
before=root.parent/'vfx-art-review-20261113'
font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',14)
records=[]
for family,baseline in [(n,before/n)for n in ['hero','common','enemy','enemy-rings','enemy-impacts','warnings']]+[('hero-final',root/'hero'),('warnings-final',root/'warnings'),('support-final',root/'common')]:
 old=baseline;new=root/family
 if not(new/'manifest.json').exists():continue
 a=json.loads((old/'manifest.json').read_text());b=json.loads((new/'manifest.json').read_text())
 def key(row):return str(row.get('id')or row.get('index'))
 lookup={key(r):r for r in a};rows=[]
 for row in b:
  prior=lookup.get(key(row))
  if not prior:continue
  def filename(r):return r.get('file',r.get('id','')+'.png')
  left=old/filename(prior);right=new/filename(row)
  if left.exists()and right.exists():rows.append((row,left,right))
 for start in range(0,len(rows),6):
  selected=rows[start:start+6];w,h=420,315
  sheet=Image.new('RGB',(w*2,(h+30)*len(selected)),(18,22,29));draw=ImageDraw.Draw(sheet)
  for i,(row,left,right)in enumerate(selected):
   y=i*(h+30)
   for side,path in enumerate([left,right]):
    im=Image.open(path).convert('RGB');im.thumbnail((w,h));sheet.paste(im,(side*w+(w-im.width)//2,y+30+(h-im.height)//2))
    title=('Before'if side==0 else'After')+' / '+str(row.get('id')or row.get('kind')or row.get('name'))
    draw.text((side*w+5,y+5),title[:60],font=font,fill='white')
  target=root/f'{family}-comparison-{start//6+1:02}.png';sheet.save(target)
  records.append({'file':target.name,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'ids':[r[0].get('id',r[0].get('index'))for r in selected]})
(root/'comparisons.json').write_text(json.dumps(records,indent=2)+'\n')
print('Comparison pages:',len(records))
