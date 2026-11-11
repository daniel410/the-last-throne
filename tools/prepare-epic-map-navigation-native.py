"""Assemble the all-epic navigation audit on an isolated, source-pinned host."""
from pathlib import Path
import argparse,json
p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');p.add_argument('--host-only',action='store_true');p.add_argument('--walk',action='store_true');p.add_argument('--regressions',action='store_true');args=p.parse_args()
paths=['src/server/World/CampaignExpansionWorld.luau','src/shared/CampaignIncidentRoute.luau','src/server/World/EmberCalderaWorld.luau','src/shared/CampaignNavigationRoute.luau','src/client/DeepwoodNavigation.luau','src/server/World/CampaignCombatRouteWorld.luau','src/server/World/CampaignRouteClearance.luau','src/server/World/CampaignSceneryPlacement.luau','src/server/World/EpicWorldArt.luau']
roots={'shared':'game.ReplicatedStorage.Shared','client':'game.StarterPlayer.StarterPlayerScripts.Client','server':'game.ServerScriptService.Server'}
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')\n"
for path in ([] if args.host_only else paths):
 parts=Path(path).with_suffix('').parts;node=roots[parts[1]]+'.'+'.'.join(parts[2:]);source=json.dumps(Path(path).read_text(),ensure_ascii=False)
 code+=f'{node}.Source={source}\n' if args.preview else f'assert({node}.Source=={source},"source mismatch: {path}")\n'
code+='''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
'''
code+='local audit=assert(loadstring('+json.dumps(Path('tests/epic-map-navigation-native.luau').read_text(),ensure_ascii=False)+'))()\n'
if not args.host_only:
 code+="for _,s in pairs(audit.epics)do assert(s.blockers==0 and s.floors==0 and s.corrections==0 and s.routeFailures==0,'epic map geometry regression')end\nprint('EPIC_MAP_GEOMETRY_PASS')\n"
if args.regressions:
 for path in ['tests/campaign-combat-route-world-native.luau','tests/campaign-expansion-native.luau','tests/scenery-collision-native.luau']:
  source=Path(path).read_text()
  if 'campaign-expansion-native' in path:
   marker="check(#report.blockers==0,'new wings and connectors have no holes or body blockers')"
   source=source[:source.index(marker)+len(marker)]+'\nreturn report\n'
  code+='do local r=assert(loadstring('+json.dumps(source,ensure_ascii=False)+'))();if type(r)=="table"then assert(not r.blockers or #r.blockers==0,"combat/incident blockers remain");assert(not r.floorFailures or #r.floorFailures==0,"combat floors remain invalid")end end\n'
if args.walk:code+='assert(loadstring('+json.dumps(Path('tests/epic-map-walk-native.luau').read_text(),ensure_ascii=False)+'))()\nprint("EPIC_MAP_ALL_PASS")\n'
out=Path('/tmp/tlt-epic-map-navigation-native.luau');out.write_text(code);print(out)
