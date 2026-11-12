"""Studio 엔진 RGB 청크를 개별 PNG·검토용 contact sheet로 복원한다(Pillow 필요)."""
from pathlib import Path
import argparse,json,hashlib
from PIL import Image,ImageDraw,ImageFont

def sheets(output,meta):
 font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',14)
 for cls in ['knight','dwarf','elf','mage']:
  rows=[r for r in meta.values()if r['classId']==cls]
  for page in range(2):
   target=output/(cls+'-'+str(page+1)+'.png')
   selected=rows[page*16:page*16+16]
   if not selected:target.unlink(missing_ok=True);continue
   sheet=Image.new('RGB',(1280,1104),(18,22,29));draw=ImageDraw.Draw(sheet)
   for slot,row in enumerate(selected):
    x,y=slot%4*320,slot//4*276
    sheet.paste(Image.open(output/(row['id']+'.png')),(x,y+32))
    draw.text((x+5,y+2),str((row['index']-1)%32+1)+'. '+row['name'],font=font,fill=(240,240,240))
   sheet.save(target)

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('log',type=Path);p.add_argument('output',type=Path)
 p.add_argument('--allow-partial',action='store_true');p.add_argument('--refresh-sheets',action='store_true');a=p.parse_args()
 a.output.mkdir(parents=True,exist_ok=True)
 if a.refresh_sheets:meta={r['index']:r for r in json.loads((a.output/'manifest.json').read_text())}
 else:
  meta={};chunks={}
  with a.log.open()as f:
   for line in f:
    if line.startswith('VFX_META '):
     row=json.loads(line[9:]);meta[row['index']]=row
    elif line.startswith('VFX_RGB '):
     _,idx,data=line.strip().split(' ',2);chunks.setdefault(int(idx),[]).append(data)
  assert a.allow_partial or len(meta)==128,('incomplete captures',len(meta))
  meta={idx:r for idx,r in meta.items()if len(''.join(chunks.get(idx,[])))==r['width']*r['height']*6}
  for idx,row in meta.items():
   raw=bytes.fromhex(''.join(chunks[idx]));assert len(raw)==row['width']*row['height']*3,(idx,len(raw))
   target=a.output/(row['id']+'.png');Image.frombytes('RGB',(row['width'],row['height']),raw).save(target)
   row['sha256']=hashlib.sha256(target.read_bytes()).hexdigest()
  (a.output/'manifest.json').write_text(json.dumps(list(meta.values()),indent=2)+'\n')
 sheets(a.output,meta);print('Processed',len(meta),'skill frames')
if __name__=='__main__':main()
