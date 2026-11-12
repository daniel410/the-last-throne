-- Local arrival gate. Server spawn readiness never implies downloaded appearance.
local Players=game:GetService('Players')
local Content=game:GetService('ContentProvider')
local Shared=game:GetService('ReplicatedStorage').Shared
local Visuals=require(Shared.FourFamilyArmorVisuals)
local Equipment=require(script.Parent.EquipmentAssetLoading)
local Warmup=require(script.Parent.EquipmentWarmup)
local M={}
local slots={Head='head',Body='body',Hands='hands',Feet='feet'}
function M.snapshot(character)
 local classId=character:GetAttribute('K0ClassId')
 local signature={tostring(classId)}
 local definitions={}
 local complete=classId~=nil and character:FindFirstChild('Head')~=nil
  and character:FindFirstChild('HumanoidRootPart')~=nil
  and (character:FindFirstChild('Torso')~=nil or (character:FindFirstChild('UpperTorso')~=nil and character:FindFirstChild('LowerTorso')~=nil))
 for suffix,slot in pairs(slots) do
  local id=character:GetAttribute('TLTEquipped'..suffix)
  table.insert(signature,suffix..':'..tostring(id))
  if id and id~='' then
   table.insert(definitions,id)
   local key=Visuals.models[id] and Visuals.models[id][classId]
   if key then
    local model=character:FindFirstChild('TLTArmor_'..slot)
    if not model or model:GetAttribute('ArmorDefinitionId')~=id then complete=false
    else
     local count=0
     for _,part in ipairs(model:GetChildren()) do if part:IsA('MeshPart') then count=count+1 end end
     if count==0 or count~=model:GetAttribute('ArmorPartCount') then complete=false end
    end
   end
  end
 end
 for _,suffix in ipairs({'Weapon','Offhand'}) do
  local id=character:GetAttribute('TLTEquipped'..suffix);table.insert(signature,suffix..':'..tostring(id))
  if id and id~='' then
   table.insert(definitions,id)
   local found=false
   for _,part in ipairs(character:GetDescendants()) do
    if part:GetAttribute(suffix=='Weapon' and 'WeaponDefinitionId' or 'ShieldDefinitionId')==id then found=true;break end
   end
   if not found then complete=false end
  end
 end
 local meshes,content={},{}
 for _,part in ipairs(character:GetDescendants()) do
  if part:IsA('MeshPart') then
   table.insert(content,part);table.insert(meshes,part)
   table.insert(signature,part:GetFullName()..':'..part.MeshId..':'..part.TextureID)
  elseif part:IsA('Decal') or part:IsA('Texture') then table.insert(content,part);table.insert(signature,part:GetFullName()..':'..part.Texture)
  elseif part:IsA('SpecialMesh') then table.insert(content,part);table.insert(signature,part:GetFullName()..':'..part.MeshId..':'..part.TextureId) end
 end
 table.sort(signature)
 return table.concat(signature,'|'),complete,definitions,meshes,classId,content
end
local started=false
function M.start(player)
 if started then return end;started=true
 local function watch(character)
  character:SetAttribute('TLTLocalAppearanceReady',false)
  local connections={}
  local function invalidate()character:SetAttribute('TLTLocalAppearanceReady',false)end
  table.insert(connections,character:GetAttributeChangedSignal('K0ClassId'):Connect(invalidate))
  table.insert(connections,character.DescendantAdded:Connect(invalidate))
  table.insert(connections,character.DescendantRemoving:Connect(invalidate))
  for _,suffix in ipairs({'Head','Body','Hands','Feet','Weapon','Offhand'}) do
   table.insert(connections,character:GetAttributeChangedSignal('TLTEquipped'..suffix):Connect(invalidate))
  end
  task.spawn(function()
   local prepared,attemptKey,failures
   while player.Character==character do
    local key,complete,definitions,meshes,classId,content=M.snapshot(character)
    if not complete or key~=prepared then
     character:SetAttribute('TLTLocalAppearanceReady',false)
     if complete then
      if attemptKey~=key then attemptKey,failures=key,0 end
      local success,failedAsset=true,nil
      local function fetched(id,status)
       if status~=Enum.AssetFetchStatus.Success then success=false;failedAsset=tostring(id)..' ('..tostring(status)..')' end
      end
      local ok,err=pcall(function()
       for _,id in ipairs(definitions) do
        if not Warmup.prepare(id,classId) then success=false;failedAsset='equipment '..id;break end
       end
       Content:PreloadAsync(content,fetched)
       for _,mesh in ipairs(meshes) do Equipment.preload(mesh,fetched) end
      end)
      local current,stillComplete=M.snapshot(character)
      if player.Character~=character then break end
      if stillComplete and current==key then
       if ok and success then
        prepared=key;character:SetAttribute('TLTLocalAppearanceError',nil)
        character:SetAttribute('TLTLocalAppearanceDegraded',nil)
       else
        failures=failures+1
        warn('Character appearance download attempt '..failures..' failed: '..tostring(failedAsset or err))
        if failures>=3 then
         -- Cosmetic download failure must not permanently deny an admitted player.
         -- Keep replication and Equipment.isReady gates; never change saved gear.
         prepared=key;character:SetAttribute('TLTLocalAppearanceError',nil)
         character:SetAttribute('TLTLocalAppearanceDegraded',true)
        else
         character:SetAttribute('TLTLocalAppearanceError','Retrying');task.wait(2)
        end
       end
      end
     end
    end
    if player.Character==character then
     local current,stillComplete=M.snapshot(character)
     character:SetAttribute('TLTLocalAppearanceReady',stillComplete and current==prepared and Equipment.isReady(character))
    end
    task.wait(.1)
   end
   for _,connection in ipairs(connections) do connection:Disconnect() end
  end)
 end
 player.CharacterAdded:Connect(watch)
 if player.Character then watch(player.Character) end
end
return M
