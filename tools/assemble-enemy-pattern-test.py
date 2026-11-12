"""Bundle current modules and isolated native engine checks; never touches live accounts."""
from pathlib import Path
import json,re
modules={
'EnemyPatterns':'src/shared/EnemyPatterns.luau','EnemyAttackGeometry':'src/shared/EnemyAttackGeometry.luau','EnemyPatternText':'src/shared/EnemyPatternText.luau',
'EnemyPatternRuntime':'src/server/Combat/EnemyPatternRuntime.luau','EnemyModelDetails':'src/server/World/EnemyModelDetails.luau','GloamwoodAppearance':'src/server/World/GloamwoodAppearance.luau',
'K0PlayerHitFeedback':'src/client/K0PlayerHitFeedback.luau','EnemyPatternPose':'src/client/EnemyPatternPose.luau','CombatAudioCatalog':'src/shared/CombatAudioCatalog.luau','BossHeroImpact':'src/client/BossHeroImpact.luau','EnemySpellProfiles':'src/shared/EnemySpellProfiles.luau','PixelFXAssets':'src/shared/PixelFXAssets.luau','PixelFX':'src/client/PixelFX.luau','EnemySpellArt':'src/client/EnemySpellArt.luau','EnemySpellVFX':'src/client/EnemySpellVFX.luau','EnemyPatternEffects':'src/client/EnemyPatternEffects.luau'}
parts=['local deps={}'];sources={}
# Catalog source uses FXCatalog only in get(), which these tests do not call.
parts.append('deps.PixelFXCatalog={}')
for name,path in modules.items():
 s=Path(path).read_text();sources[path]=s
 s=re.sub(r"require\((?:game:GetService\(['\"]ReplicatedStorage['\"]\)|RS)\.Shared\.(\w+)\)",r'deps.\1',s)
 s=re.sub(r'require\(script.Parent\.(\w+)\)',r'deps.\1',s)
 parts.append('deps.'+name+'=(function()\n'+s+'\nend)()')
# Compile every touched runtime source, including glue, before evaluating engine scenarios.
paths=list(modules.values())+['src/server/Combat/CombatService.luau','src/server/Story/DeepwoodService.luau','src/server/World/TdMonsterAppearance.luau','src/client/K0EnemyMotion.luau','src/client/K0EnemyVisual.luau','src/client/RegionalCasterMotion.luau','src/client/GloamwoodMotion.luau','src/client/PixelFXController.luau','src/client/K0PlayerHitFeedback.luau']
parts.append('local sources='+ '{'+','.join('['+json.dumps(p)+']='+json.dumps(Path(p).read_text(),ensure_ascii=False)for p in paths)+'}')
parts.append(Path('tests/enemy-patterns-native.luau').read_text())
Path('/tmp/tlt-enemy-patterns-native.luau').write_text('\n'.join(parts))
print('Native bundle bytes',Path('/tmp/tlt-enemy-patterns-native.luau').stat().st_size)
