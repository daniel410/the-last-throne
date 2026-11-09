"""Pin collision/map/budget sources and compile every module before engine QA."""
from pathlib import Path
import argparse
import json
import runpy
parser=argparse.ArgumentParser()
parser.add_argument('--all',action='store_true',help='Append composition, expansion and full traversal suites')
args=parser.parse_args()
paths = [
    'src/server/World/CampaignSceneryCollision.luau',
    'src/server/World/CampaignSceneryPlacement.luau',
    'src/server/World/CampaignWorld.luau',
    'src/server/World/CampaignExpansionWorld.luau',
    'src/server/World/CampaignIncidentScenes.luau',
    'src/server/World/EpicEnvironmentKit.luau',
    'src/server/World/EpicArchitecture.luau',
    'src/server/World/EpicWorldArt.luau',
    'src/server/World/EpicScenicComposition.luau',
    'src/client/WorldPresentationBudget.luau',
]
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\n"
for path in paths:
    parts = path.split('/')
    prefix = {'client':'game.StarterPlayer.StarterPlayerScripts.Client', 'server':'game.ServerScriptService.Server'}[parts[1]]
    node = prefix + ''.join('.'+part for part in parts[2:]).removesuffix('.luau')
    code += f'assert({node}.Source=={json.dumps(Path(path).read_text())},"source mismatch: {path}")\n'
code += """for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end
end
print('SCENERY_SOURCES_MATCH 10; ALL_LUAU_COMPILE true')
"""
code += Path('tests/scenery-collision-native.luau').read_text()
if args.all:
    runpy.run_path('tools/prepare-campaign-expansion-native.py')
    runpy.run_path('tools/prepare-map-traversal-native.py')
    code += '\nlocal suiteErrors={}\n'
    for suite in ['tests/td-scenic-composition-native.luau', '/tmp/tlt-campaign-expansion-native.luau', '/tmp/tlt-map-traversal-native.luau']:
        code += 'do local ok,why=xpcall(function()\n'+Path(suite).read_text()+'\nend,debug.traceback);if not ok then table.insert(suiteErrors,why);warn(why)end end\n'
    code += "print('SCENERY_ALL_SUITES '..tostring(#suiteErrors==0));assert(#suiteErrors==0,table.concat(suiteErrors,'\\n'))\n"
out=Path('/tmp/tlt-scenery-collision-native.luau')
out.write_text(code)
print(out)
