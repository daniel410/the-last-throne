-- Replaceable native block models requested by the user, 2026-11-03.
-- This is prototype geometry, not the final approved concept/mesh implementation.
local G={}
local types={Webling='spider',Silkweaver='spider',Barkstalker='ent',Gloambat='bat',VenomcoilCentipede='centipede',AncientHollowbark='ent',VenomcoilKing='centipede',WidowQueen='spider'}
local heights={Webling=3.8,Silkweaver=4.5,Barkstalker=6,Gloambat=4,VenomcoilCentipede=4.5,AncientHollowbark=9,VenomcoilKing=7,WidowQueen=8}
function G.supports(kind)return types[kind]~=nil end
function G.describe(kind)return {template=kind,targetHeight=heights[kind],prototype=true,version=2}end
function G.attach(rig,kind,footOffset,multiplier)
 local root=rig.HumanoidRootPart;local height=heights[kind]*(multiplier or 1);local u=height/6
 local origin=root.CFrame*CFrame.new(0,-footOffset,0)
 local model=Instance.new('Model');model.Name='TdMonsterVisual';model:SetAttribute('PrototypeGeometry',true)
 local bodyColor=types[kind]=='ent' and Color3.fromRGB(97,79,52) or types[kind]=='centipede' and Color3.fromRGB(107,42,71) or Color3.fromRGB(75,48,111)
 local eyeColor=types[kind]=='ent' and Color3.fromRGB(255,188,59) or Color3.fromRGB(220,99,255)
 local body
 local function piece(name,size,cf,color,anchor,animated,side,index)
  local tapered=name=='Fang' or name=='CrownPoint' or name=='Ear' or name=='Wing' or name=='WingTip' or name=='RootToe'
  local p=Instance.new(tapered and 'WedgePart' or 'Part');p.Name=name;
  if p:IsA('Part')and(name=='Body' or name=='HeadPlate' or name:match('^Segment')or name=='Eye')then p.Shape=Enum.PartType.Ball end
  p.Size=size*u;p.CFrame=origin*cf;p.Color=color or bodyColor;p.Material=Enum.Material.Slate;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=model
  if types[kind]=='ent' and name=='Body'then p.Shape=Enum.PartType.Cylinder;p.Size=Vector3.new(size.Y,size.X,size.Z)*u;p.CFrame=origin*cf*CFrame.Angles(0,0,math.pi/2)end
  local j=Instance.new(animated and 'Motor6D' or 'WeldConstraint');j.Name=animated and 'GloamLimb' or 'PrototypeWeld';j.Part0=anchor or rig.Torso;j.Part1=p
  if animated then j.C0=j.Part0.CFrame:ToObjectSpace(p.CFrame);j.C1=CFrame.identity;j:SetAttribute('GloamSide',side);j:SetAttribute('GloamIndex',index);j:SetAttribute('GloamShape',types[kind])end
  j.Parent=p;return p
 end
 local function cf(x,y,z)return CFrame.new(x*u,y*u,z*u)end
 if types[kind]=='ent' then
  body=piece('Body',Vector3.new(3.4,3.6,2),cf(0,3.7,0))
  piece('Brow',Vector3.new(3.2,.6,2.4),cf(0,5.4,-.2))
  for _,side in ipairs({-1,1})do
   piece('BranchArm',Vector3.new(1.3,3,1.3),cf(side*2.2,3.4,0),nil,rig.Torso,true,side,1)
   piece('RootFoot',Vector3.new(1.5,2,2),cf(side*.9,1,0),nil,rig.Torso,true,side,2)
   local leaves=piece('CrownLeaves',Vector3.new(2.4,1.1,2),cf(side*1.7,5.9,.3),Color3.fromRGB(72,107,64));leaves.Shape=Enum.PartType.Ball
   piece('RootToe',Vector3.new(.7,.5,2.6),cf(side*.9,.3,-.4),Color3.fromRGB(77,62,42))
  end
 elseif types[kind]=='bat' then
  body=piece('Body',Vector3.new(1.5,2,1.3),cf(0,3,0))
  for _,side in ipairs({-1,1})do
   piece('Wing',Vector3.new(3.3,.35,2.2),cf(side*2.1,3,.2)*CFrame.Angles(0,0,side*.15),nil,rig.Torso,true,side,1)
   piece('Ear',Vector3.new(.45,1.2,.6),cf(side*.5,4.5,0))
   piece('WingTip',Vector3.new(1.2,.35,2.6),cf(side*3.5,2.7,.4)*CFrame.Angles(0,0,side*.25),Color3.fromRGB(107,66,137),rig.Torso,true,side,2)
  end
 elseif types[kind]=='centipede' then
  body=piece('Body',Vector3.new(2.2,1.5,2),cf(0,2,-2))
  for index=1,10 do
   local z=-2+(index-1)*.85;piece('Segment'..index,Vector3.new(2.2-(index-1)*.075,1.2,.95),cf(0,1.8,z))
   for _,side in ipairs({-1,1})do piece('Leg',Vector3.new(1.5,1.3,.35),cf(side*1.6,.9,z)*CFrame.Angles(0,0,side*.6),nil,rig.Torso,true,side,index)end
  end
 else
  body=piece('Body',Vector3.new(3.3,2.3,4),cf(0,2.6,.8))
  piece('HeadPlate',Vector3.new(2.3,1.7,1.5),cf(0,2.4,-1.6))
  local abdomen=piece('Abdomen',Vector3.new(3.1,2.6,3.6),cf(0,2.7,2.1),Color3.fromRGB(98,57,128));abdomen.Shape=Enum.PartType.Ball
  for _,side in ipairs({-1,1})do local node=piece('Spinneret',Vector3.new(.55,.65,.8),cf(side*.65,2.5,3.65),Color3.fromRGB(155,119,179));node.Shape=Enum.PartType.Ball end
  for index=1,4 do for _,side in ipairs({-1,1})do
   local z=(index-2.5)*1.05
   piece('UpperLeg',Vector3.new(2.1,.6,.6),cf(side*2.3,2,z)*CFrame.Angles(0,0,side*.4),nil,rig.Torso,true,side,index)
   piece('LowerLeg',Vector3.new(.5,2.4,.5),cf(side*3.2,1,z)*CFrame.Angles(0,0,side*.22),nil,rig.Torso,true,side,index)
  end end
 end
 local eyeY=types[kind]=='ent' and 4.65 or types[kind]=='bat' and 3.4 or types[kind]=='centipede' and 2.2 or 2.7
 local eyeZ=types[kind]=='ent' and -1.1 or types[kind]=='bat' and -.7 or types[kind]=='centipede' and -3.05 or -2.4
 for _,side in ipairs({-1,1})do
  local eye=piece('Eye',Vector3.new(.35,.38,.18),cf(side*.55,eyeY,eyeZ),eyeColor);eye.Material=Enum.Material.Neon
  if types[kind]~='ent'then piece('Fang',Vector3.new(.3,.9,.35),cf(side*.5,eyeY-.65,eyeZ),Color3.fromRGB(234,219,179))end
 end
 if kind=='WidowQueen' or kind=='VenomcoilKing'then for i=-1,1 do piece('CrownPoint',Vector3.new(.4,1.3,.4),cf(i*.7,eyeY+1.25,eyeZ+.3),Color3.fromRGB(212,164,83))end end
 for _,p in ipairs(rig:GetChildren())do if p:IsA('BasePart')then p.Transparency=1 end end
 model.PrimaryPart=body;model.Parent=rig
 rig:SetAttribute('TdMonsterTemplate',kind);rig:SetAttribute('TdMonsterTargetHeight',height);rig:SetAttribute('GloamwoodPrototypeVersion',2)
 return model
end
return G
