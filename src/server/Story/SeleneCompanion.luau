-- Per-owner supporter. Journal unlock/preference is durable; actors and support are session-only.
local Players=game:GetService('Players')
local Follow=require(script.Parent.SeleneFollow)
local Progress=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
local Budget=require(game:GetService('ReplicatedStorage').Shared.SeleneSupport)
local Visual=require(script.Parent.Parent.World.SeleneVisual)
local Actors=require(script.Parent.Parent.World.NPCActors)
local M={}
function M.create(o)
 local api={};local followers={};local cooldowns={};local status={};local lastSelect={}
 local camp=o.world.seleneCamp or o.world.positions['DW-03']+Vector3.new(-45,0,45)
 -- The rescue report and companion selection share the actual camp actor.
 local npc=Actors.acquire(o.world.folder,'Selene',camp,{role='camp',priority=20})
 npc:SetAttribute('SeleneCampPosition',camp)
 local function prompt(model,name,action,offset,follow)
  local old=model.PrimaryPart:FindFirstChild(name);if old then old:Destroy() end
  local anchor=Instance.new('Attachment');anchor.Name=name;anchor.Position=Vector3.new(offset,0,0);anchor.Parent=model.PrimaryPart
  local p=Instance.new('ProximityPrompt');p.Name=name;p.Style=Enum.ProximityPromptStyle.Custom;p.ObjectText='Selene · Priestess';p.ActionText=action;p.HoldDuration=.4;p.MaxActivationDistance=12;p.RequiresLineOfSight=false;p.KeyboardKeyCode=Enum.KeyCode.F;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.Parent=anchor
  p.Triggered:Connect(function(player) api.select(player,follow) end)
 end
 local function selectionPrompts(model)
  model:SetAttribute('SeleneCampPosition',camp)
  prompt(model,'Invite','Invite Selene',-3,true);prompt(model,'Rest','Ask Selene to rest',3,false)
 end
 selectionPrompts(npc)
 local refuge=o.world.refugeCompanionCamp
 if refuge then selectionPrompts(refuge);refuge:SetAttribute('SeleneCampPosition',refuge.PrimaryPart.Position) end
 local forge=o.world.emberCompanionCamp
 if forge then selectionPrompts(forge);forge:SetAttribute('SeleneCampPosition',forge.PrimaryPart.Position)end
 local function remove(player)
  local f=followers[player];if f then f.model:Destroy();followers[player]=nil end
 end
 function api.remove(player) remove(player);cooldowns[player]=nil;status[player]=nil;lastSelect[player]=nil end
 function api.select(player,following)
  local hero=o.active(player);local ctx,root=o.context(player)
  if type(following)~='boolean' or not hero or hero.training or not ctx or ctx.heroId~=hero.heroId or not root then return false end
  local s=o.state(player,ctx.heroId)
  local atCamp=(root.Position-camp).Magnitude<=16 or refuge and s and s.main>=8 and (root.Position-refuge.PrimaryPart.Position).Magnitude<=16 or forge and s and s.main>=15 and (root.Position-forge.PrimaryPart.Position).Magnitude<=16
  if not atCamp then return false end
  if not Progress.seleneUnlocked(s) then o.publish(player,'Help the convoy reach camp, then finish the rescue report with Selene.');return false end
  local time=o.clock and o.clock() or os.clock()
  if time-(lastSelect[player] or -math.huge)<.4 then return false end
  lastSelect[player]=time;o.select(player,ctx.heroId,following);return true
 end
 function api.stepMotion(dt)
  for _,f in pairs(followers) do
   if f.root and f.root.Parent and f.params and f.model.Parent then
    local casting=workspace:GetServerTimeNow()-(f.model:GetAttribute('SupportAt') or -math.huge)<.9
    Follow.step(f,f.root,dt,f.params,f.hold or casting)
   end
  end
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
  local allowed={};for i=1,math.min(#chosen,Budget.runtimeCap,Budget.limit(#population)) do allowed[chosen[i]]=true end
  for player in pairs(followers) do if not allowed[player] then remove(player) end end
  for _,player in ipairs(population) do
   local hero=o.active(player);local ctx,root=o.context(player);local s=o.state(player,hero.heroId)
   status[player]=not Progress.seleneUnlocked(s) and 'Meet Selene after the convoy rescue.' or not s.seleneFollowing and 'Available · Invite Selene at a safe companion camp.' or not allowed[player] and 'Resting · Party companion slots are full.' or 'Following · Healing, protection and cleansing support.'
   if not allowed[player] or not ctx or ctx.heroId~=hero.heroId or not root then remove(player)
   else
    local f=followers[player]
    if f and (f.heroId~=ctx.heroId or f.character~=player.Character) then remove(player);f=nil end
    if not f then
     -- Spawn only at camp or on a new life/rejoin beside the owner's confirmed checkpoint.
     f={heroId=ctx.heroId,character=player.Character,model=Visual.create(o.world.folder,root.Position-root.CFrame.LookVector*10-Vector3.new(0,3,0),'Selene_'..player.UserId),nextPath=0};followers[player]=f
     f.model:SetAttribute('OwnerUserId',player.UserId)
     local spawnGround=Follow.ground(f.model.PrimaryPart.Position,Follow.params(f.model,player.Character,o.enemies))
     if spawnGround then f.model:PivotTo(CFrame.new(spawnGround)*root.CFrame.Rotation) end
     f.model:SetAttribute('NPCActorIdentity','npc:selene')
     selectionPrompts(f.model)
     Actors.tag(f.model,'companion')
    end
    local position=f.model.PrimaryPart.Position;local distance=(position-root.Position).Magnitude
    local params=Follow.params(f.model,player.Character,o.enemies)
    local danger=false
    for _,enemy in ipairs(o.enemies:GetChildren()) do
     local h=enemy:FindFirstChildOfClass('Humanoid');local r=enemy:FindFirstChild('HumanoidRootPart')
     if h and h.Health>0 and r and (r.Position-position).Magnitude<12 then danger=true;break end
    end
    local casting=workspace:GetServerTimeNow()-(f.model:GetAttribute('SupportAt') or -math.huge)<.9
    f.root=root;f.params=params;f.hold=danger
    if not o.frameDriven then Follow.step(f,root,dt,params,danger or casting) end
    position=f.model.PrimaryPart.Position;distance=(position-root.Position).Magnitude
    if distance>100 then
     status[player]='Waiting · Return to Selene or rejoin at your checkpoint.'
    else
     if danger then status[player]='Keeping back · Move away from nearby enemies.' end
     cooldowns[player]=cooldowns[player] or {}
     local ready=cooldowns[player][ctx.heroId] or 0
     if distance<=Budget.range and not danger and os.clock()>=ready and o.combat.applySeleneSupport then
      local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={f.model,player.Character,o.enemies}
      if not workspace:Raycast(position+Vector3.new(0,3,0),root.Position-(position+Vector3.new(0,3,0)),params) then
       local nearEnemy=false
       for _,enemy in ipairs(o.enemies:GetChildren()) do local r=enemy:FindFirstChild('HumanoidRootPart');local h=enemy:FindFirstChildOfClass('Humanoid');if r and h and h.Health>0 and (r.Position-root.Position).Magnitude<24 then nearEnemy=true;break end end
       local humanoid=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
       f.missingHealth=humanoid and math.max(0,humanoid.MaxHealth-humanoid.Health) or 0
       local action=o.combat.applySeleneSupport(player,ctx.heroId,nearEnemy)
       if action then
        cooldowns[player][ctx.heroId]=os.clock()+Budget.cooldown
        f.model:SetAttribute('LastSupport',action)
        f.model:SetAttribute('SupportTargetUserId',player.UserId)
        local humanoid=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
        f.model:SetAttribute('SupportAmount',action=='Heal' and humanoid and math.min(math.max(1,math.floor(humanoid.MaxHealth*Budget.healFraction)),f.missingHealth or 0) or 0)
        f.model:SetAttribute('SupportAt',workspace:GetServerTimeNow())
       end
      end
     end
    end
   end
  end
 end
 return api
end
return M
