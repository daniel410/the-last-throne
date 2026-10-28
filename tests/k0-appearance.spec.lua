-- Run: lua tests/k0-appearance.spec.lua
-- Independent replay of the modeling lifecycle fixture. Instance/physics/
-- CFrame are test doubles: this checks ownership, listeners and joints only.
local function signal()
  local listeners = {}
  return {
    Connect = function(_, callback)
      local entry = { callback = callback, connected = true }
      table.insert(listeners, entry)
      return { Disconnect = function() entry.connected = false end }
    end,
    Fire = function(_, ...)
      for _, entry in ipairs(listeners) do
        if entry.connected then entry.callback(...) end
      end
    end,
  }
end

local methods = {}
local instanceMt = {}
instanceMt.__index = function(self, key)
  if key == "Parent" then return rawget(self, "_parent") end
  return methods[key] or self._props[key]
end
instanceMt.__newindex = function(self, key, value)
  if key ~= "Parent" then self._props[key] = value; return end
  local previous = rawget(self, "_parent")
  if previous == value then return end
  if previous then
    for i, child in ipairs(previous._children) do
      if child == self then table.remove(previous._children, i); break end
    end
  end
  rawset(self, "_parent", value)
  if previous then previous.ChildRemoved:Fire(self) end
  if value then
    table.insert(value._children, self)
    value.ChildAdded:Fire(self)
  end
end

function methods:IsA(class)
  return self._class == class or (class == "BasePart" and self._class == "Part")
end
function methods:SetAttribute(key, value) self._attributes[key] = value end
function methods:GetAttribute(key) return self._attributes[key] end
function methods:GetChildren()
  local result = {}
  for _, child in ipairs(self._children) do table.insert(result, child) end
  return result
end
function methods:FindFirstChild(name, recursive)
  for _, child in ipairs(self._children) do
    if child.Name == name then return child end
  end
  if recursive then
    for _, child in ipairs(self._children) do
      local result = child:FindFirstChild(name, true)
      if result then return result end
    end
  end
end
function methods:FindFirstChildOfClass(class)
  for _, child in ipairs(self._children) do
    if child:IsA(class) then return child end
  end
end
function methods:Destroy()
  if self._destroyed then return end
  self._destroyed = true
  local children = self:GetChildren()
  for _, child in ipairs(children) do child:Destroy() end
  self.Parent = nil
end

Instance = {}
function Instance.new(class)
  return setmetatable({
    _class = class, _props = { Name = class }, _children = {}, _attributes = {},
    ChildAdded = signal(), ChildRemoved = signal(),
  }, instanceMt)
end

local frame = {}
frame.__index = frame
frame.__mul = function() return setmetatable({}, frame) end
CFrame = {
  new = function() return setmetatable({}, frame) end,
  Angles = function() return setmetatable({}, frame) end,
}
Vector3 = { new = function(x, y, z) return {X=x, Y=y, Z=z} end }
Color3 = { fromRGB = function(r, g, b) return {r, g, b} end }
Enum = {
  Material = { SmoothPlastic = "SmoothPlastic", Metal = "Metal" },
  HumanoidRigType = { R15 = "R15", R6 = "R6" },
}
local players = { PlayerAdded = signal(), PlayerRemoving = signal(), list = {} }
function players:GetPlayers() return self.list end
game = { GetService = function(_, name) assert(name == "Players"); return players end }
local warnings = {}
warn = function(message) table.insert(warnings, message) end

local function makePlayer(character)
  return { Character = character, CharacterAdded = signal(), CharacterRemoving = signal() }
end
local function put(class, name, parent)
  local item = Instance.new(class)
  item.Name = name
  if class == "Part" then
    item.Size = Vector3.new(1, 2, 1)
    item.CFrame = CFrame.new()
  end
  item.Parent = parent
  return item
end
local function character()
  return Instance.new("Model")
end
local function addRig(model, rig)
  local humanoid = Instance.new("Humanoid")
  humanoid.RigType = rig
  humanoid.Parent = model
  local right = put("Part", rig == "R15" and "RightHand" or "Right Arm", model)
  local left = put("Part", rig == "R15" and "LeftHand" or "Left Arm", model)
  return right, left
end
local function owned(model)
  local list = {}
  for _, child in ipairs(model:GetChildren()) do
    if child:IsA("Model") and child:GetAttribute("TLT_K0_KnightAppearance") == true then
      table.insert(list, child)
    end
  end
  return list
end
local function verify(model, right, left)
  local models = owned(model)
  assert(#models == 1, "expected one owned model, got " .. #models)
  local visual = models[1]
  assert(visual:GetAttribute("TemporaryVisual") == true)
  local sword = assert(visual:FindFirstChild("K0SwordJoint", true))
  local shield = assert(visual:FindFirstChild("K0ShieldHandWeld", true))
  assert(sword:IsA("Motor6D") and sword.Part0 == right and sword.Part1.Name == "SwordGrip")
  assert(shield:IsA("WeldConstraint") and shield.Part0 == left and shield.Part1.Name == "ShieldRim")
  assert(sword.Part1:FindFirstChild("SwordBladeWeld", true) == nil)
  local blade = assert(visual:FindFirstChild("SwordBlade"))
  local bladeWeld = assert(blade:FindFirstChild("SwordBladeWeld"))
  assert(bladeWeld.Part0 == sword.Part1 and bladeWeld.Part1 == blade)
  local count = 0
  for _, part in ipairs(visual:GetChildren()) do
    if part:IsA("BasePart") then
      count = count + 1
      assert(part.Anchored == false and part.Massless == true)
      assert(part.CanCollide == false and part.CanTouch == false and part.CanQuery == false)
    end
  end
  assert(count == 9, "unexpected visual part count " .. count)
end

local first = character()
local unrelated = put("Model", "TLT_K0_KnightAppearance", first)
local tool = put("Model", "ExistingEquipment", first)
local p1 = makePlayer(first)
players.list = {p1}
local appearance = assert(loadfile("src/server/Cosmetics/KnightAppearance.luau"))()
appearance.start()
appearance.start()
assert(#owned(first) == 0, "incomplete rig should wait")
local right, left = addRig(first, "R15")
verify(first, right, left)
assert(unrelated.Parent == first and tool.Parent == first, "existing equipment changed")
put("Part", "UnrelatedAdded", first)
verify(first, right, left)

p1.CharacterRemoving:Fire(first)
local second = character()
p1.Character = second
p1.CharacterAdded:Fire(second)
local r6right, r6left = addRig(second, "R6")
verify(second, r6right, r6left)
r6left:Destroy()
assert(#owned(second) == 0, "missing hand should detach owned model")
r6left = put("Part", "Left Arm", second)
verify(second, r6right, r6left)

local third = character()
local p2 = makePlayer(nil)
players.PlayerAdded:Fire(p2)
p2.Character = third
p2.CharacterAdded:Fire(third)
local p2right, p2left = addRig(third, "R15")
verify(third, p2right, p2left)
players.PlayerRemoving:Fire(p2)
local fourth = character()
p2.Character = fourth
p2.CharacterAdded:Fire(fourth)
addRig(fourth, "R15")
assert(#owned(fourth) == 0, "player removal should disconnect listeners")
assert(#warnings == 0, "unexpected warning: " .. table.concat(warnings, "; "))
print("PASS: existing/new players, deferred R15/R6 rigs, idempotence, respawn, hand replacement, player removal, owned visuals, and Motor6D contract")
