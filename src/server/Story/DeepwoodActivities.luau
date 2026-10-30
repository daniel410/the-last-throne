-- Server-owned activity attempts. Saved substeps remain in the personal journal.
local Players=game:GetService('Players')
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local Progress=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
local Actors=require(script.Parent.Parent.World.DeepwoodActivityWorld)
local Engine={}
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
  if attempts[player] then remove(player) end
  local count=(s.activities or {})[c.id..':'..g.id] or 0
  local p=count>0 and g.activity.steps[count].position or g.position
  attempts[player]={heroId=ctx.heroId,c=c,g=g,actor=Actors.actor(o.world.folder,g.activity.actor,Vector3.new(table.unpack(p)),g.activity.spirit),status='Follow the rescued resident.'}
 end
 function api.projection(player,heroId)
  local result={};local a=attempts[player]
  if a and a.heroId==heroId then result[a.c.id..':'..a.g.id]={actorPosition=a.actor.PrimaryPart.Position,status=a.status} end
  local d=dialogs[player]
  return result,d and d.heroId==heroId and {chapter=d.c.id,goal=d.g.id,step=d.step.id,text=d.step.text,choices=d.step.choices} or nil
 end
 function api.interact(player,node)
  local c,g=node.chapter,node.goal;local a=g.activity
  if not a or not a.steps then return false end
  local ctx,s=current(player,c,g,node.part.Position)
  if not ctx then return true end
  local step=Progress.nextStep(s,c,g);if not step then return true end
  if a.mode=='escort' then escort(player,c,g,ctx,s);o.publish(player,'Stay close to the rescued resident. They will stop if you fall behind or enemies approach.')
  elseif a.mode=='dialogue' then
   if step.choices then dialogs[player]={heroId=ctx.heroId,c=c,g=g,step=step};o.publish(player,step.text)
   else o.enqueue(player,ctx.heroId,c,g,nil,step.id) end
  else o.publish(player,a.clue or 'Explore the scene and follow the next clue, rather than the old marker.') end
  return true
 end
 function api.interactStep(player,cid,gid,sid,choice)
  local node=o.world.activityNodes[cid..':'..gid..':'..sid];if not node then return end
  local c,g=node.chapter,node.goal
  local ctx,s=current(player,c,g,node.part.Position)
  if not ctx then return end
  local step=Progress.nextStep(s,c,g)
  if not step or step.id~=sid then o.publish(player,g.activity.clue or 'Follow the evidence in order.');return end
  if g.activity.mode=='escort' then return end
  if step.choices then
   local valid=false;for _,v in ipairs(step.choices) do if v.id==choice then valid=true end end
   if not valid then return end
  end
  dialogs[player]=nil;o.enqueue(player,ctx.heroId,c,g,choice,sid)
 end
 function api.answer(player,argument)
  local cid,gid,sid,choice=argument:match('^([%w%-]+):([%w_]+):([%w_]+):([%w_]+)$')
  local d=dialogs[player]
  if d and d.c.id==cid and d.g.id==gid and d.step.id==sid then api.interactStep(player,cid,gid,sid,choice) end
 end
 function api.update(dt)
  dt=math.min(dt,.25)
  for _,p in ipairs(Players:GetPlayers()) do
   local hero=o.active(p);local ctx,root=o.context(p)
   if hero and not hero.training and ctx and root then
    local s=o.state(p,ctx.heroId)
    if s then for _,c in ipairs(Content.chapters) do if not c.side then for _,g in ipairs(c.goals) do
     local a=g.activity;local step=Progress.nextStep(s,c,g)
     if a and step then
      if (a.mode=='trail' or a.mode=='travel') and (root.Position-Vector3.new(table.unpack(step.position))).Magnitude<=10 then o.enqueue(p,ctx.heroId,c,g,nil,step.id)
      elseif a.mode=='escort' and not attempts[p] then
       local count=(s.activities or {})[c.id..':'..g.id] or 0
       if count>0 and (root.Position-Vector3.new(table.unpack(a.steps[count].position))).Magnitude<=16 then escort(p,c,g,ctx,s) end
      end
     end
    end end end end
   end
  end
  for p,a in pairs(attempts) do
   local ctx,root=o.context(p);local s=ctx and o.state(p,ctx.heroId)
   local step=s and Progress.nextStep(s,a.c,a.g)
   if not ctx or ctx.heroId~=a.heroId or not step or not root then remove(p)
   else
    local pos=a.actor.PrimaryPart.Position;local near=(root.Position-pos).Magnitude<=22
    local threatened=false
    for _,m in ipairs(o.enemies:GetChildren()) do
     local h=m:FindFirstChildOfClass('Humanoid');local r=m:FindFirstChild('HumanoidRootPart')
     if h and h.Health>0 and r and (r.Position-pos).Magnitude<14 then threatened=true;break end
    end
    a.status=not near and 'The resident is waiting. Return to their side.' or threatened and 'Enemies are too close. Protect the resident.' or 'Stay beside the resident and follow the safe route.'
    if near and not threatened then
     if a.waiting~=step.id then
      a.waiting=nil
      local target=Vector3.new(table.unpack(step.position));local delta=target-pos
      if delta.Magnitude<=1 then a.waiting=step.id;o.enqueue(p,ctx.heroId,a.c,a.g,nil,step.id)
      else local nextPos=pos+delta.Unit*math.min(delta.Magnitude,dt*6);local flat=Vector3.new(delta.X,0,delta.Z);a.actor:PivotTo(flat.Magnitude>.01 and CFrame.lookAt(nextPos,nextPos+flat) or CFrame.new(nextPos)) end
     end
    end
   end
  end
 end
 api.remove=remove
 -- Exposed for deterministic native fixtures; production calls update() with real players.
 function api.startEscort(player,c,g) local ctx,s=current(player,c,g,Vector3.new(table.unpack(g.position)));if ctx then escort(player,c,g,ctx,s) end end
 return api
end
return Engine
