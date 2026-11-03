"""Compare imported runtime Bones against independently decoded source GLB poses."""
from pathlib import Path
import argparse,json
ROOT=Path(__file__).resolve().parents[1]
def luau(x):
 if isinstance(x,dict):return '{'+','.join('['+json.dumps(k)+']='+luau(v)for k,v in x.items())+'}'
 if isinstance(x,list):return '{'+','.join(luau(v)for v in x)+'}'
 return json.dumps(x)
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);args=p.parse_args()
fixture=json.loads((ROOT/'assets/animations/regional-casters-v1/bone-fixture.json').read_text())
args.output.write_text('local fixtures='+luau(fixture)+'\n'+(ROOT/'tests/regional-caster-runtime-native.luau').read_text())
print(args.output)
