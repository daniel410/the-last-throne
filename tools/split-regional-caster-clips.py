"""Split the Studio export into per-clip modules below the 200 KB source limit."""
from pathlib import Path
import argparse,re
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True)
p.add_argument('--output',type=Path,default=Path(__file__).resolve().parents[1]/'src/client/RegionalCasterClips')
args=p.parse_args();source=args.source.read_text();root=args.output;root.mkdir(parents=True,exist_ok=True)
blocks=re.split(r'\["(QueenIceElf|VolcanoShaman|KingVolcanoShaman)"\]=\{\n',source)
assert len(blocks)==7,'Expected exactly three imported models'
init=['-- Actual Roblox import curves, split by clip to respect the script source limit.','return {']
for i in range(1,len(blocks),2):
 kind,text=blocks[i:i+2];folder=root/kind;folder.mkdir(exist_ok=True);init.append('["'+kind+'"]={')
 clips=re.findall(r'\["(\w+)"\]=\(function\(\) return (.*?) end\)\(\),\n',text,re.S)
 assert len(clips)==10 and len({name for name,_ in clips})==10
 for name,body in clips:
  module='-- Generated from v2 Roblox import.\nreturn '+body+'\n'
  assert len(module.encode())<200000
  (folder/(name+'.luau')).write_text(module)
  init.append('["'+name+'"]=require(script.'+kind+'.'+name+'),')
 init.append('},')
init.append('}');(root/'init.luau').write_text('\n'.join(init)+'\n')
print('30 imported clip modules')
