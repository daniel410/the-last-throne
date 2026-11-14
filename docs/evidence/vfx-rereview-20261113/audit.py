"""현재 카탈로그와 재열람한 캡처의 출처를 검사한다. 엔진 테스트가 아니다."""
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
OLD = ROOT / 'docs/evidence/vfx-art-review-20261113'
ART = ROOT / 'docs/evidence/vfx-art-improvements-20261113'


def read(path):
    return json.loads(path.read_text())


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


hero = read(OLD / 'hero-review.json')['skills']
enemy = read(OLD / 'enemy-review.json')['attacks']
common = read(OLD / 'common-review.json')['entries']
current = (ROOT / 'src/shared/EnemyPatterns.luau').read_text()
definitions = re.findall(r'\{\["id"\]="[^"]+"[^{}]*\}', current)
ids = [re.search(r'\["id"\]="([^"]+)"', item)[1] for item in definitions]
assert len(ids) == len(set(ids)) == 146
assert set(ids) == {item['id'] for item in enemy}
profile_source = (ROOT / 'src/client/SkillVFXProfiles.luau').read_text()
assert len(hero) == len({item['id'] for item in hero}) == 128
assert all(item['id'] in profile_source for item in hero)
assert len(common) == 55
dash = [re.search(r'\["id"\]="([^"]+)"', item)[1]
        for item in definitions if '["motion"]="dash"' in item]
assert len(dash) == 11

captures = {}
for directory in [OLD / 'hero', *[ART / name for name in (
        'hero', 'hero-final', 'enemy', 'enemy-rings', 'enemy-impacts',
        'common', 'warnings-final', 'support-final', 'support-context-final')]]:
    rows = read(directory / 'manifest.json')
    entries = []
    for row in rows:
        filename = row.get('file') or row['id'] + '.png'
        path = directory / filename
        assert path.is_file(), path
        digest = sha(path)
        assert digest == row['sha256'], path
        entries.append({'id': row.get('id'), 'file': str(path.relative_to(ROOT)),
                        'sha256': digest})
    captures[str(directory.relative_to(ROOT))] = entries

core = ['HeroVFX', 'HeroVFXSurfaces', 'SkillVFXProfiles', 'AdvancedSkillVisual',
        'EnemySpellVFX', 'EnemySpellArt', 'EnemyPatternEffects', 'K0Telegraphs',
        'K0HitEffects', 'K0MageFocus', 'PixelFX', 'CuratedVFX',
        'SelenePresentation', 'DeepwoodNavigation', 'WindLanceVisual']
sources = {}
for name in core:
    path = 'src/client/' + name + '.luau'
    baseline = subprocess.check_output(['git', 'show', 'c1b578d4:' + path], cwd=ROOT)
    sources[path] = {'sha256': sha(ROOT / path),
                     'sameAsArtBuildSource': baseline == (ROOT / path).read_bytes()}

hero_images = {}
for directory in [OLD / 'hero', ART / 'hero', ART / 'hero-final']:
    for row in captures[str(directory.relative_to(ROOT))]:
        hero_images[row['id']] = row['file']

report = {
    'reviewSourceCommit': 'a040bf82', 'version': '0.105.4',
    'validationLevel': 'static_catalog_and_existing_capture_integrity',
    'engineRun': False, 'publishedClientRun': False, 'deviceRun': False,
    'counts': {'heroSkills': len(hero), 'enemySpecies': len({e['kind'] for e in enemy}),
               'enemyAttacks': len(ids), 'commonEffectGroups': len(common)},
    'dashWarningMismatchAttackIds': dash,
    'dashBoundarySample': {'secondsAfterWindup': .30, 'warning': .30 < .22,
                          'serverDashCollisionBranch': 0 <= .30 <= .45},
    'sourceComparison': sources,
    'hero': [{'id': e['id'], 'classId': e['classId'], 'shape': e['shape'],
              'ultimate': e['ultimate'], 'reviewCapture': hero_images[e['id']],
              'acceptance': 'not_run_current_gameplay'} for e in hero],
    'enemy': [{'id': e['id'], 'kind': e['kind'], 'shape': e['shape'],
               'motif': e['motif'], 'evidenceAttackId': e['motifEvidenceAttackId'],
               'currentDefinitionPresent': True,
               'acceptance': 'not_run_current_gameplay'} for e in enemy],
    'common': [{'id': e['id'], 'sourceFiles': e['sourceFiles'],
                'coverage': 'existing_inventory_and_source_delta_review',
                'acceptance': 'not_run_current_gameplay'} for e in common],
    'verifiedExistingCaptures': captures,
}
(HERE / 'inventory.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'counts': report['counts'], 'captures': {k: len(v) for k, v in captures.items()},
                  'unchangedCoreModules': sum(v['sameAsArtBuildSource'] for v in sources.values()),
                  'dashMismatchCount': len(dash)}, ensure_ascii=False))
