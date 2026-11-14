local RS=game:GetService('ReplicatedStorage')
local Players=game:GetService('Players')
local S={}
function S.start(inventory)
 local request=Instance.new('RemoteEvent');request.Name='DeliveryRequest';request.Parent=RS.Remotes
 local response=Instance.new('RemoteEvent');response.Name='DeliveryState';response.Parent=RS.Remotes
 local last={}
 request.OnServerEvent:Connect(function(player,c,...)
  if select('#',...)~=0 or type(c)~='table'then return end
  for key in pairs(c)do if key~='action'and key~='value'and key~='requestId'then return end end
  if c.action~='GetState'and c.action~='Redeem'and c.action~='ClaimMail'then return end
  if workspace:GetAttribute('TLTServerRole')=='Battle'or player:GetAttribute('K0SessionPhase')~='Lobby'then return end
  if c.action~='GetState'then
   if type(c.requestId)~='string'or #c.requestId==0 or #c.requestId>64 or not c.requestId:match('^[%w_-]+$')then return end
   if type(c.value)~='string'or #c.value==0 or #c.value>64 then return end
  end
  local now=os.clock();local interval=c.action=='Redeem'and 1 or .25
  if now-(last[player]or -math.huge)<interval then
   response:FireClient(player,{state={status='Busy'},requestId=c.requestId,error='Busy'});return
  end;last[player]=now
  local reason,replayed
  if c.action~='GetState'then reason,replayed=inventory.claimDelivery(player,c)end
  response:FireClient(player,{state=inventory.deliveryStatus(player),requestId=c.requestId,
   error=reason,replayed=replayed,claimed=c.action~='GetState'and not reason})
 end)
 Players.PlayerRemoving:Connect(function(p)last[p]=nil end)
end
return S
