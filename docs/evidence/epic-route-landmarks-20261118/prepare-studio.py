"""Prepare isolated Studio checks for the epic route landmarks."""
import argparse
import json
from pathlib import Path

EVIDENCE = Path(__file__).resolve().parent
ROOT = EVIDENCE.parents[2]
WORLD = 'game.ServerScriptService.Server.World'
MODULES = ('ArchiveAndCanalLandmarks', 'ForestAndGraveyardLandmarks',
           'EpicStoryLandmarks', 'EpicWorldArt')

parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--frames', action='store_true')
parser.add_argument('--side-frames', action='store_true')
args = parser.parse_args()
if args.baseline and (args.frames or args.side_frames):
    parser.error('comparison frames require the candidate place')

program = ['assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)']
if not args.baseline:
    for name in MODULES:
        source = (ROOT / 'src/server/World' / f'{name}.luau').read_text()
        program.append(f'assert({WORLD}.{name}.Source=={json.dumps(source, ensure_ascii=False)},'
                       f'"source mismatch {name}")')

program.append('''local compiled=0
for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do
  if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()));compiled+=1 end
 end
end
print('TLT_ROUTE_COMPILE '..compiled)''')
program.append(f'local baseline={str(args.baseline).lower()}')
program.append(f'local sideFrames={str(args.side_frames).lower()}')
program.append((EVIDENCE / 'check-landmarks.luau').read_text())

if not args.side_frames:
    program.append("""local overlapLanes={
     ['DW-02:survivors:shelter']={samples={}},
     ['DW-Q1:marsh_report']={samples={}},
    }""")
    nav = (ROOT / 'tests/epic-map-navigation-native.luau').read_text()
    world_call = f'require({WORLD}.CampaignWorld).create()'
    points = 'local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points'
    assert world_call in nav and points in nav
    nav = nav.replace(world_call, 'reviewWorld').replace('for epic=2,5 do', 'for epic=1,5 do')
    nav = nav.replace("print('EPIC_MAP_NAVIGATION '..game.HttpService:JSONEncode(report))", '')
    for mode in ('ORIGINAL', 'EASY'):
        post = ''
        if mode == 'ORIGINAL':
            sample = 'local function sample(p)'
            assert sample in nav
            source = nav.replace(sample, sample + """
                local lane=overlapLanes[label]
                if lane then table.insert(lane.samples,p) end""")
            post = """
            for _, blocker in ipairs(report.blockers) do
                local lane=overlapLanes[blocker.label]
                if lane then
                    lane.contacts=lane.contacts or {}
                    local x,y,z=string.match(blocker.at,'([^,]+), ([^,]+), ([^,]+)')
                    table.insert(lane.contacts,Vector3.new(tonumber(x),tonumber(y),tonumber(z)))
                end
            end"""
        else:
            source = nav.replace(
                points, 'local route=c.combatRoutes and c.combatRoutes[g.id];local points=route and (route.worldPoints or route.points)'
            )
        program.append('do local report=(function()\n' + source + '\nend)();'
                       f'print("TLT_ROUTE_NAV_{mode} "..game.HttpService:JSONEncode({{epics=report.epics,blockers=report.blockers}}))'
                       + post + ' end')
    program.append((EVIDENCE / 'walk-landmarks.luau').read_text())
else:
    program.append("""for _,service in ipairs({game.ServerScriptService,game.StarterPlayer,game.ReplicatedFirst,game.StarterGui})do
 for _,child in ipairs(service:GetDescendants())do
  if child:IsA('BaseScript')then child.Enabled=false end
 end
end
game.RunService:Run()
task.wait(1)""")
if args.frames or args.side_frames:
    program.append((EVIDENCE / 'capture-comparison.luau').read_text())
program.append("print('TLT_ROUTE_FINAL')")
args.output.write_text('\n'.join(program) + '\n')
