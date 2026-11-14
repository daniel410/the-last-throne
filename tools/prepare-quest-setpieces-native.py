"""고정 빌드의 장면 소스 일치·저장 투영·실제 엔진 회귀 검사."""
from pathlib import Path
import argparse
import hashlib
import json

root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--output', type=Path, default=Path('/tmp/tlt-quest-setpieces-native.luau'))
p.add_argument('--review', action='store_true')
a = p.parse_args()
paths = ['src/server/World/CampaignQuestSetpieces.luau', 'src/server/World/CampaignWorld.luau',
         'src/client/CampaignExpansionPresentation.luau', 'src/shared/CampaignSceneState.luau']
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\n"
for path in paths:
    base = ('game.ServerScriptService.Server.World' if '/server/' in path else
            'game.StarterPlayer.StarterPlayerScripts.Client' if '/client/' in path else
            'game.ReplicatedStorage.Shared')
    code += f'assert({base}.{Path(path).stem}.Source=={json.dumps((root/path).read_text())},"source mismatch: {path}")\n'
code += """for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
"""
for suite in ['tests/quest-setpieces-native.luau']:
    code += f'assert(loadstring({json.dumps((root/suite).read_text())},{json.dumps(suite)}))()\n'
    paths.append(suite)
if a.review:
    code += """
_G.QuestSetpieceReview=true
game.Lighting.ClockTime=13;game.Lighting.Brightness=2
print('QUEST_SETPIECES_REVIEW_READY')
for i=1,600 do if _G.QuestSetpieceReviewDone then break end task.wait(1)end
"""
a.output.write_text(code)
a.output.with_suffix('.inputs.json').write_text(json.dumps({path: hashlib.sha256((root/path).read_bytes()).hexdigest() for path in paths}, indent=2)+'\n')
print(a.output)
