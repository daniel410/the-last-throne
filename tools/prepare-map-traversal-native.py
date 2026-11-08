"""Bundle read-only traversal probes and full chapter/return/connector audit."""
from pathlib import Path
probe=Path('tools/audit-map-traversal.luau').read_text()
probe=probe.replace('return report\n','')
routes=Path('tools/audit-campaign-routes.luau').read_text()
code=probe+'\nlocal audit=(function()\n'+routes+'\nend)()\n'
code+='''for i=1,#C.chapters do audit.chapter(i);if i%8==0 then print('TRAVERSAL_CHAPTER_PROGRESS '..i);task.wait()end end
local transitions={}
for i,edge in ipairs(require(game.ReplicatedStorage.Shared.CampaignAccess).edges)do
 if C.zones[edge[1]].epic==C.zones[edge[2]].epic then audit.edge(i)
 else table.insert(transitions,{from=edge[1],to=edge[2],kind='InterEpicTransfer'})end
end
audit.returns()
print('CAMPAIGN_ROUTES '..game.HttpService:JSONEncode({rows=audit.rows,edges=audit.edges,returnRoutes=audit.returnRoutes,transitions=transitions}))
local pass=#report.anchorIssues==0 and #report.floorIssues==0 and report.obstacleCount==0
for _,p in ipairs(report.hubPaths)do if p.status~='Success'then pass=false end end
local function check(r)
 if r.pathStatus~='Success'and r.pathStatus~='SamePoint'then pass=false end
 for _,v in ipairs(r.visualCandidates)do
  if not v.mesh and (v.path:match('%.LodgeWall$')or v.path:match('%.LodgeBack$'))then pass=false end
 end
end
for _,row in ipairs(audit.rows)do for _,r in ipairs(row.segments)do check(r)end end
for _,r in pairs(audit.edges)do check(r)end
for _,r in ipairs(audit.returnRoutes)do if r.error then pass=false end;for _,p in ipairs(r.approaches)do check(p)end end
print('MAP_TRAVERSAL_PASS '..tostring(pass))
assert(pass,'map traversal regression; inspect MAP_TRAVERSAL and CAMPAIGN_ROUTES')
'''
code+=Path('tests/campaign-route-clearance-native.luau').read_text()
code+='\n'+Path('tests/deepwood-watchtower-road-native.luau').read_text()
Path('/tmp/tlt-map-traversal-native.luau').write_text(code)
print('/tmp/tlt-map-traversal-native.luau')
