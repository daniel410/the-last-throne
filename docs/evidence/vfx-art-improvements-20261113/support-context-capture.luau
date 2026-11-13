-- Isolated actual-asset context capture. This is NOT a live regional/device acceptance scene.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only; no real accounts')
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Server=assert(game.ServerScriptService:FindFirstChild('Server'),'Frozen QA Server modules required')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Http=game:GetService('HttpService')
local disabled=0
local function disableScripts(container)
 for _,item in ipairs(container:GetDescendants())do
  if item:IsA('Script')or item:IsA('LocalScript')then item.Disabled=true;disabled+=1 end
 end
end
-- Disable every authored runtime entry point before enabling local rendering.
for _,container in ipairs({game.ServerScriptService,game.ServerStorage,game.ReplicatedStorage,game.ReplicatedFirst,game.StarterPlayer,game.StarterGui,workspace})do disableScripts(container)end
for _,container in ipairs({game.ServerScriptService,game.ServerStorage,game.ReplicatedStorage,game.ReplicatedFirst,game.StarterPlayer,game.StarterGui,workspace})do
 for _,item in ipairs(container:GetDescendants())do if item:IsA('Script')or item:IsA('LocalScript')then assert(item.Disabled,'Runtime script must remain disabled')end end
end
local SeleneVisual=require(Server.World.SeleneVisual)
local Presentation=require(Client.SelenePresentation)
local Pixel=require(Client.PixelFX)
local Mood=require(Client.DeepwoodAtmosphere)
local Weapon=require(Server.Cosmetics.WeaponAppearance)
local Armor=require(Server.Cosmetics.ArmorAppearance)
assert(game.ServerStorage:FindFirstChild('SeleneRepairedModels'),'Pinned TD nun storage is required')
local origin=Vector3.new(10000,50,0)
local templateStage=Instance.new('Folder');templateStage.Name='SupportContextTemplates';templateStage.Parent=workspace
local templates={}
local equipment={classId='knight',weaponDefinitionId='knight_weapon_traveler',armorDefinitionIds={head='traveler_hood',body='traveler_coat',hands='traveler_gloves',feet='traveler_boots'}}
local preload={completed=false,timedOut=false,statuses={},ok=false}
local sourceContents={}
local function inert(container)
 disableScripts(container)
 for _,item in ipairs(container:GetDescendants())do if item:IsA('BasePart')then item.CanCollide=false;item.CanTouch=false;item.CanQuery=false end end
end
local ok,err=xpcall(function()
 templates.selene=SeleneVisual.create(templateStage,origin+Vector3.new(-2.8,0,0),'ActualTDSelene',{label=false,yaw=math.pi})
 local description=Instance.new('HumanoidDescription')
 local created,recipient=pcall(function()return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)end)
 description:Destroy();assert(created,recipient)
 recipient.Name='StockR15SupportRecipient';inert(recipient);recipient.Parent=templateStage
 local human=assert(recipient:FindFirstChildOfClass('Humanoid'));human.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 local root=assert(recipient:FindFirstChild('HumanoidRootPart'));root.Anchored=true
 recipient:PivotTo(CFrame.new(origin+Vector3.new(2.2,human.HipHeight+root.Size.Y*.5,0))*CFrame.Angles(0,math.pi,0))
 recipient:SetAttribute('K0ClassId','knight');recipient:SetAttribute('K0State','Idle');recipient:SetAttribute('TLTEquippedWeapon',equipment.weaponDefinitionId)
 recipient:SetAttribute('TLTEquippedHead',equipment.armorDefinitionIds.head);recipient:SetAttribute('TLTEquippedBody',equipment.armorDefinitionIds.body)
 recipient:SetAttribute('TLTEquippedHands',equipment.armorDefinitionIds.hands);recipient:SetAttribute('TLTEquippedFeet',equipment.armorDefinitionIds.feet)
 local weapon=Instance.new('Model');weapon.Name='ContextWeapon';weapon.Parent=recipient
 local weaponOK,result,reason=pcall(function()return Weapon.attachInto(weapon,recipient,'knight')end)
 equipment.weaponApplied=weaponOK and result~=nil;equipment.weaponError=not weaponOK and tostring(result)or not result and tostring(reason)or nil
 local armorOK,armorError=pcall(function()Armor.sync(recipient)end)
 equipment.armorApplied=armorOK;equipment.armorError=not armorOK and tostring(armorError)or nil;equipment.armorSlots={}
 for slot,suffix in pairs({head='Head',body='Body',hands='Hands',feet='Feet'})do
  local model=recipient:FindFirstChild('TLTArmor_'..slot)
  equipment.armorSlots[slot]={present=model~=nil,error=recipient:GetAttribute('TLTArmor'..suffix..'Error'),visualKey=model and model:GetAttribute('ArmorVisualKey')}
  if not model then equipment.armorApplied=false end
 end
 inert(recipient);templates.recipient=recipient
 local list={}
 for _,item in ipairs(templateStage:GetDescendants())do
  if item:IsA('MeshPart')then
   list[#list+1]=item;sourceContents[item.MeshId]=true;if item.TextureID~=''then sourceContents[item.TextureID]=true end
  elseif item:IsA('SurfaceAppearance')then
   list[#list+1]=item
   for _,key in ipairs({'ColorMap','MetalnessMap','NormalMap','RoughnessMap'})do local id=tostring(item[key]);if id~=''then sourceContents[id]=true end end
  end
 end
 task.spawn(function()
  local loaded,why=pcall(function()game.ContentProvider:PreloadAsync(list,function(id,status)preload.statuses[id]=status.Name end)end)
  preload.ok=loaded;preload.error=not loaded and tostring(why)or nil;preload.completed=true
 end)
 local deadline=os.clock()+15;while not preload.completed and os.clock()<deadline do task.wait(.05)end
 preload.timedOut=not preload.completed
 templateStage.Parent=nil
 if not Run:IsRunning()then Run:Run()end
 task.wait(.2)
 local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=48
 local index=0
 for _,profile in ipairs({'Deepwood','HauntedGraveyard'})do for _,action in ipairs({'Heal','Protect','Cleanse'})do
  index+=1
  if _G.SupportContextIndex and index~=_G.SupportContextIndex then continue end
  if _G.SupportContextCaptureGroup and math.ceil(index/3)~=_G.SupportContextCaptureGroup then continue end
  assert(game.PlaceId==0 and game.GameId==0 and #Players:GetPlayers()==0,'Fixture identity changed')
  Pixel.clear();Mood.update(profile)
  local stage=Instance.new('Folder');stage.Name='SyntheticSupportContext';stage:SetAttribute('SyntheticStage',true);stage.Parent=workspace
  local floor=Instance.new('Part');floor.Name='SyntheticReviewFloor';floor.Size=Vector3.new(36,.5,30);floor.Position=origin-Vector3.yAxis*.25
  floor.Anchored=true;floor.CanCollide=false;floor.CanTouch=false;floor.CanQuery=false;floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(64,69,72);floor.Parent=stage
  local selene=templates.selene:Clone();selene.Name='ActualTDSelene';selene.Parent=stage
  local target=templates.recipient:Clone();target.Name='StockR15SupportRecipient';inert(target);target.Parent=stage
  local before={};for _,node in ipairs(workspace:GetChildren())do before[node]=true end
  local view=assert(Presentation.bind(selene,function()return target end),'Actual TD Selene rig must bind')
  local now=workspace:GetServerTimeNow();local sample=action=='Heal'and .34 or action=='Protect'and .24 or .16
  selene:SetAttribute('SupportAt',now);selene:SetAttribute('LastSupport',action);selene:SetAttribute('SupportAmount',12);view.seen=now
  local health=target.Humanoid.Health
  view:play(now,action,12,target);view:update(0,now+sample);Pixel.step(sample)
  assert(target.Humanoid.Health==health,'Presentation must not grant healing or gameplay state')
  -- Put all source/target attachments and effects under one clone boundary.
  -- Cloning separate roots would leave BlessingLink attached to destroyed sources.
  for _,node in ipairs(workspace:GetChildren())do if not before[node]then node.Parent=stage end end
  local snapshot=stage:Clone();snapshot.Name='SupportContextSnapshot'
  view:destroy();Pixel.clear();stage:Destroy();snapshot.Parent=workspace
  for _,node in ipairs(snapshot:GetDescendants())do
   if node:IsA('BasePart')then node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false
   elseif node:IsA('ParticleEmitter')then
    local count=node:GetAttribute('ReviewBurstCount')or(node.Name=='SupportMotes'and 12 or 0)
    node:Clear();node:Emit(count)
   end
  end
  local focus=origin+Vector3.new(0,2.4,0);camera.CFrame=CFrame.lookAt(focus+Vector3.new(6.8,5.8,10.5),focus)
  task.wait(.1)
  for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ParticleEmitter')then node.TimeScale=0 end end
  local links={};local images={};local particles={}
  for _,node in ipairs(snapshot:GetDescendants())do
   if node:IsA('Beam')and node.Name=='BlessingLink'then
    links[#links+1]={sourceInside=node.Attachment0~=nil and node.Attachment0:IsDescendantOf(snapshot),targetInside=node.Attachment1~=nil and node.Attachment1:IsDescendantOf(snapshot)}
    assert(node.Attachment0 and node.Attachment0:IsDescendantOf(snapshot)and node.Attachment1 and node.Attachment1:IsDescendantOf(snapshot),'Frozen support link must retain both endpoints')
   elseif node:IsA('ImageLabel')then images[#images+1]={name=node.Name,image=node.Image,loaded=node.IsLoaded}
   elseif node:IsA('ParticleEmitter')then particles[#particles+1]={name=node.Name,texture=node.Texture,loaded='notExposedByParticleEmitterAPI'}end
  end
  local meta={index=index,id='support_context.'..profile..'.'..action,name=profile..' Light / '..action,width=320,height=240,
   syntheticStage=true,regionalLightingOnly=true,actualRegionalMap=false,actualTDSelene=true,receiver='stock Roblox R15 with attempted pinned Traveler equipment',
   equipment=equipment,profile=profile,action=action,geometrySampleSeconds=sample,particleReplaySeconds=.1,sourceContents=sourceContents,preload=preload,
   disabledRuntimeScripts=disabled,realPlayers=0,links=links,images=images,particles=particles,
   acceptanceLimit='Not live account/server support, actual campaign terrain, moving multiplayer, device/GPU or final user acceptance.'}
  print('SUPPORT_CONTEXT_STATE '..Http:JSONEncode(meta))
  local captured,captureError=false,nil
  game:GetService('CaptureService'):CaptureScreenshot(function(contentId)
   local success,why=pcall(function()
    local image=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(contentId));local pixels=image:ReadPixelsBuffer(Vector2.zero,image.Size)
    local hex={};for y=0,239 do for x=0,319 do
     local offset=(math.floor(y/240*image.Size.Y)*image.Size.X+math.floor(x/320*image.Size.X))*4
     for channel=0,2 do hex[#hex+1]=string.format('%02x',buffer.readu8(pixels,offset+channel))end
    end end
    print('CURATED_META '..Http:JSONEncode(meta));local raw=table.concat(hex)
    for from=1,#raw,20000 do print('CURATED_RGB '..index..' '..raw:sub(from,from+19999))end
    image:Destroy()
   end)
   captureError=not success and tostring(why)or nil;captured=true
  end)
  local deadline=os.clock()+10;while not captured and os.clock()<deadline do task.wait(.05)end
  snapshot:Destroy();assert(captured,'Support context capture timeout');assert(not captureError,captureError)
 end end
end,debug.traceback)
Pixel.clear();Mood.update(nil);templateStage:Destroy()
for _,node in ipairs(workspace:GetChildren())do if node.Name=='SupportContextSnapshot'or node.Name=='SyntheticSupportContext'then node:Destroy()end end
if not ok then error(err)end
print('CURATED_CAPTURE_COMPLETE')
