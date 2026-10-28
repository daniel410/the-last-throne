#!/usr/bin/env python3
"""Produce an isolated blank-place Source probe; does not run Rojo or build a game.

Usage: python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-k0-source-probe
Then use run-in-roblox with the printed blank .rbxlx and runner .luau paths.
"""
from pathlib import Path
import argparse
import copy
import hashlib
import json
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser()
parser.add_argument('--output-dir', type=Path, required=True)
args = parser.parse_args()
project = Path(__file__).resolve().parents[1]
out = args.output_dir.resolve()
out.mkdir(parents=True, exist_ok=True)
project_path = project / 'default.project.json'
project_tree = json.loads(project_path.read_text())['tree']
auto_loads = project_tree.get('Players', {}).get('$properties', {}).get('CharacterAutoLoads')
if auto_loads is not False:
    raise SystemExit('K0 source probe requires CharacterAutoLoads=false in default.project.json; do not mask the project setting')

asset_manifest_path = project / 'assets/shared/td-monsters/manifest.json'
asset_manifest = json.loads(asset_manifest_path.read_text())
runtime_rel = asset_manifest['files']['runtime']['path']
runtime_path = project / runtime_rel
runtime_bytes = runtime_path.read_bytes()
if hashlib.sha256(runtime_bytes).hexdigest() != asset_manifest['files']['runtime']['sha256']:
    raise SystemExit('TD runtime XML differs from its provenance manifest')
runtime_mapping = project_tree.get('ServerStorage', {}).get('TdMonsterModels', {}).get('$path')
if runtime_mapping != runtime_rel:
    raise SystemExit('K0 source probe requires the exact ServerStorage.TdMonsterModels Rojo mapping')
runtime_xml = ET.fromstring(runtime_bytes)
top_items = runtime_xml.findall('Item')
if len(top_items) != 1 or top_items[0].get('class') != 'Folder':
    raise SystemExit('TD runtime must contain exactly one top-level Folder')
template_folder = top_items[0]
folder_name = template_folder.find("./Properties/string[@name='Name']")
if folder_name is None or folder_name.text != asset_manifest['provenance']['runtime_top_level_folder']:
    raise SystemExit('TD runtime top-level folder differs from the provenance manifest')
if any(item.get('class') in ('Script', 'LocalScript', 'ModuleScript') for item in runtime_xml.iter('Item')):
    raise SystemExit('TD runtime fixture refuses executable source containers')

# Preserve the actual serialized MeshParts, references and root metadata. Only
# the mounted folder name changes, matching Rojo's ServerStorage key.
fixture_xml = copy.deepcopy(runtime_xml)
fixture_xml.remove(fixture_xml.find('Item'))
storage_item = ET.SubElement(fixture_xml, 'Item', {'class': 'ServerStorage', 'referent': 'TLT_QA_SERVER_STORAGE'})
storage_properties = ET.SubElement(storage_item, 'Properties')
ET.SubElement(storage_properties, 'string', {'name': 'Name'}).text = 'ServerStorage'
mounted_folder = copy.deepcopy(template_folder)
mounted_folder.find("./Properties/string[@name='Name']").text = 'TdMonsterModels'
storage_item.append(mounted_folder)
players_item = ET.SubElement(fixture_xml, 'Item', {'class': 'Players', 'referent': 'TLT_QA_PLAYERS'})
players_properties = ET.SubElement(players_item, 'Properties')
ET.SubElement(players_properties, 'string', {'name': 'Name'}).text = 'Players'
ET.SubElement(players_properties, 'bool', {'name': 'CharacterAutoLoads'}).text = 'false'

def quote(value):
    marks = '='
    while ']' + marks + ']' in value:
        marks += '='
    return '[' + marks + '[' + value + ']' + marks + ']'

lines = [
    'assert(game.PlaceId == 0, "K0 source probe requires a local empty place")',
    'local rs=game:GetService("ReplicatedStorage")',
    'local ss=game:GetService("ServerScriptService")',
    'local sp=game:GetService("StarterPlayer").StarterPlayerScripts',
    'assert(not rs:FindFirstChild("Shared") and not ss:FindFirstChild("Server") and not sp:FindFirstChild("Client"), "K0 source probe refuses an existing game")',
    'assert(game:GetService("Players").CharacterAutoLoads == false, "K0 fixture must serialize CharacterAutoLoads=false")',
    'assert(game:GetService("ServerStorage"):FindFirstChild("TdMonsterModels"), "K0 fixture is missing actual vendored TD MeshParts")',
    'local shared=Instance.new("Folder");shared.Name="Shared";shared.Parent=rs',
    'local server=Instance.new("Script");server.Name="Server";server.Disabled=true;server.Parent=ss',
    'local client=Instance.new("LocalScript");client.Name="Client";client.Disabled=true;client.Parent=sp',
]
manifest = {
    'default.project.json': hashlib.sha256(project_path.read_bytes()).hexdigest(),
    str(asset_manifest_path.relative_to(project)): hashlib.sha256(asset_manifest_path.read_bytes()).hexdigest(),
    runtime_rel: hashlib.sha256(runtime_bytes).hexdigest(),
    'tests/k0-build-smoke.luau': hashlib.sha256((project / 'tests/k0-build-smoke.luau').read_bytes()).hexdigest(),
    'tests/make_k0_source_probe.py': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
}
source_count = 0
for source in sorted((project / 'src').rglob('*.luau')):
    rel = source.relative_to(project)
    data = source.read_text()
    manifest[str(rel)] = hashlib.sha256(source.read_bytes()).hexdigest()
    source_count += 1
    part = source.relative_to(project / 'src')
    tree = part.parts
    variable = {'shared': 'shared', 'server': 'server', 'client': 'client'}[tree[0]]
    if source.name.startswith('init.'):
        lines.append(variable + '.Source=' + quote(data))
        continue
    parent = variable
    for folder in tree[1:-1]:
        lines.append('do local f=' + parent + ':FindFirstChild(' + quote(folder) + ');if not f then f=Instance.new("Folder");f.Name=' + quote(folder) + ';f.Parent=' + parent + ' end end')
        parent += ':FindFirstChild(' + quote(folder) + ')'
    lines.append('do local m=Instance.new("ModuleScript");m.Name=' + quote(source.stem) + ';m.Source=' + quote(data) + ';m.Parent=' + parent + ' end')
lines.append('server.Disabled=false')
lines.append('client.Disabled=false')
lines.append('print("K0_SOURCE_PROBE_INPUTS " .. ' + quote(json.dumps(manifest, sort_keys=True)) + ')')
lines.append((project / 'tests/k0-build-smoke.luau').read_text())
place = out / 'tlt-k0-qa-empty.rbxlx'
runner = out / 'source-probe.luau'
place.write_bytes(ET.tostring(fixture_xml, encoding='utf-8', xml_declaration=True) + b'\n')
runner.write_text('\n'.join(lines) + '\n')
(out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({'kind': 'QA Source fixture with actual vendored TD MeshParts; no Rojo game build', 'place': str(place), 'script': str(runner), 'source_files': source_count, 'input_files': len(manifest), 'td_models': len(template_folder.findall("Item[@class='Model']"))}))
