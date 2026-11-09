"""Freeze HEAD runtime + this task's files; exclude unrelated working-tree edits."""
from pathlib import Path
import hashlib
import argparse
import io
import json
import subprocess
import tarfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
parser.add_argument('--source', default='HEAD')
parser.add_argument('--full-combat', action='store_true', help='Include the historical full combat matrix for baseline comparison')
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
commit = subprocess.check_output(['git', 'rev-parse', args.source], cwd=root).decode().strip()
archive = subprocess.check_output(['git', 'archive', commit, 'src'], cwd=root)
with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
    tar.extractall(out, filter='data')
owned = ['src/client/K0HitStop.luau', 'src/client/K0CombatAudio.luau',
         'src/client/K0HitEffects.luau', 'src/client/K0SwordVisual.luau',
         'src/server/Combat/EnemyKnockback.luau', 'src/server/Combat/CombatService.luau']
for name in owned:
    (out / name).write_bytes((root / name).read_bytes())
project = {'name': 'HeroFeedbackQA', 'tree': {'$className': 'DataModel',
    'Players': {'$properties': {'CharacterAutoLoads': False}},
    'ReplicatedStorage': {'Shared': {'$path': 'src/shared'}},
    'ServerScriptService': {'Server': {'$path': 'src/server'}},
    'StarterPlayer': {'StarterPlayerScripts': {'Client': {'$path': 'src/client'}}}}}
(out / 'qa.project.json').write_text(json.dumps(project))
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
parts = ['for _,s in game:GetDescendants()do if s:IsA("Script")or s:IsA("LocalScript")then s.Disabled=true end end']
parts.append('do\n' + (root / 'tests/hero-hit-feedback-native.luau').read_text() + '\nend')
parts.append('do\nlocal Client=game.StarterPlayer.StarterPlayerScripts.Client\n'
             'local S=game.ReplicatedStorage.Shared\n'
             'local deps={Audio=require(Client.K0CombatAudio),CombatAudioCatalog=require(S.CombatAudioCatalog),K0Config=require(S.K0Config)}\n'
             + subprocess.check_output(['git', 'show', commit + ':tests/combat-audio-native.luau'], cwd=root).decode() + '\nend')
for name in ['tests/k0-hit-effects-native.luau', 'tests/k0-basic-attacks-native.luau']:
    source = (root / name).read_text() if name.endswith('k0-basic-attacks-native.luau') else subprocess.check_output(['git', 'show', commit + ':' + name], cwd=root).decode()
    if name.endswith('k0-basic-attacks-native.luau') and not args.full_combat:
        marker = 'local function case(name, body)\n'
        assert source.count(marker) == 1
        selection = ''' if not (name:match('^confirmed%-hit') or name=='miss-and-forcefield-do-not-broadcast-hit-feedback'
 or name:match('^ordinary%-') or name=='fully-absorbed-hit-does-not-interrupt-hero'
 or name=='skills-resolve-at-their-own-hit-window' or name:match('^dwarf%-')
 or name=='branch-boss-control-immunity-retains-damage' or name=='mage-melee-hit-deduplicate-and-buffer'
 or name=='rapid-fire-stops-on-interruption-and-does-not-backfill-stale-shots') then return end
'''
        source = source.replace(marker, marker + selection)
    parts.append('do\n' + source + '\nend')
(out / 'probe.luau').write_text('\n'.join(parts))
manifest = {str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in (out / 'src').rglob('*') if p.is_file()}
(out / 'inputs.json').write_text(json.dumps({'baseline': commit, 'overlay': owned, 'sha256': manifest,
    'testSha256': {name: hashlib.sha256((root / name).read_bytes()).hexdigest() for name in
        ['tests/hero-hit-feedback-native.luau', 'tests/k0-basic-attacks-native.luau', 'tools/prepare-hero-feedback-tests.py']},
    'probeSha256': hashlib.sha256((out / 'probe.luau').read_bytes()).hexdigest()}, indent=2) + '\n')
print(out)
