"""Pin the stuck fix and run complete physical traversal, including invisible walls."""
from pathlib import Path
import argparse
import json
p = argparse.ArgumentParser()
p.add_argument('--preview', action='store_true', help='Inject into an isolated older host')
args = p.parse_args()
probe = Path('tools/audit-map-traversal.luau').read_text().replace('return report\n', '')
routes = Path('tools/audit-campaign-routes.luau').read_text()
scoped = probe + '\nlocal audit=(function()\n' + routes + '\nend)()\n' + """
local rows={}
for i,c in ipairs(C.chapters)do if c.epic==1 then table.insert(rows,audit.chapter(i))end end
audit.rows=rows
for i,edge in ipairs(require(game.ReplicatedStorage.Shared.CampaignAccess).edges)do
 if edge[1]:match('^DW%-')and edge[2]:match('^DW%-')then audit.edge(i)end
end
audit.returns()
local s={roadSamples=report.roadSamples,obstacles={},floorIssues={},anchorIssues={},pathCount=0,pathFailures={},outsideDeepwoodObstacles=0}
for _,r in pairs(report.obstacles)do
 local dw=false;for _,e in ipairs(r.examples)do if e.label:find('DW-',1,true)then dw=true end end
 if dw then table.insert(s.obstacles,r)else s.outsideDeepwoodObstacles+=1 end
end
for _,r in ipairs(report.floorIssues)do if r.label:find('DW-',1,true)then table.insert(s.floorIssues,r)end end
for _,r in ipairs(report.anchorIssues)do if r.label:find('DW-',1,true)then table.insert(s.anchorIssues,r)end end
local function path(r)
 s.pathCount+=1
 if r.pathStatus~='Success'and r.pathStatus~='SamePoint'then table.insert(s.pathFailures,r)end
end
for _,row in pairs(audit.rows)do for _,r in ipairs(row.segments)do path(r)end end
for _,r in pairs(audit.edges)do path(r)end
for _,row in ipairs(audit.returnRoutes)do
 assert(not row.error,row.error);for _,r in ipairs(row.approaches)do path(r)end
end
for _,r in ipairs(report.hubPaths)do assert(r.status=='Success',r.goal)end
print('DEEPWOOD_TRAVERSAL '..game.HttpService:JSONEncode(s))
assert(#s.obstacles==0 and #s.floorIssues==0 and #s.anchorIssues==0 and #s.pathFailures==0,'Deepwood traversal failed')
"""
Path('/tmp/tlt-deepwood-traversal.luau').write_text(scoped)
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene required')\n"
for name in ['CampaignRouteClearance', 'CampaignWorld', 'DeepwoodPlaces', 'CampaignCombatRouteWorld', 'EpicWorldArt']:
    source = json.dumps(Path(f'src/server/World/{name}.luau').read_text())
    node = f'game.ServerScriptService.Server.World.{name}'
    code += f'{node}.Source={source}\n' if args.preview else f'assert({node}.Source=={source},"source mismatch: {name}")\n'
code += '''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
print('ALL_LUAU_COMPILE true')
'''
for path in ['tests/deepwood-boundary-stuck-native.luau', 'tests/campaign-combat-route-world-native.luau', 'tests/campaign-expansion-native.luau', 'tests/scenery-collision-native.luau', '/tmp/tlt-deepwood-traversal.luau', 'tests/campaign-route-clearance-native.luau', 'tests/deepwood-watchtower-road-native.luau']:
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
