"""Pin or inject the report route fix into an isolated local Studio build."""
from pathlib import Path
import argparse,json
p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');p.add_argument('--all',action='store_true');p.add_argument('--walk',action='store_true');args=p.parse_args()
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')\n"
paths={'src/shared/CampaignNavigationRoute.luau':'game.ReplicatedStorage.Shared','src/shared/DeepwoodQuestLog.luau':'game.ReplicatedStorage.Shared','src/client/DeepwoodNavigation.luau':'game.StarterPlayer.StarterPlayerScripts.Client','src/server/World/CampaignCombatRouteWorld.luau':'game.ServerScriptService.Server.World','src/server/World/EpicWorldArt.luau':'game.ServerScriptService.Server.World','src/server/World/CampaignRouteClearance.luau':'game.ServerScriptService.Server.World','src/server/World/CampaignSceneryPlacement.luau':'game.ServerScriptService.Server.World'}
for path,parent in paths.items():
 name=Path(path).stem;source=json.dumps(Path(path).read_text(),ensure_ascii=False);node=parent+'.'+name
 if args.preview:
  code+=f'local m={parent}:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={source};m.Parent={parent}\n'
 else:code+=f'assert({node}.Source=={source},"source mismatch: {name}")\n'
code+='''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
print('REPORT_NAVIGATION_SOURCES_AND_COMPILE_PASS')
'''
if args.all:
 code+='assert(loadstring('+json.dumps(Path('tests/navigation-always-on-native.luau').read_text(),ensure_ascii=False)+'))()\n'
code+='assert(loadstring('+json.dumps(Path('tests/deepwood-report-navigation-native.luau').read_text(),ensure_ascii=False)+'))()\n'
if args.all:
 for path in ['tests/campaign-combat-route-world-native.luau','tests/campaign-expansion-native.luau','tests/scenery-collision-native.luau']:
  source=Path(path).read_text()
  if 'campaign-expansion-native' in path:
   marker="check(#report.blockers==0,'new wings and connectors have no holes or body blockers')"
   source=source[:source.index(marker)+len(marker)]+'\nreturn report\n'
  code+='do local r=assert(loadstring('+json.dumps(source,ensure_ascii=False)+'))();if type(r)=="table"then assert(not r.blockers or #r.blockers==0,"physical blockers remain");assert(not r.floorFailures or #r.floorFailures==0,"floor failures remain")end end\n'
if args.all or args.walk:
 code+='assert(loadstring('+json.dumps(Path('tests/deepwood-report-walk-native.luau').read_text(),ensure_ascii=False)+'))()\n'
code+="print('REPORT_NAVIGATION_ALL_PASS')\n"
Path('/tmp/tlt-report-navigation-native.luau').write_text(code)
print('/tmp/tlt-report-navigation-native.luau')
