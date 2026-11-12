"""Prepare isolated source-pinned combat, migration geometry and HUD checks."""
from pathlib import Path
import argparse, json
p=argparse.ArgumentParser()
p.add_argument('--preview',action='store_true',help='Inject candidate modules into an old disposable artifact')
p.add_argument('--bake',action='store_true',help='Export cartography after all checks pass')
p.add_argument('--output',type=Path,default=Path('/tmp/tlt-story-combat-pacing-native.luau'))
a=p.parse_args()
paths=['src/shared/CampaignContent.luau','src/shared/CampaignCombatPacing.luau','src/shared/CampaignCartography.luau','src/shared/DeepwoodProgress.luau','src/shared/AdventureRules.luau','src/client/BattlePresentation.luau','src/client/BattleController.luau','src/client/init.client.luau']
roots={'shared':'game.ReplicatedStorage.Shared','client':'game.StarterPlayer.StarterPlayerScripts.Client'}
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated only')\n"
for path in paths:
    parts=path.removesuffix('.luau').split('/');parent=roots[parts[1]];name=parts[-1]
    node=parent if name=='init.client' else parent+'.'+name
    source=json.dumps(Path(path).read_text())
    if a.preview and name!='CampaignCartography':
        if name=='init.client':code+=f'{parent}.Source={source}\n'
        else:code+=f"do local m={parent}:FindFirstChild('{name}')or Instance.new('ModuleScript');m.Name='{name}';m.Source={source};m.Parent={parent} end\n"
    code+=f'assert({node}.Source=={source},"source pin: {path}")\n'
code+="for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end end\n"
for test in ['campaign-combat-route-runtime-native','campaign-combat-route-world-native','campaign-expansion-native','story-combat-pacing-native','cartography-native']:
    code+=f"do local r=assert(loadstring({json.dumps(Path('tests/'+test+'.luau').read_text())},{json.dumps(test)}))();assert(not r.blockers or #r.blockers==0,'body collision');assert(not r.floorFailures or #r.floorFailures==0,'floor failure')end\n"
# Repeat real production lifecycle for a normal supplemental patrol, rather than a boss.
source=Path('tests/campaign-combat-route-runtime-native.luau').read_text().replace("local c=C.byId['DW-05'];local g=P.goal(c,'warlord')","local c=C.byId['GW-01'];local g=P.goal(c,'lantern_patrol')").replace('expansionVersion=1}','expansionVersion=1,combatPacingVersion=1}').replace('total==expected and boss==1','total==expected and boss==0')
code+=f"assert(loadstring({json.dumps(source)},'PatrolLifecycle'))()\n"
if a.bake:code+=f"assert(loadstring({json.dumps(Path('tools/export-cartography-native.luau').read_text())},'CartographyBake'))()\n"
code+="print('STORY_COMBAT_PACING_COMPLETE')\n"
a.output.write_text(code);print(a.output)
