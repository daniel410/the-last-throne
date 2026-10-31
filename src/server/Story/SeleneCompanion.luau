-- Per-owner supporter. Journal unlock/preference is durable; actors and support are session-only.
local Players=game:GetService('Players')
local Pathfinding=game:GetService('PathfindingService')
local Progress=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
local Budget=require(game:GetService('ReplicatedStorage').Shared.SeleneSupport)
local Visual=require(script.Parent.Parent.World.SeleneVisual)
local M={}
function M.create(o)
 local api={};local followers={};local cooldowns={};local status={};local lastSelect={}
 local camp=o.world.seleneCamp or o.world.positions['DW-03']+Vector3.new(-45,0,45)
 -- The story actor at the report marker uses the same TD model. This one owns selection.
 local npc=Visual.create(o.world.folder,camp,'SeleneCamp')
 local function prompt(name,action,offset,follow)
  local anchor=Instance.new('Attachment');anchor.Name=name;anchor.Position=Vector3.new(offset,0,0);anchor.Parent=npc.PrimaryPart
  local p=Instance.new('ProximityPrompt');p.Name=name;p.Style=Enum.ProximityPromptStyle.Custom;p.ObjectText='Selene · Priest';p.ActionText=action;p.HoldDuration=.4;p.MaxActivationDistance=12;p.RequiresLineOfSight=false;p.KeyboardKeyCode=Enum.KeyCode.F;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.Parent=anchor
  p.Triggered:Connect(function(player) api.select(player,follow) end)
 end
 prompt('Invite','Invite Selene',-3,true);prompt('Rest','Ask Selene to rest',3,false)
 local function remove(player)
  local f=followers[player];if f then f.model:Destroy();followers[player]=nil end
 end
 function api.remove(player) remove(player);cooldowns[player]=nil;status[player]=nil;lastSelect[player]=nil end
 function api.select(player,following)
  local hero=o.active(player);local ctx,root=o.context(player)
  if type(following)~='boolean' or not hero or hero.training or not ctx or ctx.heroId~=hero.heroId or not root or (root.Position-camp).Magnitude>16 then return false end
  local s=o.state(player,ctx.heroId)
  if not Progress.seleneUnlocked(s) then o.publish(player,'Help the convoy reach camp, then finish the rescue report with Selene.');return false end
  local time=o.clock and o.clock() or os.clock()
  if time-(lastSelect[player] or -math.huge)<.4 then return false end
  lastSelect[player]=time;o.select(player,ctx.heroId,following);return true
 end
 function api.projection(player) return status[player] end
 function api.update(dt)
  dt=math.min(dt,.25)
  local population={};local chosen={}
  for _,player in ipairs(o.players and o.players() or Players:GetPlayers()) do
   local hero=o.active(player)
   if hero and not hero.training then
    table.insert(population,player)
    local s=o.state(player,hero.heroId)
    if s and Progress.seleneUnlocked(s) and s.seleneFollowing then table.insert(chosen,player) end
   end
  end
  table.sort(chosen,function(a,b) return a.UserId<b.UserId end)
  local allowed={};for i=1,math.min(#chosen,Budget.limit(#population)) do allowed[chosen[i]]=true end
  for player in pairs(followers) do if not allowed[player] then remove(player) end end
  for _,player in ipairs(population) do
   local hero=o.active(player);local ctx,root=o.context(player);local s=o.state(player,hero.heroId)
   status[player]=not Progress.seleneUnlocked(s) and 'Meet Selene after the convoy rescue.' or not s.seleneFollowing and 'Available · Invite Selene at the elder tree camp.' or not allowed[player] and 'Resting · Party companion slots are full.' or 'Following · Healing, protection and cleansing support.'
   if not allowed[player] or not ctx or ctx.heroId~=hero.heroId or not root then remove(player)
   else
    local f=followers[player]
    if f and (f.heroId~=ctx.heroId or f.character~=player.Character) then remove(player);f=nil end
    if not f then
     -- Spawn only at camp or on a new life/rejoin beside the owner's confirmed checkpoint.
     f={heroId=ctx.heroId,character=player.Character,model=Visual.create(o.world.folder,root.Position-root.CFrame.LookVector*10-Vector3.new(0,3,0),'Selene_'..player.UserId),nextPath=0};followers[player]=f
     f.model:SetAttribute('OwnerUserId',player.UserId)
    end
    local position=f.model.PrimaryPart.Position;local distance=(position-root.Position).Magnitude
    local target=root.Position-root.CFrame.LookVector*10-Vector3.new(0,3,0);local formationDistance=(target-position).Magnitude
    if distance>100 then
     status[player]='Waiting · Return to Selene or rejoin at your checkpoint.'
    else
     if os.clock()>=f.nextPath and not f.computing and formationDistance>4 then
      f.nextPath=os.clock()+Budget.pathRefresh;f.computing=true
      task.spawn(function()
       local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=6,AgentCanJump=false,WaypointSpacing=5})
       local ok=pcall(function() path:ComputeAsync(position,target) end)
       if followers[player]==f and ok and path.Status==Enum.PathStatus.Success then f.waypoints=path:GetWaypoints();f.index=2 end
       f.computing=false;path:Destroy()
      end)
     end
     local point=f.waypoints and f.waypoints[f.index or 2]
     if point and formationDistance>3 then
      local delta=point.Position-position
      if delta.Magnitude<2 then f.index=(f.index or 2)+1
      else
       local nextPos=position+delta.Unit*math.min(delta.Magnitude,dt*Budget.followSpeed)
       local facing=Vector3.new(delta.X,0,delta.Z)
       if facing.Magnitude>.01 then f.model:PivotTo(CFrame.lookAt(nextPos,nextPos+facing)) end
      end
     end
     local danger=false
     for _,enemy in ipairs(o.enemies:GetChildren()) do
      local h=enemy:FindFirstChildOfClass('Humanoid');local r=enemy:FindFirstChild('HumanoidRootPart')
      if h and h.Health>0 and r and (r.Position-position).Magnitude<12 then danger=true;break end
     end
     -- Stop while threatened; recalculate next tick rather than treating a blocked route as a teleport.
     if danger then f.waypoints=nil;status[player]='Keeping back · Move away from nearby enemies.' end
     cooldowns[player]=cooldowns[player] or {}
     local ready=cooldowns[player][ctx.heroId] or 0
     if distance<=Budget.range and not danger and os.clock()>=ready and o.combat.applySeleneSupport then
      local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={f.model,player.Character,o.enemies}
      if not workspace:Raycast(position+Vector3.new(0,3,0),root.Position-(position+Vector3.new(0,3,0)),params) then
       local nearEnemy=false
       for _,enemy in ipairs(o.enemies:GetChildren()) do local r=enemy:FindFirstChild('HumanoidRootPart');local h=enemy:FindFirstChildOfClass('Humanoid');if r and h and h.Health>0 and (r.Position-root.Position).Magnitude<24 then nearEnemy=true;break end end
       local action=o.combat.applySeleneSupport(player,ctx.heroId,nearEnemy)
       if action then cooldowns[player][ctx.heroId]=os.clock()+Budget.cooldown;f.model:SetAttribute('LastSupport',action);f.model:SetAttribute('SupportAt',workspace:GetServerTimeNow()) end
      end
     end
    end
   end
  end
 end
 return api
end
return M
