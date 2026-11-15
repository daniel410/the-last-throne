-- Frozen production native guard geometry only; not live input or user acceptance.
-- Prepared by tools/prepare-natural-block-capture.py. Never run in the user's TD Place.
-- RGB chunks yield so run-in-roblox's Output transport stays below its1MB request limit.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated empty host required')
assert(not game.RunService:IsRunning(),'prepare native FK in edit mode first')
for _,container in {game.ServerScriptService,game.StarterPlayer,game.ReplicatedFirst}do
 for _,node in container:GetDescendants()do
  if node:IsA('Script')or node:IsA('LocalScript')then assert(node.Disabled,'disable host bootstrap')end
 end
end
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Baseline=require(Client.NaturalBlockBaselineVisual)
local Candidate=_G.NaturalBlockBaselineOnly and Baseline or require(Client.K0SwordVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Armor=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local rigName=_G.NaturalBlockCaptureRig or'R15'
local rig=rigName=='R6'and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
local camera=workspace.CurrentCamera
local oldCamera={CFrame=camera.CFrame,CameraType=camera.CameraType,FieldOfView=camera.FieldOfView}
local lighting=game.Lighting
local oldLighting={ClockTime=lighting.ClockTime,Brightness=lighting.Brightness,Ambient=lighting.Ambient,OutdoorAmbient=lighting.OutdoorAmbient}
lighting.ClockTime=12;lighting.Brightness=2
lighting.Ambient=Color3.fromRGB(165,170,180);lighting.OutdoorAmbient=lighting.Ambient
local board=Instance.new('Folder');board.Name='NaturalBlockReview';board.Parent=workspace
local floor=Instance.new('Part');floor.Name='ReviewFloor';floor.Size=Vector3.new(56,.4,48)
floor.Position=Vector3.new(0,496.8,12);floor.Anchored=true;floor.Color=Color3.fromRGB(43,50,61)
floor.Material=Enum.Material.SmoothPlastic;floor.Parent=board
local report={baseline='eda125e7b447502422a5b552df8d666fa2e280dc',baselineOnly=_G.NaturalBlockBaselineOnly==true,
 rig=rigName,snapshots={},cameras={},scope='Frozen native production Block FK, not live input/timing or visual acceptance'}

local function linksFor(character)
 local links={};local constraints={}
 local function link(a,b,offset)
  links[a]=links[a]or{};links[b]=links[b]or{}
  table.insert(links[a],{part=b,offset=offset});table.insert(links[b],{part=a,offset=offset:Inverse()})
 end
 for _,node in character:GetDescendants()do
  if(node:IsA('Motor6D')or node:IsA('AnimationConstraint')or node:IsA('Weld'))and node.Part0 and node.Part1 then
   local transform=(node:IsA('Motor6D')or node:IsA('AnimationConstraint'))and node.Transform or CFrame.identity
   link(node.Part0,node.Part1,node.C0*transform*node.C1:Inverse());table.insert(constraints,node)
  elseif node:IsA('WeldConstraint')and node.Part0 and node.Part1 then
   link(node.Part0,node.Part1,node.Part0.CFrame:ToObjectSpace(node.Part1.CFrame));table.insert(constraints,node)
  end
 end
 return links,constraints
end
local function evaluate(character)
 local links,constraints=linksFor(character)
 local root=character.HumanoidRootPart
 local frames={[root]=root.CFrame};local queue={root};local cursor=1
 while cursor<=#queue do
  local p=queue[cursor];cursor+=1
  for _,edge in links[p]or{}do
   if not frames[edge.part]then frames[edge.part]=frames[p]*edge.offset;table.insert(queue,edge.part)end
  end
 end
 for part,cf in frames do part.CFrame=cf end
 return frames,constraints,#queue
end

for index,classId in {'elf','dwarf','mage'}do
 if _G.NaturalBlockCaptureClass and _G.NaturalBlockCaptureClass~=classId then continue end
 local row=_G.NaturalBlockCaptureClass and 0 or index-1
 local templates=game.ServerStorage:FindFirstChild('HeroSkillReviewTemplates')
 local stored=templates and templates:FindFirstChild(classId)
 local template
 if stored and stored:FindFirstChildOfClass('Humanoid')and stored:FindFirstChildOfClass('Humanoid').RigType==rig then template=stored:Clone()
 else
  local description=Instance.new('HumanoidDescription')
  template=game.Players:CreateHumanoidModelFromDescriptionAsync(description,rig);description:Destroy()
 end
 template.Name='BlockCaptureTemplate';template.Parent=board;template:PivotTo(CFrame.new(0,500,100))
 template:SetAttribute('K0ClassId',classId)
 for suffix,item in {Head=classId=='mage'and'mage_traveler_hat'or'traveler_hood',Body=classId=='mage'and'mage_traveler_coat'or'traveler_coat',Hands='traveler_gloves',Feet='traveler_boots'}do
  if not template:GetAttribute('TLTEquipped'..suffix)then template:SetAttribute('TLTEquipped'..suffix,item)end
 end
 Armor.sync(template)
 for _,node in template:GetDescendants()do
  if node:IsA('LuaSourceContainer')then node:Destroy()
  elseif node:IsA('BasePart')then node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false end
 end
 for version=1,2 do for view=1,2 do
  local character=template:Clone();character.Name=(version==1 and'Before'or'After')..'_'..classId..'_'..view
  character.Parent=board;character:PivotTo(CFrame.new(0,500,100));character:SetAttribute('ReviewClass',classId)
  local model=Instance.new('Model');model.Name='BlockCaptureAppearance';model.Parent=character
  local weapon=assert(Appearance.attachInto(model,character,classId))
  character:SetAttribute('K0ClassId',classId);character:SetAttribute('K0State','Block')
  character:SetAttribute('K0AttackKind','Basic');character:SetAttribute('K0AttackPhase','None')
  character:SetAttribute('K0SkillId',nil);character:SetAttribute('K0AttackStartedAt',nil)
  character:SetAttribute('K0GuardStartedAt',100);character:SetAttribute('K0StateStartedAt',100)
  local humanoid=character:FindFirstChildOfClass('Humanoid');humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
  local renderer=version==1 and Baseline or Candidate
  -- The old shoulder tracker reads live part CFrames. Feed every deterministic
  -- FK result into the next60Hz sample, matching native constraint evaluation.
  for frame=0,119 do
   renderer.renderArms(character,1/60,100+frame/60)
   renderer.renderCharacter(character,1/60,100+frame/60)
   evaluate(character)
  end
  local frames,constraints,count=evaluate(character)
  local root=character.HumanoidRootPart
  local grip=root.CFrame:ToObjectSpace(frames[weapon.grip])
  local freeSide=classId=='elf'and'Right'or'Left'
  local free=character:FindFirstChild(freeSide..(rigName=='R15'and'Hand'or' Arm'))
  local target=weapon.grip:FindFirstChild('K0BlockHandTarget')
  local contact=rigName=='R15'and free.Position or free.CFrame:PointToWorldSpace(Vector3.new(0,-free.Size.Y*.5,0))
  local distance=target and(target.WorldPosition-contact).Magnitude
  for _,node in character:GetDescendants()do
   if node:IsA('BasePart')then node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false
   elseif node:IsA('Trail')or node:IsA('ParticleEmitter')then node.Enabled=false
   elseif node:IsA('Animator')or node:IsA('IKControl')then node:Destroy()end
  end
  for _,constraint in constraints do constraint:Destroy()end
  local column=(version-1)*2+view
  -- Front-facing camera looks+Z: screen-right is world-X.
  local location=Vector3.new((2.5-column)*11,500,row*16)
  character:PivotTo(CFrame.new(location)*CFrame.Angles(0,view==2 and math.rad(70)or 0,0))
  table.insert(report.snapshots,{class=classId,version=version==1 and'Before'or'After',view=view==1 and'Front'or'Side',
   grip={grip:GetComponents()},freeHandDistance=distance,source=weapon.sourceKey,evaluatedParts=count})
 end end
 template:Destroy()
 local focus=Vector3.new(0,500.8,row*16)
 table.insert(report.cameras,{index=index,class=classId,camera_position={focus.X,focus.Y+6,focus.Z-38},look_at_position={focus.X,focus.Y,focus.Z}})
 task.wait()
end
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=43
print('NATURAL_BLOCK_CAPTURE_READY '..game.HttpService:JSONEncode(report))
if not game.RunService:IsRunning()then game.RunService:Run()end
local transparency={}
local enabled={}
for _,child in board:GetChildren()do if child:GetAttribute('ReviewClass')then
 for _,node in child:GetDescendants()do
  if node:IsA('BasePart')then transparency[node]=node.Transparency
  elseif node:IsA('Beam')or node:IsA('Trail')then enabled[node]=node.Enabled end
 end
end end
local captured=0
for _,view in report.cameras do
 for _,child in board:GetChildren()do if child:GetAttribute('ReviewClass')then
  local visible=child:GetAttribute('ReviewClass')==view.class
  for _,node in child:GetDescendants()do
   if node:IsA('BasePart')then node.Transparency=visible and transparency[node]or 1
   elseif node:IsA('Beam')or node:IsA('Trail')then node.Enabled=visible and enabled[node]or false end
  end
 end end
 camera.CFrame=CFrame.lookAt(Vector3.new(unpack(view.camera_position)),Vector3.new(unpack(view.look_at_position)))
 task.wait(.3)
 local complete=false;local captureError
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local image=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pixels=image:ReadPixelsBuffer(Vector2.zero,image.Size)
   local width=math.min(_G.NaturalBlockCaptureWidth or 1280,image.Size.X)
   local height=math.floor(image.Size.Y/image.Size.X*width)
   print('NATURAL_BLOCK_CAPTURE_META '..game.HttpService:JSONEncode({index=view.index,class=view.class,rig=rigName,width=width,height=height,
    sourceWidth=image.Size.X,sourceHeight=image.Size.Y,order={'Before Front','Before Side','After Front','After Side'},baseline=report.baseline,
    baselineOnly=report.baselineOnly,scope=report.scope,camera=view}))
   local hex={}
   for y=0,height-1 do for x=0,width-1 do
    local offset=(math.floor(y/height*image.Size.Y)*image.Size.X+math.floor(x/width*image.Size.X))*4
    hex[#hex+1]=string.format('%02x%02x%02x',buffer.readu8(pixels,offset),buffer.readu8(pixels,offset+1),buffer.readu8(pixels,offset+2))
   end end
   local data=table.concat(hex)
   for i=1,#data,20000 do print('NATURAL_BLOCK_CAPTURE_RGB '..view.index..' '..data:sub(i,i+19999));task.wait()end
   image:Destroy();captured+=1
  end)
  if not ok then captureError=tostring(err);print('NATURAL_BLOCK_CAPTURE_ERROR '..captureError)end
  complete=true
 end)
 local deadline=os.clock()+45;while not complete and os.clock()<deadline do task.wait(.05)end
 assert(complete and not captureError,captureError or'native block capture timeout')
end
board:Destroy()
for key,value in oldCamera do camera[key]=value end
for key,value in oldLighting do lighting[key]=value end
print('NATURAL_BLOCK_CAPTURE_COMPLETE '..game.HttpService:JSONEncode({images=captured,cleanup=true}))
