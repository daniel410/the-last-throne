local file=assert(io.open('src/client/ArmoryView.luau'));local source=file:read('*a');file:close()
local body=assert(source:match('( local function itemCategory%(d%)(.-)\n end)'))
local category
local env=setmetatable({store='items',Catalog={category=function()return category end}},{__index=_G})
local itemCategory=assert(load(body..'\nreturn itemCategory','actual shop filter','t',env))()
for input,expected in pairs({Potions='Potions',Accessories='Accessories',Armor='Etc',Weapons='Etc'}) do
 category=input;assert(itemCategory({})==expected,input..' mapped incorrectly')
end
env.store='blacksmith';category='Armor';assert(itemCategory({})=='Armor','other shops changed')
assert(source:find("itemCategory(d)~=category",1,true) and source:find("itemCategory(Items.items[item.definitionId])==category",1,true),'buy and sell must use the same filter')
print('item-shop-categories: category mapping and buy/sell filter PASS; native UI NOT RUN')
