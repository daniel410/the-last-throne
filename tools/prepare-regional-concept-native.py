"""격리 Studio의 소스·콘셉트·물리·도보 회귀. 고정 빌드는 주입하지 않는다."""
from pathlib import Path
import argparse,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--overlay',action='store_true');p.add_argument('--review',action='store_true');a=p.parse_args()
paths=['src/shared/CampaignBiome.luau','src/server/World/CampaignSurfaceFinish.luau','src/server/World/CampaignWorld.luau','src/server/World/RegionalArchitectureTemplates.luau','src/server/World/RegionalArchitecture.luau','src/server/World/RegionalConceptProfiles.luau','src/server/World/RegionalConceptArt.luau','src/server/World/EpicEnvironmentKit.luau','src/server/World/EpicWorldArt.luau','src/client/DeepwoodAtmosphere.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene only')\nfor _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\nlocal bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end\n"
for path in paths:
 name=Path(path).stem;source=Path(path).read_text();parent='game.ReplicatedStorage.Shared'if '/shared/'in path else 'game.StarterPlayer.StarterPlayerScripts.Client'if '/client/'in path else 'game.ServerScriptService.Server.World'
 if a.overlay:code+=f'do local parent={parent};local m=parent:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={json.dumps(source,ensure_ascii=False)};m.Parent=parent end\n'
 else:code+=f'assert({parent}.{name}.Source=={json.dumps(source,ensure_ascii=False)},"source mismatch {name}")\n'
code+="for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end end\nprint('REGIONAL_SOURCE_COMPILE_PASS')\n"
code+='local qaWorld=assert(loadstring('+json.dumps(Path('tests/regional-concept-art-native.luau').read_text(),ensure_ascii=False)+'))()\n'
for path in ['tests/campaign-story-composition-native.luau','tests/scenery-collision-native.luau','tests/campaign-combat-route-world-native.luau','tests/epic-environment-native.luau','tests/epic-overland-native.luau']:
 source=Path(path).read_text();code+='do local r=assert(loadstring('+json.dumps(source,ensure_ascii=False)+'))();if type(r)=="table"then assert(not r.blockers or #r.blockers==0);assert(not r.floorFailures or #r.floorFailures==0);assert(not r.failureCount or r.failureCount==0)end end\n';paths.append(path)
# Reuse the existing world for the measured navigation sweep.
source=Path('tests/epic-map-navigation-native.luau').read_text().replace('local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()','local world=assert(qaWorld)')
code+='do local fn=assert(loadstring('+json.dumps(source,ensure_ascii=False)+'));setfenv(fn,setmetatable({qaWorld=qaWorld},{__index=getfenv()}));local r=fn();for _,s in pairs(r.epics)do assert(s.blockers==0 and s.floors==0 and s.corrections==0 and s.routeFailures==0)end end\n'
code+='assert(loadstring('+json.dumps(Path('tests/story-terrain-fixes-native.luau').read_text(),ensure_ascii=False)+'))()\n'
code+="print('REGIONAL_CONCEPT_ALL_PASS')\n"
if a.review:code+="_G.RegionalConceptWorld=qaWorld;for i=1,600 do if _G.TLTReviewDone then break end task.wait(1)end\n"
out=Path('/tmp/tlt-regional-concept-native.luau');out.write_text(code)
paths+=['tests/regional-concept-art-native.luau','tests/story-terrain-fixes-native.luau','tests/epic-map-navigation-native.luau']
out.with_suffix('.inputs.json').write_text(json.dumps({p:hashlib.sha256(Path(p).read_bytes()).hexdigest()for p in paths},indent=2)+'\n')
print(out)
