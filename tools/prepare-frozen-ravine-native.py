"""TLT-062 고정 빌드의 실제 지형·전 지역 회귀. 소스를 주입하지 않는다."""
from pathlib import Path
import argparse
import hashlib
import json

p = argparse.ArgumentParser()
p.add_argument('--review', action='store_true')
a = p.parse_args()
inputs = ['src/server/World/FrozenRavineLandforms.luau', 'src/server/World/EpicWorldArt.luau']
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')\n"
code += "for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\n"
code += "local bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end\n"
for path in inputs:
    code += f'assert(game.ServerScriptService.Server.World.{Path(path).stem}.Source=={json.dumps(Path(path).read_text())},"frozen source mismatch")\n'
code += "for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end end\nprint('FV03_FIXED_SOURCE_COMPILE_PASS')\n"
code += 'local qaWorld\n'
for name in ['regional-concept-art-native', 'campaign-story-composition-native', 'scenery-collision-native', 'campaign-combat-route-world-native', 'epic-environment-native', 'story-terrain-fixes-native', 'frozen-ravine-landforms-native']:
    path = f'tests/{name}.luau'
    inputs.append(path)
    code += 'do local r=assert(loadstring(' + json.dumps(Path(path).read_text()) + '))();' + ('qaWorld=r;' if name=='regional-concept-art-native' else '') + 'if type(r)=="table"then assert(not r.failureCount or r.failureCount==0);assert(not r.blockers or #r.blockers==0);assert(not r.floorFailures or #r.floorFailures==0)end end\n'
path = 'tests/epic-map-navigation-native.luau'
inputs.append(path)
code += 'local navFn=assert(loadstring(' + json.dumps(Path(path).read_text().replace('local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()', 'local world=assert(qaWorld)')) + '));setfenv(navFn,setmetatable({qaWorld=qaWorld},{__index=getfenv()}));local nav=navFn()\n'
code += "local fv=assert(nav.epics['3']or nav.epics[3]);assert(fv.blockers==0 and fv.floors==0 and fv.corrections==0 and fv.routeFailures==0,'Frozen Vale regression')\n"
code += "print('FV03_SCOPED_ACCEPTANCE_PASS; other-region navigation findings require baseline comparison')\n"
path='tests/epic-overland-native.luau'
inputs.append(path)
code += 'assert(loadstring('+json.dumps(Path(path).read_text())+'))()\n'
if a.review:
    code += "_G.RegionalConceptWorld=qaWorld;require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere).update('FrozenVale');print('FV03_REVIEW_READY');for i=1,600 do if _G.TLTReviewDone then break end task.wait(1)end\n"
out = Path('/tmp/tlt-frozen-ravine-native.luau')
out.write_text(code)
out.with_suffix('.inputs.json').write_text(json.dumps({path: hashlib.sha256(Path(path).read_bytes()).hexdigest() for path in inputs}, indent=2) + '\n')
print(out)
