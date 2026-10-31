"""Isolated local native-art fixture. Does not publish or touch an open place."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET
import hashlib

ROOT = Path(__file__).resolve().parents[1]
OUT = Path('/tmp/tlt-npc-cast-v1')
OUT.mkdir(exist_ok=True)
root = ET.Element('roblox', version='4')
inputs = {}

def item(parent, cls, name, source=None):
    el = ET.SubElement(parent, 'Item', {'class': cls})
    p = ET.SubElement(el, 'Properties')
    ET.SubElement(p, 'string', name='Name').text = name
    if source is not None:
        ET.SubElement(p, 'ProtectedString', name='Source').text = source
    return el

def folder(parent, name, path):
    f = item(parent, 'Folder', name)
    for p in sorted(path.iterdir()):
        if p.is_dir():
            folder(f, p.name, p)
        elif p.suffix in ('.luau', '.lua') and '.server.' not in p.name and '.client.' not in p.name:
            data = p.read_bytes()
            item(f, 'ModuleScript', p.stem, data.decode())
            inputs[str(p.relative_to(ROOT))] = hashlib.sha256(data).hexdigest()
    return f

folder(item(root, 'ReplicatedStorage', 'ReplicatedStorage'), 'Shared', ROOT/'src/shared')
folder(item(root, 'ServerScriptService', 'ServerScriptService'), 'Server', ROOT/'src/server')
sp = item(root, 'StarterPlayer', 'StarterPlayer')
client = item(item(sp, 'StarterPlayerScripts', 'StarterPlayerScripts'), 'LocalScript', 'Client', '')
ET.SubElement(client.find('Properties'), 'bool', name='Disabled').text = 'true'
for p in (ROOT/'src/client').glob('*.luau'):
    if '.client.' not in p.name:
        item(client, 'ModuleScript', p.stem, p.read_text())
        inputs[str(p.relative_to(ROOT))] = hashlib.sha256(p.read_bytes()).hexdigest()
players = item(root, 'Players', 'Players')
ET.SubElement(players.find('Properties'), 'bool', name='CharacterAutoLoads').text = 'false'
storage = item(root, 'ServerStorage', 'ServerStorage')
project = json.loads((ROOT/'default.project.json').read_text())
for name, desc in project['tree']['ServerStorage'].items():
    if '$path' in desc:
        path = ROOT/desc['$path']
        source = ET.parse(path).getroot()
        refs = {el.attrib['referent']: name+'_'+el.attrib['referent'] for el in source.iter() if 'referent' in el.attrib}
        for el in source.iter():
            if 'referent' in el.attrib:
                el.attrib['referent'] = refs[el.attrib['referent']]
            if el.tag == 'Ref' and el.text in refs:
                el.text = refs[el.text]
        for el in source.findall('Item'):
            el.find('./Properties/string[@name="Name"]').text = name
            storage.append(el)
        inputs[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
ET.ElementTree(root).write(OUT/'tlt-npc-cast-preview.rbxlx', encoding='utf-8', xml_declaration=True)
(OUT/'source-manifest.json').write_text(json.dumps(inputs,indent=2)+'\n')
print(OUT/'tlt-npc-cast-preview.rbxlx')
