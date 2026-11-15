local S={}
function S.start(inventory)
 local Players=game:GetService('Players')
 local Market=game:GetService('MarketplaceService')
 local Products=require(game.ReplicatedStorage.Shared.DiamondProducts)
 local studio=game:GetService('RunService'):IsStudio()
 Market.ProcessReceipt=function(receipt)
  if studio or game.GameId~=Products.universeId or not Products.find(receipt.ProductId)then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local ok,reason=pcall(inventory.grantDiamondReceipt,player,receipt)
  if ok and reason==nil then return Enum.ProductPurchaseDecision.PurchaseGranted end
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
end
return S
