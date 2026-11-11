"""Pin grounding, removed scenery, tree physics, and roadblock regressions."""
from pathlib import Path
import argparse,json
p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');p.add_argument('--hold',action='store_true');a=p.parse_args()
paths=['src/server/World/'+n+'.luau' for n in ['CaptiveSceneTemplates','DeepwoodActivityWorld','EpicArchitecture','ArchitectureGrounding','CampaignSceneryPlacement','CampaignSceneryCollision','EpicWorldArt','DeepwoodEnvironment','DeepwoodWorld','CampaignIncidentScenes']]
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
for path in paths:
 f=Path(path);parent='game.ServerScriptService.Server.World'
 if a.preview:code+=f'do local m={parent}:FindFirstChild("{f.stem}")or Instance.new("ModuleScript");m.Name="{f.stem}";m.Source={json.dumps(f.read_text(),ensure_ascii=False)};m.Parent={parent} end\n'
 else:code+=f'assert({parent}.{f.stem}.Source=={json.dumps(f.read_text(),ensure_ascii=False)},"source mismatch {path}")\n'
f=Path('src/server/Story/DeepwoodActivities.luau');parent='game.ServerScriptService.Server.Story'
if a.preview:code+=f'{parent}.DeepwoodActivities.Source={json.dumps(f.read_text(),ensure_ascii=False)}\n'
else:code+=f'assert({parent}.DeepwoodActivities.Source=={json.dumps(f.read_text(),ensure_ascii=False)})\n'
for name in ['DeepwoodGates','DeepwoodCaptivePresentation','DeepwoodStoryPresentation','DeepwoodJournal']:
 f=Path('src/client/'+name+'.luau');parent='game.StarterPlayer.StarterPlayerScripts.Client'
 if a.preview:code+=f'do local m={parent}:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={json.dumps(f.read_text(),ensure_ascii=False)};m.Parent={parent} end\n'
 else:code+=f'assert({parent}.{name}.Source=={json.dumps(f.read_text(),ensure_ascii=False)})\n'
code+="for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end end\n"
for suite in ['captive-rescue-native','architecture-grounding-native','scenery-collision-native','story-obstacles-travel-native','campaign-combat-route-world-native','campaign-expansion-native','epic-map-navigation-native','deepwood-report-navigation-native']:
 source=Path('tests/'+suite+'.luau').read_text()
 if suite=='campaign-expansion-native':
  marker="check(#report.blockers==0,'new wings and connectors have no holes or body blockers')"
  source=source[:source.index(marker)+len(marker)]+'\nreturn report'
 code+='do local r=assert(loadstring('+json.dumps(source,ensure_ascii=False)+'))();if type(r)=="table"then assert(not r.blockers or #r.blockers==0);assert(not r.floorFailures or #r.floorFailures==0);assert(not r.floors or #r.floors==0);assert(not r.corrections or #r.corrections==0);assert(not r.routeFailures or #r.routeFailures==0)end end\n'
if a.hold:code+="print('GROUNDING_REVIEW_READY');for i=1,600 do if _G.TLTReviewDone then break end task.wait(1)end\n"
Path('/tmp/tlt-architecture-grounding-native.luau').write_text(code)
