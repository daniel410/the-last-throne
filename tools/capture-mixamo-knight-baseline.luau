local clips=require(game.StarterPlayer.StarterPlayerScripts.Client.K0MeleeClips)
print('KNIGHT_BASELINE_STANCE '..game.HttpService:JSONEncode({rest=clips.rest.knight,guard=clips.guard.knight,channels=clips.channels}))
for i,c in clips.clips.knight do print('KNIGHT_BASELINE_CLIP '..game.HttpService:JSONEncode({combo=i,clip=c}))end
