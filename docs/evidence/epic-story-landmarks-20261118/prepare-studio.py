"""Assemble the isolated Studio checks from the recorded source and route suite."""
import argparse
import json
from pathlib import Path

EVIDENCE = Path(__file__).resolve().parent
ROOT = EVIDENCE.parents[2]


def quote(source):
    return json.dumps(source, ensure_ascii=False)


parser = argparse.ArgumentParser()
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--frames', action='store_true')
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
if args.baseline and args.frames:
    parser.error('landmark frames require the candidate place')

program = ['assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)']
world = 'game.ServerScriptService.Server.World'
for name in ('EpicWorldArt', 'EpicStoryLandmarks'):
    if args.baseline:
        break
    source = (ROOT / 'src/server/World' / f'{name}.luau').read_text()
    program.append(f'assert({world}.{name}.Source=={quote(source)},"source mismatch {name}")')

program.append('''local compiled=0
for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do
  if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()));compiled+=1 end
 end
end
print('EPIC_STORY_LANDMARK_COMPILE '..compiled)''')
if args.baseline:
    program.append(f'_G.TLTStoryLandmarkReviewWorld=require({world}.CampaignWorld).create()')
else:
    program.append('do\n' + (EVIDENCE / 'check-landmarks.luau').read_text() + '\nend')

nav = (ROOT / 'tests/epic-map-navigation-native.luau').read_text()
world_call = f'require({world}.CampaignWorld).create()'
points = 'local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points'
assert world_call in nav and points in nav
nav = nav.replace(world_call, '_G.TLTStoryLandmarkReviewWorld')
nav = nav.replace('for epic=2,5 do', 'for epic=1,5 do')
nav = nav.replace("print('EPIC_MAP_NAVIGATION '..game.HttpService:JSONEncode(report))", '')
for mode in ('ORIGINAL', 'EASY'):
    source = nav if mode == 'ORIGINAL' else nav.replace(
        points, 'local route=c.combatRoutes and c.combatRoutes[g.id];local points=route and (route.worldPoints or route.points)'
    )
    program.append('do local report=(function()\n' + source + '\nend)();'
                   f'print("EPIC_STORY_NAV_{mode} "..game.HttpService:JSONEncode({{epics=report.epics,blockers=report.blockers}})) end')
if args.frames:
    program.append((EVIDENCE / 'capture-comparison.luau').read_text())
program.append("print('EPIC_STORY_LANDMARK_FINAL')")
args.output.write_text('\n'.join(program) + '\n')
