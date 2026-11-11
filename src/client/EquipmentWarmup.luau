-- Download before sending Equip; no ownership or equipment authority here.
local Content = game:GetService('ContentProvider')
local Shared = game:GetService('ReplicatedStorage').Shared
local Manifest = require(Shared.EquipmentPreloadManifest)
local Armor = require(Shared.FourFamilyArmorVisuals)
local Warmup = {}
local loaded, running = {}, {}
local function prepareKey(key)
 local entries = Manifest[key]
 if not entries or loaded[key] then return true end
 if running[key] then
  local job=running[key]
  while not job.done do task.wait() end
  return job.success
 end
 local job={};running[key]=job
 local inputs={}
 for _,entry in ipairs(entries) do
  local mesh=Instance.new('SpecialMesh');mesh.MeshId=entry[1];table.insert(inputs,mesh)
  if entry[2]~='' then local decal=Instance.new('Decal');decal.Texture=entry[2];table.insert(inputs,decal) end
 end
 local success=false
 for attempt=1,3 do
  local all,count=true,0
  local ok=pcall(function() Content:PreloadAsync(inputs,function(_,status)
   count=count+1;if status~=Enum.AssetFetchStatus.Success then all=false end
  end) end)
  success=ok and all and count>0
  if success then break end
  if attempt<3 then task.wait(attempt) end
 end
 for _,input in ipairs(inputs) do input:Destroy() end
 loaded[key]=success or nil;job.success=success;job.done=true;running[key]=nil
 return success
end
function Warmup.prepare(definitionId,classId)
 local armor=Armor.models[definitionId]
 local key=armor and armor[classId] or definitionId
 if not prepareKey(key) then return false end
 if armor and key and (key:match('_hat$') or key:match('_hood$') or key:match('_helmet$')) then
  return prepareKey(classId=='mage' and 'MageHair' or classId=='elf' and 'ShortHair' or 'HelmetHair')
 end
 return true
end
return Warmup
