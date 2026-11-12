-- Client presentation only. Keep untextured equipment out of rendered frames;
-- ownership, equipment visibility and combat remain with their existing owners.
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Assets = {}
local started = false
local pending = {}
local masked = {}

local function equipment(part)
 if part:GetAttribute("TLTPlayerWeaponPart") or part:GetAttribute("TLTPlayerShieldPart") then return true end
 local parent = part.Parent
 while parent and parent ~= workspace do
  if parent:GetAttribute("TLTArmorAppearance") then return true end
  parent = parent.Parent
 end
 return false
end

local function restore(part)
 local value = masked[part]
 if value ~= nil then
  -- Restore before other presentation code runs, so a throw, unequip or
  -- first-person mask can still choose its own value in this frame.
  part.LocalTransparencyModifier = value
  masked[part] = nil
 end
end

-- Request images through a texture-bearing instance. Raw image IDs can request
-- the wrong asset representation, and SurfaceAppearance itself cannot preload.
function Assets.preload(part, callback)
 local inputs, textures, seen = {part}, {}, {}
 local function texture(id)
  if not id or id == "" or seen[id] then return end
  seen[id] = true
  local decal = Instance.new("Decal")
  decal.Texture = id
  table.insert(textures, decal)
  table.insert(inputs, decal)
 end
 texture(part.TextureID)
 for _, child in ipairs(part:GetChildren()) do
  if child:IsA("SurfaceAppearance") then
   for _, property in ipairs({"ColorMapContent", "NormalMapContent", "MetalnessMapContent", "RoughnessMapContent"}) do
    -- Legacy map IDs require Plugin capability even for reads.
    texture(child[property].Uri)
   end
  end
 end
 local ok, err = pcall(function() ContentProvider:PreloadAsync(inputs, callback) end)
 for _, decal in ipairs(textures) do decal:Destroy() end
 if not ok then error(err) end
end

function Assets.isReady(character)
 for part,state in pairs(pending) do
  if part:IsDescendantOf(character) and not state.ready then return false end
 end
 return true
end

function Assets.start()
 if started then return end
 started = true
 local function add(part)
  if not part:IsA("MeshPart") or pending[part] or not equipment(part) then return end
  local state = {}
  pending[part] = state
  task.spawn(function()
   for attempt = 1, 3 do
    if pending[part] ~= state or not part:IsDescendantOf(workspace) then return end
    local succeeded, count = true, 0
    local ok = pcall(function()
     Assets.preload(part, function(_, status)
      count = count + 1
      if status ~= Enum.AssetFetchStatus.Success then succeeded = false end
     end)
    end)
    if pending[part] ~= state then return end
    if ok and succeeded and count > 0 then
     state.ready = true
     return
    end
    if attempt < 3 then task.wait(2 ^ attempt) end
   end
   -- A denied asset must not leave equipment invisible forever. Preserve the
   -- existing Knight substitute and let other equipment retain its authored view.
   state.ready = true
   warn("Equipment assets could not be fully loaded: " .. part:GetFullName())
  end)
 end
 workspace.DescendantAdded:Connect(add)
 workspace.DescendantRemoving:Connect(function(part)
  pending[part] = nil
  restore(part)
 end)
 for _, part in ipairs(workspace:GetDescendants()) do add(part) end
 RunService.PreSimulation:Connect(function()
  for part in pairs(masked) do restore(part) end
 end)
 RunService:BindToRenderStep("TLTEquipmentAssetLoading", Enum.RenderPriority.Last.Value + 1, function()
  for part, state in pairs(pending) do
   if state.ready or not part:IsDescendantOf(workspace) then
    restore(part)
    pending[part] = nil
   else
    -- Capture the latest animation/camera mask, never replace it with zero.
    if masked[part] == nil then masked[part] = part.LocalTransparencyModifier end
    part.LocalTransparencyModifier = 1
   end
  end
 end)
end

return Assets
