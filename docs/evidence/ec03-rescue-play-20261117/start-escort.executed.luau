task.spawn(function()
 local p=game.Players.LocalPlayer
 while (_G.ECRescue.walk[#_G.ECRescue.walk].label=='Orik' and not _G.ECRescue.walk[#_G.ECRescue.walk].done)do task.wait(.1)end
 local prompt=workspace.DeepwoodCampaign.Objectives['EC-03_miners'].StoryInteract
 prompt:InputHoldBegin();task.wait(1);prompt:InputHoldEnd()
 _G.ECRescue.escortStart=true
end);return 'Orik interaction armed'
