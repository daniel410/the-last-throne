"""TLT-065 GW-01 밤 단서 재질·통행 검사. 격리 고정 빌드에서 실행한다."""
from pathlib import Path
import hashlib
import json

module = Path('src/server/World/GloamwoodTrailEvidence.luau')
trace = Path('tests/gloamwood-trail-evidence-native.luau')
nav = Path('tests/epic-map-navigation-native.luau')
inputs = [module, trace, nav, Path('src/client/DeepwoodAtmosphere.luau'), Path('src/client/AdventureCamera.luau')]
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
code += 'assert(game.ServerScriptService.Server.World.GloamwoodTrailEvidence.Source==' + json.dumps(module.read_text()) + ')\n'
code += 'assert(loadstring(game.ServerScriptService.Server.World.GloamwoodTrailEvidence.Source))\n'
code += 'local trace=assert(loadstring(' + json.dumps(trace.read_text()) + '))()\n'
code += '_G.NightNav={}\n'
source = nav.read_text().replace('local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()', 'local world=assert(_G.TraceWorld)').replace('for epic=2,5 do', 'for epic=2,2 do')
for variant in ['points', 'worldPoints']:
    candidate = source.replace('and c.combatRoutes[g.id].points', 'and c.combatRoutes[g.id].' + variant)
    code += 'do local r=assert(loadstring(' + json.dumps(candidate) + '))();_G.NightNav.' + variant + '=r;assert(#r.blockers==0 and #r.floors==0 and #r.corrections==0 and #r.routeFailures==0 and #r.lowSteps==0)end\n'
code += '''require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere).update('Gloamwood')
local camera=workspace.CurrentCamera;camera.FieldOfView=70
local focus=Vector3.new(-1340,58.5,-4078)
camera.CFrame=require(game.StarterPlayer.StarterPlayerScripts.Client.AdventureCamera).constrain(focus,Vector3.new(-1328,74,-4059),{workspace.Terrain,_G.TraceWorld.terrain})
camera.Focus=CFrame.new(focus);_G.NightCamera=camera.CFrame
return game.HttpService:JSONEncode({trace=_G.TraceReport,navigation=_G.NightNav})
'''
out = Path('/tmp/tlt-gw01-night-native.luau')
out.write_text(code)
out.with_suffix('.inputs.json').write_text(json.dumps({str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs}, indent=2) + '\n')
print(out)
