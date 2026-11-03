"""Assemble MR-01 review sheets from Blender renders (requires Pillow)."""
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/evidence/regional-casters-mr01-20261103'
for kind in ['QueenIceElf','VolcanoShaman','KingVolcanoShaman']:
 for view in ['front','side']:
  sheet=Image.new('RGB',(1320,4010),(22,27,35));draw=ImageDraw.Draw(sheet)
  draw.text((20,16),kind+' | '+view+' | top: 0.62.7 fixed arms / bottom: MR-01 candidate',fill='white')
  for row,clip in enumerate(['Attack','AttackAlt','Heavy','HeavyAlt']):
   for col,phase in enumerate([.4,.62,.78]):
    x=col*440;y=50+row*990;draw.text((x+10,y),clip+' / '+str(phase),fill='white')
    for offset,tag in [(25,'baseline-'),(505,'')]:
     image=Image.open(OUT/(kind+'-'+tag+clip+'-'+str(phase)+'-'+view+'.png')).convert('RGB');sheet.paste(image,(x,y+offset))
  sheet.save(OUT/(kind+'-'+view+'-comparison.jpg'),quality=88)
print('6 comparison sheets created')
