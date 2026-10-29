#!/usr/bin/env python3
"""Produce an isolated blank-place Source probe; does not run Rojo or build a game.

Usage: python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-k0-source-probe
       ... --test-script tests/k0-timing-native.luau
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
parser.add_argument('--test-script', type=Path, default=Path('tests/k0-build-smoke.luau'))
args = parser.parse_args()
project = Path(__file__).resolve().parents[1]
test_script = (project / args.test_script).resolve()
if not test_script.is_relative_to(project) or not test_script.is_file():
    raise SystemExit('--test-script must select an existing file inside this repository')
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

weapon_manifest_path = project / 'assets/shared/td-player-weapons/manifest.json'
weapon_manifest = json.loads(weapon_manifest_path.read_text())
weapon_rel = weapon_manifest['files']['runtime']['path']
weapon_path = project / weapon_rel
weapon_bytes = weapon_path.read_bytes()
if hashlib.sha256(weapon_bytes).hexdigest() != weapon_manifest['files']['runtime']['sha256']:
    raise SystemExit('TD weapon runtime XML differs from its provenance manifest')
weapon_mapping = project_tree.get('ServerStorage', {}).get('TDPlayerWeaponModels', {}).get('$path')
if weapon_mapping != weapon_rel:
    raise SystemExit('K0 source probe requires the exact ServerStorage.TDPlayerWeaponModels Rojo mapping')
weapon_xml = ET.fromstring(weapon_bytes)
weapon_items = weapon_xml.findall('Item')
if len(weapon_items) != 1 or weapon_items[0].get('class') != 'Folder':
    raise SystemExit('TD weapon runtime must contain exactly one top-level Folder')
weapon_folder = weapon_items[0]
weapon_name = weapon_folder.find("./Properties/string[@name='Name']")
if weapon_name is None or weapon_name.text != weapon_manifest['provenance']['runtime_top_level_folder']:
    raise SystemExit('TD weapon runtime top-level folder differs from the provenance manifest')
if any(item.get('class') in ('Script', 'LocalScript', 'ModuleScript') for item in weapon_xml.iter('Item')):
    raise SystemExit('TD weapon fixture refuses executable source containers')

shield_manifest_path = project / 'assets/shared/td-player-weapons/shield/manifest.json'
shield_manifest = json.loads(shield_manifest_path.read_text())
shield_rel = shield_manifest['files']['runtime']['path']
shield_bytes = (project / shield_rel).read_bytes()
if hashlib.sha256(shield_bytes).hexdigest() != shield_manifest['files']['runtime']['sha256']:
    raise SystemExit('TD shield runtime XML differs from its provenance manifest')
shield_mapping = project_tree.get('ServerStorage', {}).get('TDKnightShieldModels', {}).get('$path')
if shield_mapping != shield_rel:
    raise SystemExit('K0 source probe requires the exact ServerStorage.TDKnightShieldModels Rojo mapping')
shield_xml = ET.fromstring(shield_bytes)
shield_items = shield_xml.findall('Item')
if len(shield_items) != 1 or shield_items[0].get('class') != 'Folder':
    raise SystemExit('TD shield runtime must contain exactly one top-level Folder')
shield_folder = shield_items[0]
shield_name = shield_folder.find("./Properties/string[@name='Name']")
if shield_name is None or shield_name.text != shield_manifest['provenance']['runtime_top_level_folder']:
    raise SystemExit('TD shield runtime top-level folder differs from its provenance manifest')
if any(item.get('class') in ('Script', 'LocalScript', 'ModuleScript') for item in shield_xml.iter('Item')):
    raise SystemExit('TD shield fixture refuses executable source containers')

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
mounted_weapons = copy.deepcopy(weapon_folder)
mounted_weapons.find("./Properties/string[@name='Name']").text = 'TDPlayerWeaponModels'
# Isolate referents because the two independently authored model files may use
# the same local IDs. Update internal references such as Model.PrimaryPart too.
weapon_referents = {}
for item in mounted_weapons.iter('Item'):
    old = item.get('referent')
    if old:
        weapon_referents[old] = 'TLT_WEAPON_' + old
        item.set('referent', weapon_referents[old])
for reference in mounted_weapons.iter('Ref'):
    if reference.text in weapon_referents:
        reference.text = weapon_referents[reference.text]
storage_item.append(mounted_weapons)
mounted_shields = copy.deepcopy(shield_folder)
mounted_shields.find("./Properties/string[@name='Name']").text = 'TDKnightShieldModels'
shield_referents = {}
for item in mounted_shields.iter('Item'):
    old = item.get('referent')
    if old:
        if old in shield_referents:
            raise SystemExit('TD shield runtime has duplicate instance referents')
        shield_referents[old] = 'TLT_SHIELD_' + old
        item.set('referent', shield_referents[old])
for reference in mounted_shields.iter('Ref'):
    if reference.text in shield_referents:
        reference.text = shield_referents[reference.text]
storage_item.append(mounted_shields)
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
    'assert(game:GetService("ServerStorage"):FindFirstChild("TDPlayerWeaponModels"), "K0 fixture is missing actual vendored TD weapons")',
    'assert(game:GetService("ServerStorage"):FindFirstChild("TDKnightShieldModels"), "K0 fixture is missing actual reviewed TD shield")',
    'local shared=Instance.new("Folder");shared.Name="Shared";shared.Parent=rs',
    'local server=Instance.new("Script");server.Name="Server";server.Disabled=true;server.Parent=ss',
    'local client=Instance.new("LocalScript");client.Name="Client";client.Disabled=true;client.Parent=sp',
]
health_rel = project_tree.get('StarterPlayer', {}).get('StarterCharacterScripts', {}).get('Health', {}).get('$path')
if health_rel != 'src/character/Health.server.lua':
    raise SystemExit('K0 source probe requires the exact default-health override mapping')
health_path = project / health_rel
lines.append('do local h=Instance.new("Script");h.Name="Health";h.Source=' + quote(health_path.read_text())
             + ';h.Parent=game:GetService("StarterPlayer").StarterCharacterScripts end')
manifest = {
    'default.project.json': hashlib.sha256(project_path.read_bytes()).hexdigest(),
    str(asset_manifest_path.relative_to(project)): hashlib.sha256(asset_manifest_path.read_bytes()).hexdigest(),
    runtime_rel: hashlib.sha256(runtime_bytes).hexdigest(),
    str(weapon_manifest_path.relative_to(project)): hashlib.sha256(weapon_manifest_path.read_bytes()).hexdigest(),
    weapon_rel: hashlib.sha256(weapon_bytes).hexdigest(),
    str(shield_manifest_path.relative_to(project)): hashlib.sha256(shield_manifest_path.read_bytes()).hexdigest(),
    shield_rel: hashlib.sha256(shield_bytes).hexdigest(),
    str(test_script.relative_to(project)): hashlib.sha256(test_script.read_bytes()).hexdigest(),
    'tests/make_k0_source_probe.py': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    health_rel: hashlib.sha256(health_path.read_bytes()).hexdigest(),
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
lines.append(test_script.read_text())
place = out / 'tlt-k0-qa-empty.rbxlx'
runner = out / 'source-probe.luau'
place.write_bytes(ET.tostring(fixture_xml, encoding='utf-8', xml_declaration=True) + b'\n')
runner.write_text('\n'.join(lines) + '\n')
(out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({'kind': 'QA Source fixture with actual vendored TD MeshParts; no Rojo game build', 'place': str(place), 'script': str(runner), 'test_script': str(test_script.relative_to(project)), 'source_files': source_count, 'input_files': len(manifest), 'td_models': len(template_folder.findall("Item[@class='Model']"))}))
