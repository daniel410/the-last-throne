local RS=game:GetService('ReplicatedStorage')
local Access=require(script.Parent.FacilityAccess)
local S={}
function S.start(options)
 local remote=Instance.new('RemoteEvent');remote.Name='ArmoryRequest';remote.Parent=RS.Remotes
 local update=Instance.new('RemoteEvent');update.Name='ArmoryState';update.Parent=RS.Remotes
 local last={}
 local function publish(p,id,reason,open) update:FireClient(p,{inventory=options.inventory.snapshot(p),requestId=id,error=reason,open=open}) end
 if options.merchant then options.merchant.prompt.Triggered:Connect(function(p)
  if Access.allowed(p,options.merchant.prompt) and options.inventory.ready(p) then publish(p,nil,nil,true) end
 end) end
 remote.OnServerEvent:Connect(function(p,c,...)
  if os.clock()-(last[p] or -math.huge)<.2 then return end;last[p]=os.clock()
  if select('#',...)~=0 or type(c)~='table' then return end
  local allowed={action=true,requestId=true,heroId=true,revision=true,offerId=true,instanceId=true,itemVersion=true}
  for k,v in pairs(c) do if not allowed[k] or type(v)~='string' and type(v)~='number' then publish(p,nil,'InvalidRequest');return end end
  if type(c.requestId)~='string' or #c.requestId>64 or not c.requestId:match('^[%w_-]+$') then return end
  if c.action=='GetState' then publish(p,c.requestId,nil,c.open);return end
  local function integer(v) return type(v)=='number' and v==v and v%1==0 and v>=0 and v<=1e12 end
  if (c.action~='Buy' and c.action~='Sell') or not integer(c.revision) or type(c.heroId)~='string' or #c.heroId>64
   or c.action=='Buy' and (type(c.offerId)~='string' or #c.offerId>80) or c.action=='Sell' and (type(c.instanceId)~='string' or #c.instanceId>100 or not integer(c.itemVersion)) then publish(p,c.requestId,'InvalidRequest');return end
  local e=options.inventory.shop(p,c);publish(p,c.requestId,e)
 end)
 game.Players.PlayerRemoving:Connect(function(p) last[p]=nil end)
end
return S
