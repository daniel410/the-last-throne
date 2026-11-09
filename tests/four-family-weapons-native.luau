-- Isolated engine acceptance: real imported meshes, equipment-ID switching and UI sprites.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated candidate file')
local Shared=game.ReplicatedStorage.Shared
local V=require(Shared.FourFamilyWeaponVisuals)
local Catalog=require(Shared.ItemCatalog)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local G=require(Shared.ElfBowGeometry)
local Atlas=require(Shared.ItemSpriteAtlas)
local Sprites=require(game.StarterPlayer.StarterPlayerScripts.Client.ItemSprites)
local report={checks=0,models=0,preload={},passed=false}
local function check(ok,label)report.checks+=1;assert(ok,label)end
local folder=assert(game.ServerStorage:FindFirstChild(V.folderName))
check(#folder:GetChildren()==16,'Exactly 16 whitelisted templates')
local ids={};local content={};local preloadInstances={}
for id,spec in pairs(V.models)do
 table.insert(ids,id)
 check(Catalog.items[id] and Catalog.items[id].classId==spec.classId,'Existing server definition matches visual class')
 check(Atlas.images[id]~=nil,'Individual equipment and bag sprite exists')
 local template=assert(folder:FindFirstChild(id));check(template:GetAttribute('MeshyTaskId')==spec.taskId,'Exact task pinned')
 for _,p in template:GetDescendants()do
  check(not p:IsA('LuaSourceContainer') and not p:IsA('PackageLink'),'No scripts or package update links')
  if p:IsA('MeshPart')and p.Name~='String'and p.Name~='NockedArrow'then table.insert(content,p.MeshId);table.insert(content,p.TextureID);table.insert(preloadInstances,p)end
 end
 table.insert(content,Atlas.images[id]);local icon=Instance.new('ImageLabel');icon.Image=Atlas.images[id];table.insert(preloadInstances,icon)
end
check(#ids==16,'Whitelist is 4 families by 4 classes')
check(not V.models.knight_weapon_rare and not V.models.knight_weapon_epic,'Prior Rare/Epic are not replaced')
check(Atlas.images.enhancement_gem=='rbxassetid://81095702596861','Existing material sprite preserved')
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
 local desc=Instance.new('HumanoidDescription');local character=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
 character.Parent=workspace;character:PivotTo(CFrame.new(0,1500,0));character.HumanoidRootPart.Anchored=true
 local rootFrame=character.HumanoidRootPart.CFrame;local health=character.Humanoid.Health
 local model=Instance.new('Model');model.Parent=character
 for _,classId in ipairs({'knight','dwarf','elf','mage'})do
  character:SetAttribute('K0ClassId',classId)
  for _,tier in ipairs({'traveler','tempered','veteran','sentinel'})do
   local id=classId..'_weapon_'..(tier=='tempered'and'fine'or tier)
   character:SetAttribute('TLTEquippedWeapon',id)
   local result,reason=A.attachInto(model,character,classId);assert(result,reason)
   check(A.isAttached(model,character,classId),'Current equipped definition validates '..id)
   check(model:GetAttribute('WeaponDefinitionId')==id,'Exact definition selected '..id)
   check(model:GetAttribute('WeaponSourceKey')==V.models[id].sourceKey,'Exact latest Meshy task selected '..id)
   check(result.grip.CFrame:FuzzyEq(result.joint.Part0.CFrame*result.joint.C0,.0001),'Grip follows existing hand pose')
   local oldGrip=result.grip
   check(A.attachInto(model,character,classId).grip==oldGrip,'Idempotent reattach without duplication')
   local count=0
   for _,p in model:GetChildren()do if p:IsA('BasePart')and p:GetAttribute('TLTPlayerWeaponPart')then
    count+=1;check(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery,'Only inert visual parts')
   end end
   check(count==(classId=='elf'and 4 or 2),'Old weapon removed on swap')
   if classId=='elf'then
    check(G.valid(model,result.grip),'New bow uses the existing dynamic string rig')
    local nock=result.grip.BowNock;local rest=nock:GetAttribute('ElfBowRestPosition')
    check(rest==result.grip.BowNockRest.Position,'Nock comes from this model')
    for _,draw in ipairs({0,.5,1,0})do
     check(G.pose(model,draw,true),'Draw pose supported')
     check((nock.Position-rest-Vector3.new(0,0,.86*draw)).Magnitude<.0001,'Draw follows existing time curve')
    end
    check(model.String.Transparency==1,'Old baked source string stays hidden')
    check(result.grip.BowStrandUpper.Enabled and result.grip.BowStrandLower.Enabled,'Two beams remain visible')
   elseif classId=='dwarf'then
    local direction=result.grip.AxeCuttingDirection.Position
    check(direction.X>0 and direction.Z<0,'Cutting edge follows reviewed forward/inward frame')
   elseif classId=='knight'then
    check(model.SwordBlade:IsA('MeshPart')and model.SwordBlade.K0TrailTop.Position~=model.SwordBlade.K0TrailBottom.Position,'Sword mesh and trail remain connected')
   end
   local ui=Instance.new('Frame');local image=Sprites.create(ui,Catalog.items[id],UDim2.new(),UDim2.fromOffset(64,64))
   check(image and image.Image==Atlas.images[id]and image.ScaleType==Enum.ScaleType.Fit,'Gear and bag resolve the exact new icon')
   check(image.ImageRectSize==Vector2.zero,'Individual image does not use the old class atlas crop');ui:Destroy()
   check(character.HumanoidRootPart.CFrame==rootFrame and character.Humanoid.Health==health,'Visual swap never changes root or HP')
   report.models+=1
  end
  character:SetAttribute('TLTEquippedWeapon',classId..'_weapon_rare')
  local legacy=assert(A.attachInto(model,character,classId))
  check(not string.find(legacy.sourceKey,'meshy:four-family:',1,true),'Other Rare uses its existing source')
  check(model:GetAttribute('WeaponDefinitionId')==nil,'Whitelist metadata cleared on legacy fallback')
 end
 character:Destroy()
end
for start=1,#preloadInstances,8 do
 local batch={};for i=start,math.min(start+7,#preloadInstances)do table.insert(batch,preloadInstances[i])end
 game.ContentProvider:PreloadAsync(batch,function(id,status)report.preload[id]=tostring(status)end)
 task.wait()
end
for _,id in content do check(report.preload[id]=='Enum.AssetFetchStatus.Success','Uploaded mesh/texture/icon loads '..id..' '..tostring(report.preload[id]))end
report.passed=true
print('FOUR_FAMILY_WEAPONS_NATIVE '..game.HttpService:JSONEncode(report))
