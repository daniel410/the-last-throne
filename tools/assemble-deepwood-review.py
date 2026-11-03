from pathlib import Path
from PIL import Image,ImageDraw
import json
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'docs/evidence/deepwood-individual-review-20261102'
for stage in ['before','after']:
 for kind in json.loads((folder/'before.json').read_text()):
  files=[('Walk','0'),('Walk','0.25'),('Walk','0.5'),('Walk','0.75'),('Attack','0.4'),('Attack','0.62'),('Attack','0.78')]
  if not all((folder/kind/(stage+'-'+clip+'-'+phase+'.png')).exists()for clip,phase in files):continue
  out=Image.new('RGB',(1600,860),(43,49,56));draw=ImageDraw.Draw(out)
  for i,(clip,phase)in enumerate(files):
   img=Image.open(folder/kind/(stage+'-'+clip+'-'+phase+'.png')).resize((400,400));x=i%4*400;y=i//4*430
   out.paste(img,(x,y));draw.text((x+10,y+403),kind+' '+stage+' '+clip+' '+phase,fill='white')
  out.save(folder/(kind+'-'+stage+'.png'))
