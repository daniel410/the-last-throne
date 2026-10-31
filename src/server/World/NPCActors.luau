-- Static dialogue, scenery and quest roles share one named actor per world.
local Identity=require(game.ReplicatedStorage.Shared.NPCIdentity)
local Visual=require(script.Parent.NPCVisual)
local Tags=game:GetService('CollectionService')
local A={}
function A.tag(model,role,owner)
 model:SetAttribute('NPCActorRole',role or 'static')
 if owner then model:SetAttribute('NPCPrivateOwnerUserId',owner) end
 Tags:AddTag(model,'TLTStoryNPC')
 return model
end
function A.acquire(world,name,position,options)
 options=options or {}
 local _,identity,named=Identity.resolve(name,options.spirit)
 local folder=world:FindFirstChild('NPCActors')
 if not folder then folder=Instance.new('Folder');folder.Name='NPCActors';folder.Parent=world end
 local model
 for _,candidate in ipairs(folder:GetChildren())do
  if candidate:GetAttribute('NPCActorIdentity')==identity and candidate.PrimaryPart
   and (named or (candidate.PrimaryPart.Position-position).Magnitude<24) then model=candidate;break end
 end
 local priority=options.priority or 10
 if not model then
  model=Visual.actor(folder,name,position,options.spirit);model:SetAttribute('NPCActorPriority',priority)
 elseif priority>(model:GetAttribute('NPCActorPriority') or 0) then
  model:PivotTo(CFrame.new(position));model:SetAttribute('NPCActorPriority',priority)
 end
 model:SetAttribute('NPCRole_'..(options.role or 'scene'),true)
 return A.tag(model,'static')
end
-- Reuse an authored Studio scene too; old action-title placeholders are not people.
function A.reconcile(world)
 if world:GetAttribute('NPCActorRegistryVersion')==1 then return end
 local Content=require(game.ReplicatedStorage.Shared.DeepwoodContent)
 local actions={}
 for _,c in ipairs(Content.chapters)do for _,g in ipairs(c.goals)do for _,s in ipairs(g.activity and g.activity.steps or {})do
  if s.kind=='actor' and not s.actor then actions[s.title]=true end
 end end end
 local old={}
 for _,m in ipairs(world:GetDescendants())do
  if m:IsA('Model') and m:GetAttribute('TLTNPC') and m:GetAttribute('NPCActorRole')~='companion'
   and not m:GetAttribute('NPCPrivateOwnerUserId') and not (m.Parent and m.Parent.Name=='NPCActors') then table.insert(old,m) end
 end
 for _,m in ipairs(old)do if m.Parent then
  local name=m:GetAttribute('NPCStoryAlias') or m.Name
  if name=='SeleneCamp' then name='Selene' end
  if not actions[name] and not m:GetAttribute('OwnerUserId') then
   local inActivity=m.Parent.Name=='AdventureActivities'
   local actor=A.acquire(world,name,m.PrimaryPart.Position,{role=inActivity and 'dialogue' or 'scene',priority=inActivity and 30 or 10})
   for _,child in ipairs(m.PrimaryPart:GetChildren())do
    if child:IsA('Attachment') or child:IsA('ProximityPrompt') then child.Parent=actor.PrimaryPart end
   end
  end
  m:Destroy()
 end end
 world:SetAttribute('NPCActorRegistryVersion',1)
end
return A
