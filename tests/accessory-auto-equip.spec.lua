local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Slots=dofile('src/shared/EquipmentSlotRules.luau')
local Impact=dofile('src/shared/EquipmentImpact.luau')
local n,sequence=0,0;local function check(v,m)n=n+1;assert(v,m)end
local p=assert(R.addHero(R.new(714),'hero','knight',C))
p=assert(R.addHero(p,'other','elf',C))
local function find(id)
 for _,i in pairs(p.items)do if i.definitionId==id and i.location.heroId=='hero' and i.location.kind=='bag'then return i end end
 error(id)
end
local function equip(item,extra)
 sequence=sequence+1
 local cmd={action='Equip',requestId='auto-'..sequence,heroId='hero',instanceId=item.instanceId,itemVersion=item.version,revision=p.revision}
 for k,v in pairs(extra or {})do cmd[k]=v end
 return R.apply(p,cmd,{safe=true},C),cmd
end
local function previewAndEquip(item,expected)
 local target=Slots.resolve('hero',p.items,C.items[item.definitionId],C)
 check(target==expected,'automatic target '..expected)
 local list={};for _,i in pairs(p.items)do list[#list+1]=i end
 local rows=assert(Impact.compare(p.heroes.hero,list,item,nil,C))
 local before=R.copy(p);local nextProfile,cmd=equip(item);p=assert(nextProfile)
 check(R.validate(p,C),'profile ownership/capacity/unique-group invariants hold')
 check(R.equipped(p,'hero',expected).instanceId==item.instanceId,'server agrees with preview slot')
 local actual=assert(Impact.compare(before.heroes.hero,list,item,expected,C))
 for i,row in ipairs(rows)do check(row.after==actual[i].after,'automatic and explicit previews agree')end
 local stats=R.stats(p,'hero',C)
 local Preview=dofile('src/shared/SkillStatPreview.luau')
 local derived=Preview.derived('knight',p.heroes.hero.progression,stats)
 for _,row in ipairs(rows)do check(math.abs(row.after-derived[row.key])<.00001,'preview equals actual post-equip stats')end
 local retry,why,repeated=R.apply(p,cmd,{safe=true},C)
 check(retry and repeated and not why and retry.revision==p.revision,'same request retry cannot select another slot or swap twice')
 return before
end
local ring=find('copper_ring');local charm=find('amber_charm')
previewAndEquip(ring,'accessory1')
previewAndEquip(charm,'accessory2')
local another=R.copy(p.items[ring.instanceId]);another.instanceId='new-ring';another.location={kind='bag',heroId='hero'};p.items[another.instanceId]=another
-- Matching unique group in slot 2 takes precedence over empty slot 1.
p.items[ring.instanceId].location.slot='accessory2';p.items[charm.instanceId].location={kind='bag',heroId='hero'}
previewAndEquip(another,'accessory2')
check(p.items[ring.instanceId].location.kind=='bag','replaced unique item is preserved in bag')
previewAndEquip(p.items[charm.instanceId],'accessory1')
local third=R.copy(p.items[charm.instanceId]);third.instanceId='third-charm';third.location={kind='bag',heroId='hero'};p.items[third.instanceId]=third
while R.count(p,'bag','hero')<C.bagCapacity do
 local filler=R.copy(find('traveler_gloves'));filler.instanceId='fill-'..R.count(p,'bag','hero');p.items[filler.instanceId]=filler
end
previewAndEquip(third,'accessory1')
check(R.count(p,'bag','hero')==C.bagCapacity,'full-bag replacement conserves bag capacity')
check(p.items[charm.instanceId].location.kind=='bag','both full replaces first slot and preserves its former item')
local stale={action='Equip',requestId='stale',heroId='hero',instanceId=ring.instanceId,itemVersion=p.items[ring.instanceId].version,revision=p.revision-1}
local no,reason=R.apply(p,stale,{safe=true},C)
check(not no and reason=='Changed','stale preview cannot replace a changed loadout')
local invalid=Slots.resolve('hero',p.items,C.items.copper_ring,C,'weapon')
check(invalid==nil,'explicit malformed accessory slot still rejected')
local command={action='Equip',requestId='combat',heroId='hero',instanceId=ring.instanceId,itemVersion=p.items[ring.instanceId].version,revision=p.revision}
no,reason=R.apply(p,command,{safe=false},C)
check(not no and reason=='InCombat','automatic equip cannot bypass combat restriction')
-- Other hero's equipment never occupies the current hero's empty slots.
check(Slots.resolve('other',p.items,C.items.copper_ring,C)=='accessory1','slot selection is hero-specific')
print('Accessory automatic equip: '..n..' checks passed')
