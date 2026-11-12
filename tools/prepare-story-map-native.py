"""고정 빌드의 스토리 맵 구성/동선 검증. --overlay는 개발 후보만 주입한다."""
from pathlib import Path
import argparse, json, hashlib
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--overlay',action='store_true');p.add_argument('--output',type=Path,default=Path('/tmp/tlt-story-map-native.luau'));a=p.parse_args()
paths=['src/server/World/CampaignStoryComposition.luau','src/server/World/EpicWorldArt.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
for path in paths:
 name=Path(path).stem;source=(root/path).read_text()
 if a.overlay:
  code+=f'do local parent=game.ServerScriptService.Server.World;local m=parent:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={json.dumps(source)};m.Parent=parent end\n'
 else:code+=f'assert(game.ServerScriptService.Server.World.{name}.Source=={json.dumps(source)},"source mismatch {name}")\n'
code+="for _,root in ipairs({game.ServerScriptService.Server,game.ReplicatedStorage.Shared,game.StarterPlayer.StarterPlayerScripts.Client})do for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end end\nprint('STORY_MAP_SOURCE_COMPILE_PASS')\n"
for suite in ['tests/campaign-story-composition-native.luau','tests/scenery-collision-native.luau','tests/campaign-combat-route-world-native.luau']:
 code+='do local result=(function()\n'+(root/suite).read_text()+'\nend)();if result then assert(not result.blockers or #result.blockers==0,"route blockers");assert(not result.floorFailures or #result.floorFailures==0,"route floor failures");assert(not result.failureCount or result.failureCount==0,"collision failures") end end\n';paths.append(suite)
code+="print('STORY_MAP_REVIEW_READY');for i=1,600 do if _G.TLTReviewDone then break end task.wait(1)end\n"
a.output.write_text(code)
paths.append('tools/prepare-story-map-native.py')
a.output.with_suffix('.inputs.json').write_text(json.dumps({path:hashlib.sha256((root/path).read_bytes()).hexdigest()for path in paths},indent=2)+'\n')
print(a.output)
