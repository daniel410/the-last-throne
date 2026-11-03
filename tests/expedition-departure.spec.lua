local S=dofile('src/server/Network/ExpeditionStore.luau')
local Departure=dofile('src/server/Network/ExpeditionDeparture.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local Config=dofile('src/shared/ExpeditionConfig.luau')
local n=0;local function check(v,label)n=n+1;assert(v,label)end
local profiles={}
local members={};local players={{UserId=1},{UserId=2}}
local db,failKey,afterWrite={},nil,false
local map={GetAsync=function(_,k)return R.copy(db[k])end,UpdateAsync=function(_,k,fn)
 if k==failKey and not afterWrite then error('outage')end
 local v=fn(R.copy(db[k]));if v then db[k]=R.copy(v)end
 if k==failKey then error('lost reply')end
 return R.copy(v)
end}
local store=S.new(map,function()return 100 end,Config)
for _,p in ipairs(players)do
 local uid=p.UserId;local profile=assert(R.addHero(R.new(uid),'hero','knight',C))
 profile=assert(A.begin(profile,'hero','DW-01','Easy','old'..uid,profile.revision,R,C))
 local goal=D.mission('DW-01').goals[1]
 profiles[uid]=assert(A.event(profile,'hero','DW-01',goal.id,nil,nil,R,C,'old'..uid))
 local old=assert(store.createRun({id='old'..uid,ticket='master'..uid,members={[tostring(uid)]={heroId='hero',ticket='old-ticket'..uid}}}))
 assert(store.offer(uid,old,'hero','old-ticket'..uid,true))
 members[tostring(uid)]={heroId='hero',ticket='new-ticket'..uid}
end
local failMember;local closed={}
local inventory={prepareTransfer=function(p)if p.UserId==failMember then return false end;closed[p.UserId]=true;return true end}
local function unlock(p)closed[p.UserId]=nil end
local function run(id)return {id=id,ticket='master-'..id,members=members,missionId='DW-01',difficultyId='Easy',rulesVersion=D.version}end
local function preserved()
 for _,p in ipairs(players)do
  local uid=p.UserId;local h=profiles[uid].heroes.hero
  check(h.expeditions.active.runId=='old'..uid,'old checkpoint retained')
  check(h.expeditions.active.journal.flags['DW-01:'..D.mission('DW-01').goals[1].id],'old objective retained')
  check(store.rejoin(uid).runId=='old'..uid,'old rejoin retained')
 end
end
failKey='run:create-fails';check(not Departure.prepare(store,inventory,players,members,run('create-fails'),unlock),'run creation fails');preserved()
failKey=nil;failMember=2
check(not Departure.prepare(store,inventory,players,members,run('member-fails'),unlock),'second member transfer fails')
check(not closed[1]and not closed[2],'prepared first member released');preserved()
check(not store.admit('member-fails',1,'new-ticket1','battle'),'cancelled pending ticket rejects arrival')
failMember=nil;failKey='rejoin:2';afterWrite=true
check(not Departure.prepare(store,inventory,players,members,run('offer-unknown'),unlock),'unknown staged offer stops travel')
failKey=nil;afterWrite=false;preserved()
check(not store.admit('offer-unknown',2,'new-ticket2','battle'),'unknown committed offer cancelled safely')
local manifest,err,prepared=Departure.prepare(store,inventory,players,members,run('new'),unlock)
check(manifest and not err and #prepared==2,'successful preparation returns both accounts');preserved()
check(store.admit('new',1,'new-ticket1','battle'),'staged ticket authorizes initial destination')
check(store.departure(1,'new','new-ticket1'),'destination may begin only staged run')
-- Crash/lost MemoryStore promotion after a successful durable account begin.
profiles[1]=assert(A.begin(profiles[1],'hero','DW-01','Easy','new',profiles[1].revision,R,C))
check(D.verifyRun(profiles[1].heroes.hero,manifest),'destination saved correct journal')
local function active(heroId)return profiles[1].heroes[heroId].expeditions.active.runId end
check(store.rejoin(1,active).runId=='new','reconnect resolves committed begin before promotion')
check(store.admit('new',1,'new-ticket1','battle'),'pending committed begin admits reconnect')
check(store.offer(1,manifest,'hero','new-ticket1',true),'promotion commits')
check(not store.admit('old1',1,'old-ticket1','battle'),'old ticket fenced after promotion')
local revision=profiles[1].revision
profiles[1]=assert(A.begin(profiles[1],'hero','DW-01','Easy','new',revision-1,R,C))
check(profiles[1].revision==revision,'destination retry retains checkpoint revision')
local newer=assert(store.createRun(run('newer')));assert(store.stageOffer(2,newer,'hero','newer-ticket'))
check(not store.departure(2,'new','new-ticket2'),'superseded pending arrival cannot start old run')
check(not store.admit('new',2,'new-ticket2','other'),'superseded pending ticket rejects admission')
check(store.admit('old2',2,'old-ticket2','old-battle'),'failed or superseded departure preserves prior resume')
print('Expedition departure: '..n..' checks passed')
