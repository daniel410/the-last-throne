"""Build isolated pure rules and actual GUI checks; never accesses live DataStore."""
from pathlib import Path
import argparse,json
p=argparse.ArgumentParser();p.add_argument('--fixed-build',action='store_true');args=p.parse_args()
sources={str(p):p.read_text() for root in ['src/shared','src/server/Inventory'] for p in Path(root).rglob('*.luau')}
tests=['tests/quest-completion-rewards.spec.lua','tests/side-quest-review.spec.lua','tests/campaign-reorder.spec.lua','tests/difficulty-balance.spec.lua','tests/story-completion.spec.lua']
for test in tests:sources[test]=Path(test).read_text()
changed=['QuestCompletionRewards','CampaignContent','DeepwoodProgress','DeepwoodQuestLog','Difficulty','AdventureRules','ExpeditionPresentation','ExpeditionText','StoryCompletion']
clients=['LobbyQuestJournal','ExpeditionView']
for name in clients:sources[f'src/client/{name}.luau']=Path(f'src/client/{name}.luau').read_text()
code='local sources={'+','.join('['+json.dumps(k)+']='+json.dumps(v,ensure_ascii=False) for k,v in sources.items())+'}\n'
code+="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local Place only')\n"
for prefix,names,target in [('src/shared',changed,'game.ReplicatedStorage.Shared'),('src/client',clients,'game.StarterPlayer.StarterPlayerScripts.Client'),('src/server/Inventory',['InventoryRules','AccountStore'],'game.ServerScriptService.Server.Inventory')]:
 for name in names:
  path=f'{prefix}/{name}.luau'
  if args.fixed_build:
   code+=f"assert({target}.{name}.Source==sources[{json.dumps(path)}],'fixed source mismatch: {name}')\n"
  else:
   code+=f"do local root={target};local old=root:FindFirstChild('{name}');if old then old:Destroy()end;local m=Instance.new('ModuleScript');m.Name='{name}';m.Source=sources[{json.dumps(path)}];m.Parent=root end\n"
code+="""for path,source in pairs(sources)do local fn,why=loadstring(source,'@'..path);assert(fn,why)end
local cache={}
local function pure(path)
 if cache[path]then return cache[path]end
 local fn,why=loadstring(assert(sources[path],path),'@'..path);assert(fn,why)
 setfenv(fn,setmetatable({game=false,dofile=pure},{__index=getfenv()}))
 local value=fn();cache[path]=value or true;return value
end
"""
for test in tests:code+='pure('+json.dumps(test)+')\n'
code+='local guiTest=function()\n'+Path('tests/quest-reward-ui-native.luau').read_text()+'\nend\n'
code+="local report=guiTest();print('QUEST_COMPLETION_REWARDS_NATIVE_PASS');return report\n"
out=Path('/tmp/tlt-quest-rewards-native.luau');out.write_text(code);print(out)
