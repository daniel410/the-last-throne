-- Run real launch preparation and destination account transitions with store/transport doubles.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local Config=dofile('src/shared/ExpeditionConfig.luau')
local checks=0
local function check(v,label)checks=checks+1;assert(v,label)end
local function fresh(uid)return assert(R.addHero(R.new(uid),'hero','knight',C))end
local function begin(p,id,version)
 return assert(A.begin(p,'hero','DW-01','Easy',id,p.revision,R,C,version))
end
local file=assert(io.open('src/server/Network/ExpeditionService.luau'));local source=file:read('*a');file:close()
local first=assert(source:find('local function startRunLocked(',1,true))
local last=assert(source:find('local function startRun(p,party)',first,true))
local code=source:sub(first,last-1)..'\nreturn startRunLocked'
local function launch(profiles,expectVersion,expectError)
 local actors,members,parties={},{},{}
 for uid in ipairs(profiles)do
  local p={UserId=uid};function p:SetAttribute()end
  actors[uid]=p;members[tostring(uid)]={heroId='hero',token='member'..uid,main=0,level=1}
  parties[p]={id='party'}
 end
 local before={};for uid,p in ipairs(profiles)do before[uid]=R.copy(p)end
 local calls,manifest,status=0,nil,nil
 local inventory={expeditionHero=function(p)return profiles[p.UserId].heroes.hero end}
 local store={freeze=function()return {missionId='DW-01',difficultyId='Easy',members=members}end,
  membership=function(uid)return {id='party',token='member'..uid}end,
  launchStatus=function(_,_,value)status=value end}
 local env=setmetatable({studio=false,C=Config,Players={GetPlayerByUserId=function(_,uid)return actors[uid]end},
  Difficulty=D,Adventure=A,o={inventory=inventory},parties=parties,travel={},store=store,
  member=function(p,token)return {heroId='hero',main=0,level=1,token=token}end,
  selection=function()return {missionId='DW-01',difficultyId='Easy'}end,
  guid=function()return 'new-ticket'end,Http={GenerateGUID=function()return 'reserved'end},
  unlock=function()end,advertise=function()end,
  Departure={prepare=function(_,_,people,_,run)
   calls=calls+1;manifest=run;return run,nil,people
  end},send=function()end},{__index=_G})
 local start=assert(load(code,'production launch','t',env))()
 local result,why=start(actors[1],#actors>1 and {id='party'}or nil,'new-run')
 if expectError then
  check(not result and why==expectError,'mixed rules rejected in lobby')
  check(calls==0 and status=='forming','no manifest/save/teleport and party restored')
 else
  check(result and not why and calls==1,'launch prepares one manifest')
  check(manifest.rulesVersion==expectVersion,'manifest uses destination journal version')
  for uid,p in ipairs(profiles)do
   local a,b=p.heroes.hero.expeditions and p.heroes.hero.expeditions.active,before[uid].heroes.hero.expeditions and before[uid].heroes.hero.expeditions.active
   check(p.revision==before[uid].revision and (a and a.runId)==(b and b.runId),'source journal preserved')
   local saved=begin(p,'new-run',manifest.rulesVersion)
   check(D.verifyRun(saved.heroes.hero,manifest),'saved destination journal passes admission')
   check(saved.heroes.hero.expeditions.active.balanceVersion==expectVersion,'original combat/reward rules preserved')
   local retry=begin(saved,'new-run',manifest.rulesVersion)
   check(retry.revision==saved.revision and D.verifyRun(retry.heroes.hero,manifest),'duplicate arrival remains idempotent')
  end
 end
end
for version=1,D.version do
 local p=begin(fresh(1),'old-run',version)
 local resumed=begin(p,'new-run',D.version)
 if version~=D.version then
  check(not D.verifyRun(resumed.heroes.hero,{id='new-run',missionId='DW-01',difficultyId='Easy',rulesVersion=D.version}),'reproduces old latest-manifest mismatch')
 end
 check(A.departureVersion(p.heroes.hero,'DW-01','Easy')==version,'resume plan preserves version '..version)
 launch({p},version)
end
launch({fresh(1)},D.version)
launch({fresh(1),fresh(2)},D.version)
launch({begin(fresh(1),'old-a',17),begin(fresh(2),'old-b',17)},17)
launch({begin(fresh(1),'old-a',17),begin(fresh(2),'old-b',D.version)},nil,'PartyRulesMismatch')
local p=begin(fresh(1),'easy',17)
p=assert(A.begin(p,'hero','DW-01','Hard','hard',p.revision,R,C,18))
check(A.departureVersion(p.heroes.hero,'DW-01','Easy')==17,'inactive mode checkpoint retains its rules')
check(A.departureVersion(p.heroes.hero,'DW-01','Hard')==18,'active mode checkpoint retains its rules')
check(A.departureVersion(p.heroes.hero,'DW-02','Easy')==D.version,'different mission uses current rules')
check(A.departureVersion(fresh(3).heroes.hero,'DW-01','Easy')==D.version,'new hero uses current rules')
print('Expedition resume rules: '..checks..' checks passed')
