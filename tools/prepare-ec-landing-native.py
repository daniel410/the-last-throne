"""TLT-063 Caldera 연결부의 단차·양방향 보행 회귀. 소스를 주입하지 않는다."""
from pathlib import Path
import argparse
import hashlib
import json

p = argparse.ArgumentParser()
p.add_argument('--review', action='store_true')
a = p.parse_args()
inputs = ['src/server/World/CampaignCombatRouteWorld.luau']
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')\n"
code += "for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\n"
code += "local bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end\n"
for path in inputs:
    code += f'assert(game.ServerScriptService.Server.World.{Path(path).stem}.Source=={json.dumps(Path(path).read_text())},"frozen source mismatch")\n'
code += "for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end end\nprint('ROUTE_BLOCKERS_SOURCE_COMPILE_PASS')\n"
code += 'local qaWorld\n'
for name in ['regional-concept-art-native', 'campaign-story-composition-native', 'scenery-collision-native', 'campaign-combat-route-world-native', 'epic-environment-native', 'story-terrain-fixes-native', 'frozen-ravine-landforms-native']:
    path = f'tests/{name}.luau'
    inputs.append(path)
    code += 'do local r=assert(loadstring(' + json.dumps(Path(path).read_text()) + '))();' + ('qaWorld=r;' if name=='regional-concept-art-native' else '') + 'if type(r)=="table"then assert(not r.failureCount or r.failureCount==0);assert(not r.blockers or #r.blockers==0);assert(not r.floorFailures or #r.floorFailures==0)end end\n'
path = 'tests/epic-map-navigation-native.luau'
inputs.append(path)
for variant in ['points', 'worldPoints']:
    source = Path(path).read_text().replace('local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()', 'local world=assert(qaWorld)')
    source = source.replace('and c.combatRoutes[g.id].points', 'and c.combatRoutes[g.id].'+variant)
    code += 'do local fn=assert(loadstring('+json.dumps(source)+'));setfenv(fn,setmetatable({qaWorld=qaWorld},{__index=getfenv()}));local nav=fn();assert(#nav.blockers==0 and #nav.floors==0 and #nav.corrections==0 and #nav.routeFailures==0 and #nav.lowSteps==0,"global navigation '+variant+'");print("ROUTE_VARIANT_PASS '+variant+'")end\n'
path='tests/ec-landing-walk-native.luau'
inputs.append(path)
code += 'assert(loadstring('+json.dumps(Path(path).read_text())+'))()\n'
if a.review:
    code += "_G.RegionalConceptWorld=qaWorld;require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere).update('EmberCaldera');print('ROUTE_BLOCKERS_REVIEW_READY');for i=1,600 do if _G.TLTReviewDone then break end task.wait(1)end\n"
out = Path('/tmp/tlt-ec-landing-native.luau')
out.write_text(code)
out.with_suffix('.inputs.json').write_text(json.dumps({path: hashlib.sha256(Path(path).read_bytes()).hexdigest() for path in inputs}, indent=2) + '\n')
print(out)
