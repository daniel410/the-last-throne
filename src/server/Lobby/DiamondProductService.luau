local S={}
local receiptWaitSeconds=130 -- Account loading may wait up to 125 seconds for a previous lease.
function S.start(inventory)
 local Players=game:GetService('Players')
 local Market=game:GetService('MarketplaceService')
 local Products=require(game.ReplicatedStorage.Shared.DiamondProducts)
 local studio=game:GetService('RunService'):IsStudio()
 Market.ProcessReceipt=function(receipt)
  if studio or game.GameId~=Products.universeId or not Products.find(receipt.ProductId)then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
  -- Roblox does not schedule retries while the player stays in this server.
  local deadline,delay=os.clock()+receiptWaitSeconds,.25
  while Players:GetPlayerByUserId(receipt.PlayerId)==player do
   local ok,reason=pcall(inventory.grantDiamondReceipt,player,receipt)
   if not ok then break end
   if reason==nil then return Enum.ProductPurchaseDecision.PurchaseGranted end
   if reason~='Busy' and reason~='SaveUnknown' then break end
   local remaining=deadline-os.clock()
   if remaining<=0 then break end
   task.wait(math.min(delay,remaining))
   delay=math.min(delay*2,5)
  end
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
end
return S
