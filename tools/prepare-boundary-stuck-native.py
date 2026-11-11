"""Pin the stuck fix and run complete physical traversal, including invisible walls."""
from pathlib import Path
import argparse
import json
import runpy
p = argparse.ArgumentParser()
p.add_argument('--preview', action='store_true', help='Inject into an isolated older host')
args = p.parse_args()
runpy.run_path('tools/prepare-map-traversal-native.py')
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene required')\n"
for name in ['CampaignRouteClearance', 'CampaignWorld']:
    source = json.dumps(Path(f'src/server/World/{name}.luau').read_text())
    node = f'game.ServerScriptService.Server.World.{name}'
    code += f'{node}.Source={source}\n' if args.preview else f'assert({node}.Source=={source},"source mismatch: {name}")\n'
code += '''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
print('ALL_LUAU_COMPILE true')
'''
for path in ['tests/deepwood-boundary-stuck-native.luau', 'tests/campaign-combat-route-world-native.luau', 'tests/campaign-expansion-native.luau', 'tests/scenery-collision-native.luau', '/tmp/tlt-map-traversal-native.luau']:
    source = Path(path).read_text()
    if path == 'tests/campaign-expansion-native.luau':
        # Only physical traversal is in scope; later assertions cover unrelated UI.
        marker = "check(#report.blockers==0,'new wings and connectors have no holes or body blockers')"
        source = source[:source.index(marker) + len(marker)] + '\nreturn report\n'
    code += 'do local r=assert(loadstring('+json.dumps(source)+'))(); if type(r)=="table" then assert(not r.blockers or #r.blockers==0,"blockers remain");assert(not r.floorFailures or #r.floorFailures==0,"floor failures") end end\n'
code += "print('BOUNDARY_STUCK_ALL_PASS true')\n"
out = Path('/tmp/tlt-boundary-stuck-native.luau')
out.write_text(code)
print(out)
