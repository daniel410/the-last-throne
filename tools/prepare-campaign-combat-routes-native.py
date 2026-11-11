"""Pin route implementation and exercise real server, map, geometry and story paths."""
from pathlib import Path
import json,argparse
p=argparse.ArgumentParser();p.add_argument('--bake',action='store_true');p.add_argument('--runtime-only',action='store_true');p.add_argument('--preview-seconds',type=int,default=0);args=p.parse_args()
paths=['src/shared/CampaignCartography.luau','src/shared/CampaignContent.luau','src/shared/CampaignCombatRoutes.luau','src/shared/CampaignRouteFootprint.luau','src/shared/EncounterPopulation.luau','src/shared/DeepwoodEncounterBalance.luau','src/shared/Difficulty.luau','src/server/Story/DeepwoodService.luau','src/server/World/CampaignWorld.luau','src/server/World/CampaignCombatRouteWorld.luau','src/server/World/DeepwoodPlaces.luau','src/server/World/EpicWorldArt.luau','src/server/World/CampaignSceneryPlacement.luau','src/server/World/CampaignRouteClearance.luau','src/client/DeepwoodJournal.luau']
roots={'shared':'game.ReplicatedStorage.Shared','server':'game.ServerScriptService.Server','client':'game.StarterPlayer.StarterPlayerScripts.Client'}
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated only')\n"
for path in paths:
 parts=path.removesuffix('.luau').split('/');node=roots[parts[1]]+'.'+'.'.join(parts[2:])
 code+=f'assert({node}.Source=={json.dumps(Path(path).read_text(),ensure_ascii=False)},"source pin mismatch: {path}")\n'
code+='''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end
end
'''
tests=['tests/campaign-combat-route-runtime-native.luau']
if not args.runtime_only:tests+=['tests/campaign-combat-route-world-native.luau','tests/campaign-expansion-native.luau']
for test in tests:
 code+='local result=assert(loadstring('+json.dumps(Path(test).read_text(),ensure_ascii=False)+','+json.dumps(test)+'))()\n'
 code+='assert(not result.blockers or #result.blockers==0,"route/incident blockers remain")\nassert(not result.floorFailures or #result.floorFailures==0,"route floors remain invalid")\n'
if args.bake:code+='assert(loadstring('+json.dumps(Path('tools/export-cartography-native.luau').read_text(),ensure_ascii=False)+'))()\n'
if args.preview_seconds:code+=f'print("ROUTE_WORLD_READY");task.wait({args.preview_seconds})\n'
Path('/tmp/tlt-combat-routes-native.luau').write_text(code);print('/tmp/tlt-combat-routes-native.luau')
