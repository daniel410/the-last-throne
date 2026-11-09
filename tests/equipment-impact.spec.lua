local I=dofile('src/shared/EquipmentImpact.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=R.addHero(R.new(2),class,class,C);local h=p.heroes[class];local list={}
 for _,item in pairs(p.items)do table.insert(list,item)end
 local same=assert(I.compare(h,list,{definitionId=class..'_weapon_traveler',location={kind='bag'}},nil,C))
 check(same[1].delta==0 and same[2].delta==0,'starter Traveler weapon is already equipped and does not count twice')
 local selected={definitionId=class..'_weapon_veteran',location={kind='bag'}}
 local rows=assert(I.compare(h,list,selected,nil,C));local base=G.derived(class,h.progression)
 check(#rows==5,'comparison always shows both attacks, defense, HP and MP')
 check(math.abs(rows[1].delta-6)<.00001,'physical attack gains six fixed power points')
 check(math.abs(rows[2].delta-6)<.00001,'magic attack gains six fixed power points')
 check(rows[3].delta==0 and rows[4].delta==0 and rows[5].delta==0,'weapon comparison does not invent defense, HP or MP')
 local original=R.copy(p)
 local current=assert(R.equipped(p,class,'weapon'));current.definitionId=class..'_weapon_veteran'
 local upgraded=assert(I.compare(h,list,selected,nil,C));check(upgraded[1].delta==0,'already equipped item never counts twice')
 local downgrade=assert(I.compare(h,list,{definitionId=class..'_weapon'},nil,C));check(downgrade[1].delta<0,'downgrade shows negative actual attack')
 local before=p.revision;local hp=assert(I.compare(h,list,{definitionId=class=='mage'and 'mage_traveler_coat'or 'traveler_coat'},nil,C))
 check(hp[3].delta==0 and hp[4].delta==0 and hp[5].delta==0,'starter coat is already equipped and does not count twice')
 local emptyBody={};for _,item in ipairs(list)do if not (item.location.kind=='equipped' and item.location.slot=='body') then table.insert(emptyBody,item) end end
 local added=assert(I.compare(h,emptyBody,{definitionId=class=='mage'and 'mage_traveler_coat'or 'traveler_coat'},nil,C))
 check(added[3].delta==0 and added[4].delta==(class=='mage'and 0 or 20) and added[5].delta==(class=='mage'and 20 or 0),'empty body slot gains only its class resource')
 check(p.revision==before and p.heroes[class].progression.stats.VIT==original.heroes[class].progression.stats.VIT,'read-only preview never saves, heals or allocates stats')
 local accessory=I.compare(h,list,{definitionId='copper_ring'},nil,C);check(accessory and accessory[1].delta==0,'starter ring automatically replaces its own unique group without double counting')
 local other=class=='mage' and 'knight' or 'mage'
 check(not I.compare(h,list,{definitionId=other..'_weapon_fine'},nil,C),'incompatible gear cannot imply an applicable stat increase')
 check(I.text(rows):find('Max MP',1,true)~=nil,'comparison explicitly labels max MP even at zero')
end
print('Equipment impact: '..checks..' checks passed')
