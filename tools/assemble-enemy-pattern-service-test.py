from pathlib import Path
s=Path('tests/k0-basic-attacks-native.luau').read_text()
prefix=s.split('\tfor classId,hp in pairs')[0]
prefix=prefix.replace('Config=Config, playerStates=', 'Pack=Pack,Afflictions=Afflictions,packContext=packContext,clearMechanics=function()Afflictions.clearAll(now())end,tacticalDestination=tacticalDestination,chooseEnemyPattern=chooseEnemyPattern,moveEnemy=moveEnemy,damageEnemy=damageEnemy,setStoryTargetValidator=CombatService.setStoryTargetValidator,applyStoryHazard=CombatService.applyStoryHazard,setPatternRemote=function(value)patternRemote=value end, Config=Config, playerStates=')
prefix=prefix.replace('if api then\n', 'if api then\n  api.clearMechanics()\n',1)
suffix=s[s.rfind('end, debug.traceback)'):]
out=prefix+Path('tests/enemy-pattern-service-cases.luau').read_text()+Path('tests/enemy-combat-movement-cases.luau').read_text()+Path('tests/enemy-encounter-depth-cases.luau').read_text()+suffix
out=out.replace('K0_BASIC_ATTACK_NATIVE','ENEMY_PATTERN_SERVICE_NATIVE')
Path('/tmp/tlt-enemy-pattern-service-native.luau').write_text(out)
print('Service suite bytes',len(out))
