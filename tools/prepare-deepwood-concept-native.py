"""Deepwood 콘셉트 구현의 고정 소스·물리·서사 회귀 검증. 후보만 --overlay 사용."""
from pathlib import Path
import argparse,json,hashlib
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--overlay',action='store_true');p.add_argument('--output',type=Path,default=Path('/tmp/tlt-deepwood-concept-native.luau'));a=p.parse_args()
paths=['src/server/World/DeepwoodElderGrove.luau','src/server/World/DeepwoodElderGroveGeometry.luau','src/server/World/CampaignSceneryCollision.luau','src/server/World/DeepwoodArchitectureTemplates.luau','src/server/World/DeepwoodArchitecture.luau','src/server/World/DeepwoodConceptArt.luau','src/server/World/EpicWorldArt.luau','src/server/World/CampaignWorld.luau','src/client/DeepwoodAtmosphere.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\nfor _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\nlocal bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end\n"
for path in paths:
 name=Path(path).stem;source=(root/path).read_text();parent='game.StarterPlayer.StarterPlayerScripts.Client'if '/client/'in path else 'game.ServerScriptService.Server.World'
 if a.overlay:code+=f'do local parent={parent};local m=parent:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={json.dumps(source)};m.Parent=parent end\n'
 else:code+=f'assert({parent}.{name}.Source=={json.dumps(source)},"source mismatch {name}")\n'
code+="for _,root in ipairs({game.ServerScriptService.Server,game.ReplicatedStorage.Shared,game.StarterPlayer.StarterPlayerScripts.Client})do for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end end\nprint('DEEPWOOD_CONCEPT_SOURCE_COMPILE_PASS')\n"
for suite in ['tests/deepwood-concept-art-native.luau','tests/campaign-story-composition-native.luau','tests/scenery-collision-native.luau','tests/campaign-combat-route-world-native.luau','tests/epic-environment-native.luau']:
 code+='do local result=(function()\n'+(root/suite).read_text()+'\nend)();if result then assert(not result.blockers or #result.blockers==0,"route blockers");assert(not result.floorFailures or #result.floorFailures==0,"route floor failures");assert(not result.failureCount or result.failureCount==0,"collision failures")end end\n';paths.append(suite)
audit='tools/audit-campaign-routes.luau';paths.append(audit)
code+='local audit=(function()\n'+(root/audit).read_text()+'\nend)()\n'
code+='''local C=require(game.ReplicatedStorage.Shared.CampaignContent)
for i,c in ipairs(C.chapters)do if c.epic==1 then audit.chapter(i);task.wait()end end
for i,e in ipairs(require(game.ReplicatedStorage.Shared.CampaignAccess).edges)do if e[1]:sub(1,2)=='DW'and e[2]:sub(1,2)=='DW'then audit.edge(i);task.wait()end end
audit.returns()
local summary={segments=0,success=0,samePoint=0,noPath=0,failures={}}
local function visit(t)
 if type(t)~='table'then return end
 if t.pathStatus then
  summary.segments+=1
  if t.pathStatus=='Success'then summary.success+=1 elseif t.pathStatus=='SamePoint'then summary.samePoint+=1
  else summary.noPath+=1;summary.failures[#summary.failures+1]={label=t.label,status=t.pathStatus}end
 end
 for _,v in pairs(t)do if type(v)=='table'then visit(v)end end
end
_G.DeepwoodRouteResult={rows=audit.rows,edges=audit.edges,returns=audit.returnRoutes}
visit(_G.DeepwoodRouteResult)
print('DEEPWOOD_PATHFINDING_QA '..game.HttpService:JSONEncode(summary))
assert(summary.noPath==0,'Deepwood pathfinding regression')
'''
code+="require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere).update('Deepwood')\nprint('DEEPWOOD_CONCEPT_REVIEW_READY');for i=1,900 do if _G.TLTReviewDone then break end task.wait(1)end\n"
a.output.write_text(code)
paths.extend(['tools/prepare-deepwood-concept-native.py','assets/models/deepwood-elder-grove-v1/runtime.rbxmx'])
a.output.with_suffix('.inputs.json').write_text(json.dumps({f:hashlib.sha256((root/f).read_bytes()).hexdigest()for f in paths},indent=2)+'\n')
print(a.output)
