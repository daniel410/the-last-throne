-- Real campaign saves and party-store transitions, with an in-memory transport.
local A=dofile('src/shared/AdventureRules.luau')
local C=dofile('src/shared/CampaignContent.luau')
local D=dofile('src/shared/Difficulty.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local V=dofile('src/shared/ExpeditionPresentation.luau')
local G=dofile('src/shared/HeroProgression.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local Store=dofile('src/server/Network/ExpeditionStore.luau')
local function hero(p)return p.heroes.h end
local function begin(p,c,id,party)
 return assert(A.begin(p,'h',c,'Easy',id,p.revision,R,Items,D.version,party))
end
local function step(p,c,g,s,id)
 local choice=s and s.choices and(s.solution or s.choices[1].id)or g.choice and 'shared' or nil
 return assert(A.event(p,'h',c.id,g.id,choice,s and s.id or nil,R,Items,id))
end
local function finish(p,c,id)
 for _,g in ipairs(c.goals)do
  if P.required(A.projection(hero(p)),g)then
   for _,s in ipairs(g.activity and g.activity.steps or {false})do p=step(p,c,g,s,id)end
  end
 end
 assert(hero(p).expeditions.active.journal.clears[c.id]);return p
end
local profiles={}
for uid,frontier in ipairs({1,2,4}) do
 local p=assert(R.addHero(R.new(uid),'h','knight',Items))
 hero(p).level=({1,10,20})[uid];hero(p).progression=G.new(hero(p).level)
 local run='original'..uid
 for i=1,frontier do
  local c=C.mainChapters[i];p=begin(p,c.id,run..i)
  if i<frontier then p=finish(p,c,run..i) end
 end
 profiles[uid]=p
end
local function member(i)
 local h=hero(profiles[i])
 return {userId=i,token='t'..i,heroId='h',name='Hero'..i,arrived=true,level=h.level,main=h.deepwood and h.deepwood.main or 0,routes=A.partyRoutes(h)}
end
for host=1,3 do
 local db={};local map={UpdateAsync=function(_,k,fn)local value=fn(db[k]);if value then db[k]=value end;return value end,GetAsync=function(_,k)return db[k]end}
 local store=Store.new(map,function()return 0 end,{partyLease=180})
 assert(store.create('p',member(host),3,'job',1))
 assert(store.configure('p',host,'DW-04','Easy',true))
 for i=1,3 do if i~=host then
  local before=store.readParty('p')
  local ad=Store.advertisement(before,i==1 and 1 or 2)
  local listing=Store.listing(ad,member(i).routes)
  assert(listing.missionId==before.missionId and listing.difficultyId=='Easy' and not listing.route)
  local rejected,why=store.join('p',member(i),listing.joinMissionId,'Hard')
  assert(not rejected and why=='ListingChanged' and not store.readParty('p').members[tostring(i)])
  local joined=assert(store.join('p',member(i),listing.joinMissionId,listing.difficultyId))
  assert(joined.missionId==listing.joinMissionId)
 end end
 local p=store.readParty('p')
 assert(p.missionId=='DW-01','all leaders recommend earliest shared frontier')
 for i=1,3 do assert(store.touch('p',member(i),true,p.missionId,'Easy'))end
 local v=V.party(store.readParty('p'),function(m)return hero(profiles[m.userId])end)
 assert(v.launchAllowed and v.members[1].firstClear and not v.members[2].firstClear and not v.members[3].firstClear)
 assert(store.configure('p',host,'DW-04','Easy'))
 assert(store.readParty('p').recommendedMissionId=='DW-01' and store.readParty('p').missionId=='DW-04','manual selection retains common alternative')
 local manual=Store.listing(Store.advertisement(store.readParty('p'),3),member(1).routes)
 assert(manual.joinMissionId=='DW-04' and manual.missionId=='DW-04','manually selected mission is advertised unchanged')
 assert(not store.touch('p',member(1),true,'DW-01','Easy'),'late Ready cannot consent to a different mission')
 assert(not V.party(store.readParty('p'),function(m)return hero(profiles[m.userId])end).launchAllowed)
 assert(store.configure('p',host,'DW-04','Easy',true).missionId=='DW-01')
end
local helper=profiles[2];local second=C.mainChapters[2];local first=C.mainChapters[1]
helper=step(helper,second,second.goals[1],false,'original22')
local saved=hero(helper).expeditions.active
saved.kills.personal_pack_1=true
local function checkResume(p)
 local h=hero(p);assert(A.selection(h).missionId==second.id)
 local resumed=begin(p,second.id,'home',false);local a=hero(resumed).expeditions.active
 assert(a.kills.personal_pack_1 and a.journal.flags[second.id..':'..second.goals[1].id])
end
helper=begin(helper,first.id,'together',true)
assert(hero(helper).expeditions.active.partyAssist)
checkResume(helper)
local before=helper.wallet.gold
helper=finish(helper,first,'together')
assert(helper.wallet.gold-before==D.completion(first,'Easy',D.version,hero(helper).expeditions.active.growthCycle).gold)
checkResume(helper)
assert(A.projection(hero(helper)).flags[second.id..':'..second.goals[1].id],'helper keeps checkpoint when party catches up')
hero(helper).expeditions.active.kills['DW-02:new_pack_2']=true
assert(hero(begin(helper,'DW-02','resume_after_kill',false)).expeditions.active.kills.new_pack_2)
local resumedParty=finish(helper,second,'together')
assert(A.selection(hero(resumedParty)).missionId=='DW-03','party and helper advance together once caught up')
local novice=finish(begin(profiles[1],first.id,'together',true),first,'together')
assert(hero(novice).expeditions.modeRewardClaims.Easy[first.id] and A.selection(hero(novice)).missionId==second.id)
assert(A.partyRoutes(hero(novice)).Easy.next==2)
print('Party campaign: three leader permutations, stale Ready, manual/automatic selection, checkpoint and rewards passed')
