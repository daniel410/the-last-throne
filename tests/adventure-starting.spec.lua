-- Execute the production departure lock boundary with controlled store/save outcomes.
local file=assert(io.open('src/server/Network/ExpeditionService.luau'));local source=file:read('*a');file:close()
local first=assert(source:find('local function startRun(p,party)',1,true))
local last=assert(source:find('function Service.solo(p)',first,true))
local code=source:sub(first,last-1)..'\nreturn startRun'
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local function scenario(kind,solo)
 local players={};local busy,travel,parties={},{},{}
 for i=1,solo and 1 or 4 do
  local p={Parent=players,attrs={},UserId=i}
  function p:SetAttribute(key,value)self.attrs[key]=value end
  table.insert(players,p);parties[p]={id='party'}
 end
 local p=players[1];local observations=0
 local env=setmetatable({Players=players,busy=busy,travel=travel,parties=parties,guid=function()return 'run' end,Backend=dofile('src/server/Network/ExpeditionBackend.luau'),
  cancelTransfer=function(person)person.unlocked=true end,store={launchStatus=function()end},
  startRunLocked=function()
   -- This represents the first yielding store/save operation.
   for _,person in ipairs(players)do
    check(person.attrs.TLTAdventureStarting==true,'all participants see starting before store/save')
    check(busy[person]==true,'all participants remain action-locked');observations=observations+1
   end
   if kind=='throw' then error('store unavailable')end
   if kind=='reject' then return nil,'NotReady'end
   if kind=='travel' then for _,person in ipairs(players)do travel[person]={}end end
   return true
  end},{__index=_G})
 local run=assert(load(code,'departure boundary','t',env))()
 if kind=='busy' then busy[players[2]]=true end
 local result,reason=run(p,not solo and {id='party'}or nil)
 if kind=='busy' then
  check(result==nil and reason=='Busy' and observations==0,'busy party never starts departure')
  for _,person in ipairs(players)do check(person.attrs.TLTAdventureStarting==nil,'busy rejection never shows starting')end
 else
  for _,person in ipairs(players)do
   check(person.attrs.TLTAdventureStarting==(kind=='travel'),'progress persists only for dispatched participants')
   check(busy[person]==nil,'departure boundary restores request lock')
   if kind=='throw' then check(person.unlocked,'unexpected failure resumes participants')end
  end
  if kind=='throw' then check(reason=='NetworkUnavailable','exception returns recoverable error')end
  if kind=='reject' then check(reason=='NotReady','validation rejection is preserved')end
 end
end
for _,kind in ipairs({'preview','travel','reject','throw'})do scenario(kind,true);scenario(kind,false)end
scenario('busy',false)
print('Adventure starting: '..checks..' checks passed')
