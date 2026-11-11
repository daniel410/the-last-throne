-- Presentation only. Item ownership and eligibility stay in InventoryService.
local Players = game:GetService("Players")
local Storage = game:GetService("ServerStorage")
local Visuals = require(game:GetService("ReplicatedStorage").Shared.FourFamilyArmorVisuals)
local Armor = {}
local bindings = {}
local hidden = setmetatable({}, {__mode = "k"})
local syncing = setmetatable({}, {__mode = "k"})
local SLOTS = {head = "Head", body = "Body", hands = "Hands", feet = "Feet"}
local SUPPORTED = {knight=true, dwarf=true, elf=true, mage=true}
local R6 = {
 UpperTorso={"Torso",Vector3.new(0,0,0)}, LowerTorso={"Torso",Vector3.new(0,0,0)},
 LeftUpperArm={"Left Arm",Vector3.new(-1.5,0,0)},LeftLowerArm={"Left Arm",Vector3.new(-1.5,0,0)},LeftHand={"Left Arm",Vector3.new(-1.5,0,0)},
 RightUpperArm={"Right Arm",Vector3.new(1.5,0,0)},RightLowerArm={"Right Arm",Vector3.new(1.5,0,0)},RightHand={"Right Arm",Vector3.new(1.5,0,0)},
 LeftUpperLeg={"Left Leg",Vector3.new(-.5,-2,0)},LeftLowerLeg={"Left Leg",Vector3.new(-.5,-2,0)},LeftFoot={"Left Leg",Vector3.new(-.5,-2,0)},
 RightUpperLeg={"Right Leg",Vector3.new(.5,-2,0)},RightLowerLeg={"Right Leg",Vector3.new(.5,-2,0)},RightFoot={"Right Leg",Vector3.new(.5,-2,0)},
}
local function multiply(a,b) return Vector3.new(a.X*b.X,a.Y*b.Y,a.Z*b.Z) end
local function owned(child)
 return child:IsA("Model") and child:GetAttribute("TLTArmorAppearance") == true
end
local function finiteVector(v)
 return typeof(v)=="Vector3" and v.X==v.X and v.Y==v.Y and v.Z==v.Z and v.Magnitude<100
end
local function sizeScale(character, slot, r15)
 local head=character:FindFirstChild("Head")
 if slot=="head" and head and head:IsA("BasePart") then
  return Vector3.new(head.Size.X/1.159,head.Size.Y/1.182,head.Size.Z/1.161)
 end
 local torso=character:FindFirstChild(r15 and "UpperTorso" or "Torso")
 if not torso or not torso:IsA("BasePart") then return nil end
 local lower=character:FindFirstChild("LowerTorso")
 return Vector3.new(torso.Size.X/(r15 and 1.9432 or 2),
  r15 and (torso.Size.Y+(lower and lower:IsA("BasePart") and lower.Size.Y or .4))/2.0987 or torso.Size.Y/2,
  torso.Size.Z/(r15 and 1.004 or 1))
end
local function build(character, slot, key, classId, definitionId, r15)
 local folder=Storage:FindFirstChild(Visuals.folderName)
 local template=folder and folder:FindFirstChild(key)
 if not template or not template:IsA("Model") then return nil,"MissingTemplate" end
 local scale=sizeScale(character,slot,r15)
 if not scale or scale.X<.25 or scale.Y<.25 or scale.Z<.25 or scale.Magnitude>8 then return nil,"UnsupportedBodyScale" end
 local clone=template:Clone()
 local isRobe=key:match("_robe$")~=nil
 local isHat=key:match("_hat$")~=nil
 local isHelmet=key:match("_helmet$")~=nil
 if slot=="head" then
  local hairFolder=Storage:FindFirstChild(Visuals.hair.folderName)
  local sourceHair=hairFolder and hairFolder:FindFirstChild(Visuals.hair.templates[isHat and "hat" or isHelmet and "helmet" or "hood"])
  local family=key:match("^(%a+)_")
  local color=(isHat and Visuals.hair.colors or Visuals.hair.shortColors)[family]
  if not sourceHair or not sourceHair:IsA("MeshPart") or not color then clone:Destroy();return nil,"MissingHeadgearHair" end
  local hair=sourceHair:Clone();hair.Name="Hair";hair:SetAttribute("HeadgearHair",true)
  hair.Color=Color3.fromRGB(color[1],color[2],color[3]);hair.Parent=clone
 end
 local fittedScale=multiply(scale,Vector3.new(1,1,isRobe and Visuals.fit.robeDepth or 1))
 local count=0
 for _,part in clone:GetDescendants() do
  if part:IsA("BasePart") then
   local isHair=part:GetAttribute("HeadgearHair")==true
   if not part:IsA("MeshPart") or part.MeshId=="" or (part.TextureID=="" and not isHair) then clone:Destroy();return nil,"InvalidMesh" end
   local anchorName=part:GetAttribute("ArmorAnchor")
   local reference=part:GetAttribute("ArmorReferenceAnchor")
   local center=part:GetAttribute("ArmorLocalCenter")
   if type(anchorName)~="string" or not finiteVector(reference) or not finiteVector(center) then clone:Destroy();return nil,"InvalidSocket" end
   local alias=not r15 and R6[anchorName] or nil
   local anchor=character:FindFirstChild(alias and alias[1] or anchorName)
   if not anchor or not anchor:IsA("BasePart") then clone:Destroy();return nil,"MissingBodyPart" end
   local offset=center-reference
   if alias then offset+=reference-alias[2] end
   if isHat and not isHair then offset-=Vector3.new(0,Visuals.fit.hatLowering,0) end
   if isHelmet and not isHair then offset+=Vector3.new(0,Visuals.fit.helmetLift,0) end
   if isHair and not isHat and not isHelmet then offset+=Vector3.new(0,.05,-.13) end
   local rotation=part.CFrame.Rotation
   part.Size=multiply(part.Size,fittedScale)
   part.CFrame=anchor.CFrame*CFrame.new(multiply(offset,fittedScale))*rotation
   part.Anchored=false;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
   local weld=Instance.new("WeldConstraint");weld.Name="ArmorWeld";weld.Part0=anchor;weld.Part1=part;weld.Parent=part
   count+=1
  elseif not part:IsA("SurfaceAppearance") then
   clone:Destroy();return nil,"UnexpectedTemplateInstance"
  end
 end
 if count==0 then clone:Destroy();return nil,"EmptyTemplate" end
 clone.Name="TLTArmor_"..slot
 clone:SetAttribute("TLTArmorAppearance",true)
 clone:SetAttribute("ArmorSlot",slot);clone:SetAttribute("ArmorVisualKey",key)
 clone:SetAttribute("ArmorDefinitionId",definitionId);clone:SetAttribute("ArmorClassId",classId)
 clone:SetAttribute("ArmorScale",scale)
 clone:SetAttribute("ArmorFitVersion",Visuals.version)
 clone:SetAttribute("ArmorPartCount",count)
 return clone
end
local function refreshVisibility(character)
 local has={}
 for _,child in character:GetChildren() do
  if owned(child) then has[child:GetAttribute("ArmorSlot")]=child:GetAttribute("ArmorVisualKey") end
 end
 local wanted={}
 local function hide(name)
  local p=character:FindFirstChild(name);if p and p:IsA("BasePart") then wanted[p]=true end
 end
 if has.body then
  hide("Torso");hide("UpperTorso");hide("LowerTorso")
  if string.match(has.body,"_robe$") then
   for _,name in {"LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
    "LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","Left Leg","Right Leg"} do hide(name) end
  end
 end
 if has.hands then hide("LeftHand");hide("RightHand");hide("LeftLowerArm");hide("RightLowerArm") end
 if has.feet then hide("LeftFoot");hide("RightFoot");hide("LeftLowerLeg");hide("RightLowerLeg") end
 if has.head then
  for _,accessory in character:GetChildren() do
   if accessory:IsA("Accessory") and (accessory.AccessoryType==Enum.AccessoryType.Hat or accessory.AccessoryType==Enum.AccessoryType.Hair) then
    for _,p in accessory:GetDescendants() do if p:IsA("BasePart") then wanted[p]=true end end
   end
  end
 end
 local original=hidden[character] or {};hidden[character]=original
 for part,value in original do
  if not wanted[part] then
   if part.Parent then part.Transparency=value end
   original[part]=nil
  end
 end
 for part in wanted do
  if original[part]==nil then original[part]=part.Transparency end
  part.Transparency=1
 end
end
function Armor.sync(character)
 if syncing[character] then return end
 syncing[character]=true
 local ok,err=pcall(function()
  local humanoid=character:FindFirstChildOfClass("Humanoid")
  if not humanoid then return end
  local r15=humanoid.RigType==Enum.HumanoidRigType.R15
  local classId=character:GetAttribute("K0ClassId")
  for slot,suffix in SLOTS do
   local definitionId=character:GetAttribute("TLTEquipped"..suffix)
   local candidates=SUPPORTED[classId] and Visuals.models[definitionId] or nil
   local key=candidates and candidates[classId] or nil
   local old={}
   for _,child in character:GetChildren() do if owned(child) and child:GetAttribute("ArmorSlot")==slot then table.insert(old,child) end end
   local existing=old[1]
   local healthy=existing and #old==1 and existing:GetAttribute("ArmorVisualKey")==key
    and existing:GetAttribute("ArmorFitVersion")==Visuals.version
    and existing:GetAttribute("ArmorDefinitionId")==definitionId and existing:GetAttribute("ArmorClassId")==classId
    and existing:GetAttribute("ArmorScale")==sizeScale(character,slot,r15)
   if healthy then
    local count=0
    for _,part in existing:GetChildren() do
     if part:IsA("MeshPart") then
      count+=1;local weld=part:FindFirstChild("ArmorWeld")
      if not weld or not weld:IsA("WeldConstraint") or weld.Part1~=part or not weld.Part0 or weld.Part0.Parent~=character then healthy=false;break end
     end
    end
    if count~=existing:GetAttribute("ArmorPartCount") then healthy=false end
   end
   if not key then
    for _,child in old do child:Destroy() end
    character:SetAttribute("TLTArmor"..suffix.."Error",nil)
   elseif not healthy then
    local replacement,reason=build(character,slot,key,classId,definitionId,r15)
    if replacement then
     -- Prepare all sockets first. A failed replacement cannot leave half an outfit.
     for _,child in old do child:Destroy() end
     replacement.Parent=character
     character:SetAttribute("TLTArmor"..suffix.."Error",nil)
    else
     character:SetAttribute("TLTArmor"..suffix.."Error",reason)
     for _,child in old do if child:GetAttribute("ArmorClassId")~=classId then child:Destroy() end end
    end
   end
  end
  refreshVisibility(character)
 end)
 syncing[character]=nil
 if not ok then warn("Armor appearance could not synchronize: "..tostring(err)) end
end
local function clear(binding)
 for _,connection in binding.connections do connection:Disconnect() end
 binding.connections={};binding.epoch+=1;binding.queued=false
 local character=binding.character;binding.character=nil
 if character and hidden[character] then
  for part,value in hidden[character] do if part.Parent then part.Transparency=value end end
  hidden[character]=nil
 end
end
local function watch(binding,character)
 clear(binding);binding.character=character
 local function queue()
  if binding.queued then return end
  binding.queued=true;local epoch=binding.epoch
  task.defer(function()
   if binding.epoch~=epoch or binding.player.Character~=character then return end
   binding.queued=false;Armor.sync(character)
  end)
 end
 for _,key in {"K0ClassId","TLTEquippedHead","TLTEquippedBody","TLTEquippedHands","TLTEquippedFeet"} do
  table.insert(binding.connections,character:GetAttributeChangedSignal(key):Connect(queue))
 end
 table.insert(binding.connections,character.ChildAdded:Connect(queue))
 table.insert(binding.connections,character.ChildRemoved:Connect(queue))
 table.insert(binding.connections,character.DescendantRemoving:Connect(function(item)
  if not syncing[character] and (item:IsA("BasePart") or item:IsA("WeldConstraint")) then queue() end
 end))
 for _,p in character:GetChildren() do
  if p:IsA("BasePart") then table.insert(binding.connections,p:GetPropertyChangedSignal("Size"):Connect(queue)) end
 end
 queue()
end
local function bind(player)
 if bindings[player] then return end
 local binding={player=player,connections={},epoch=0};bindings[player]=binding
 binding.added=player.CharacterAdded:Connect(function(character) watch(binding,character) end)
 binding.removing=player.CharacterRemoving:Connect(function() clear(binding) end)
 binding.loaded=player.CharacterAppearanceLoaded:Connect(function(character)
  if player.Character==character then watch(binding,character) end
 end)
 if player.Character then watch(binding,player.Character) end
end
local started=false
function Armor.start()
 if started then return end;started=true
 Players.PlayerAdded:Connect(bind)
 Players.PlayerRemoving:Connect(function(player)
  local binding=bindings[player];if not binding then return end
  clear(binding);binding.added:Disconnect();binding.removing:Disconnect();binding.loaded:Disconnect();bindings[player]=nil
 end)
 for _,player in Players:GetPlayers() do bind(player) end
end
return Armor
