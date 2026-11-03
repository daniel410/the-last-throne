"""Host-side safe Blender MCP payload builder; never asks Blender to exec/open files."""
from pathlib import Path
import argparse,json
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--stage',choices=['before','after'],required=True);p.add_argument('--kind',required=True);p.add_argument('--output',type=Path,required=True);args=p.parse_args()
folder=ROOT/'docs/evidence/haunted-monster-review-20261103';record=next(r for r in json.load(open(folder/(args.stage+'.json')))if r['kind']==args.kind)
manifest=json.load(open(ROOT/'assets/shared/td-haunted-graveyard/manifest.json'));source=ROOT.parent/'throne-defense/assets/models/meshy-blocky-monsters-v1/runtime'/manifest['models'][args.kind]['template']/'textured-review.glb'
(folder/args.kind).mkdir(exist_ok=True)
body=(ROOT/'tools/review-deepwood-model-blender.py').read_text().replace("scene.render.engine='BLENDER_WORKBENCH';", "try:\n scene.render.engine='BLENDER_WORKBENCH'\nexcept TypeError as e:\n print('Available render engines',str(e));raise\n")
header='import bpy,json\nactive_scene_before_review=bpy.context.window.scene\nREVIEW=json.loads('+repr(json.dumps(record))+')\nREVIEW_STAGE='+repr(args.stage)+'\nSOURCE='+repr(str(source))+'\nREVIEW_OUT='+repr(str(folder/args.kind))+'\n'
args.output.write_text(header+'try:\n'+'\n'.join(' '+line for line in body.splitlines())+'\nfinally:\n bpy.context.window.scene=active_scene_before_review\n')
print(args.output)
