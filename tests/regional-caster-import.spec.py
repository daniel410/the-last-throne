"""Re-run independent skinning checks against the import-ready GLBs."""
from pathlib import Path
import importlib.util,json,argparse
ROOT=Path(__file__).resolve().parents[1]
s=importlib.util.spec_from_file_location('rigs',ROOT/'tests/regional-caster-rigs.spec.py');rigs=importlib.util.module_from_spec(s);s.loader.exec_module(rigs)
rigs.ASSETS=ROOT/'assets/animations/regional-casters-v2'
models={}
for kind in ['QueenIceElf','VolcanoShaman','KingVolcanoShaman']:
 source,before=rigs.load(ROOT/'assets/animations/regional-casters-v1'/(kind+'-rigged.glb'))
 imported,after=rigs.load(rigs.ASSETS/(kind+'-rigged.glb'))
 rigs.check(before==after,kind+' geometry, UVs, skin weights and texture bytes unchanged')
 rigs.check(all(c['target']['path']not in ['scale','weights']for a in imported['animations']for c in a['channels']),kind+' Roblox-compatible animation channels')
 models[kind]=rigs.validate(kind)
report={'workId':'MR-01','scope':'import-ready GLB CPU skinning; not Roblox skin rendering','checks':rigs.checks,'pass':True,'models':models}
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path);args=parser.parse_args()
if args.output:args.output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
