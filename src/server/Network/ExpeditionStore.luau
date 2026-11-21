-- Adapter-driven, server-only matchmaking. Every roster/seat transition is one
-- atomic key update. Membership indexes are fenced tokens, not a multi-key transaction.
local Content=game and require(game.ReplicatedStorage.Shared.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local Store={}
-- A recruiting row needs only the intersection of the roster's routes.
local function commonRoute(p)
 local common
 for _,member in pairs(p.members) do
  local route=member.routes and member.routes[p.difficultyId]
  if not route then return nil end
  if not common then
   common={next=route.next,versions={}}
   for i,version in ipairs(route.versions) do common.versions[i]=version end
  else
   common.next=math.min(common.next,route.next)
   for i,version in ipairs(common.versions) do
    if version~=route.versions[i] then common.versions[i]=0 end
   end
  end
 end
 return common
end
local function destination(common,viewer)
 local earliest=viewer and math.min(common.next,viewer.next) or common.next
 for i=earliest,1,-1 do
  local version=common.versions[i]
  if version and version>0 and (not viewer or viewer.versions[i]==version) then
   return Content.mainChapters[i].id,true
  end
 end
 return Content.mainChapters[earliest].id,false
end
function Store.advertisement(p,memberCount)
 local host=p.members[tostring(p.hostId)]
 return {id=p.id,host=host and host.name or 'Adventurer',count=memberCount,target=p.target,
  missionId=p.missionId,difficultyId=p.difficultyId,route=p.autoMission and commonRoute(p) or nil,expiresAt=p.expiresAt,
  passwordRequired=p.password~=nil}
end
function Store.listing(ad,routes)
 local mission=ad.missionId
 local viewer=routes and routes[ad.difficultyId]
 if ad.route and viewer then mission=destination(ad.route,viewer) end
 return {id=ad.id,host=ad.host,count=ad.count,target=ad.target,missionId=ad.missionId,difficultyId=ad.difficultyId,
  joinMissionId=mission,passwordRequired=ad.passwordRequired==true}
end
function Store.validPassword(password)
 return type(password)=='string' and password:match('^[0-9][0-9][0-9][0-9]$')~=nil
end
local function syncMission(p)
 if not p.difficultyId or p.status~='forming' then return p end
 local common=commonRoute(p)
 if not common then return p end
 local id,shared=destination(common)
 p.recommendedMissionId=shared and id or nil
 if p.autoMission and id~=p.missionId then
  p.missionId=id
  for _,m in pairs(p.members) do m.ready=false end
 end
 return p
end
local function copy(v) if type(v)~='table' then return v end;local n={};for k,x in pairs(v) do n[k]=copy(x) end;return n end
local function size(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
function Store.new(map,clock,config)
 local S={};local C=config
 local function read(key)
  local ok,v=pcall(function() return map:GetAsync(key) end)
  if not ok then
   if warn then warn('[Expedition] MemoryStore read failed ('..key:match('^[^:]+')..'): '..tostring(v))end
   return nil,'NetworkUnavailable'
  end
  if v and v.expiresAt<=clock() then return nil end
  return v
 end
 local function update(key,ttl,fn)
  local reason
  local ok,v=pcall(function() return map:UpdateAsync(key,function(old)
   reason=nil
   if old and old.expiresAt<=clock() then old=nil end
   local n,e=fn(copy(old));reason=e;return n
  end,ttl) end)
  if not ok then
   if warn then warn('[Expedition] MemoryStore update failed ('..key:match('^[^:]+')..'): '..tostring(v))end
   return nil,'NetworkUnavailable'
  end
  return v,reason
 end
 local function prune(p)
  for uid,m in pairs(p.members) do if m.expiresAt<=clock() then p.members[uid]=nil end end
  if p.kicked then
   for uid,untilTime in pairs(p.kicked) do if untilTime<=clock() then p.kicked[uid]=nil end end
  end
  if not p.members[tostring(p.hostId)] then
   local lowest;for uid,m in pairs(p.members) do if m.arrived and (not lowest or tonumber(uid)<lowest) then lowest=tonumber(uid) end end
   if lowest then p.hostId=lowest end
  end
  if (p.status=='launching' or p.status=='launched') and next(p.members) then
   -- Departed members are removed by the source. Reopen only once every remaining seat returned.
   local allReturned=true
   for _,m in pairs(p.members) do if m.returnedFrom~=p.runId then allReturned=false;break end end
   if allReturned then
    p.status='forming';p.runId=nil
    for _,m in pairs(p.members) do m.returnedFrom=nil;m.ready=false end
   end
  end
  return syncMission(p)
 end
 function S.readParty(id) local p,e=read('party:'..id);return p and prune(p),e end
 function S.membership(uid) return read('member:'..uid) end
 function S.claimMembership(uid,id,token)
  return update('member:'..uid,C.partyLease,function(old)
   if old and (old.id~=id or old.token~=token) then return nil,'AlreadyParty' end
   return {id=id,token=token,expiresAt=clock()+C.partyLease}
  end)
 end
 function S.releaseMembership(uid,id,token)
  return update('member:'..uid,1,function(old)
   if not old or old.id~=id or old.token~=token then return nil,'PartyChanged' end
   old.expiresAt=clock();return old
  end)
 end
 function S.allowPasswordAttempt(uid)
  return update('password-attempt:'..uid,C.partyPasswordWindow,function(attempt)
   attempt=attempt or {count=0,expiresAt=clock()+C.partyPasswordWindow}
   if attempt.count>=C.partyPasswordAttempts then return nil,'PasswordRateLimited' end
   attempt.count=attempt.count+1
   return attempt
  end)
 end
 function S.create(id,member,target,job,place,password)
  if target~=2 and target~=3 and target~=4 then return nil,'InvalidRequest' end
  if password~=nil and not Store.validPassword(password) then return nil,'InvalidPassword' end
  return update('party:'..id,C.partyLease,function(old)
   if old then
    local host=old.members[tostring(member.userId)]
    if old.hostId==member.userId and host and host.token==member.token then return old end
    return nil,'AlreadyParty'
   end
   member.arrived=true;member.ready=false;member.expiresAt=clock()+C.partyLease
   return {id=id,version=1,hostId=member.userId,jobId=job,placeId=place,target=target,status='forming',
    members={[tostring(member.userId)]=member},expiresAt=clock()+C.partyLease,password=password}
  end)
 end
 function S.join(id,member,expectedMission,expectedMode,password)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.status~='forming' then return nil,'PartyFull' end;prune(p)
   local uid=tostring(member.userId)
   if not p.members[tostring(p.hostId)] then return nil,'PartyFull' end
   if p.kicked and p.kicked[uid] then return nil,'PartyKickedBlocked' end
   local old=p.members[uid]
   if old then if old.token==member.token then return p end;return nil,'AlreadyParty' end
   if size(p.members)>=p.target then return nil,'PartyFull' end
   if p.password then
    if password==nil then return nil,'PasswordRequired' end
    if not Store.validPassword(password) then return nil,'InvalidPassword' end
    if password~=p.password then return nil,'WrongPassword' end
   end
   member.ready=false;member.expiresAt=clock()+(member.arrived and C.partyLease or C.claimSeconds)
   p.members[uid]=member;p.expiresAt=clock()+C.partyLease
   syncMission(p)
   if expectedMission and (p.missionId~=expectedMission or p.difficultyId~=expectedMode) then return nil,'ListingChanged' end
   return p
  end)
 end
 function S.arrive(id,uid,token,job,member)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.status~='forming' or p.jobId~=job then return nil,'PartyChanged' end;prune(p)
   local m=p.members[tostring(uid)]
   if not m or m.token~=token or m.expiresAt<=clock() or m.heroId~=member.heroId then return nil,'PartyChanged' end
   member.token=token;member.arrived=true;member.ready=false;member.expiresAt=clock()+C.partyLease
   p.members[tostring(uid)]=member;p.expiresAt=clock()+C.partyLease;return syncMission(p)
  end)
 end
 function S.touch(id,member,ready,missionId,mode)
  return update('party:'..id,C.partyLease,function(p)
   if not p then return nil,'PartyChanged' end;prune(p)
   local m=p.members[tostring(member.userId)]
   if not m or m.token~=member.token or not m.arrived then return nil,'PartyChanged' end
   if p.status~='forming' then
    m.expiresAt=clock()+C.partyLease;p.expiresAt=m.expiresAt
    return p
   end
   if ready and missionId and (missionId~=p.missionId or mode~=p.difficultyId) then return nil,'PartyChanged' end
   local changed=m.heroId~=member.heroId or m.main~=member.main or m.level~=member.level
   if changed and p.missionId then for _,other in pairs(p.members)do other.ready=false end end
   member.arrived=true;member.ready=not changed and (ready==nil and m.ready or ready) or false
   member.expiresAt=clock()+C.partyLease;p.members[tostring(member.userId)]=member;p.expiresAt=clock()+C.partyLease;return syncMission(p)
  end)
 end
 function S.returnSeat(id,uid,token,runId)
  return update('party:'..id,C.partyLease,function(p)
   local m=p and p.members[tostring(uid)]
   if not m or m.token~=token then return nil,'PartyChanged' end
   if p.runId~=runId then return p end
   m.returnedFrom=runId;m.ready=false;m.expiresAt=clock()+C.partyLease
   p.expiresAt=m.expiresAt
   return prune(p)
  end)
 end
 function S.remove(id,uid,token)
  return update('party:'..id,C.partyLease,function(p)
   if not p then return nil,'PartyChanged' end
   local m=p.members[tostring(uid)];if not m or m.token~=token then return nil,'PartyChanged' end
   p.members[tostring(uid)]=nil;prune(p)
   if size(p.members)==0 then p.status='closed' end;p.expiresAt=clock()+C.partyLease;return p
  end)
 end
 local function manageParty(id,leader,token,change)
  return update('party:'..id,C.partyLease,function(p)
   if not p then return nil,'PartyChanged' end
   prune(p)
   local host=p.members[tostring(leader)]
   if p.hostId~=leader or not host or host.token~=token or not host.arrived then return nil,'LeaderOnly' end
   if p.status~='forming' then return nil,'PartyChanged' end
   local reason=change(p)
   if reason then return nil,reason end
   p.expiresAt=clock()+C.partyLease
   return p
  end)
 end
 function S.setPassword(id,leader,token,password)
  if password~='' and not Store.validPassword(password) then return nil,'InvalidPassword' end
  return manageParty(id,leader,token,function(p)
   p.password=password~='' and password or nil
  end)
 end
 function S.kick(id,leader,token,target)
  if target==leader then return nil,'InvalidRequest' end
  local targetId=tostring(target)
  local removedToken
  local party,reason=manageParty(id,leader,token,function(p)
   local m=p.members[targetId]
   if not m then return 'PartyChanged' end
   removedToken=m.token
   p.members[targetId]=nil
   p.kicked=p.kicked or {}
   p.kicked[targetId]=clock()+C.partyKickSeconds
   for _,other in pairs(p.members) do other.ready=false end
   syncMission(p)
  end)
  return party,reason,party and removedToken
 end
 function S.configure(id,leader,missionId,difficultyId,autoMission)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.hostId~=leader then return nil,'LeaderOnly'end
   if p.status~='forming'then return nil,'PartyChanged'end
   p.autoMission=autoMission==true
   if p.missionId~=missionId or p.difficultyId~=difficultyId then
    p.missionId=missionId;p.difficultyId=difficultyId
    for _,m in pairs(p.members)do m.ready=false end
   end
   p.expiresAt=clock()+C.partyLease;return syncMission(p)
  end)
 end
 function S.freeze(id,leader,runId)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.hostId~=leader then return nil,'LeaderOnly' end;prune(p)
   if p.status~='forming' then return nil,'PartyChanged' end
   if size(p.members)~=p.target then return nil,'NotReady' end
   local main
   for _,m in pairs(p.members) do
    if not m.arrived or not m.ready or m.expiresAt<=clock() or (not p.missionId and main~=nil and main~=m.main) then return nil,'NotReady' end
    main=m.main
   end
   p.status='launching';p.runId=runId;p.expiresAt=clock()+C.partyLease;return p
  end)
 end
 function S.launchStatus(id,runId,status)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.runId~=runId then return nil,'PartyChanged' end
   p.status=status;p.expiresAt=clock()+C.partyLease
   if status=='forming' then
    p.runId=nil
    for _,m in pairs(p.members) do m.ready=false;m.returnedFrom=nil end
   end
   return p
  end)
 end
 function S.createRun(run)
  return update('run:'..run.id,C.rejoinSeconds,function(old)
   if old then if old.ticket==run.ticket then return old end;return nil,'PartyChanged' end
   run.expiresAt=clock()+C.rejoinSeconds;run.ownerJob='';run.ownerUntil=0;return run
  end)
 end
 function S.readRun(id) return read('run:'..id) end
 function S.cancelRun(id,ticket)
  return update('run:'..id,C.rejoinSeconds,function(run)
   if not run or run.ticket~=ticket then return nil,'PartyChanged' end;run.closed=true;return run
  end)
 end
 -- A departure ticket is tentative. Keep the old rejoin capability until the
 -- destination has durably begun the new run. No account rollback is needed.
 function S.stageOffer(uid,run,heroId,ticket)
  return update('rejoin:'..uid,C.rejoinSeconds,function(old)
   old=old or {}
   old.pending={runId=run.id,heroId=heroId,ticket=ticket,expiresAt=clock()+C.rejoinSeconds}
   old.expiresAt=math.max(old.expiresAt or 0,old.pending.expiresAt)
   return old
  end)
 end
 function S.departure(uid,id,ticket)
  local r,e=read('rejoin:'..uid);local p=r and r.pending
  if not p or p.expiresAt<=clock()or p.runId~=id or p.ticket~=ticket then return nil,e or 'RejoinExpired'end
  local run,why=S.readRun(id)
  local m=run and run.members[tostring(uid)]
  if not m or m.cancelled or m.ticket~=ticket or run.closed then return nil,why or 'RejoinExpired'end
  return p
 end
 function S.offer(uid,run,heroId,ticket,replace)
  return update('rejoin:'..uid,C.rejoinSeconds,function(old)
   if not replace and (not old or old.runId~=run.id or old.ticket~=ticket or old.finished) then return nil,'RejoinExpired' end
   return {runId=run.id,heroId=heroId,ticket=ticket,expiresAt=clock()+C.rejoinSeconds,pending=not replace and old and old.pending or nil}
  end)
 end
 function S.rejoin(uid,activeRun)
  local r,e=read('rejoin:'..uid);if not r then return nil,e end
  -- Recover a committed begin even if the destination lost the promotion reply.
  local pending=r.pending
  if pending and pending.expiresAt>clock()and activeRun and activeRun(pending.heroId)==pending.runId then return pending end
  if r.finished then return nil,'RejoinExpired'end
  return r.runId and r or nil
 end
 function S.finish(uid,id,ticket)
  return update('rejoin:'..uid,C.rejoinSeconds,function(old)
   if not old or old.runId~=id or old.ticket~=ticket then return nil,'RejoinExpired' end
   old.finished=true;return old
  end)
 end
 function S.admit(id,uid,ticket,job)
  local offer,e=read('rejoin:'..uid)
  local pending=offer and offer.pending
  if pending and pending.runId==id and pending.ticket==ticket and pending.expiresAt>clock()then offer=pending end
  if not offer or offer.finished or offer.runId~=id or offer.ticket~=ticket then return nil,e or 'RejoinExpired' end
  return update('run:'..id,C.rejoinSeconds,function(run)
   local m=run and run.members[tostring(uid)]
   if not m or m.ticket~=ticket or m.cancelled or run.closed then return nil,'RejoinExpired' end
   if run.ownerJob~='' and run.ownerJob~=job and run.ownerUntil>clock() then return nil,'AccountBusy' end
   m.admitted=true;run.ownerJob=job;run.ownerUntil=clock()+C.runLease;run.expiresAt=clock()+C.rejoinSeconds;return run
  end)
 end
 -- Fence delayed arrivals for a failed teleport without cancelling users already admitted.
 function S.failTravel(id,uid,ticket)
  return update('run:'..id,C.rejoinSeconds,function(run)
   local m=run and run.members[tostring(uid)]
   if not m or m.ticket~=ticket then return nil,'RejoinExpired' end
   if m.admitted then return run end
   m.cancelled=true
   for _,other in pairs(run.members) do if not other.cancelled then return run end end
   run.closed=true
   return run
  end)
 end
 function S.renewRun(id,job)
  return update('run:'..id,C.rejoinSeconds,function(run)
   if not run or run.ownerJob~=job or run.closed then return nil,'RejoinExpired' end
   run.ownerUntil=clock()+C.runLease;run.expiresAt=clock()+C.rejoinSeconds;return run
  end)
 end
 return S
end
return Store
