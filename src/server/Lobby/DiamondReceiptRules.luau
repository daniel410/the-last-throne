local P=game and require(game:GetService('ReplicatedStorage').Shared.DiamondProducts)or dofile('src/shared/DiamondProducts.luau')
local R={}
local function integer(v)return type(v)=='number'and v==v and v%1==0 and v>0 and v<=1e12 end
function R.valid(profile)
 if profile.productReceipts==nil then return true end
 if type(profile.productReceipts)~='table'then return false end
 for id,r in pairs(profile.productReceipts)do
  if type(id)~='string'or #id==0 or #id>200 or type(r)~='table'or not integer(r.productId)or not integer(r.diamonds)or not integer(r.version)then return false end
 end
 return true
end
function R.grant(profile,receipt,rules,products)
 products=products or P
 if type(receipt)~='table'or receipt.PlayerId~=profile.userId or type(receipt.PurchaseId)~='string'or #receipt.PurchaseId==0 or #receipt.PurchaseId>200 then return nil,'InvalidReceipt'end
 local pack=products.find(receipt.ProductId)
 if not pack then return nil,'UnknownProduct'end
 if not R.valid(profile)then return nil,'Incompatible'end
 local old=profile.productReceipts and profile.productReceipts[receipt.PurchaseId]
 if old then
  if old.productId~=receipt.ProductId then return nil,'ReceiptConflict'end
  return profile,nil,true
 end
 if not profile.wallet or profile.wallet.diamonds+pack.diamonds>1e12 then return nil,'BalanceLimit'end
 local n=rules.copy(profile)
 n.productReceipts=n.productReceipts or {}
 -- Permanent ledger: never put paid receipts in the bounded request history.
 n.productReceipts[receipt.PurchaseId]={productId=receipt.ProductId,diamonds=pack.diamonds,version=products.version}
 n.wallet.diamonds=n.wallet.diamonds+pack.diamonds;n.revision=n.revision+1
 return n
end
return R
