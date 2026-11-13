"""Run overland physics QA in an isolated existing Place, or verify a fixed build."""
from pathlib import Path
import argparse,json
p=argparse.ArgumentParser();p.add_argument('--fixed',action='store_true');a=p.parse_args()
paths=['src/shared/CampaignOverland.luau','src/shared/CampaignContent.luau','src/shared/CampaignNavigationRoute.luau','src/client/DeepwoodGates.luau','src/server/Story/DeepwoodService.luau','src/server/World/CampaignWorld.luau','src/server/World/EpicWorldArt.luau','src/server/init.server.luau']
roots={'shared':'game.ReplicatedStorage.Shared','client':'game.StarterPlayer.StarterPlayerScripts.Client','server':'game.ServerScriptService.Server'}
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')\n"
for path in paths:
 parts=Path(path).with_suffix('').parts
 node=roots[parts[1]]+'.'+'.'.join(parts[2:])
 if path.endswith('init.server.luau'):node=roots['server']
 source=json.dumps(Path(path).read_text(),ensure_ascii=False)
 if a.fixed:code+=f'assert({node}.Source=={source},"source mismatch: {path}")\n'
 else:
  if path.endswith('CampaignOverland.luau'):code+="local m=Instance.new('ModuleScript');m.Name='CampaignOverland';m.Parent=game.ReplicatedStorage.Shared\n"
  code+=f'{node}.Source={source}\n'
code+='''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
print('OVERLAND_COMPILE_PASS')
'''
code+='local overlandWorld=assert(loadstring('+json.dumps(Path('tests/epic-overland-native.luau').read_text(),ensure_ascii=False)+'))()\n'
code+='assert(loadstring('+json.dumps(Path('tests/epic-overland-service-native.luau').read_text(),ensure_ascii=False)+'))()\n'
code+='assert(loadstring('+json.dumps(Path('tests/story-obstacles-travel-native.luau').read_text(),ensure_ascii=False)+'))()\n'
audit=Path('tests/epic-map-navigation-native.luau').read_text().replace("local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()","local world=assert(qaWorld)")
code+='local auditFn=assert(loadstring('+json.dumps(audit,ensure_ascii=False)+'))\n'
code+='setfenv(auditFn,setmetatable({qaWorld=overlandWorld},{__index=getfenv()}));local audit=auditFn()\n'
code+="for _,s in pairs(audit.epics)do assert(s.blockers==0 and s.floors==0 and s.corrections==0 and s.routeFailures==0,'regional geometry regression')end\nprint('OVERLAND_REGIONAL_GEOMETRY_PASS')\n"
out=Path('/tmp/tlt-epic-overland-native.luau');out.write_text(code);print(out)
