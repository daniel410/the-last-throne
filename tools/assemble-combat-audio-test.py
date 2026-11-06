"""Bundle current audio sources for an isolated empty-place Studio test.
Run: python3 tools/assemble-combat-audio-test.py
Then: run-in-roblox --place <empty-local.rbxlx> --script /tmp/tlt-combat-audio-native.luau
"""
from pathlib import Path
modules=[('AdvancedSkills','src/shared/AdvancedSkills.luau'),('K0Config','src/shared/K0Config.luau'),('SkillPresentation','src/shared/SkillPresentation.luau'),('PixelFXCatalog','src/shared/PixelFXCatalog.luau'),('CombatAudioCatalog','src/shared/CombatAudioCatalog.luau'),('Audio','src/client/K0CombatAudio.luau')]
parts=['local deps={}']
for name,path in modules:
 s=Path(path).read_text()
 if name=='K0Config':
  s=s.replace('game and require(game:GetService("ReplicatedStorage").Shared.AdvancedSkills) or dofile("src/shared/AdvancedSkills.luau")','deps.AdvancedSkills')
 import re
 s=re.sub(r'require\((?:script.Parent|RS.Shared)\.(\w+)\)',r'deps.\1',s)
 parts.append('deps.'+name+'=(function()\n'+s+'\nend)()')
parts.append(Path('tests/combat-audio-native.luau').read_text())
Path('/tmp/tlt-combat-audio-native.luau').write_text('\n'.join(parts))
