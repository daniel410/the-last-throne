"""ART 검토용 native RGB 청크를 PNG·접촉시트·해시로 복원한다(Pillow 필요)."""
from pathlib import Path
import argparse,hashlib,json,re
from PIL import Image,ImageDraw,ImageFont
import zstandard
p=argparse.ArgumentParser(description=__doc__);p.add_argument('log',type=Path);p.add_argument('output',type=Path);p.add_argument('--prefix',required=True);p.add_argument('--expected',type=int,required=True);a=p.parse_args()
meta={};chunks={};lines=a.log.read_text().splitlines()
for line in lines:
 if line.startswith(a.prefix+'_META '):
  row=json.loads(line.split(' ',1)[1]);assert row['index']not in meta,'duplicate frame';meta[row['index']]=row
 elif line.startswith(a.prefix+'_RGB '):
  _,i,data=line.split(' ',2);chunks.setdefault(int(i),[]).append(data)
assert len(meta)==a.expected,(len(meta),a.expected)
a.output.mkdir(parents=True,exist_ok=True);font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',14);manifest=[]
for index,row in sorted(meta.items()):
 raw=bytes.fromhex(''.join(chunks[index]))
 if row.get('encoding')=='zstd-hex':raw=zstandard.ZstdDecompressor().decompress(raw)
 assert len(raw)==row['width']*row['height']*3
 name=re.sub(r'[^a-zA-Z0-9_.-]+','_',str(row.get('kind',row.get('name',row.get('id',index)))));target=a.output/(f'{index:03}-'+name+'.png')
 Image.frombytes('RGB',(row['width'],row['height']),raw).save(target);row['file']=target.name;row['sha256']=hashlib.sha256(target.read_bytes()).hexdigest();manifest.append(row)
for page,start in enumerate(range(0,len(manifest),8),1):
 selected=manifest[start:start+8];width=640;height=max(round(r['height']*width/r['width'])for r in selected);sheet=Image.new('RGB',(width*2,(height+32)*4),(18,22,29));draw=ImageDraw.Draw(sheet)
 for i,row in enumerate(selected):
  x,y=i%2*width,i//2*(height+32);frame=Image.open(a.output/row['file']);frame=frame.resize((width,round(frame.height*width/frame.width)));sheet.paste(frame,(x,y+32))
  label=str(row['index'])+'. '+str(row.get('kind',row.get('name',row.get('id'))));label+=' / '+str(row.get('motif',row.get('shape','')));draw.text((x+5,y+5),label[:85],font=font,fill='white')
 sheet.save(a.output/f'sheet-{page:02}.png')
(a.output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('Decoded',len(manifest),'frames')
