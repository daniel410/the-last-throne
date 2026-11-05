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
