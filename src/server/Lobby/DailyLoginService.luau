local RS=game:GetService('ReplicatedStorage')
local Players=game:GetService('Players')
local S={}
function S.start(inventory)
 local request=Instance.new('RemoteEvent');request.Name='DailyLoginRequest';request.Parent=RS.Remotes
 local response=Instance.new('RemoteEvent');response.Name='DailyLoginState';response.Parent=RS.Remotes
 local last={}
 request.OnServerEvent:Connect(function(player,command,...)
  if select('#',...)~=0 or type(command)~='table' then return end
  for key in pairs(command)do if key~='action' and key~='requestId'then return end end
  if command.action~='GetState' and command.action~='Claim'then return end
  if command.action=='Claim' and (type(command.requestId)~='string' or #command.requestId==0 or #command.requestId>64 or not command.requestId:match('^[%w_-]+$'))then return end
  if os.clock()-(last[player]or -math.huge)<.2 then return end;last[player]=os.clock()
  local reason,replayed
  if command.action=='Claim'then reason,replayed=inventory.claimDaily(player,command.requestId)end
  response:FireClient(player,{state=inventory.dailyStatus(player),requestId=command.requestId,error=reason,replayed=replayed,claimed=command.action=='Claim' and not reason})
 end)
 Players.PlayerRemoving:Connect(function(p)last[p]=nil end)
end
return S
