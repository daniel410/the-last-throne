-- Actual inventory queue + session store; fake Player projection, no live DataStore.
local Inventory=game:GetService('ServerScriptService').Server.Inventory
local original=Inventory.InventoryService
local copy=original:Clone();copy.Name='DeathInventoryQA'
local source=copy.Source
local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.ready',first,true))
source=source:sub(1,first-1)..'local function publish() end\n'..source:sub(last)
source=source:gsub('if result then data%[key%] = Rules.copy%(result%) end',"if result then data[key] = Rules.copy(result) end; if script:GetAttribute('QASaveUnknown') then error('QA lost acknowledgement after commit') end")
copy.Source=source;copy.Parent=Inventory
local service=require(copy)
local backing=Instance.new('Folder');backing.Name='DeathPlayerAttributes';backing.Parent=workspace
local player={UserId=8123,Parent=game.Players,SetAttribute=function(_,key,value)backing:SetAttribute(key,value)end,GetAttribute=function(_,key)return backing:GetAttribute(key)end}
local ctx={heroId='death-hero',generation=1,atHub=false}
service.start({heroSession={getInventoryContext=function()return ctx end,isBusy=function()return false end,refresh=function()end},combat={isSafeForEquipment=function()return true end,refreshEquipment=function()end},prompts={}})
local count=0
local function check(v,m)count+=1;assert(v,m)end
local function waitFor(fn)local deadline=os.clock()+8;repeat if fn()then return true end;task.wait(.05)until os.clock()>deadline;return false end
check(service.open(player)~=nil,'session account opens')
check(service.createHero(player,'death-hero','knight')==nil,'hero created')
service.awardXP(player,'death-hero',140,false,0)
check(waitFor(function()local g=service.growth(player,'death-hero');return g and g.level==2 and g.xp==40 end),'initial XP queue settles')
copy:SetAttribute('QASaveUnknown',true)
service.penalizeDeath(player,'death-hero','death-unknown',false)
check(backing:GetAttribute('TLTDeathXPState')=='Saving' and backing:GetAttribute('TLTDeathXPLost')==nil,'pending write never claims a loss')
service.penalizeDeath(player,'death-hero','death-unknown',false)
task.wait(1.5)
check(backing:GetAttribute('TLTDeathXPState')=='Saving','unknown write stays pending')
copy:SetAttribute('QASaveUnknown',false)
check(waitFor(function()return backing:GetAttribute('TLTDeathXPState')=='Saved'end),'same queued death recovers after unknown write')
check(service.growth(player,'death-hero').xp==36 and backing:GetAttribute('TLTDeathXPLost')==4,'exactly four XP lost once')
check(service.growth(player,'death-hero').level==2,'level protected')
service.penalizeDeath(player,'death-hero','training-death',true)
check(backing:GetAttribute('TLTDeathXPState')=='Training' and service.growth(player,'death-hero').xp==36,'training skips persistence deduction')
service.awardXP(player,'death-hero',20,false,0)
check(waitFor(function()return service.growth(player,'death-hero').xp==56 end),'ordinary reward queue still works')
service.penalizeDeath(player,'death-hero','death-unknown',false)
check(service.growth(player,'death-hero').xp==56 and backing:GetAttribute('TLTDeathXPLost')==4,'same receipt never deducts newer rewards')
copy:SetAttribute('QASaveUnknown',true)
service.penalizeDeath(player,'death-hero','death-close',false)
service.close(player)
task.delay(2,function()copy:SetAttribute('QASaveUnknown',false)end)
check(waitFor(function()return not service.available(player) and backing:GetAttribute('TLTDeathXPState')=='Saved'end),'close flush settles queued death')
-- Opening again verifies what the actual session adapter retained.
check(waitFor(function()return not service.busy(player)end),'close no longer busy')
check(service.open(player)~=nil,'account reopens')
check(service.growth(player,'death-hero').xp==50 and service.growth(player,'death-hero').level==2,'close/reopen preserves one six-XP deduction')
service.close(player);task.wait(.1);backing:Destroy();copy:Destroy()
print('DEATH_XP_SERVICE_NATIVE '..game.HttpService:JSONEncode({pass=true,checks=count,coverage='Actual inventory queue and session store; fake Player; no real network/DataStore'}))
