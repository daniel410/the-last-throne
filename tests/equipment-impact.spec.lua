local I=dofile('src/shared/EquipmentImpact.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=R.addHero(R.new(2),class,class,C);local h=p.heroes[class];local list={}
 for _,item in pairs(p.items)do table.insert(list,item)end
 local selected={definitionId=class..'_weapon_fine',location={kind='bag'}}
 local rows=assert(I.compare(h,list,selected,nil,C));local base=G.derived(class,h.progression)
 check(#rows==5,'comparison always shows both attacks, defense, HP and MP')
 check(math.abs(rows[1].delta-base.physicalPower*.1)<.00001,'physical attack converts percent bonus to actual power')
 check(math.abs(rows[2].delta-base.magicPower*.1)<.00001,'magic attack converts percent bonus to actual power')
 check(rows[3].delta==0 and rows[4].delta==0 and rows[5].delta==0,'weapon comparison does not invent defense, HP or MP')
 local original=R.copy(p)
 local current=assert(R.equipped(p,class,'weapon'));current.definitionId=class..'_weapon_fine'
 local upgraded=assert(I.compare(h,list,selected,nil,C));check(upgraded[1].delta==0,'already equipped item never counts twice')
 local downgrade=assert(I.compare(h,list,{definitionId=class..'_weapon'},nil,C));check(downgrade[1].delta<0,'downgrade shows negative actual attack')
 local before=p.revision;local hp=assert(I.compare(h,list,{definitionId='traveler_coat'},nil,C))
 check(hp[3].delta==2 and hp[4].delta==40 and hp[5].delta==0,'body armor reports actual defense, max HP and zero MP')
 check(p.revision==before and p.heroes[class].progression.stats.VIT==original.heroes[class].progression.stats.VIT,'read-only preview never saves, heals or allocates stats')
 local no,reason=I.compare(h,list,{definitionId='copper_ring'},nil,C);check(not no and reason=='ChooseAccessory','accessory comparison requires explicit replacement slot')
 local other=class=='mage' and 'knight' or 'mage'
 check(not I.compare(h,list,{definitionId=other..'_weapon_fine'},nil,C),'incompatible gear cannot imply an applicable stat increase')
 check(I.text(rows):find('Max MP',1,true)~=nil,'comparison explicitly labels max MP even at zero')
end
print('Equipment impact: '..checks..' checks passed')
