"""고정 빌드 원문·엔진 결과·캡처 해시를 검증한다. 실기기 수용 검사는 아니다."""
from pathlib import Path
import hashlib
import json
import subprocess
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
build = json.loads((HERE / 'build.json').read_text())
commit = build['sourceCommit']
artifact = ROOT / build['outputs'][0]['path']
digest = lambda data: hashlib.sha256(data).hexdigest()
assert digest(artifact.read_bytes()) == build['outputs'][0]['sha256']
nodes = {}


def walk(node, path):
    for item in node.findall('Item'):
        name = item.find("Properties/string[@name='Name']")
        key = path + '/' + (name.text or '')
        source = item.find("Properties/*[@name='Source']")
        if source is not None:
            nodes[key] = source.text or ''
        walk(item, key)


walk(ET.parse(artifact).getroot(), '')
paths = ['src/client/' + name + '.luau' for name in (
    'HeroVFX', 'HeroVFXSurfaces', 'SkillVFXProfiles', 'AdvancedSkillVisual',
    'EnemyPatternEffects', 'GameSettings', 'EnemySpellVFX', 'EnemySpellArt',
    'PixelFX', 'CuratedVFX', 'K0HitEffects', 'SelenePresentation', 'WindLanceVisual')]
paths += ['src/shared/EnemyPatterns.luau', 'src/shared/CombatVFXPalette.luau',
          'src/shared/SkillPresentation.luau', 'src/server/Combat/EnemyPatternRuntime.luau']
modules = []
for path in paths:
    section, relative = path.split('/', 2)[1:]
    prefix = {'client': '/StarterPlayer/StarterPlayerScripts/Client',
              'shared': '/ReplicatedStorage/Shared',
              'server': '/ServerScriptService/Server'}[section]
    source = subprocess.check_output(['git', 'show', commit + ':' + path], cwd=ROOT)
    assert nodes.get(prefix + '/' + relative.removesuffix('.luau')) == source.decode(), path
    modules.append({'path': path, 'sha256': digest(source)})
results = []
for line in (HERE / 'pinned-native.log').read_text().splitlines():
    if '{' not in line:
        continue
    row = json.loads(line[line.index('{'):])
    if 'checks' not in row:
        continue
    assert not row.get('failures') and row.get('pass', True), row
    results.append(row)
assert len(results) == 18, len(results)
frames = 0
for folder in ['before-first', 'before-later', 'after-first', 'after-later', 'ultimate-last']:
    rows = json.loads((HERE / folder / 'manifest.json').read_text())
    assert len(rows) == (3 if folder == 'ultimate-last' else 12)
    for row in rows:
        assert digest((HERE / folder / (row['id'] + '.png')).read_bytes()) == row['sha256']
    frames += len(rows)
report = {'version': build['version'], 'sourceCommit': commit,
          'buildSha256': digest(artifact.read_bytes()), 'matchingModules': modules,
          'nativeSuites': len(results), 'nativeChecks': sum(row['checks'] for row in results),
          'nativeResults': results, 'verifiedCaptureFrames': frames,
          'publishedClient': 'not-run', 'realDevice': 'not-run', 'userArtAcceptance': 'pending'}
(HERE / 'validation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({key: report[key] for key in ('version', 'nativeSuites', 'nativeChecks', 'verifiedCaptureFrames')}))
