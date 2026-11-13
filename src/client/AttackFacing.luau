-- Local locomotion consumes a server-approved heading; never selects targets.
local Facing={}
local held
local idleRotate=setmetatable({},{__mode='k'})
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
function Facing.direction(character)
 local packed=character:GetAttribute('K0AttackAim')or character:GetAttribute('K0BowAim')
 if type(packed)~='string'or #packed>128 then return end
 local f=string.split(packed,'|');if #f~=4 or tonumber(f[1])~=character:GetAttribute('K0AttackSeq')then return end
 local x,y,z=tonumber(f[2]),tonumber(f[3]),tonumber(f[4])
 if not finite(x)or not finite(y)or not finite(z)then return end
 local d=Vector3.new(x,0,z);if d.Magnitude>.01 and d.Magnitude<2 then return d.Unit end
end
local function release()
 if held then
  local c,h=held.character,held.humanoid
  local mode=c:GetAttribute('K0State')
  -- Dodge/death own their rotation policy until the server releases them.
  if h.Parent and mode~='Dodge'and mode~='Dead'and mode~='Stunned'and not c:GetAttribute('TLTDeathFalling')then h.AutoRotate=held.restoreRotate end
  held=nil
 end
end
function Facing.update(character)
 local class=character and character:GetAttribute('K0ClassId')
 local h=character and character:FindFirstChildOfClass('Humanoid')
 local root=character and character:FindFirstChild('HumanoidRootPart')
 local direction=character and Facing.direction(character)
 if held and held.character~=character then release()end
 if not character or(class~='elf'and class~='mage')or character:GetAttribute('K0State')~='Attack'
  or character:GetAttribute('TLTDeathFalling')or not h or h.Health<=0 or not root or not direction then
  release()
  if character and h and character:GetAttribute('K0State')=='Idle'then idleRotate[character]=h.AutoRotate end
  return false
 end
 local restoreRotate=character:GetAttribute('K0AttackAutoRotate')
 if type(restoreRotate)~='boolean'then restoreRotate=idleRotate[character];if restoreRotate==nil then restoreRotate=h.AutoRotate end end
 if not held then held={character=character,humanoid=h,restoreRotate=restoreRotate}end
 held.restoreRotate=restoreRotate
 h.AutoRotate=false
 -- Preserve translation and velocity; only the accepted cast yaw is held.
 root.CFrame=CFrame.lookAt(root.Position,root.Position+direction)
 return true
end
function Facing.clear()release()end
return Facing
