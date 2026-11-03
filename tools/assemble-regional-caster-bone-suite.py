"""Build a local Roblox Bone contract runner from independently decoded GLBs."""
from pathlib import Path
import argparse,json
ROOT=Path(__file__).resolve().parents[1]
def luau(value):
 if isinstance(value,dict):return '{'+','.join('['+json.dumps(k)+']='+luau(v)for k,v in value.items())+'}'
 if isinstance(value,list):return '{'+','.join(luau(v)for v in value)+'}'
 return json.dumps(value)
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);args=p.parse_args()
fixture=json.loads((ROOT/'assets/animations/regional-casters-v1/bone-fixture.json').read_text())
args.output.write_text('local fixtures='+luau(fixture)+'\n'+(ROOT/'tests/regional-caster-bones-native.luau').read_text())
print(args.output)
