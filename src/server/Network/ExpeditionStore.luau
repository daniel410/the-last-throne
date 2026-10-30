-- Adapter-driven, server-only matchmaking. Every roster/seat transition is one
-- atomic key update. Membership indexes are fenced tokens, not a multi-key transaction.
local Store={}
local function copy(v) if type(v)~='table' then return v end;local n={};for k,x in pairs(v) do n[k]=copy(x) end;return n end
local function size(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
function Store.new(map,clock,config)
 local S={};local C=config
 local function read(key)
  local ok,v=pcall(function() return map:GetAsync(key) end)
  if not ok then return nil,'NetworkUnavailable' end
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
  if not ok then return nil,'NetworkUnavailable' end
  return v,reason
 end
 local function prune(p)
  for uid,m in pairs(p.members) do if m.expiresAt<=clock() then p.members[uid]=nil end end
  if not p.members[tostring(p.hostId)] then
   local lowest;for uid,m in pairs(p.members) do if m.arrived and (not lowest or tonumber(uid)<lowest) then lowest=tonumber(uid) end end
   if lowest then p.hostId=lowest end
  end
  return p
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
 function S.create(id,member,target,job,place)
  if target~=2 and target~=3 and target~=4 then return nil,'InvalidRequest' end
  return update('party:'..id,C.partyLease,function(old)
   if old then if old.hostId==member.userId then return old end;return nil,'AlreadyParty' end
   member.arrived=true;member.ready=false;member.expiresAt=clock()+C.partyLease
   return {id=id,version=1,hostId=member.userId,jobId=job,placeId=place,target=target,status='forming',members={[tostring(member.userId)]=member},expiresAt=clock()+C.partyLease}
  end)
 end
 function S.join(id,member)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.status~='forming' then return nil,'PartyFull' end;prune(p)
   local old=p.members[tostring(member.userId)]
   if old then if old.token==member.token then return p end;return nil,'AlreadyParty' end
   if size(p.members)>=p.target then return nil,'PartyFull' end
   member.ready=false;member.expiresAt=clock()+(member.arrived and C.partyLease or C.claimSeconds)
   p.members[tostring(member.userId)]=member;p.expiresAt=clock()+C.partyLease;return p
  end)
 end
 function S.arrive(id,uid,token,job,member)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.status~='forming' or p.jobId~=job then return nil,'PartyChanged' end;prune(p)
   local m=p.members[tostring(uid)]
   if not m or m.token~=token or m.expiresAt<=clock() or m.heroId~=member.heroId then return nil,'PartyChanged' end
   member.token=token;member.arrived=true;member.ready=false;member.expiresAt=clock()+C.partyLease
   p.members[tostring(uid)]=member;p.expiresAt=clock()+C.partyLease;return p
  end)
 end
 function S.touch(id,member,ready)
  return update('party:'..id,C.partyLease,function(p)
   if not p then return nil,'PartyChanged' end;prune(p)
   local m=p.members[tostring(member.userId)]
   if not m or m.token~=member.token or not m.arrived then return nil,'PartyChanged' end
   if p.status~='forming' then return p end
   local changed=m.heroId~=member.heroId or m.main~=member.main
   member.arrived=true;member.ready=not changed and (ready==nil and m.ready or ready) or false
   member.expiresAt=clock()+C.partyLease;p.members[tostring(member.userId)]=member;p.expiresAt=clock()+C.partyLease;return p
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
 function S.freeze(id,leader,runId)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.hostId~=leader then return nil,'LeaderOnly' end;prune(p)
   if p.status~='forming' then return nil,'PartyChanged' end
   if size(p.members)~=p.target then return nil,'NotReady' end
   local main
   for _,m in pairs(p.members) do
    if not m.arrived or not m.ready or m.expiresAt<=clock() or (main~=nil and main~=m.main) then return nil,'NotReady' end
    main=m.main
   end
   p.status='launching';p.runId=runId;p.expiresAt=clock()+C.partyLease;return p
  end)
 end
 function S.launchStatus(id,runId,status)
  return update('party:'..id,C.partyLease,function(p)
   if not p or p.runId~=runId then return nil,'PartyChanged' end
   p.status=status;p.expiresAt=clock()+C.partyLease
   if status=='forming' then for _,m in pairs(p.members) do m.ready=false end end
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
 function S.offer(uid,run,heroId,ticket,replace)
  return update('rejoin:'..uid,C.rejoinSeconds,function(old)
   if not replace and (not old or old.runId~=run.id or old.ticket~=ticket or old.finished) then return nil,'RejoinExpired' end
   return {runId=run.id,heroId=heroId,ticket=ticket,expiresAt=clock()+C.rejoinSeconds}
  end)
 end
 function S.rejoin(uid) local r,e=read('rejoin:'..uid);return r and not r.finished and r or nil,e end
 function S.finish(uid,id,ticket)
  return update('rejoin:'..uid,C.rejoinSeconds,function(old)
   if not old or old.runId~=id or old.ticket~=ticket then return nil,'RejoinExpired' end
   old.finished=true;return old
  end)
 end
 function S.admit(id,uid,ticket,job)
  local offer,e=S.rejoin(uid)
  if not offer or offer.runId~=id or offer.ticket~=ticket then return nil,e or 'RejoinExpired' end
  return update('run:'..id,C.rejoinSeconds,function(run)
   local m=run and run.members[tostring(uid)]
   if not m or m.ticket~=ticket or run.closed then return nil,'RejoinExpired' end
   if run.ownerJob~='' and run.ownerJob~=job and run.ownerUntil>clock() then return nil,'AccountBusy' end
   run.ownerJob=job;run.ownerUntil=clock()+C.runLease;run.expiresAt=clock()+C.rejoinSeconds;return run
  end)
 end
 function S.renewRun(id,job)
  return update('run:'..id,C.rejoinSeconds,function(run)
   if not run or run.ownerJob~=job or run.closed or run.ownerUntil<=clock() then return nil,'RejoinExpired' end
   run.ownerUntil=clock()+C.runLease;run.expiresAt=clock()+C.rejoinSeconds;return run
  end)
 end
 return S
end
return Store
