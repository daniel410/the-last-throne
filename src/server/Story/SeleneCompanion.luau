-- Per-owner supporter. Journal unlock/preference is durable; actors and support are session-only.
local Players=game:GetService('Players')
local Follow=require(script.Parent.SeleneFollow)
local Progress=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
local Budget=require(game:GetService('ReplicatedStorage').Shared.SeleneSupport)
local Visual=require(script.Parent.Parent.World.SeleneVisual)
local Actors=require(script.Parent.Parent.World.NPCActors)
local RS=game:GetService('ReplicatedStorage')
local Info=require(RS.Shared.SupporterInfo)
local Text=Info.text
local M={}
function M.create(o)
 local api={};local followers={};local cooldowns={};local status={};local lastSelect={}
 local reasonKeys,noticeState,noticeTimes={},{},{}
 local activatingOwner
 local remote=RS.Remotes:FindFirstChild('NPCDialogue') or Instance.new('RemoteEvent');remote.Name='NPCDialogue';remote.Parent=RS.Remotes
 local camp,npc,refuge,forge
 local lateCamps=o.world.lateCompanionCamps or {}
 local boundCamps=setmetatable({},{__mode='k'})
 local function prompt(model,name,action,offset,follow)
  local old=model.PrimaryPart:FindFirstChild(name);if old then old:Destroy() end
  local anchor=Instance.new('Attachment');anchor.Name=name;anchor.Position=Vector3.new(offset,0,0);anchor.Parent=model.PrimaryPart
  local p=Instance.new('ProximityPrompt');p.Name=name;p.Style=Enum.ProximityPromptStyle.Custom;p.ObjectText='Selene · Priestess';p.ActionText=action;p.HoldDuration=.4;p.MaxActivationDistance=12;p.RequiresLineOfSight=false;p.KeyboardKeyCode=Enum.KeyCode.F;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.Parent=anchor
  p.Triggered:Connect(function(player) api.select(player,follow) end)
 end
 local function selectionPrompts(model)
  model:SetAttribute('SeleneCampPosition',model==npc and camp or model.PrimaryPart.Position)
  prompt(model,'Invite','Invite Selene',-3,true);prompt(model,'Rest','Ask Selene to rest',3,false)
  local old=model.PrimaryPart:FindFirstChild('SupporterDetails');if old then old:Destroy()end
  local anchor=Instance.new('Attachment');anchor.Name='SupporterDetails';anchor.Position=Vector3.new(0,4,0);anchor.Parent=model.PrimaryPart
  local p=Instance.new('ProximityPrompt');p.Name='SupporterDetails';p.Style=Enum.ProximityPromptStyle.Custom;p.ObjectText='Selene · Priestess';p.ActionText=Text.view
  p.KeyboardKeyCode=Enum.KeyCode.G;p.GamepadKeyCode=Enum.KeyCode.ButtonR3;p.MaxActivationDistance=12;p.RequiresLineOfSight=false;p.Parent=anchor
  p.Triggered:Connect(function(player)api.inspect(player,model)end)

 end
 function api.refreshWorld()
  if not npc and o.world.seleneCamp then
   camp=o.world.seleneCamp
   npc=Actors.acquire(o.world.folder,'Selene',camp,{role='camp',priority=20})
  end
  refuge=o.world.refugeCompanionCamp;forge=o.world.emberCompanionCamp
  lateCamps=o.world.lateCompanionCamps or {}
  local models={};if npc then table.insert(models,npc)end
  if refuge then table.insert(models,refuge)end;if forge then table.insert(models,forge)end
  for _,entry in ipairs(lateCamps)do table.insert(models,entry.model)end
  for _,model in ipairs(models)do if not boundCamps[model]then selectionPrompts(model);boundCamps[model]=true end end
 end
 api.refreshWorld()
 local function nearLateCamp(root,s)
  for _,entry in ipairs(lateCamps)do if s and s.main>=entry.requiresMain and (root.Position-entry.model.PrimaryPart.Position).Magnitude<=16 then return true end end
  return false
 end
 local function remove(player)
  local f=followers[player];if f then f.model:Destroy();followers[player]=nil end
 end
 function api.remove(player) if activatingOwner==player then activatingOwner=nil end;remove(player);cooldowns[player]=nil;status[player]=nil;lastSelect[player]=nil;reasonKeys[player]=nil;noticeState[player]=nil;noticeTimes[player]=nil end
 function api.details(player)
  local h=o.active(player);local s=h and o.state(player,h.heroId)
  local pass=o.passState and h and o.passState(player,h.heroId) or nil
  local data=Info.project(s,status[player],s and reasonKeys[player] or 'Unknown',false,pass)
  return data
 end
 function api.inspect(player,model)
  local h=o.active(player);local ctx,root=o.context(player)
  if not h or h.training or not ctx or ctx.heroId~=h.heroId or not root or not model or not model:IsDescendantOf(o.world.folder) or not model.PrimaryPart or (root.Position-model.PrimaryPart.Position).Magnitude>14 then return false end
  local now=o.clock and o.clock() or os.clock()
  if now-(lastSelect[player] or -math.huge)<.4 then return false end;lastSelect[player]=now
  remote:FireClient(player,{supporter=api.details(player)});return true
 end
 function api.atCamp(player,heroId)
  local hero=o.active(player);local ctx,root=o.context(player)
  if not hero or hero.training or not ctx or ctx.heroId~=heroId or not root then return false end
  local s=o.state(player,heroId)
  return (camp and (root.Position-camp).Magnitude<=16) or refuge and s and s.main>=8 and (root.Position-refuge.PrimaryPart.Position).Magnitude<=16 or nearLateCamp(root,s) or forge and s and s.main>=15 and (root.Position-forge.PrimaryPart.Position).Magnitude<=16 or false
 end
 function api.select(player,following)
  local hero=o.active(player);local ctx,root=o.context(player)
  if type(following)~='boolean' or not hero or hero.training or not ctx or ctx.heroId~=hero.heroId or not root then return false end
  local s=o.state(player,ctx.heroId)
  local atCamp=(camp and (root.Position-camp).Magnitude<=16) or refuge and s and s.main>=8 and (root.Position-refuge.PrimaryPart.Position).Magnitude<=16 or nearLateCamp(root,s) or forge and s and s.main>=15 and (root.Position-forge.PrimaryPart.Position).Magnitude<=16
  if not atCamp then return false end
  if not Progress.seleneUnlocked(s) then o.publish(player,'Help the convoy reach camp, then finish the rescue report with Selene.');return false end
  local time=o.clock and o.clock() or os.clock()
  if time-(lastSelect[player] or -math.huge)<.4 then return false end
  lastSelect[player]=time
  if following then
   if not o.activate or not o.passState then o.publish(player,Text.SupportPassRequired);return false end
   local pass=o.passState(player,ctx.heroId)
   if not pass or not pass.active then
    for owner in pairs(followers)do if owner~=player then o.publish(player,Text.PartyFull);return false end end
   end
   if activatingOwner and activatingOwner~=player then o.publish(player,Text.PartyFull);return false end
   activatingOwner=player
   local ok,reason=pcall(o.activate,player,ctx.heroId)
   if not ok then activatingOwner=nil;o.publish(player,Text.Unavailable);return false end
   if reason then
    if reason~='SaveUnknown' and reason~='AccountBusy' then activatingOwner=nil end
    o.publish(player,Text[reason] or Text.Unavailable);return false
   end
  end
  o.select(player,ctx.heroId,following);return true
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
    local pass=o.passState and o.passState(player,hero.heroId)
    if s and Progress.seleneUnlocked(s) and s.seleneFollowing and pass and pass.active then table.insert(chosen,player) end
   end
  end
  table.sort(chosen,function(a,b) return a.UserId<b.UserId end)
  local allowed={};for i=1,math.min(#chosen,Budget.runtimeCap,Budget.limit(#population)) do allowed[chosen[i]]=true end
  for player in pairs(followers) do if not allowed[player] then remove(player) end end
  for _,player in ipairs(population) do
   local hero=o.active(player);local ctx,root=o.context(player);local s=o.state(player,hero.heroId)
   status[player]=not Progress.seleneUnlocked(s) and 'Meet Selene after the convoy rescue.' or not s.seleneFollowing and 'Available · Invite Selene at a safe companion camp.' or not allowed[player] and 'Resting · Party companion slots are full.' or 'Following · Healing, protection and cleansing support.'
   reasonKeys[player]=not Progress.seleneUnlocked(s) and 'Locked' or not s.seleneFollowing and 'Available' or not allowed[player] and 'PartyFull' or 'Following'
   local pass=o.passState and o.passState(player,hero.heroId)
   if Progress.seleneUnlocked(s) and (not pass or not pass.active) then reasonKeys[player]=not pass and 'SupportChecking' or pass.credits>0 and 'SupportReady' or 'SupportPassRequired';status[player]=Text[reasonKeys[player]] end
   if not allowed[player] or not ctx or ctx.heroId~=hero.heroId or not root then
    if allowed[player] then
     reasonKeys[player]=o.phase and o.phase(player)=='Lobby' and 'AtLobby' or 'Respawning';status[player]=Text[reasonKeys[player]]
    end
    remove(player)
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
     status[player]='Waiting · Return to Selene or rejoin at your checkpoint.';reasonKeys[player]='Distance'
    else
     if danger then status[player]='Keeping back · Move away from nearby enemies.';reasonKeys[player]='Threat'
     elseif distance>Budget.range then status[player]=string.format(Text.Range,Budget.range);reasonKeys[player]='Range' end
     cooldowns[player]=cooldowns[player] or {}
     local ready=cooldowns[player][ctx.heroId] or 0
     if distance<=Budget.range and not danger then
      local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={f.model,player.Character,o.enemies}
      if not workspace:Raycast(position+Vector3.new(0,3,0),root.Position-(position+Vector3.new(0,3,0)),params) then
       local nearEnemy=false
       for _,enemy in ipairs(o.enemies:GetChildren()) do local r=enemy:FindFirstChild('HumanoidRootPart');local h=enemy:FindFirstChildOfClass('Humanoid');if r and h and h.Health>0 and (r.Position-root.Position).Magnitude<24 then nearEnemy=true;break end end
       local humanoid=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
       f.missingHealth=humanoid and math.max(0,humanoid.MaxHealth-humanoid.Health) or 0
       local action=os.clock()>=ready and o.combat.applySeleneSupport and o.combat.applySeleneSupport(player,ctx.heroId,nearEnemy)
       if action then
        cooldowns[player][ctx.heroId]=os.clock()+Budget.cooldown
        f.model:SetAttribute('LastSupport',action)
        f.model:SetAttribute('SupportTargetUserId',player.UserId)
        local humanoid=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
        f.model:SetAttribute('SupportAmount',action=='Heal' and humanoid and math.min(math.max(1,math.floor(humanoid.MaxHealth*Budget.healFraction)),f.missingHealth or 0) or 0)
        f.model:SetAttribute('SupportAt',workspace:GetServerTimeNow())
       end
      else
       reasonKeys[player]='Blocked';status[player]=Text.Blocked
      end
     end
    end
   end
   local key=reasonKeys[player];local previous=noticeState[player];noticeState[player]=key
   local message=Info.transition(previous,key)
   if previous and previous~=key and (key=='SupportReady' or key=='SupportPassRequired') then message=Text.SupportEnded end
   local now=o.clock and o.clock() or os.clock()
   if message and o.notice and (key=='Available' or now-(noticeTimes[player] or -math.huge)>=4) then
    noticeTimes[player]=now;o.notice(player,message)
   end
  end
  if activatingOwner then
   local h=o.active(activatingOwner);local pass=h and o.passState and o.passState(activatingOwner,h.heroId)
   if followers[activatingOwner] or not h or pass and not pass.active then activatingOwner=nil end
  end
 end
 return api
end
return M
