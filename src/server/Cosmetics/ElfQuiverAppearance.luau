-- Default class visual, derived from TD Archer's leather quiver/rim/harness.
-- No equipment slot, ammunition count, ownership, collision or combat authority.
local Q={version=1}
local NAME='ElfQuiver'
local OWNED='TLTElfQuiverPart'
local function torsoFor(character)return character:FindFirstChild('UpperTorso')or character:FindFirstChild('Torso')end
local function inert(part)
 part.Anchored=false;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
 part:SetAttribute(OWNED,true)
end
function Q.valid(model,character)
 local q=model:FindFirstChild(NAME);local torso=torsoFor(character)
 if not q or not q:IsA('Model')or q:GetAttribute('Version')~=Q.version or not torso then return false end
 local root=q:FindFirstChild('QuiverRoot');local joint=root and root:FindFirstChild('QuiverTorsoJoint')
 if not root or not joint or not joint:IsA('Motor6D')or joint.Part0~=torso or joint.Part1~=root then return false end
 if not root:FindFirstChild('QuiverDrawSocket')then return false end
 local count=0
 for _,p in q:GetChildren()do if p:IsA('BasePart')and p:GetAttribute(OWNED)then
  count+=1;if p.CanCollide or p.CanTouch or p.CanQuery or not p.Massless then return false end
 end end
 if count~=14 then return false end
 for i=1,3 do local arrow=q:FindFirstChild('QuiverArrow'..i);if not arrow or not arrow:IsA('MeshPart')then return false end end
 return true
end
function Q.remove(model)local q=model:FindFirstChild(NAME);if q then q:Destroy()end end
function Q.ensure(model,character)
 if Q.valid(model,character)then return model[NAME]end
 local torso=assert(torsoFor(character),'Elf quiver torso is not ready')
 local source=assert(model:FindFirstChild('NockedArrow'),'Elf quiver requires the reviewed arrow mesh')
 local q=Instance.new('Model');q.Name=NAME;q:SetAttribute('Version',Q.version)
 q:SetAttribute('SourceKey','td:ArcherQuiver:TLT-visual-v1')
 local root=Instance.new('Part');root.Name='QuiverRoot';root.Size=Vector3.new(.12,.12,.12);root.Transparency=1
 inert(root);root.Parent=q;q.PrimaryPart=root
 local sx=math.clamp(torso.Size.X/2,.75,1.35);local sy=math.clamp(torso.Size.Y/2,.75,1.35)
 local offset=CFrame.new(.35*sx,-.30*sy,torso.Size.Z*.5+.35)*CFrame.Angles(0,0,math.rad(-25))
 root.CFrame=torso.CFrame*offset
 local joint=Instance.new('Motor6D');joint.Name='QuiverTorsoJoint';joint.Part0=torso;joint.Part1=root;joint.C0=offset;joint.Parent=root
 local function attach(part,frame)
  inert(part);part.CFrame=root.CFrame*frame;part.Parent=q
  local weld=Instance.new('WeldConstraint');weld.Name='QuiverPartWeld';weld.Part0=root;weld.Part1=part;weld.Parent=part
 end
 local function block(name,size,frame,color)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.Color=color;p.Material=Enum.Material.SmoothPlastic
  attach(p,frame);return p
 end
 local leather=Color3.fromRGB(105,74,43);local trim=Color3.fromRGB(43,82,45)
 -- Four walls and a base leave a real open mouth around the stored shafts.
 block('QuiverFront',Vector3.new(.62,1.9,.08),CFrame.new(0,0,-.25),leather)
 block('QuiverBack',Vector3.new(.62,1.9,.08),CFrame.new(0,0,.25),leather)
 block('QuiverLeft',Vector3.new(.08,1.9,.44),CFrame.new(-.27,0,0),leather)
 block('QuiverRight',Vector3.new(.08,1.9,.44),CFrame.new(.27,0,0),leather)
 block('QuiverBase',Vector3.new(.62,.10,.58),CFrame.new(0,-.94,0),leather)
 for _,side in {-1,1}do
  block('QuiverRimZ'..side,Vector3.new(.68,.14,.10),CFrame.new(0,.90,.27*side),trim)
  block('QuiverRimX'..side,Vector3.new(.10,.14,.48),CFrame.new(.29*side,.90,0),trim)
 end
 local harness=CFrame.new(0,0,-torso.Size.Z*.5-.055)*CFrame.Angles(0,0,math.rad(-25))
 block('QuiverHarness',Vector3.new(.16,torso.Size.Y*1.12,.075),offset:Inverse()*harness,leather)
 for i=1,3 do
  local arrow=source:Clone();arrow.Name='QuiverArrow'..i
  for _,child in arrow:GetChildren()do if not child:IsA('SurfaceAppearance')then child:Destroy()end end
  arrow:SetAttribute('TLTPlayerWeaponPart',nil);arrow.Transparency=0
  local frame=CFrame.new((i-2)*.14,.40+(i-1)*.08,(i%2==0 and -.06 or .06))*CFrame.Angles(-math.pi*.5,0,0)
  attach(arrow,frame)
  if i==1 then
   local socket=Instance.new('Attachment');socket.Name='QuiverDrawSocket'
   -- Same deterministic grip as the carried arrow: hand * (0,0,-.9).
   socket.CFrame=frame*CFrame.new(0,0,.9);socket.Parent=root
  end
 end
 Q.remove(model);q.Parent=model
 assert(Q.valid(model,character),'Elf quiver construction contract')
 return q
end
return Q
