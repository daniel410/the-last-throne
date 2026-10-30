local C={version=1,storyDiamonds=2,offers={},sell={}}
for _,class in ipairs({'knight','elf','dwarf','mage'}) do
 local fine=class..'_weapon_fine';local veteran=class..'_weapon_veteran'
 table.insert(C.offers,{id=fine,definitionId=fine,currency='gold',price=250})
 table.insert(C.offers,{id=veteran,definitionId=veteran,currency='gold',price=600})
 table.insert(C.offers,{id=veteran..'_diamond',definitionId=veteran,currency='diamonds',price=10})
 C.sell[fine]=50;C.sell[veteran]=120
end
table.insert(C.offers,{id='knight_shield_fine',definitionId='knight_shield_fine',currency='gold',price=250})
C.sell.knight_shield_fine=50
function C.offer(id) for _,v in ipairs(C.offers) do if v.id==id then return v end end end
return C
