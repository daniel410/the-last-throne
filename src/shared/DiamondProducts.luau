-- RPG-only Developer Products. TD IDs must never be used here.
local P={universeId=10773575153,version=1,packs={
 {id='diamonds_100',name='100 Diamonds',diamonds=100,productId=0,referencePrice=49},
 {id='diamonds_500',name='500 Diamonds',diamonds=500,productId=0,referencePrice=199},
 {id='diamonds_1200',name='1,200 Diamonds',diamonds=1200,productId=0,referencePrice=399},
}}
function P.find(productId)
 if type(productId)~='number' or productId<=0 then return nil end
 for _,pack in ipairs(P.packs)do if pack.productId==productId then return pack end end
end
return P
