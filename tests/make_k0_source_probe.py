#!/usr/bin/env python3
"""Produce an isolated blank-place Source probe; does not run Rojo or build a game.

Usage: python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-k0-source-probe
Then use run-in-roblox with the printed blank .rbxlx and runner .luau paths.
"""
from pathlib import Path
import argparse
import hashlib
import json

parser = argparse.ArgumentParser()
parser.add_argument('--output-dir', type=Path, required=True)
args = parser.parse_args()
project = Path(__file__).resolve().parents[1]
out = args.output_dir.resolve()
out.mkdir(parents=True, exist_ok=True)

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
    'local shared=Instance.new("Folder");shared.Name="Shared";shared.Parent=rs',
    'local server=Instance.new("Script");server.Name="Server";server.Disabled=true;server.Parent=ss',
    'local client=Instance.new("LocalScript");client.Name="Client";client.Disabled=true;client.Parent=sp',
]
manifest = {}
for source in sorted((project / 'src').rglob('*.luau')):
    rel = source.relative_to(project)
    data = source.read_text()
    manifest[str(rel)] = hashlib.sha256(source.read_bytes()).hexdigest()
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
place.write_text('<roblox version="4"><External>null</External><External>nil</External></roblox>\n')
runner.write_text('\n'.join(lines) + '\n')
(out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({'kind': 'QA blank fixture and source runner; no game build', 'place': str(place), 'script': str(runner), 'source_files': len(manifest)}))
