-- Native, asset-independent cast. Smooth sculpted faces; torso and limbs stay cuboid.
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local V={}
local function color(hex) return Color3.fromHex(hex) end
function V.create(parent,id,position,options)
 options=options or {};local c=assert(Catalog.byId[id],'Unknown NPC identity: '..tostring(id))
 local m=Instance.new('Model');m.Name=options.name or c.name
 m:SetAttribute('TLTNPC',true);m:SetAttribute('NPCId',id);m:SetAttribute('NPCRegion',c.region);m:SetAttribute('NPCVisualVersion',1)
 m:SetAttribute('NPCNameKey',c.nameKey);m:SetAttribute('NPCRoleKey',c.roleKey)
 m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local skin,coat,hair,accent=color(c.skin),color(c.coat),color(c.hair),color(c.accent)
 local dwarf=c.race=='dwarf';local child=c.race=='child';local ghost=c.race=='spirit'
 local scale=options.scale or (dwarf and .88 or child and .74 or 1)
 local width=dwarf and 1.24 or 1
 local function part(name,size,p,tint,round,container,material,rotation)
  local x=Instance.new('Part');x.Name=name;x.Size=size;x.CFrame=CFrame.new(p)*(rotation or CFrame.identity);x.Color=tint
  x.Material=material or Enum.Material.SmoothPlastic;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;x.CastShadow=not ghost
  x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x:SetAttribute('TLTDecorative',true)
  if round then
   -- Ball Parts render a sphere using their smallest axis; Sphere meshes preserve oval faces.
   local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=x
  end
  if ghost then x.Transparency=.22 end
  x.Parent=container or m;return x
 end
 local function block(name,x,y,z,px,py,pz,tint,mat,rot) return part(name,Vector3.new(x,y,z),Vector3.new(px,py,pz),tint,false,nil,mat,rot) end
 local root=block('ActorRoot',1,1,1,0,0,0,skin);root.Transparency=1;m.PrimaryPart=root
 block('Torso',2.05*width,2.05,1.12,0,3.12,0,coat)
 block('ShirtFront',.62,1.61,.06,0,3.23,-.59,color('D5C8AB'))
 for _,s in ipairs({-1,1}) do
  block('CoatLapel',.22,1.54,.09,s*.42,3.3,-.63,accent,Enum.Material.SmoothPlastic,CFrame.Angles(0,0,s*.12))
  block('ShoulderTrim',.8,.18,1.02,s*1.43*width,4.12,0,accent)
 end
 for i=1,3 do block('CoatButton',.12,.12,.08,0,3.72-i*.35,-.65,accent,Enum.Material.Metal) end
 block('Belt',2.13*width,.22,1.18,0,2.34,0,accent)
 block('Buckle',.32,.32,.12,0,2.34,-.65,accent,Enum.Material.Metal)
 for _,s in ipairs({-1,1}) do
  local x=s*.55*width
  block('UpperLeg',.92*width,.91,1,x,1.8,0,coat:Lerp(Color3.new(),.35))
  block('LowerLeg',.88*width,.82,.92,x,.94,0,coat:Lerp(Color3.new(),.5))
  block('Boot',1.02*width,.55,1.22,x,.3,-.12,color('423D3C'))
  local ax=s*(1.43*width)
  block('UpperArm',.75,1.04,.98,ax,3.58,0,coat,Enum.Material.SmoothPlastic,CFrame.Angles(0,0,s*-.055))
  block('LowerArm',.7,.9,.9,ax+s*.06,2.63,-.04,coat)
  block('Cuff',.77,.2,.96,ax+s*.06,2.26,-.04,accent)
  block('Hand',.65,.52,.72,ax+s*.06,1.94,-.06,skin)
 end
 block('Collar',1.2,.32,1.19,0,4.07,-.02,accent,Enum.Material.Fabric)
 local head=Instance.new('Model');head.Name='FaceRig';head.Parent=m
 local function face(name,size,p,tint,rot) return part(name,size,p,tint,true,head,nil,rot) end
 local function oval(name,x,y,z,px,py,pz,tint,rot) return face(name,Vector3.new(x,y,z),Vector3.new(px,py,pz),tint,rot) end
 local skull=oval('Head',1.7,1.9,1.53,0,5.14,0,skin);head.PrimaryPart=skull
 oval('Jaw',1.39,1.14,1.38,0,4.74,-.08,skin)
 oval('HairCap',1.8,1.13,1.57,0,5.74,.09,hair)
 for _,s in ipairs({-1,1}) do
  oval('Ear',.28,c.race=='elf' and .72 or .42,.3,s*.84,5.06,0,skin,CFrame.Angles(0,0,s*-.35))
  oval('Cheek',.55,.4,.12,s*.49,4.89,-.63,skin)
  oval('EyeWhite',.44,.37,.17,s*.36,5.22,-.734,color('F5EEDD'))
  oval('Iris',.21,.27,.12,s*.36,5.22,-.828,ghost and color('64D1CA') or color('49677B'))
  oval('Pupil',.105,.19,.07,s*.36,5.22,-.886,color('262C35'))
  oval('EyeGlint',.065,.075,.04,s*.36-.03,5.29,-.925,Color3.new(1,1,1))
  oval('Brow',.48,.115,.12,s*.36,5.49,-.77,hair,CFrame.Angles(0,0,s*.08))
 end
 oval('Nose',.26,.32,.24,0,5,-.78,skin:Lerp(accent,.12))
 oval('Smile',.54,.12,.09,0,4.65,-.739,color('895E50'))
 oval('LowerLip',.36,.065,.07,0,4.605,-.746,skin:Lerp(color('E0A08A'),.45))
 if c.hairstyle~='bald' and c.hairstyle~='hood' and c.hairstyle~='hardhat' then
  for i=1,4 do oval('SweptFringe',.56,.42,.4,-.66+(i-1)*.4,5.79-i*.045,-.64,hair,CFrame.Angles(0,0,-.22)) end
 end
 if c.hairstyle=='beard' then
  oval('Beard',1.44,1.07,.67,0,4.43,-.6,hair)
  for _,s in ipairs({-1,1}) do oval('Mustache',.68,.24,.25,s*.29,4.83,-.89,hair,CFrame.Angles(0,0,s*-.15)) end
 elseif c.hairstyle=='braid' or c.hairstyle=='ponytail' then
  for i=1,4 do oval('Braid',.49,.52,.5,.68,5.36-i*.38,.53,hair) end
 elseif c.hairstyle=='bob' then
  for _,s in ipairs({-1,1}) do oval('SideHair',.48,1.31,1.14,s*.73,5.13,.16,hair) end
 elseif c.hairstyle=='curly' or c.hairstyle=='tousled' then
  for i=1,7 do local a=i*math.pi*2/7;oval('Curl',.66,.65,.59,math.cos(a)*.66,5.84,math.sin(a)*.5,hair) end
 elseif c.hairstyle=='bald' then
  skull.Color=skin;local cap=head:FindFirstChild('HairCap');cap.Transparency=1
  for _,s in ipairs({-1,1}) do oval('SideHair',.25,.62,.8,s*.78,5.38,.17,hair) end
 elseif c.hairstyle=='hood' then
  oval('HoodBack',2,2.14,1.6,0,5.25,.35,color('EBE3CE'))
  oval('HoodCrown',1.93,.55,1.58,0,6,.09,color('EBE3CE'))
  for _,s in ipairs({-1,1}) do oval('HoodEdge',.28,1.65,.57,s*.9,5.2,-.38,color('EBE3CE')) end
  block('PriestTabard',1.53,2.08,.12,0,3.1,-.63,color('ADA1C4'))
 elseif c.hairstyle=='hat' or c.hairstyle=='hardhat' then
  oval('HatCrown',2.02,.72,1.85,0,6,.07,c.hairstyle=='hardhat' and accent or coat)
  block('HatBrim',2.62,.15,2.1,0,5.83,-.1,c.hairstyle=='hardhat' and accent or coat)
 end
 if c.hairstyle=='goggles' then for _,s in ipairs({-1,1}) do
  oval('GoggleRim',.69,.59,.25,s*.39,5.92,-.69,accent)
  oval('GoggleLens',.46,.38,.13,s*.39,5.92,-.84,color('77B9C0'))
 end end
 if c.prop=='hammer' then
  block('SmithApron',1.73,1.64,.15,0,2.95,-.66,color('694934'),Enum.Material.Fabric)
  block('HammerHandle',.18,1.65,.18,1.7*width,2.18,-.38,color('825734'))
  block('HammerHead',1.04,.52,.57,1.7*width,3.1,-.38,color('A3A9AD'),Enum.Material.Metal)
 elseif c.prop=='lantern' then
  block('LanternHandle',.1,.7,.1,1.6*width,1.65,-.3,accent)
  block('LanternFrame',.78,.88,.66,1.6*width,1.06,-.3,accent,Enum.Material.Metal)
  block('LanternGlass',.6,.61,.69,1.6*width,1.08,-.3,color('F7DCA0'),Enum.Material.Neon)
 elseif c.prop=='staff' then
  block('HealingStaff',.17,4.6,.17,1.83*width,2.4,-.32,accent,Enum.Material.Wood)
  part('StaffCrystal',Vector3.new(.48,.7,.48),Vector3.new(1.83*width,4.86,-.32),color('A6DBDD'),true,nil,Enum.Material.Neon)
 elseif c.prop=='key' then
  part('KeyRing',Vector3.new(.56,.56,.13),Vector3.new(1.63*width,1.75,-.49),accent,true)
  block('KeyShaft',.12,.8,.12,1.63*width,1.1,-.49,accent,Enum.Material.Metal)
  block('KeyTeeth',.35,.13,.16,1.75*width,.78,-.49,accent)
 elseif c.prop=='book' or c.prop=='map' then
  block('Record',.95,1.19,.32,1.6*width,1.76,-.25,c.prop=='book' and coat:Lerp(accent,.4) or color('E1D2AC'))
  block('RecordBand',1,.16,.36,1.6*width,1.76,-.25,accent)
 elseif c.prop=='bow' then
  for _,s in ipairs({-1,1}) do block('BowLimb',.16,1.65,.21,-1.72*width,2.35+s*.64,-.43,color('8B6843'),Enum.Material.Wood,CFrame.Angles(0,0,s*-.3)) end
  block('BowString',.035,2.9,.035,-1.41*width,2.35,-.43,color('E1D6B5'))
  block('Quiver',.63,1.92,.54,.7,3.5,.91,color('765437'))
 elseif c.prop=='pickaxe' or c.prop=='wrench' or c.prop=='sword' then
  block('ToolHandle',.2,1.76,.2,1.7*width,2.3,-.3,color('806044'))
  block('ToolHead',c.prop=='sword' and .32 or 1.19,c.prop=='sword' and 1.4 or .32,.28,1.7*width,3.3,-.3,color('AEBBC0'),Enum.Material.Metal)
 elseif c.prop=='crate' then block('SupplyPack',1.32,1.23,.75,0,3.13,.92,color('987044'),Enum.Material.Wood)
 elseif c.prop=='cup' then block('SoupCup',.62,.56,.61,1.6*width,2,-.45,color('CCA36B'))
 elseif c.prop=='crown' then
  block('ToyCrownBand',1.66,.2,.2,0,3.2,-.77,accent,Enum.Material.Wood)
  for i=-1,1 do block('ToyCrownPoint',.26,.42,.2,i*.57,3.46,-.77,accent) end
 else
  block('Satchel',.9,1,.44,-1.07*width,2.27,-.48,color('96754D'))
  block('SatchelStrap',.16,1.62,.15,-.55,3.27,-.64,accent,Enum.Material.Fabric,CFrame.Angles(0,0,-.55))
  if c.prop=='herbs' then for i=-1,1 do part('HerbLeaf',Vector3.new(.18,.5,.18),Vector3.new(-1.07*width+i*.18,2.99,-.48),color('96B66B'),true) end end
 end
 if ghost then m:SetAttribute('NPCSpirit',true) end
 if options.label~=false then
  local gui=Instance.new('BillboardGui');gui.Name='NPCLabel';gui.Size=UDim2.fromOffset(220,44);gui.StudsOffset=Vector3.new(0,7.3,0);gui.MaxDistance=55;gui.Parent=root
  local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=c.name..' · '..c.role;t.Font=Enum.Font.GothamBold;t.TextSize=12;t.TextColor3=accent;t.TextStrokeTransparency=.2;t.AutoLocalize=false;t.Parent=gui
 end
 m:ScaleTo(scale);m:PivotTo(CFrame.new(position)*CFrame.Angles(0,options.yaw or 0,0));m.Parent=parent;return m
end
-- Authored aliases preserve quest/escort IDs and labels while gaining the shared art system.
local aliases={['Quartermaster']='liora',['Outpost Storekeeper']='liora',['Quarry Foreman']='fen',['Outpost Scout']='eryn',['Supply Survivor']='tobin',['Wounded Scout']='tobin',['Freed Prisoner']='tobin',['Villager']='tobin',['Goblin Refugee']='pip',['Freed Forest Spirit']='wispkeeper',['Herbalist']='fen',['Outpost Quartermaster']='liora',['Scout Captain']='eryn'}
function V.actor(parent,name,position,spirit)
 local id=aliases[name] or (spirit and 'wispkeeper') or 'tobin'
 for _,c in ipairs(Catalog.characters) do if c.name==name then id=c.id;break end end
 local model=V.create(parent,id,position,{name=name})
 model:SetAttribute('NPCStoryAlias',name)
 if name~=Catalog.byId[id].name then model.PrimaryPart.NPCLabel.TextLabel.Text=name end
 return model
end
return V
