"""Studio의 무손실 zstd RGB 캡처를 PNG·GIF·MP4로 복원한다(Pillow/zstandard/imageio-ffmpeg)."""
from pathlib import Path
import argparse,base64,json,re,subprocess
from PIL import Image,ImageDraw,ImageFont
import zstandard
import imageio_ffmpeg
p=argparse.ArgumentParser();p.add_argument('log',type=Path);p.add_argument('output',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
meta={};chunks={}
for line in a.log.read_text().splitlines():
 if line.startswith('SPELL_ART_META '):
  row=json.loads(line[15:]);meta[row['index']]=row
 elif line.startswith('SPELL_ART_FRAME '):
  _,i,s=line.split(' ',2);chunks.setdefault(int(i),[]).append(s)
assert len(meta)==18,('incomplete capture',len(meta))
frames=[]
w,h=meta[1]['width'],meta[1]['height']
font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',12)
for i,row in sorted(meta.items()):
 data=zstandard.ZstdDecompressor().decompress(bytes.fromhex(''.join(chunks[i]))if row.get('encoding')=='zstd-hex'else base64.b64decode(''.join(chunks[i])))
 assert len(data)==row['width']*row['height']*3
 im=Image.frombytes('RGB',(row['width'],row['height']),data);im.save(a.output/f'{i:02d}.png')
 fr=Image.new('RGB',(w,h+28),(20,25,32));fr.paste(im,(0,28));ImageDraw.Draw(fr).text((10,6),f"{row['case']} | {row['phase']} | {row['age']:.2f}s",font=font,fill=(235,239,245));frames.append(fr)
rows=list(meta.values());durations=[max(30,min(800,round((rows[min(i+1,len(rows)-1)].get('clock',0)-r.get('clock',0))*1000)))for i,r in enumerate(rows)];durations[-1]=150
frames[0].save(a.output/'review.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,optimize=False)
selection=[2,6,9,12,14,16];sheet=Image.new('RGB',(w*3,(h+28)*2),(20,25,32))
for j,i in enumerate(selection):sheet.paste(frames[i-1],(j%3*w,j//3*(h+28)))
sheet.save(a.output/'timing.png')
(a.output/'frames.json').write_text(json.dumps(list(meta.values()),indent=2)+'\n')
ff=imageio_ffmpeg.get_ffmpeg_exe()
subprocess.run([ff,'-y','-framerate','9','-i',str(a.output/'%02d.png'),'-c:v','libx264','-pix_fmt','yuv420p','-vf','pad=ceil(iw/2)*2:ceil(ih/2)*2',str(a.output/'review.mp4')],capture_output=True,check=True)
print('decoded frames',len(frames))
