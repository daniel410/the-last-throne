#!/usr/bin/env python3
"""TD 몬스터 원본·manifest·XML·LFS·Rojo 계약 검사(Python 표준 라이브러리).

python3 tests/td-monster-assets.spec.py [--td-root ../throne-defense]
Studio/네트워크/빌드 없이 실행한다. MeshId의 존재는 실제 로드·표면 렌더 증거가 아니다.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import struct
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    'goblin': {'height': 3.6, 'texture': '134919664038207', 'meshes': {
        'Body': '77403549111699', 'ArmL': '127402469282462', 'ArmR': '106102430341786',
        'LegL': '78392327157438', 'LegR': '100268725310905'}},
    'ogre': {'height': 6.05, 'texture': '90412861785322', 'meshes': {
        'Body': '98618217378067', 'ArmL': '108622715572697', 'ArmR': '98353562560509',
        'LegL': '76243711635467', 'LegR': '77089513742534'}},
    'slime': {'height': 1.1, 'texture': '75994104212849', 'meshes': {'Body': '84245584635347'}},
    'orc': {'height': 4.6, 'texture': '140427201929012', 'meshes': {
        'Body': '91974284442570', 'ArmL': '80036546875989', 'ArmR': '126087041396792',
        'LegL': '122434686618387', 'LegR': '108357424176147'}},
}
CAPTURED_HASHES = {
    'runtime': '14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5',
    'goblin': '90ece6137ab326db2e9b929383c5b98c3f2529b0f78bc7f4d1fc8dbba1dc0a7b',
    'ogre': 'd5a01cdc860ce2bc0725594e89c01b574f095ac9cde4a84807b72640493af2b3',
    'slime': '3adc1a12f3e89f6690047abb2c8cab3d6fbb4ae0f3726b87e2a5607d4d7324c2',
    'orc': 'b612a43d660f11cf24a9b5216462fdf1cf7b98a2e49db625102006cc70fb5ad3',
}
report = {'kind': 'TLT_TD_MONSTER_ASSETS_STATIC', 'checks': [], 'failures': [], 'not_run': [],
          'coverage': 'Vendored bytes/schema/XML/LFS/Rojo only; no Studio, asset fetch, visible render, Player, performance or published access'}


def check(condition, label):
    report['checks'].append({'id': label, 'pass': bool(condition)})
    if not condition:
        report['failures'].append(label)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def prop(item, name):
    return item.find("./Properties/*[@name='%s']" % name)


def text(item, name):
    value = prop(item, name)
    return None if value is None else value.text


def content(item, name):
    value = prop(item, name)
    return None if value is None else value.findtext('url')


def numbers(item, name, fields):
    value = prop(item, name)
    return [] if value is None else [float(value.findtext(field)) for field in fields]


def same_numbers(actual, expected):
    return len(actual) == len(expected) and all(math.isfinite(a) and math.isclose(a, b, abs_tol=1e-6) for a, b in zip(actual, expected))


def local_file(relative):
    path = (ROOT / relative).resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError('Manifest path escapes this repository: ' + relative)
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--td-root', type=Path, help='Optional original TD checkout for byte comparison')
    args = parser.parse_args()
    manifest = json.loads((ROOT / 'assets/shared/td-monsters/manifest.json').read_text())
    check(manifest['schema_version'] == 1, 'manifest/schema-v1')
    check(set(manifest['files']) == set(CAPTURED_HASHES), 'manifest/runtime-and-four-originals')
    check(set(manifest['models']) == set(EXPECTED), 'manifest/four-selected-models')
    td_root = (args.td_root or (ROOT / manifest['provenance']['td_repository'])).resolve()
    if args.td_root and not td_root.is_dir():
        raise ValueError('Explicit TD checkout does not exist: ' + str(td_root))
    payloads = {}
    paths = []
    for key, expected_hash in CAPTURED_HASHES.items():
        entry = manifest['files'][key]
        path = local_file(entry['path'])
        data = path.read_bytes()
        payloads[key] = data
        paths.append(entry['path'])
        check(not data.startswith(b'version https://git-lfs.github.com/spec/v1'), key + '/LFS-materialized')
        check(entry['sha256'] == expected_hash and sha(data) == entry['sha256'], key + '/captured-SHA256')
        check(len(data) == entry['size_bytes'] and entry['git_lfs'] is True, key + '/size-and-LFS-declaration')
        if td_root.is_dir():
            original = (td_root / entry['td_source_path']).resolve()
            check(original.is_relative_to(td_root) and original.is_file(), key + '/TD-source-present')
            if original.is_file() and original.is_relative_to(td_root):
                check(original.read_bytes() == data, key + '/TD-byte-identical-copy')
        else:
            report['not_run'].append(key + '/TD-byte-comparison: original checkout unavailable')
        if key != 'runtime':
            magic, version, length = struct.unpack_from('<4sII', data)
            check(magic == b'glTF' and version == 2 and length == len(data), key + '/original-GLB-v2-header')
            json_length, chunk_type = struct.unpack_from('<II', data, 12)
            gltf = json.loads(data[20:20 + json_length])
            check(chunk_type == 0x4E4F534A and gltf.get('asset', {}).get('version') == '2.0' and bool(gltf.get('meshes')), key + '/original-GLB-mesh-JSON')
            resources = gltf.get('buffers', []) + gltf.get('images', [])
            check(all('uri' not in row or row['uri'].startswith('data:') for row in resources), key + '/GLB-self-contained-resources')

    attrs = subprocess.run(['git', 'check-attr', '-z', 'filter', 'diff', 'merge', 'text', '--', *paths],
                           cwd=ROOT, check=True, capture_output=True).stdout.decode().split('\0')
    triples = dict(((attrs[i], attrs[i + 1]), attrs[i + 2]) for i in range(0, len(attrs) - 1, 3))
    for path in paths:
        check(all(triples.get((path, attr)) == value for attr, value in
                  {'filter': 'lfs', 'diff': 'lfs', 'merge': 'lfs', 'text': 'unset'}.items()), path + '/effective-git-LFS-attributes')

    xml = ET.fromstring(payloads['runtime'])
    tops = xml.findall('Item')
    check(xml.get('version') == '4' and len(tops) == 1 and tops[0].get('class') == 'Folder', 'XML/single-model-folder')
    folder = tops[0]
    check(text(folder, 'Name') == manifest['provenance']['runtime_top_level_folder'], 'XML/original-folder-name')
    items = list(xml.iter('Item'))
    check(not any(item.get('class') in ('Script', 'LocalScript', 'ModuleScript') for item in items), 'XML/no-executable-scripts')
    referents = [item.get('referent') for item in items]
    check(all(referents) and len(referents) == len(set(referents)), 'XML/unique-instance-references')
    check(all(ref.text in set(referents) | {'null', 'nil', None} for ref in xml.iter('Ref')), 'XML/no-dangling-instance-references')
    models = folder.findall("Item[@class='Model']")
    names = [text(model, 'Name') for model in models]
    check(len(models) == manifest['provenance']['runtime_model_count'] == 43 and len(names) == len(set(names)), 'XML/full-43-model-source-preserved')
    for kind, expected in EXPECTED.items():
        model = next(model for model in models if text(model, 'Name') == kind)
        metadata = manifest['models'][kind]
        parts = list(model.iter('Item'))
        parts = [part for part in parts if part.get('class') == 'MeshPart']
        by_name = {text(part, 'Name'): part for part in parts}
        check(len(parts) == len(expected['meshes']) and set(by_name) == set(expected['meshes']), kind + '/exact-original-mesh-parts')
        target = next(item for item in model.findall('Item') if text(item, 'Name') == 'TargetHeight')
        check(target.get('class') == 'NumberValue' and math.isclose(float(text(target, 'Value')), expected['height'])
              and metadata['target_height'] == expected['height'], kind + '/original-TargetHeight')
        check(metadata['template_name'] == kind and metadata['source_glb_path'] == manifest['files'][kind]['path'], kind + '/manifest-original-link')
        recorded = {part['name']: part for part in metadata['parts']}
        check(len(metadata['parts']) == len(parts) and set(recorded) == set(by_name), kind + '/manifest-part-coverage')
        for name, mesh_id in expected['meshes'].items():
            part, row = by_name[name], recorded[name]
            check(content(part, 'MeshId') == row['mesh_id'] == 'rbxassetid://' + mesh_id and
                  content(part, 'TextureID') == row['texture_id'] == 'rbxassetid://' + expected['texture'], kind + '/' + name + '/original-content-IDs')
            check(same_numbers(numbers(part, 'size', 'XYZ'), row['size']) and
                  same_numbers(numbers(part, 'CFrame', 'XYZ'), row['position']) and
                  same_numbers(numbers(part, 'CFrame', ['R' + str(r) + str(c) for r in range(3) for c in range(3)]), row['rotation_matrix']),
                  kind + '/' + name + '/manifest-geometry-and-rotation')
            anchor = next((item for item in part.findall('Item') if text(item, 'Name') == 'MeshAnchor'), None)
            check(anchor is not None and text(anchor, 'Value') == row['mesh_anchor'] == name, kind + '/' + name + '/original-anchor')
            check(text(part, 'Anchored') == 'true' and row['anchored'] is True and text(part, 'CanCollide') == 'false' and row['can_collide'] is False,
                  kind + '/' + name + '/serialized-template-physics')

    project = json.loads((ROOT / 'default.project.json').read_text())
    check(project['tree']['ServerStorage']['TdMonsterModels']['$path'] == manifest['files']['runtime']['path'], 'Rojo/actual-TD-runtime-mount')
    check(project['tree']['Players']['$properties']['CharacterAutoLoads'] is False, 'Rojo/spawn-loading-regression')
    # The runtime import is intentionally XML, not a generated surrogate mesh.
    check(local_file(project['tree']['ServerStorage']['TdMonsterModels']['$path']).suffix == '.rbxmx', 'Rojo/serialized-MeshPart-source')
    report['td_source_comparison'] = 'executed' if td_root.is_dir() else 'not_run'


try:
    main()
except Exception as exc:
    report['failures'].append(type(exc).__name__ + ': ' + str(exc))
report['pass'] = not report['failures']
report['check_count'] = len(report['checks'])
print(json.dumps(report, ensure_ascii=False, indent=2))
sys.exit(0 if report['pass'] else 1)
