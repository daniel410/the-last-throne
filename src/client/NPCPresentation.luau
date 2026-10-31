-- Server actors remain authoritative interaction/movement anchors. Each viewer
-- sees one representation of a person, even when party journals differ.
local Tags=game:GetService('CollectionService')
local Run=game:GetService('RunService')
local MapState=require(script.Parent.DeepwoodMapState)
local View={}
function View.create(player,world,readState)
 readState=readState or function()return MapState.current end
 local records={};local api={}
 local function restore(record)
  for object,value in pairs(record)do if object.Parent then
   if object:IsA('BasePart') then object.LocalTransparencyModifier=value else object.Enabled=value end
  end end
 end
 function api.update()
  local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
  local state=readState();local journal=state and state.journal
  local candidates,chosen,present={},{},{}
  for _,model in ipairs(Tags:GetTagged('TLTStoryNPC'))do
   if model:IsA('Model') and model:IsDescendantOf(world) and model:GetAttribute('NPCActorIdentity') then
    present[model]=true
    local identity=model:GetAttribute('NPCActorIdentity')
    local owner=model:GetAttribute('NPCPrivateOwnerUserId')
    local actorRoot=model.PrimaryPart
    if actorRoot and (not owner or owner==player.UserId) then
     local distance=root and (actorRoot.Position-root.Position).Magnitude or math.huge
     local role=model:GetAttribute('NPCActorRole');local priority=0
     if role=='escort' then priority=4
     elseif role=='companion' and distance<=120 then priority=model:GetAttribute('OwnerUserId')==player.UserId and 4 or 3 end
     if identity=='npc:selene' and model:GetAttribute('NPCRole_camp') and distance<80
      and journal and journal.main>=2 and not journal.flags['DW-03:report'] then priority=6 end
     candidates[model]={identity=identity,priority=priority,distance=distance}
     local old=chosen[identity]
     if not old or priority>candidates[old].priority or priority==candidates[old].priority
      and (distance<candidates[old].distance or distance==candidates[old].distance and model:GetFullName()<old:GetFullName()) then chosen[identity]=model end
    end
   end
  end
  for model,record in pairs(records)do if not present[model] then restore(record);records[model]=nil end end
  for model in pairs(present)do
   local data=candidates[model]
   local shown=data and chosen[data.identity]==model
   -- Personal escorts must not leak into another player's story, including loading.
   local private=model:GetAttribute('NPCPrivateOwnerUserId')
   if private and private~=player.UserId then shown=false end
   local record=records[model];if not record then record={};records[model]=record end
   for _,object in ipairs(model:GetDescendants())do
    if object:IsA('BasePart') then
     if record[object]==nil then record[object]=object.LocalTransparencyModifier end
     object.LocalTransparencyModifier=shown and record[object] or 1
    elseif object:IsA('BillboardGui') or object:IsA('ProximityPrompt') then
     if record[object]==nil then record[object]=object.Enabled end
     local enabled=shown and record[object]
     if object:IsA('ProximityPrompt') and (object.Name=='Invite' or object.Name=='Rest') then
      local camp=model:GetAttribute('SeleneCampPosition')
      local unlocked=journal and journal.flags['DW-03:report']==true
      enabled=enabled and unlocked and root and typeof(camp)=='Vector3' and (root.Position-camp).Magnitude<=16
       and (object.Name=='Rest' and journal.seleneFollowing==true or object.Name=='Invite' and journal.seleneFollowing~=true)
     end
     object.Enabled=enabled==true
    end
   end
  end
 end
 local added=Tags:GetInstanceAddedSignal('TLTStoryNPC'):Connect(function(model)
  if model:IsDescendantOf(world) then api.update()end
 end)
 local removed=Tags:GetInstanceRemovedSignal('TLTStoryNPC'):Connect(function(model)
  if records[model] then api.update()end
 end)
 function api.destroy()
  added:Disconnect();removed:Disconnect()
  for _,record in pairs(records)do restore(record)end;table.clear(records)
 end
 return api
end
function View.start()
 local player=game.Players.LocalPlayer;local current,controller;local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.15 then return end;elapsed=0
  local world=workspace:FindFirstChild('DeepwoodCampaign')
  if current~=world then
   if controller then controller.destroy();controller=nil end
   current=world;if world then controller=View.create(player,world)end
  end
  if controller then controller.update()end
 end)
end
return View
