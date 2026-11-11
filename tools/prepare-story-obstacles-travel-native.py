"""Pin production sources and run isolated roadblock/onward-travel engine QA."""
from pathlib import Path
import argparse
p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');args=p.parse_args()
paths=['src/server/World/CampaignNarrativeScenes.luau','src/server/World/CampaignIncidentScenes.luau','src/server/Story/CheckpointTravelService.luau','src/server/Story/DeepwoodService.luau','src/server/World/StoryGateTemplates.luau','src/server/World/CampaignWorld.luau','src/client/DeepwoodGates.luau','src/client/DeepwoodJournal.luau','src/shared/CampaignExpansionCheckpoints.luau','src/server/World/StoryCheckpointPortal.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
for path in paths:
 f=Path(path);prefix={'server':'game.ServerScriptService.Server','client':'game.StarterPlayer.StarterPlayerScripts.Client','shared':'game.ReplicatedStorage.Shared'}[f.parts[1]]
 parent=prefix+''.join('.'+v for v in f.parts[2:-1]);s=f.read_text();assert ']====]' not in s
 if args.preview:
  code+=f'do local p={parent};local m=p:FindFirstChild("{f.stem}")or Instance.new("ModuleScript");m.Name="{f.stem}";m.Source=[====[{s}]====];m.Parent=p end\n'
 else:code+=f'assert({parent}.{f.stem}.Source==[====[{s}]====],"source mismatch {path}")\n'
code+=Path('tests/story-obstacles-travel-native.luau').read_text()
out=Path('/tmp/tlt-story-obstacles-travel-native.luau');out.write_text(code);print(out)
