"""TLT-061~064 전체 폭 연결부·지형 끼임 복구 회귀. preview만 소스를 주입한다."""
from pathlib import Path
import argparse, hashlib, json
p=argparse.ArgumentParser()
p.add_argument('--preview',action='store_true')
a=p.parse_args()
inputs=['src/shared/CampaignPassage.luau','src/shared/CampaignBounds.luau','src/server/World/CampaignPassageFloor.luau','src/server/World/CampaignCombatRouteWorld.luau','src/server/World/EpicWorldArt.luau','src/server/Story/DeepwoodRegionAccess.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated QA only')\nfor _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\nlocal bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end\n"
for path in inputs:
    node='game.ReplicatedStorage.Shared' if '/shared/' in path else 'game.ServerScriptService.Server.'+Path(path).parent.name
    name=Path(path).stem
    if a.preview:
        code+=f'do local p={node};local m=p:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={json.dumps(Path(path).read_text())};m.Parent=p end\n'
    else:
        code+=f'assert({node}.{name}.Source=={json.dumps(Path(path).read_text())},"frozen source mismatch: {name}")\n'
code+="for _,p in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,m in ipairs(p:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end end\nprint('STORY_PASSAGE_SOURCE_COMPILE_PASS')\n"
for path in ['tests/story-passage-native.luau','tests/deepwood-boundary-stuck-native.luau','tests/epic-overland-service-native.luau']:
    inputs.append(path)
    code+='do local result=assert(loadstring('+json.dumps(Path(path).read_text())+'))();end\n'
path='tests/epic-map-navigation-native.luau';inputs.append(path)
for variant in ['points','worldPoints']:
    source=Path(path).read_text().replace('local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()', 'local world=assert(_G.StoryPassageWorld)').replace('and c.combatRoutes[g.id].points','and c.combatRoutes[g.id].'+variant)
    code+='do local r=assert(loadstring('+json.dumps(source)+'))();assert(#r.blockers==0 and #r.floors==0 and #r.corrections==0 and #r.routeFailures==0 and #r.lowSteps==0,"navigation regression '+variant+'");print("STORY_PASSAGE_NAV_PASS '+variant+'")end\n'
path='tests/story-passage-walk-native.luau';inputs.append(path)
code+='assert(loadstring('+json.dumps(Path(path).read_text())+'))()\n'
Path('/tmp/tlt-story-passage-native.luau').write_text(code)
Path('/tmp/tlt-story-passage-inputs.json').write_text(json.dumps({p:hashlib.sha256(Path(p).read_bytes()).hexdigest()for p in inputs},indent=2)+'\n')
print('/tmp/tlt-story-passage-native.luau')
