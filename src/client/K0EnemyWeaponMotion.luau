-- Local accents follow the original mesh's Blender-authored tip socket.
-- They never add hitboxes, replicated parts, damage or impact claims.
local Sockets=require(game:GetService('ReplicatedStorage').Shared.EnemyRigSockets)
local FrozenRigs=table.clone(require(game:GetService('ReplicatedStorage').Shared.FrozenValeRigs))
for kind,spec in pairs(require(game.ReplicatedStorage.Shared.EmberCalderaRigs))do FrozenRigs[kind]=spec end
for kind,spec in pairs(require(game.ReplicatedStorage.Shared.HauntedGraveyardRigs))do FrozenRigs[kind]=spec end
local Weapon={}
local function point(part,v)return part.Size*Vector3.new(v[1],v[2],v[3])end
function Weapon.bind(model,caster)
 local kind=model:GetAttribute('EnemyKind');local spec=Sockets[kind] or FrozenRigs[kind] and FrozenRigs[kind].socket
 local visual=model:FindFirstChild('TdMonsterVisual');local part=visual and visual:FindFirstChild(model:GetAttribute('TdWeaponPart') or model:GetAttribute('TdWeaponArm') or 'ArmR')
 if not spec or not part then return nil end
 for _,name in ipairs({'K0WeaponPresentation','K0BladeTip','K0BladeBase'})do local old=part:FindFirstChild(name);if old then old:Destroy()end end
 local folder=Instance.new('Folder');folder.Name='K0WeaponPresentation';folder.Parent=part
 local socketPart=caster and visual.VisualRoot or part
 local a=Instance.new('Attachment');a.Name='K0BladeTip';a.Position=point(part,spec.tip);a.Parent=socketPart
 local b=Instance.new('Attachment');b.Name='K0BladeBase';b.Position=point(part,spec.base);b.Parent=socketPart
 -- Attachments must be direct BasePart children to follow the physical mesh.
 local trail=Instance.new('Trail');trail.Name='WeaponEdge';trail.Attachment0=a;trail.Attachment1=b
 trail.Color=ColorSequence.new(spec.element=='fire' and Color3.fromRGB(255,183,105) or spec.caster and Color3.fromRGB(123,224,190) or Color3.fromRGB(224,231,214))
 trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.65),NumberSequenceKeypoint.new(.6,.84),NumberSequenceKeypoint.new(1,1)})
 trail.Lifetime=.09;trail.MinLength=.04;trail.LightEmission=.25;trail.FaceCamera=true;trail.Enabled=false;trail.Parent=folder
 local shards={}
 if spec.caster then
  for i=1,3 do
   local shard=Instance.new('WedgePart');shard.Name='FocusShard'..i
   shard.Size=Vector3.new(.05,.12,.075)*(model:GetAttribute('TdMonsterTargetHeight') or 5)*.25
   shard.Material=Enum.Material.Neon;shard.Color=spec.element=='fire' and Color3.fromRGB(255,151,74) or Color3.fromRGB(94,221,169)
   shard.Anchored=true;shard.Massless=true;shard.CanCollide=false;shard.CanTouch=false;shard.CanQuery=false;shard.CastShadow=false;shard.Transparency=1;shard.Parent=folder
   table.insert(shards,shard)
  end
 end
 local root=model:FindFirstChild('HumanoidRootPart');local torso=model:FindFirstChild('Torso')
 local shoulder=torso and torso:FindFirstChild(model:GetAttribute('TdWeaponShoulder') or 'Left Shoulder')
 return {folder=folder,part=part,a=a,b=b,trail=trail,shards=shards,position=part.Position,clock=nil,
  root=root,rootJoint=root and root:FindFirstChild('RootJoint'),shoulder=not caster and shoulder or nil,caster=caster,
  socketInArm=shoulder and shoulder.Part1.CFrame:ToObjectSpace(part.CFrame)*a.CFrame}
end
function Weapon.step(s,phase,active,heavy,clock,current,distance,discontinuity)
 if not s or not s.folder.Parent then return end
 if s.caster then
  local c=s.caster;local cf=c.bones.Staff.TransformedWorldCFrame
  s.a.CFrame=s.a.Parent.CFrame:ToObjectSpace(cf*CFrame.new(c.tip))
  s.b.CFrame=s.b.Parent.CFrame:ToObjectSpace(cf*CFrame.new(c.base))
 end
 local jumped=discontinuity or (s.part.Position-s.position).Magnitude>math.max(3,s.part.Size.Magnitude);s.position=s.part.Position
 if jumped or s.clock~=clock then s.trail:Clear();s.clock=clock end
 -- Short trails only during the actual downswing/follow-through. No idle glow.
 s.trail.Lifetime=heavy and .12 or .09
 s.trail.Enabled=active and not jumped and distance<110 and phase>=.55 and phase<=.73
 if not active then s.trail:Clear()end
 local charge=active and distance<110 and phase>.18 and phase<.64 and math.sin(math.clamp((phase-.18)/.46,0,1)*math.pi) or 0
 local focus=s.a.WorldCFrame
 if charge>0 and s.rootJoint and s.shoulder then
  -- PreSimulation precedes Motor6D application. Compose this frame's pose so
  -- the focus cannot lag behind the staff by a frame on a slow device.
  local j,m=s.rootJoint,s.shoulder
  focus=s.root.CFrame*j.C0*j.Transform*j.C1:Inverse()*m.C0*m.Transform*m.C1:Inverse()*s.socketInArm
 end
 for i,shard in ipairs(s.shards)do
  shard.Transparency=1-charge*.8
  if charge>0 then
   local angle=current*3.8+i*math.pi*2/3
   local radius=s.part.Size.Y*.09
   shard.CFrame=focus*CFrame.new(math.cos(angle)*radius,math.sin(angle)*radius,0)*CFrame.Angles(0,angle,angle)
  end
 end
end
function Weapon.hide(s)
 if not s then return end;s.trail.Enabled=false;s.trail:Clear()
 for _,shard in ipairs(s.shards)do shard.Transparency=1 end
end
function Weapon.destroy(s)
 if not s then return end
 s.folder:Destroy();s.a:Destroy();s.b:Destroy()
end
return Weapon
