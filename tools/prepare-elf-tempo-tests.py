"""Prepare isolated native elf timing QA; no game build or active Studio edits."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
out = Path(sys.argv[1]).resolve()
subprocess.run(['node', 'tools/prepare-dwarf-swing-review.mjs', str(out),
                'tests/elf-basic-tempo-native.luau'], cwd=root, check=True)
place = out / 'tlt-k0-qa-empty.rbxlx'
tree = ET.parse(place)
server = tree.find("./Item[@class='ServerScriptService']/Item")
manifest = json.loads((out / 'source-manifest.json').read_text())


def record(path):
    manifest[str(path.relative_to(root))] = hashlib.sha256(path.read_bytes()).hexdigest()
    return path.read_text()


def folder(parent, name):
    for child in parent.findall('Item'):
        if child.findtext('./Properties/string[@name="Name"]') == name:
            return child
    child = ET.SubElement(parent, 'Item', {'class': 'Folder'})
    ET.SubElement(ET.SubElement(child, 'Properties'), 'string', {'name': 'Name'}).text = name
    return child


for source in sorted((root / 'src/server').rglob('*.luau')):
    if source.name.startswith('init.') or '.server.' in source.name:
        continue
    parent = server
    for part in source.relative_to(root / 'src/server').parts[:-1]:
        parent = folder(parent, part)
    if any(c.findtext('./Properties/string[@name="Name"]') == source.stem for c in parent.findall('Item')):
        continue  # Cosmetics are already supplied by the base fixture.
    item = ET.SubElement(parent, 'Item', {'class': 'ModuleScript'})
    props = ET.SubElement(item, 'Properties')
    ET.SubElement(props, 'string', {'name': 'Name'}).text = source.stem
    ET.SubElement(props, 'ProtectedString', {'name': 'Source'}).text = record(source)
tree.write(place, encoding='utf-8', xml_declaration=True)


def lua(value):
    if isinstance(value, dict):
        return '{' + ','.join('[' + json.dumps(k) + ']=' + lua(v) for k, v in value.items()) + '}'
    if isinstance(value, list):
        return '{' + ','.join(map(lua, value)) + '}'
    return json.dumps(value)


runner = (out / 'source-probe.luau').read_text()
golden = json.loads(record(root / 'assets/animations/mixamo-elf-v1/blender-golden.json'))
legacy = record(root / 'tests/elf-bow-golden.luau').replace('\nreturn ', '\nlocal BowGolden=', 1)
for test, prefix in [
    ('mixamo-elf-native.luau', 'local elfGolden=' + lua(golden)),
    ('k0-elf-bow-native.luau', legacy),
    ('elf-quiver-native.luau', ''),
    ('elf-straight-shot-native.luau', ''),
]:
    runner += '\ndo\n' + prefix + '\n' + record(root / 'tests' / test) + '\nend\n'
(out / 'source-probe.luau').write_text(runner)
record(Path(__file__).resolve())
record(root / 'tools/prepare-dwarf-swing-review.mjs')
(out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
