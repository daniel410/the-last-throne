local Access=require(script.Parent.FacilityAccess)
local S={}
function S.start(options)
 local remote=Instance.new('RemoteEvent');remote.Name='LobbyFacilityState';remote.Parent=game.ReplicatedStorage.Remotes
 local last={}
 local function bind(facility,action)
  facility.prompt.Triggered:Connect(function(player)
   if os.clock()-(last[player] or -math.huge)<.5 or not Access.allowed(player,facility.prompt) then return end
   last[player]=os.clock()
   local errorCode=action(player)
   if errorCode then remote:FireClient(player,{error=errorCode}) end
  end)
 end
 if options.facilities then
  bind(options.facilities.portal,function(player) return options.expedition.openMenu(player) end)
  bind(options.facilities.training,function(player) return options.heroSession.startTraining(player) end)
 end
 game.Players.PlayerRemoving:Connect(function(player) last[player]=nil end)
end
return S
