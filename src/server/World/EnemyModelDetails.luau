-- Derived solid geometry and sockets on the existing TD originals. No asset IDs or collision changes.
local Profiles=require(game:GetService('ReplicatedStorage').Shared.EnemyPatterns)
local BladeRigs = require(game.ReplicatedStorage.Shared.BladeMonsterRigs)
local Details={version=2}
local colors={arcane=Color3.fromRGB(178,105,255),frost=Color3.fromRGB(115,227,253),fire=Color3.fromRGB(255,136,56),venom=Color3.fromRGB(158,208,74),web=Color3.fromRGB(206,174,234),soul=Color3.fromRGB(96,218,170),shadow=Color3.fromRGB(181,110,235),physical=Color3.fromRGB(185,144,77)}
local casters={Shaman=true,KingShaman=true,IceElf=true,QueenIceElf=true,VolcanoShaman=true,KingVolcanoShaman=true,Lich=true,LichSovereign=true}
local armored={Warlord=true,EnragedWarlord=true,KingOgre=true,IceTrollKing=true,KingIceBear=true,KingIceGolem=true,AncientGlacierKing=true,MagmaGolem=true,InfernoOverlord=true,CalderaTitan=true,DeathKnight=true,DreadCommander=true,Veyr=true,SkeletonKnight=true}
function Details.attach(rig,kind,visual,footOffset,height)
 local profile=Profiles.get(kind);if not profile or not visual then return end
 local root=rig:FindFirstChild('HumanoidRootPart');local torso=rig:FindFirstChild('Torso');if not root or not torso then return end
 local old=visual:FindFirstChild('CombatDetails');if old then return old end
 local folder=Instance.new('Folder');folder.Name='CombatDetails';folder:SetAttribute('Version',Details.version)
 local feet=root.CFrame*CFrame.new(0,-footOffset,0);local color=colors[profile.element]
 local function piece(name,class,size,cf,material,anchor)
  local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
  local weld=Instance.new('WeldConstraint');weld.Name='CombatDetailWeld';weld.Part0=anchor or torso;weld.Part1=p;weld.Parent=p;p.Parent=folder;return p
 end
 if armored[kind]then
  for _,side in ipairs({-1,1})do
   local shoulder=piece('LayeredPauldron','WedgePart',Vector3.new(.17,.10,.18)*height,feet*CFrame.new(side*height*.23,height*.68,0)*CFrame.Angles(0,side*math.pi/2,side*.1))
   shoulder.Color=Color3.fromRGB(76,81,87)
   piece('ArmorRidge','WedgePart',Vector3.new(.10,.045,.15)*height,feet*CFrame.new(side*height*.25,height*.74,0)*CFrame.Angles(0,side*math.pi/2,0),Enum.Material.SmoothPlastic)
  end
  if kind=='Veyr' or kind=='DreadCommander'then
   piece('ThroneCrest','WedgePart',Vector3.new(.11,.18,.045)*height,feet*CFrame.new(0,height*.63,-height*.17))
  end
 end
 if not BladeRigs[kind] and (profile.boss and profile.element~='physical' or casters[kind]) then
  local staff=visual:FindFirstChild('Staff')or visual:FindFirstChild(rig:GetAttribute('TdWeaponPart')or 'ArmR')
  if staff and staff:IsA('BasePart')then
   local tip=staff.CFrame*CFrame.new(0,staff.Size.Y*.43,0)
   local focus=piece('SpellFocus','Part',Vector3.new(.07,.10,.07)*height,tip,Enum.Material.Glass,staff)
   focus.Shape=Enum.PartType.Ball;focus.Transparency=.12
   local core=piece('SpellFocusCore','Part',Vector3.new(.034,.061,.034)*height,tip,Enum.Material.Neon,staff)
   core.Shape=Enum.PartType.Ball;core.CastShadow=false
   for _,side in ipairs({-1,1})do piece('FocusProng','WedgePart',Vector3.new(.025,.12,.04)*height,tip*CFrame.new(side*height*.055,-height*.015,0)*CFrame.Angles(0,0,-side*.25),Enum.Material.Metal,staff)end
  end
 end
 local cast=Instance.new('Attachment');cast.Name='EnemyCastSocket';cast.Position=Vector3.new(height*.18,height*.15,-height*.22);cast.Parent=torso
 rig:SetAttribute('EnemyModelDetailVersion',Details.version)
 folder.Parent=visual;return folder
end
return Details
