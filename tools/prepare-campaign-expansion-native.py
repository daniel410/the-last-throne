"""Pin changed production module bytes before isolated world/activity/UI checks."""
from pathlib import Path
import json
paths='''src/client/CampaignExpansionPresentation.luau
src/client/DawnspireHomecoming.luau
src/client/DeepwoodAtmosphere.luau
src/client/DeepwoodJournal.luau
src/client/DeepwoodMapCanvas.luau
src/client/DeepwoodNavigation.luau
src/client/DeepwoodQuestBook.luau
src/server/Lobby/NPCService.luau
src/server/Story/DeepwoodActivities.luau
src/server/Story/DeepwoodService.luau
src/server/World/CampaignWorld.luau
src/server/World/CampaignExpansionWorld.luau
src/server/World/DeepwoodActivityWorld.luau
src/server/World/LobbyResidents.luau
src/server/World/StoryCheckpointPortal.luau
src/server/World/StoryProps.luau
src/shared/AdventureRules.luau
src/shared/CampaignAccess.luau
src/shared/CampaignAreas.luau
src/shared/CampaignBounds.luau
src/shared/CampaignContent.luau
src/shared/CampaignExpansion.luau
src/shared/CampaignExpansionContent.luau
src/shared/CampaignExpansionCheckpoints.luau
src/shared/CheckpointTravel.luau
src/shared/DeepwoodProgress.luau
src/shared/DeepwoodQuestLog.luau
src/shared/Difficulty.luau
src/shared/StoryEventText.luau
src/shared/CampaignExpansionLayout.luau
src/shared/CampaignCircuit.luau
src/shared/CampaignSceneState.luau
src/shared/CampaignIncidentRoute.luau
src/server/World/CampaignIncidentProps.luau
src/server/World/CampaignIncidentScenes.luau
src/shared/DeepwoodQuestLog.luau
src/shared/CampaignStoryBeats.luau
src/server/World/CampaignCircuitWorld.luau
src/server/World/CampaignNarrativeScenes.luau
src/server/World/CampaignReturnScenes.luau
src/server/World/ScoutLantern.luau'''.splitlines()
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\n"
for path in dict.fromkeys(paths):
 parts=path.split('/');prefix={'shared':'game.ReplicatedStorage.Shared','client':'game.StarterPlayer.StarterPlayerScripts.Client','server':'game.ServerScriptService.Server'}[parts[1]]
 node=prefix+''.join('.'+part for part in parts[2:]).removesuffix('.luau')
 code+=f'assert({node}.Source=={json.dumps(Path(path).read_text(),ensure_ascii=False)},"fixed source mismatch: {path}")\n'
code+='''for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end
end
'''
code+=Path('tests/campaign-expansion-native.luau').read_text()
out=Path('/tmp/tlt-campaign-expansion-native.luau');out.write_text(code);print(out)
