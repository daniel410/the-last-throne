"""Verify the packaged runtime role/config sources and compatibility entry point."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
project=json.loads((root/'default.project.json').read_text())
assert project==json.loads((root/'battle.project.json').read_text()), 'compatibility project must stay identical'
tree=project['tree']
assert 'ServerRole' not in tree['ServerStorage']
assert 'ServerRole' not in tree['ReplicatedFirst']
for name in ('PlaceRole','ExpeditionConfig'):
 assert tree['ReplicatedFirst'][name]['$path']==f'src/shared/{name}.luau'
assert tree['ReplicatedStorage']['Shared']['$path']=='src/shared'
print('single-build: project mounts and compatibility alias PASS')

# Optional artifact check exercises the exact ModuleScript/LocalScript bytes
# emitted by Rojo, rather than the possibly dirty working tree.
import argparse, subprocess, tempfile, xml.etree.ElementTree as E
parser=argparse.ArgumentParser()
parser.add_argument('--artifact',type=Path)
args=parser.parse_args()
if args.artifact:
 xml=E.parse(args.artifact).getroot()
 def child(parent,name):
  return next(item for item in parent.findall('./Item') if item.findtext('./Properties/string[@name="Name"]')==name)
 def source(item):
  return item.findtext('./Properties/string[@name="Source"]')
 first=child(xml,'ReplicatedFirst')
 shared=child(child(xml,'ReplicatedStorage'),'Shared')
 for name in ('PlaceRole','ExpeditionConfig'):
  assert source(child(first,name))==source(child(shared,name)), name+' early/server bytes differ'
 for service in ('ReplicatedFirst','ServerStorage'):
  assert not any(i.findtext('./Properties/string[@name="Name"]')=='ServerRole' for i in child(xml,service).findall('./Item'))
 assert 'Shared.PlaceRole).resolve' in source(child(child(xml,'ServerScriptService'),'Server'))
 with tempfile.TemporaryDirectory(prefix='tlt-single-artifact-') as folder:
  frozen=Path(folder)
  for name in ('PlaceRole','ExpeditionConfig'):
   path=frozen/f'src/shared/{name}.luau';path.parent.mkdir(parents=True,exist_ok=True);path.write_text(source(child(first,name)))
  path=frozen/'src/loading/ArrivalLoading.client.luau';path.parent.mkdir(parents=True,exist_ok=True);path.write_text(source(child(first,'ArrivalLoading')))
  for test in ('place-role.spec.lua','arrival-loading.spec.lua'):
   subprocess.run(['lua',str(root/'tests'/test)],cwd=frozen,check=True)
 print('single-build: actual artifact role/config/loading checks PASS')
