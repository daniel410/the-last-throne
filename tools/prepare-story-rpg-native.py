"""Pin production source and run actual campaign scenes plus TD journal acceptance in an isolated place."""
from pathlib import Path
import json

paths = '''src/shared/CampaignStoryGuide.luau
src/shared/StoryPlaytestMetrics.luau
src/shared/CampaignSceneState.luau
src/shared/StoryCompletion.luau
src/shared/EquipmentImpact.luau
src/client/DeepwoodJournal.luau
src/client/DeepwoodQuestBook.luau
src/client/LobbyQuestJournal.luau
src/client/InventoryGui.luau
src/client/StoryCompletionView.luau
src/server/World/CampaignNarrativeScenes.luau
src/server/World/CampaignReturnScenes.luau'''.splitlines()
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\n"
prefixes = {'shared': 'game.ReplicatedStorage.Shared', 'client': 'game.StarterPlayer.StarterPlayerScripts.Client', 'server': 'game.ServerScriptService.Server'}
for path in paths:
    parts = path.split('/')
    node = prefixes[parts[1]] + ''.join('.' + part for part in parts[2:]).removesuffix('.luau')
    code += f'assert({node}.Source=={json.dumps(Path(path).read_text(), ensure_ascii=False)},"fixed source mismatch: {path}")\n'
code += '''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end
end
'''
for path in ('tests/campaign-expansion-native.luau', 'tests/lobby-quest-journal-native.luau', 'tests/story-rpg-guide-native.luau'):
    code += f'local result=assert(loadstring({json.dumps(Path(path).read_text(), ensure_ascii=False)},{json.dumps(path)}))()\n'
    code += "assert(not result.failures or #result.failures==0,game.HttpService:JSONEncode(result))\n"
    code += "print('STORY_RPG_NATIVE_SUITE '..game.HttpService:JSONEncode(result))\n"
out = Path('/tmp/tlt-story-rpg-native.luau')
out.write_text(code)
print(out)
