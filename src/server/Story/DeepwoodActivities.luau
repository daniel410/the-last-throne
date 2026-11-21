-- Server-owned activity attempts. Saved substeps remain in the personal journal.
local Players=game:GetService('Players')
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Progress=require(Shared.DeepwoodProgress)
local IncidentRoute=require(Shared.CampaignIncidentRoute)
local Bounds=require(Shared.CampaignBounds)
local Actors=require(script.Parent.Parent.World.DeepwoodActivityWorld)
local Engine={}
local escortSpeed=12
local escortRange=22
local cageRescues={['DW-04:spirit']=true,['DW-05:prisoners']=true,['DW-07:rescue_captives']=true}
function Engine.create(o)
 local attempts,dialogs={},{}
 local api={}
 local function current(player,c,g,position,radius)
  local hero=o.active(player);local ctx,root=o.context(player)
  if not hero or hero.training or not ctx or not root or (root.Position-position).Magnitude>(radius or 16) then return nil end
  local s=o.state(player,ctx.heroId)
  if not s or not Progress.available(s,c,g) then return nil end
  return ctx,s,root
 end
 local function remove(player)
  local a=attempts[player];if a and a.actor then a.actor:Destroy() end;attempts[player]=nil;dialogs[player]=nil
 end
 local function escort(player,c,g,ctx,s)
  local previous=attempts[player]
  if previous and not previous.failed and previous.c==c and previous.g==g and previous.heroId==ctx.heroId
   and previous.character==player.Character and previous.runId==s.expeditionRunId then return end
  if attempts[player] then remove(player) end
  local count=(s.activities or {})[c.id..':'..g.id] or 0
  local p=count>0 and g.activity.steps[count].position or g.position
  attempts[player]={heroId=ctx.heroId,character=player.Character,runId=s.expeditionRunId,c=c,g=g,actor=Actors.actor(o.world.folder,g.activity.actor,Vector3.new(table.unpack(p)),g.activity.spirit,{dynamic=true,role='escort',ownerUserId=player.UserId}),status='Follow the rescued resident.'}
  if count==0 and cageRescues[c.id..':'..g.id]then attempts[player].cageExit=Vector3.new(table.unpack(g.position))+Vector3.new(0,0,7)end
  if g.activity.actor=='Finn'then require(script.Parent.Parent.World.ScoutLantern).attach(attempts[player].actor)end
 end
 function api.projection(player,heroId)
  local result={};local a=attempts[player]
  if a and a.heroId==heroId then
   local actorRoot=a.actor.PrimaryPart
   result[a.c.id..':'..a.g.id]={actorRoot=actorRoot,actorPosition=actorRoot.Position,status=a.status}
  end
  local d=dialogs[player];local ctx,root=o.context(player)
  local confirmed=d and ctx and ctx.heroId==d.heroId and o.state(player,ctx.heroId)
  local expected=confirmed and Progress.nextStep(confirmed,d.c,d.g)
  if d and (not expected or expected.id~=d.step.id or not ctx or ctx.heroId~=d.heroId or not root or (root.Position-(d.position or Vector3.new(table.unpack(d.g.position)))).Magnitude>16) then dialogs[player]=nil;d=nil end
  return result,d and d.heroId==heroId and {chapter=d.c.id,goal=d.g.id,step=d.step.id,text=d.feedback or d.step.text,choices=require(game.ReplicatedStorage.Shared.CampaignCircuit).display(d.step)} or nil
 end
 function api.interact(player,node)
  local c,g=node.chapter,node.goal;local a=g.activity
  if not a or not a.steps then return false end
  if a.finish then return true end
  local ctx,s=current(player,c,g,node.part.Position)
  if not ctx then return true end
  local step=Progress.nextStep(s,c,g);if not step then return true end
  if a.mode=='escort' then escort(player,c,g,ctx,s);o.publish(player,nil,'Stay close to the rescued resident. They will stop if you fall behind or enemies approach.')
  elseif a.mode=='dialogue' then
   if step.choices then dialogs[player]={heroId=ctx.heroId,c=c,g=g,step=step};o.publish(player,step.text)
   else o.enqueue(player,ctx.heroId,c,g,nil,step.id) end
  else o.publish(player,a.clue or 'Explore the scene and follow the next clue, rather than the old marker.') end
  return true
 end
 function api.interactStep(player,cid,gid,sid,choice)
  local node=o.world.activityNodes[cid..':'..gid..':'..sid];if not node then return end
  local c,g=node.chapter,node.goal
  local control=choice and (o.world.activityChoices or {})[cid..':'..gid..':'..sid..':'..choice]
  local ctx,s=current(player,c,g,control and control.part.Position or node.part.Position)
  if not ctx then return end
  local step=Progress.nextStep(s,c,g)
  local a=g.activity
  if a.finish then
   if step~=a.finish or not step.prompt or sid~=step.id then return end
  elseif not step or a.mode~='investigate' and step.id~=sid then
   o.publish(player,a.clue or 'Follow the evidence in order.');return
  elseif a.mode=='escort' then return end
  if step.choices then
   if choice==nil then
    dialogs[player]={heroId=ctx.heroId,c=c,g=g,step=step,position=node.part.Position};o.publish(player,step.text);return
   end
   local valid=false;for _,v in ipairs(step.choices) do if v.id==choice then valid=true end end
   if not valid then return end
   if step.solution and choice~=step.solution then
    local dialog=dialogs[player]
    if dialog and dialog.step==step then dialog.feedback=step.failure end
    o.publish(player,step.failure);return
   end
  end
  dialogs[player]=nil;o.enqueue(player,ctx.heroId,c,g,choice,sid)
 end
 function api.answer(player,argument)
  local cid,gid,sid,choice=argument:match('^([%w%-]+):([%w_]+):([%w_]+):([%w_]+)$')
  local d=dialogs[player]
  if d and d.c.id==cid and d.g.id==gid and d.step.id==sid then api.interactStep(player,cid,gid,sid,choice) end
 end
 local function threatened(pos)
  for _,m in ipairs(o.enemies:GetChildren()) do
   local h=m:FindFirstChildOfClass('Humanoid');local r=m:FindFirstChild('HumanoidRootPart')
   if h and h.Health>0 and r and (r.Position-pos).Magnitude<14 then return true end
  end
  return false
 end
 local function advance(p,a,dt)
  local root,step=a.root,a.step
  if not root or not step or a.failed or p.Character~=a.character then return end
  local pos=a.actor.PrimaryPart.Position
  if a.waiting==step.id then a.status='Saving the escort checkpoint.';return end
  if (root.Position-pos).Magnitude>escortRange then a.status='The resident is waiting. Return to their side.';return end
  if a.threatened then a.status='Enemies are too close. Protect the resident.';return end
  a.status='Stay beside the resident and follow the safe route.'
  local target=Vector3.new(table.unpack(step.position))
  local following=false
  if a.g.expansion then
   if a.routeStep~=step.id then
    a.routeStep=step.id;a.routeIndex=2
    a.route=IncidentRoute.route({pos.X,pos.Y,pos.Z},step.position)
   end
   while a.routeIndex<#a.route and (Vector3.new(table.unpack(a.route[a.routeIndex]))-pos).Magnitude<1 do a.routeIndex+=1 end
   target=Vector3.new(table.unpack(a.route[a.routeIndex]));following=a.routeIndex<#a.route
  end
  -- Leave through the opened front door before joining the saved escort route.
  if a.cageExit then
   if (pos-a.cageExit).Magnitude<1 then a.cageExit=nil else target=a.cageExit;following=true end
  end
  local delta=target-pos
  local distance=delta.Magnitude
  if distance<=1 and not following then
   local ctx,currentJournal=current(p,a.c,a.g,pos,escortRange)
   if ctx and ctx.heroId==a.heroId and currentJournal.expeditionRunId==a.runId
    and Progress.nextStep(currentJournal,a.c,a.g)==step and not threatened(pos) then
    a.waiting=step.id;a.status='Saving the escort checkpoint.'
    o.enqueue(p,a.heroId,a.c,a.g,nil,step.id)
   end
  elseif distance>0 then
   local nextPos=pos+delta*(math.min(distance,dt*escortSpeed)/distance)
   if a.g.expansion then local floor=Bounds.surface(nextPos.X,nextPos.Z);if floor then nextPos=Vector3.new(nextPos.X,floor,nextPos.Z)end end
   local flat=Vector3.new(delta.X,0,delta.Z)
   a.actor:PivotTo(flat.Magnitude>.01 and CFrame.lookAt(nextPos,nextPos+flat) or CFrame.new(nextPos))
  end
 end
 function api.saveFailed(player,heroId,c,g,stepId,runId)
  local a=attempts[player]
  if a and a.heroId==heroId and a.c==c and a.g==g and a.waiting==stepId and a.runId==runId then
   a.failed=true;a.status='Escort checkpoint could not be saved. Return to the checkpoint to retry.'
  end
 end
 function api.stepMotion(dt)
  dt=math.clamp(dt,0,.25)
  for p,a in pairs(attempts) do advance(p,a,dt) end
 end
 function api.update(dt)
  for _,p in ipairs(o.players and o.players()or Players:GetPlayers()) do
   local hero=o.active(p);local ctx,root=o.context(p)
   if hero and not hero.training and ctx and root then
    local s=o.state(p,ctx.heroId)
    if s then
     local chapter=s.expeditionMission and Content.byId[s.expeditionMission]
     local chapters=chapter and {chapter} or Content.chapters
     for _,c in ipairs(chapters) do for _,g in ipairs(c.goals) do
     local a=g.activity;local step=Progress.nextStep(s,c,g)
     if a and step then
      if a.finish then
       if not step.prompt and o.world.activityNodes[c.id..':'..g.id..':'..step.id]
        and (root.Position-Vector3.new(table.unpack(step.position))).Magnitude<=10 then
        o.enqueue(p,ctx.heroId,c,g,nil,step.id)
       end
      elseif (a.mode=='trail' or a.mode=='travel') and (root.Position-Vector3.new(table.unpack(step.position))).Magnitude<=10 then o.enqueue(p,ctx.heroId,c,g,nil,step.id)
      elseif a.mode=='escort' and not attempts[p] then
       local count=(s.activities or {})[c.id..':'..g.id] or 0
       if count>0 and (root.Position-Vector3.new(table.unpack(a.steps[count].position))).Magnitude<=16 then escort(p,c,g,ctx,s) end
      end
     end
    end end end
   end
  end
  for p,a in pairs(attempts) do
   local hero=o.active(p)
   local ctx,root=o.context(p);local s=ctx and o.state(p,ctx.heroId)
   local step=s and Progress.nextStep(s,a.c,a.g)
   if not hero or hero.training or hero.heroId~=a.heroId or p.Character~=a.character then remove(p)
   elseif not ctx and a.waiting and not a.failed then
    a.root=nil
   elseif not ctx or ctx.heroId~=a.heroId or not step or not root or s.expeditionRunId~=a.runId then remove(p)
   else
    if a.waiting~=step.id then a.waiting=nil end
    a.root=root;a.step=step;a.threatened=threatened(a.actor.PrimaryPart.Position)
   end
  end
  if not o.frameDriven then api.stepMotion(dt) end
 end
 api.remove=remove
 -- Exposed for deterministic native fixtures; production calls update() with real players.
 function api.startEscort(player,c,g) local ctx,s=current(player,c,g,Vector3.new(table.unpack(g.position)));if ctx and not g.activity.finish then escort(player,c,g,ctx,s) end end
 return api
end
return Engine
