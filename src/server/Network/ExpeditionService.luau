local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local Run=game:GetService('RunService')
local Teleport=game:GetService('TeleportService')
local C=require(RS.Shared.ExpeditionConfig)
local Store=require(script.Parent.ExpeditionStore)
local Departure=require(script.Parent.ExpeditionDeparture)
local TravelAttempt=require(script.Parent.TravelAttempt)
local Difficulty=require(RS.Shared.Difficulty)
local Content=require(RS.Shared.CampaignContent)
local Presentation=require(RS.Shared.ExpeditionPresentation)
local Service={}
local selections={}
local o,store,remote,index,role,job
local parties,travel,arrivals,admitted,busy,last,leaving={},{},{},{},{},{},{}
local battleRun,battleStarted,runHealthy=nil,nil,true
local seats={};local seatCount=0
local studio=Run:IsStudio()
local function guid() return Http:GenerateGUID(false):gsub('%-','') end
local function count(t) local n=0;for _ in pairs(t or {}) do n+=1 end;return n end
local function sourceValid(data) return data.SourceGameId==game.GameId and (data.SourcePlaceId==C.lobbyPlaceId or data.SourcePlaceId==C.battlePlaceId) end
local function member(p,token)
 local h=o.heroSession.getActiveHero(p);local ctx=o.heroSession.getInventoryContext(p)
 if not h or not ctx or not ctx.atHub or p:GetAttribute('K0SessionPhase')~='Lobby' then return nil end
 local s=o.inventory.storyState(p,h.heroId);local g=o.inventory.growth(p,h.heroId)
 return {userId=p.UserId,name=p.DisplayName,heroId=h.heroId,classId=h.classId,main=s and s.main or 0,level=g and g.level or 1,token=token,arrived=true}
end
local function offer(p)
 local r,e=store.rejoin(p.UserId,function(heroId)
  local a=o.inventory.expedition(p,heroId);return a and a.runId
 end);if not r then return nil,e end
 local run,why=store.readRun(r.runId);if not run or run.closed then return nil,why or 'RejoinExpired' end
 return r,nil,run
end
local function selection(p)
 if selections[p]then return selections[p]end
 return require(RS.Shared.AdventureRules).selection(o.inventory.expeditionHero(p))
end
local function publish(p,errorCode,open,requestId)
 if p.Parent~=Players or not remote then return end
 local localParty=parties[p];local party=localParty and store.readParty(localParty.id)
 local list={}
 if role=='Lobby' then
  local ok,rows=pcall(function() return index:GetRangeAsync(Enum.SortDirection.Descending,20) end)
  if ok then for _,row in ipairs(rows) do local v=row.value;if v.expiresAt>os.time() and v.count<v.target then table.insert(list,v) end end end
 end
 -- Reserved destination IDs, membership fences and admission tickets stay server-only.
 local clean=Presentation.party(party,function(m)
  local person=Players:GetPlayerByUserId(m.userId)
  local ctx=person and o.heroSession.getInventoryContext(person)
  local fence=person and parties[person]
  if not ctx or not ctx.atHub or ctx.heroId~=m.heroId or not fence or fence.id~=party.id or fence.token~=m.token or travel[person]then return nil end
  return o.inventory.expeditionHero(person)
 end)
 local r,_,rejoinRun=offer(p)
 local choice=party and {missionId=party.missionId,difficultyId=party.difficultyId}or selection(p)
 local hero=o.inventory.expeditionHero(p);local missions=Presentation.missions(hero,clean and clean.target or 1)
 local activeHero=o.heroSession.getActiveHero(p)
 local expedition=activeHero and o.inventory.expedition(p,activeHero.heroId)
 remote:FireClient(p,{role=role,studio=studio,configured=C.battlePlaceId>0,capacity=role=='Lobby' and C.lobbyCapacity or C.battleCapacity,
  requestId=requestId,busy=busy[p]==true,hero=hero and {classId=hero.baseClassId,level=hero.level},selection=choice,missions=missions,expedition=expedition,population=#Players:GetPlayers(),party=clean,list=list,travelling=travel[p]~=nil,error=errorCode,open=open==true,rejoin=r and {heroId=r.heroId,expiresAt=r.expiresAt,rulesVersion=rejoinRun and rejoinRun.rulesVersion} or nil})
end
function Service.openMenu(p)
 if role~='Lobby' or p:GetAttribute('K0SessionPhase')~='Lobby' then return 'WaitForLobby' end
 if Service.isBusy(p) then return 'Busy' end
 publish(p,nil,true)
end
local function advertise(id)
 local p=store.readParty(id);if not p then return end
 if p.status~='forming' or count(p.members)==0 then pcall(function() index:RemoveAsync(id) end);return end
 local host=p.members[tostring(p.hostId)]
 pcall(function() index:SetAsync(id,{id=id,host=host and host.name or 'Adventurer',count=count(p.members),target=p.target,expiresAt=p.expiresAt},C.partyLease,os.time()) end)
end
local function unlock(p)
 if o.inventory.resumeTransfer(p) then p:SetAttribute('TLTTravelLock',false);o.heroSession.refresh(p);return true end
 return false
end
local function retryTravel(p,attempt)
 if travel[p]~=attempt or p.Parent~=Players then return end
 attempt.tries+=1
 if attempt.tries>3 then
  travel[p]=nil;local resumed=unlock(p)
  if attempt.kind=='gather' and parties[p] then
   local party=parties[p];store.remove(party.id,p.UserId,party.token);store.releaseMembership(p.UserId,party.id,party.token);parties[p]=nil;advertise(party.id)
  end
  if attempt.kind=='return' then
   leaving[p]=nil
   if resumed and admitted[p] and battleRun then local m=admitted[p];store.offer(p.UserId,battleRun,m.heroId,m.ticket,true) end
  end
  if attempt.kind=='defense' then
   local notice=RS.Remotes:FindFirstChild('LobbyFacilityState')
   if notice then notice:FireClient(p,{error=resumed and 'DefenseTravelFailed' or 'DefenseResumeFailed'}) end
  end
  publish(p,'TravelFailed');return
 end
 local options=Instance.new('TeleportOptions')
 if attempt.reservedId then options.ReservedServerId=attempt.reservedId elseif attempt.jobId then options.ServerInstanceId=attempt.jobId end
 attempt.callbackToken=guid()
 options:SetTeleportData(TravelAttempt.data(attempt.data,attempt.callbackToken))
 local ok=pcall(function() Teleport:TeleportAsync(attempt.placeId,{p},options) end)
 local generation=attempt.tries
 task.delay(ok and 20 or 2,function() if attempt.tries==generation and not attempt.retrying then retryTravel(p,attempt) end end)
end
local function send(p,attempt,prepared)
 if not prepared and not o.inventory.prepareTransfer(p) then return false,'Unavailable' end
 p:SetAttribute('TLTTravelLock',true);attempt.tries=0;travel[p]=attempt;publish(p)
 retryTravel(p,attempt);return true
end
function Service.travelToDefense(p)
 if role~='Lobby' or p:GetAttribute('K0SessionPhase')~='Lobby' then return 'WaitForLobby' end
 if Service.isBusy(p) then return 'Busy' end
 if parties[p] then return 'LeavePartyForDefense' end
 if studio then return 'DefenseStudioUnavailable' end
 if type(C.defensePlaceId)~='number' or C.defensePlaceId~=C.defensePlaceId or C.defensePlaceId<=0 or C.defensePlaceId%1~=0 then return 'DefenseNotConfigured' end
 busy[p]=true
 local notice=RS.Remotes:FindFirstChild('LobbyFacilityState')
 if notice then notice:FireClient(p,{status='DefenseSaving'}) end
 local ok,reason=send(p,{kind='defense',placeId=C.defensePlaceId,data={}})
 busy[p]=nil
 if not ok then return 'DefenseSaveFailed' end
 if notice and p.Parent==Players then notice:FireClient(p,{status='DefenseTravelling'}) end
end
function Service.isBusy(p) return travel[p]~=nil or busy[p]==true end
function Service.admitArrival(p)
 local max=role=='Battle' and C.battleCapacity or C.lobbyCapacity
 if not seats[p] then
  if seatCount>=max then return nil,'This server is full. Rejoin to find another lobby.' end
  seats[p]=true;seatCount+=1
 end
 local data=p:GetJoinData();local t=data.TeleportData
 if role=='Lobby' then
  if sourceValid(data)and type(t)=='table'and t.returning==true and t.replay==true then p:SetAttribute('TLTReplayRequested',true)end
  if sourceValid(data) and type(t)=='table' and type(t.partyId)=='string' and #t.partyId<=64 and type(t.token)=='string' and #t.token<=64 then arrivals[p]=t end
  -- A return hero is a selection hint only; the loaded account checks ownership.
  if sourceValid(data) and data.SourcePlaceId==C.battlePlaceId and type(t)=='table' and t.returning==true and type(t.heroId)=='string' and #t.heroId>0 and #t.heroId<=64 then
   return {lobbyHeroId=t.heroId}
  end
  return nil
 end
 if studio then return nil end
 if game.PrivateServerId=='' or game.PrivateServerOwnerId~=0 or not sourceValid(data) or type(t)~='table' or type(t.runId)~='string' or #t.runId>64 or type(t.ticket)~='string' or #t.ticket>64 then return nil,'Join an adventure from the Dawnspire lobby.' end
 local r,e=store.admit(t.runId,p.UserId,t.ticket,job)
 if not r or r.placeId~=game.PlaceId or count(r.members)>4 or not Difficulty.compatible(r.rulesVersion) or not Content.byId[r.missionId]or not Difficulty.modes[r.difficultyId]then return nil,'Your expedition could not be verified. Return to the lobby and rejoin.' end
 if battleRun and battleRun.id~=r.id then return nil,'This battle server belongs to another expedition.' end
 battleRun=r;battleStarted=battleStarted or os.clock();admitted[p]=r.members[tostring(p.UserId)]
 p:SetAttribute('TLTTravelLock',true)
 local ready,loadError=xpcall(function()o.previewWorld(r.missionId)end,debug.traceback)
 if not ready then
  warn(string.format('[Expedition] World load failed: mission=%s place=%s\n%s',r.missionId,tostring(game.PlaceId),tostring(loadError)))
  return nil,'The adventure could not load. Return to the lobby and rejoin.'
 end
 return {heroId=admitted[p].heroId}
end
local function startRunLocked(p,party,runId)
 if not studio and C.battlePlaceId<=0 then return nil,'Configuration' end
 local members={};local participants={};local chosen=selection(p)
 if party then
  local frozen,e=store.freeze(party.id,p.UserId,runId);if not frozen then store.launchStatus(party.id,runId,'forming');return nil,e end
  chosen={missionId=frozen.missionId,difficultyId=frozen.difficultyId}
  for uid,m in pairs(frozen.members) do
   local person=Players:GetPlayerByUserId(tonumber(uid));local known=person and parties[person];local current=person and member(person,m.token)
   local fence=store.membership(tonumber(uid))
   if not person or not known or known.id~=party.id or not current or current.heroId~=m.heroId or current.main~=m.main or current.level~=m.level or not fence or fence.id~=party.id or fence.token~=m.token or travel[person] then
    store.launchStatus(party.id,runId,'forming');return nil,'NotReady'
   end
   table.insert(participants,person);members[uid]={heroId=m.heroId,ticket=guid()}
  end
 else
  local m=member(p,'solo');if not m then return nil,'NotReady' end
  participants={p};members[tostring(p.UserId)]={heroId=m.heroId,ticket=guid()}
 end
 for _,person in ipairs(participants)do
  local h=o.inventory.expeditionHero(person);local allowed,why=Difficulty.allowed(h,chosen.missionId,chosen.difficultyId)
  if not allowed then if party then store.launchStatus(party.id,runId,'forming')end;return nil,why end
 end
 if studio then
  for _,person in ipairs(participants)do
   local why=o.inventory.beginExpedition(person,members[tostring(person.UserId)].heroId,chosen.missionId,chosen.difficultyId,runId)
   if why then if party then store.launchStatus(party.id,runId,'forming')end;return nil,why end
  end
  if party then store.launchStatus(party.id,runId,'forming') end
  o.previewWorld(chosen.missionId)
  for _,person in ipairs(participants) do o.heroSession.enterAdventure(person,members[tostring(person.UserId)].heroId) end
  return true
 end
 local r,e,prepared=Departure.prepare(store,o.inventory,participants,members,{id=runId,ticket=guid(),reservedId=Http:GenerateGUID(false),members=members,placeId=C.battlePlaceId,missionId=chosen.missionId,difficultyId=chosen.difficultyId,rulesVersion=Difficulty.version},unlock)
 if not r then if party then store.launchStatus(party.id,runId,'forming')end;return nil,e end
 for _,person in ipairs(prepared)do person:SetAttribute('TLTTravelLock',true)end
 if party then store.launchStatus(party.id,runId,'launched');advertise(party.id) end
 -- Each server-created ticket belongs to one user. Separate TeleportData is
 -- required, while the same ReservedServerId gathers all users into one battle.
 for _,person in ipairs(prepared) do local m=members[tostring(person.UserId)]
  send(person,{kind='battle',reservedId=r.reservedId,placeId=r.placeId,data={runId=r.id,ticket=m.ticket}},true)
 end
 return true
end
local function startRun(p,party)
 -- Lock every local participant before the first MemoryStore/DataStore yield.
 -- A hero/ready change cannot race an already frozen departure roster.
 local locked={};local candidates={p}
 if party then
  candidates={}
  for person,mine in pairs(parties) do if mine.id==party.id and person.Parent==Players then table.insert(candidates,person) end end
 end
 for _,person in ipairs(candidates) do if person~=p and (busy[person] or travel[person]) then return nil,'Busy' end end
 for _,person in ipairs(candidates) do locked[person]={previous=busy[person]};busy[person]=true end
 local runId=guid();local ok,result,reason=pcall(startRunLocked,p,party,runId)
 for person,lock in pairs(locked) do busy[person]=lock.previous end
 if not ok then
  local moving=false;for person in pairs(locked) do if travel[person] then moving=true else unlock(person) end end
  if party then store.launchStatus(party.id,runId,moving and 'launched' or 'forming') end
  return nil,'NetworkUnavailable'
 end
 return result,reason
end
function Service.solo(p)
 if role~='Lobby' or parties[p] then return 'AlreadyParty' end
 if Service.isBusy(p) then return 'Busy' end
 busy[p]=true;local _,e=startRun(p);busy[p]=nil;publish(p,e);return e
end
function Service.returnLobby(p)
 if studio then p:SetAttribute('TLTTravelLock',false);return false end
 if role~='Battle' or not admitted[p] or not battleRun then return true,'Busy' end
 if travel[p] then return true,'Busy' end
 local m=admitted[p]
 local replay=o.inventory.expedition(p,m.heroId)
 if not o.inventory.prepareTransfer(p) then return true,'Unavailable' end
 local saved=store.finish(p.UserId,battleRun.id,m.ticket)
 if not saved then unlock(p);return true,'NetworkUnavailable' end
 leaving[p]=true
 local ok,e=send(p,{kind='return',placeId=C.lobbyPlaceId,data={returning=true,heroId=m.heroId,replay=replay and replay.completed==true or false}},true)
 return true,e
end
function Service.beforeHeroAction(p,action)
 if travel[p] or busy[p] then return true,'Busy' end
 if action=='ReturnLobby' then selections[p]=nil;if role=='Battle' then return Service.returnLobby(p) end end
 if role=='Battle' and action~='GetState' then return true,'WaitForLobby' end
 -- The lobby Continue action follows saved progress, independent of the
 -- mission picker cache. Explicit Solo in the expedition panel keeps its choice.
 if action=='StartTutorial' then selections[p]=nil;return true,Service.solo(p) end
 if parties[p] and action=='StartTraining' then return true,'PartyChanged' end
 return false
end
local function handle(p,c,...)
 if select('#',...)~=0 or type(c)~='table' or type(c.action)~='string' or #c.action>16 then return end
 for k,v in pairs(c) do if k~='action' and k~='id' and k~='target' and k~='ready' and k~='missionId' and k~='difficultyId' and k~='requestId' then return end;if type(v)~='string' and type(v)~='number' and type(v)~='boolean' then return end end
 if c.id~=nil and (type(c.id)~='string' or #c.id>64 or not c.id:match('^[%w_-]+$')) then return end
 if c.ready~=nil and type(c.ready)~='boolean' then return end
 if c.requestId~=nil and(type(c.requestId)~='string'or #c.requestId>64 or not c.requestId:match('^[%w_-]+$'))then return end
 if os.clock()-(last[p] or -math.huge)<.35 then
  remote:FireClient(p,{ackOnly=true,requestId=c.requestId,error='Busy',retryAfter=.4});return
 end;last[p]=os.clock()
 if c.action=='GetState' then publish(p,nil,nil,c.requestId);return end
 if c.action=='Solo' then local why=Service.solo(p);publish(p,why,nil,c.requestId);return end
 if Service.isBusy(p) then publish(p,'Busy',nil,c.requestId);return end
 if role~='Lobby' or p:GetAttribute('K0SessionPhase')~='Lobby' then publish(p,'ShopLobbyOnly',nil,c.requestId);return end
 local previousParty=parties[p]and parties[p].id
 busy[p]=true
 local success,e=pcall(function()
  local mine=parties[p]
  if c.action=='Configure'then
   if not Content.byId[c.missionId]or not Difficulty.modes[c.difficultyId]then return 'InvalidMission'end
   if mine then
    local _,why=store.configure(mine.id,p.UserId,c.missionId,c.difficultyId);if why then return why end
   else selections[p]={missionId=c.missionId,difficultyId=c.difficultyId}end
  elseif c.action=='Create' or c.action=='Join' then
   if mine then return 'AlreadyParty' end
   local id=c.action=='Create' and guid() or c.id
   if not id then return 'InvalidRequest' end
   local token=guid();local m=member(p,token);if not m then return 'NotReady' end
   local fence,why=store.claimMembership(p.UserId,id,token);if not fence then store.releaseMembership(p.UserId,id,token);return why end
   local party
   if c.action=='Create' then party,why=store.create(id,m,c.target,job,C.lobbyPlaceId)
    if party then local chosen=selection(p);party,why=store.configure(id,p.UserId,chosen.missionId,chosen.difficultyId)end
   else
    party,why=store.readParty(id)
    if party and party.jobId~=job then m.arrived=false end
    if party then party,why=store.join(id,m) end
   end
   if not party then store.remove(id,p.UserId,token);store.releaseMembership(p.UserId,id,token);return why or 'PartyFull' end
   parties[p]={id=id,token=token};advertise(id)
   if party.jobId~=job then
    if studio then store.remove(id,p.UserId,token);store.releaseMembership(p.UserId,id,token);parties[p]=nil;return 'Configuration' end
    local ok,reason=send(p,{kind='gather',placeId=C.lobbyPlaceId,jobId=party.jobId,data={partyId=id,token=token}})
    if not ok then store.remove(id,p.UserId,token);store.releaseMembership(p.UserId,id,token);parties[p]=nil;advertise(id);return reason end
   end
  elseif c.action=='Leave' then
   if not mine then return 'PartyRequired' end
   local removed,why=store.remove(mine.id,p.UserId,mine.token)
   if not removed then return why end
   store.releaseMembership(p.UserId,mine.id,mine.token);parties[p]=nil;advertise(mine.id)
  elseif c.action=='Ready' then
   if not mine then return 'PartyRequired' end
   local m=member(p,mine.token);if not m then return 'NotReady' end
   local value,why=store.touch(mine.id,m,c.ready==true);if not value then return why end
   advertise(mine.id)
  elseif c.action=='Launch' then
   if not mine then return 'PartyRequired' end
   local _,why=startRun(p,mine);return why
  elseif c.action=='Rejoin' then
   if studio then return 'Configuration' end
   local r,why=offer(p);if not r then return why or 'RejoinExpired' end
   local run=store.readRun(r.runId);if not run or not run.members[tostring(p.UserId)] then return 'RejoinExpired' end
   local ok,reason=send(p,{kind='battle',placeId=run.placeId,reservedId=run.reservedId,data={runId=run.id,ticket=r.ticket}});if not ok then return reason end
  else return 'InvalidRequest' end
 end)
 busy[p]=nil
 local errorCode=not success and 'NetworkUnavailable'or e
 publish(p,errorCode,nil,c.requestId)
 local partyId=parties[p]and parties[p].id or previousParty
 if partyId then for person,mine in pairs(parties)do
  if person~=p and mine.id==partyId and not travel[person]then publish(person)end
 end end
end
function Service.start(options)
 o=options;role=options.role;job=game.JobId~='' and game.JobId or guid()
 local map
 if studio then
  local values={};map={GetAsync=function(_,key) return values[key] end,UpdateAsync=function(_,key,fn) local v=fn(values[key]);if v then values[key]=v end;return v end}
  local rows={};index={SetAsync=function(_,id,v) rows[id]=v end,RemoveAsync=function(_,id) rows[id]=nil end,GetRangeAsync=function() local a={};for id,v in pairs(rows) do table.insert(a,{key=id,value=v}) end;return a end}
 else
  local memory=game:GetService('MemoryStoreService');map=memory:GetHashMap('TLT_Expedition_v1');index=memory:GetSortedMap('TLT_Parties_v1')
 end
 store=Store.new(map,os.time,C)
 remote=Instance.new('RemoteEvent');remote.Name='ExpeditionState';remote.Parent=RS.Remotes
 local request=Instance.new('RemoteEvent');request.Name='ExpeditionRequest';request.Parent=RS.Remotes;request.OnServerEvent:Connect(handle)
 workspace:SetAttribute('TLTServerRole',role)
 Teleport.TeleportInitFailed:Connect(function(p,_,_,place,options)
  local a=travel[p]
  local ok,data=pcall(function() return options:GetTeleportData() end)
  if ok and TravelAttempt.matches(a,place,data) then
   local token=a.callbackToken;a.retrying=true
   task.delay(2,function()
    if travel[p]~=a or a.callbackToken~=token then return end
    a.retrying=nil;retryTravel(p,a)
   end)
  end
 end)
 Players.PlayerRemoving:Connect(function(p)
  if seats[p] then seats[p]=nil;seatCount-=1 end
  if admitted[p] and battleRun and not leaving[p] then local m=admitted[p];store.offer(p.UserId,battleRun,m.heroId,m.ticket,false) end
  local mine=parties[p]
  if mine and not travel[p] then store.remove(mine.id,p.UserId,mine.token);store.releaseMembership(p.UserId,mine.id,mine.token);advertise(mine.id) end
  parties[p]=nil;travel[p]=nil;arrivals[p]=nil;admitted[p]=nil;last[p]=nil;busy[p]=nil;leaving[p]=nil;selections[p]=nil
 end)
 task.spawn(function()
  local ticks=0
  while true do task.wait(2);ticks+=1
   if role=='Battle' and battleRun and ticks%10==0 then
    local r=store.renewRun(battleRun.id,job);runHealthy=r~=nil
    if r then battleRun=r end
   end
   for _,p in ipairs(Players:GetPlayers()) do
    if admitted[p] and not travel[p] then
     if p:GetAttribute('K0SessionPhase')=='Lobby' and o.inventory.ready(p) then
      local m=admitted[p]
      local verified=Difficulty.verifyRun(o.inventory.expeditionHero(p),battleRun)
      if not verified and runHealthy and store.departure(p.UserId,battleRun.id,m.ticket)then
       -- Only a server-staged departure may replace the old checkpoint. A rejoin
       -- can verify an existing run but cannot restart a superseded journal.
       local why=o.inventory.beginExpedition(p,m.heroId,battleRun.missionId,battleRun.difficultyId,battleRun.id,battleRun.rulesVersion)
       verified=not why and Difficulty.verifyRun(o.inventory.expeditionHero(p),battleRun)
      end
      if verified and runHealthy then
       -- Keep the pending capability on unknown MemoryStore results; rejoin()
       -- resolves it against the account's durable active run after reconnect.
       if store.offer(p.UserId,battleRun,m.heroId,m.ticket,true)then o.heroSession.enterAdventure(p,m.heroId)end
      elseif not verified and runHealthy and o.inventory.ready(p)then
       p:Kick('Your expedition could not be verified. Rejoin from the Dawnspire lobby.')
      end
     end
     local arrived=count(admitted);local complete=arrived>=count(battleRun.members) or os.clock()-battleStarted>=30
     p:SetAttribute('TLTTravelLock',not runHealthy or not complete or p:GetAttribute('K0SessionPhase')~='Tutorial')
     if ticks%10==0 and runHealthy then local m=admitted[p];store.offer(p.UserId,battleRun,m.heroId,m.ticket,false) end
    elseif arrivals[p] and o.inventory.ready(p) and p:GetAttribute('K0SessionPhase')=='Lobby' then
     local a=arrivals[p];local party=store.readParty(a.partyId);local m=party and party.members[tostring(p.UserId)]
     if m then o.heroSession.selectForArrival(p,m.heroId) end
     local current=m and member(p,a.token);local fence=store.membership(p.UserId)
     if current and fence and fence.id==a.partyId and fence.token==a.token and store.arrive(a.partyId,p.UserId,a.token,job,current) then parties[p]={id=a.partyId,token=a.token};advertise(a.partyId)
     else publish(p,'PartyChanged') end
     arrivals[p]=nil
    end
    if ticks%5==0 and parties[p] and not travel[p] and not busy[p] then
     local mine=parties[p];local m=member(p,mine.token)
     if m then
      store.claimMembership(p.UserId,mine.id,mine.token)
      local party=store.touch(mine.id,m);if not party then store.releaseMembership(p.UserId,mine.id,mine.token);parties[p]=nil else advertise(mine.id) end
     end
    end
    if ticks%5==0 then publish(p) end
   end
  end
 end)
end
return Service
