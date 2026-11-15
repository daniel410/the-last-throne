"""TLT-062 고정 빌드 표면/물리 회귀. 원문 소스 주입 없이 실행한다."""
from pathlib import Path
import json, hashlib
inputs=['src/server/World/CampaignSurfaceFinish.luau','src/server/World/FrozenSurfaceUnderlays.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\nfor _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\nlocal bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end\n"
for path in inputs:
 code+=f'assert(game.ServerScriptService.Server.World.{Path(path).stem}.Source=={json.dumps(Path(path).read_text())},"source mismatch")\n'
code+="for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,s in r:GetDescendants()do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end end\n"
code+="local messages={};_G.SurfaceMessages=messages;local function log(v)table.insert(messages,tostring(v));print(v)end\nlog('SURFACE_SOURCE_COMPILE_PASS');local qaWorld\n"
def execute(source, label, first=False, nav=False):
 env='{print=log,qaWorld=qaWorld}'
 result='qaWorld=r;' if first else ''
 checks='assert(#r.blockers==0 and #r.floors==0 and #r.corrections==0 and #r.routeFailures==0 and #r.lowSteps==0);' if nav else 'assert(not r.failureCount or r.failureCount==0);assert(not r.blockers or #r.blockers==0);assert(not r.floorFailures or #r.floorFailures==0);'
 return 'do local fn=assert(loadstring('+json.dumps(source)+'));setfenv(fn,setmetatable('+env+',{__index=getfenv()}));local r=fn();'+result+'if type(r)=="table"then '+checks+'end;log('+json.dumps(label)+')end\n'
for name in ['regional-concept-art-native','campaign-story-composition-native','scenery-collision-native','campaign-combat-route-world-native','epic-environment-native','story-terrain-fixes-native','frozen-ravine-landforms-native','frozen-ravine-vegetation-native','frozen-surface-underlays-native']:
 path=f'tests/{name}.luau';inputs.append(path);code+=execute(Path(path).read_text(),name+' PASS',first=name=='regional-concept-art-native')
path='tests/epic-map-navigation-native.luau';inputs.append(path)
for variant in ['points','worldPoints']:
 source=Path(path).read_text().replace('local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()','local world=assert(qaWorld)').replace('and c.combatRoutes[g.id].points','and c.combatRoutes[g.id].'+variant)
 code+=execute(source,'SURFACE_NAV_PASS '+variant,nav=True)
path='tests/fv03-verge-walk-native.luau';inputs.append(path);code+=execute(Path(path).read_text(),'SURFACE_WALK_PASS')
code+="_G.SurfaceDone=true;return game.HttpService:JSONEncode(messages)\n"
out=Path('/tmp/tlt-fv-surface-native.luau');out.write_text(code)
out.with_suffix('.inputs.json').write_text(json.dumps({p:hashlib.sha256(Path(p).read_bytes()).hexdigest()for p in inputs},indent=2)+'\n')
print(out)
