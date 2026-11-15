-- Native still review only: run in the task's empty unpublished QA Studio.
-- First inject KnightWideBaseline* modules using the frozen module block from
-- /tmp/tlt-knight-wide-combo-native.luau. Do not execute this in the user's TD Place.
-- Optional _G.KnightWideCaptureCombo=1/2/3 limits the board to one readable strike.
-- CaptureService exports three RGB-hex images before this script completes.
-- Decode KNIGHT_WIDE_CAPTURE_META / KNIGHT_WIDE_CAPTURE_RGB from the native log.
-- _G.KnightWideCaptureWidth defaults to960px; original aspect ratio is preserved.
-- Cleanup removes this board and restores camera/lighting after every capture.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'empty unpublished QA host only')
assert(not game.RunService:IsRunning(),'prepare frozen captures in edit mode first')
-- The caller disables only the throwaway host's runnable production scripts.
-- Requiring presentation modules is allowed; starting the game bootstrap is not.
local disabledScripts=0
for _,container in {game.ServerScriptService,game.StarterPlayer,game.ReplicatedFirst}do
 for _,node in container:GetDescendants()do
  if node:IsA('Script')or node:IsA('LocalScript')then
   assert(node.Disabled,'disable isolated host bootstrap before capture: '..node:GetFullName())
   disabledScripts+=1
  end
 end
end
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Armor=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local Visual=require(Client.K0SwordVisual)
local BaselineVisual=require(assert(Client:FindFirstChild('KnightWideBaselineVisual'),'inject frozen KnightWideBaseline modules first'))
if _G.KnightWideCaptureCleanup then _G.KnightWideCaptureCleanup()end
local selected=_G.KnightWideCaptureCombo
assert(selected==nil or selected==1 or selected==2 or selected==3,'capture combo must be1/2/3')
local board=Instance.new('Folder');board.Name='KnightWideComboReview';board.Parent=workspace
local camera=workspace.CurrentCamera
local previousCamera={cframe=camera.CFrame,type=camera.CameraType,fov=camera.FieldOfView}
local lighting=game.Lighting
local previousLighting={ClockTime=lighting.ClockTime,Brightness=lighting.Brightness,Ambient=lighting.Ambient,OutdoorAmbient=lighting.OutdoorAmbient}
_G.KnightWideCaptureCleanup=function()
 if board.Parent then board:Destroy()end
 camera.CFrame=previousCamera.cframe;camera.CameraType=previousCamera.type;camera.FieldOfView=previousCamera.fov
 for key,value in previousLighting do lighting[key]=value end
 _G.KnightWideCaptureCleanup=nil
end
lighting.ClockTime=12;lighting.Brightness=2
lighting.Ambient=Color3.fromRGB(150,156,166);lighting.OutdoorAmbient=Color3.fromRGB(150,156,166)
local floor=Instance.new('Part');floor.Name='ReviewFloor';floor.Size=Vector3.new(78,.4,52)
floor.Anchored=true;floor.Position=Vector3.new(0,496.7,13);floor.Color=Color3.fromRGB(43,50,61)
floor.Material=Enum.Material.SmoothPlastic;floor.Parent=board

-- Reuse an existing isolated review template when present. Otherwise use the
-- native R15 rig and the production armor builder, sword and shield sockets.
local templates=game.ServerStorage:FindFirstChild('HeroSkillReviewTemplates')
local stored=templates and templates:FindFirstChild('knight')
local template
if stored and stored:FindFirstChildOfClass('Humanoid')and stored:FindFirstChildOfClass('Humanoid').RigType==Enum.HumanoidRigType.R15 then
 template=stored:Clone()
else
 local description=Instance.new('HumanoidDescription')
 template=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
 description:Destroy()
end
template.Name='KnightCaptureTemplate';template.Parent=board;template:PivotTo(CFrame.new(0,500,100))
template:SetAttribute('K0ClassId','knight')
for suffix,item in {Head='traveler_hood',Body='traveler_coat',Hands='traveler_gloves',Feet='traveler_boots'}do
 if not template:GetAttribute('TLTEquipped'..suffix)then template:SetAttribute('TLTEquipped'..suffix,item)end
end
Armor.sync(template)
for _,node in template:GetDescendants()do
 if node:IsA('LuaSourceContainer')then node:Destroy()
 elseif node:IsA('BasePart')then node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false end
end
local armorEvidence={}
for _,child in template:GetChildren()do
 if child:GetAttribute('TLTArmorAppearance')then table.insert(armorEvidence,child:GetAttribute('ArmorVisualKey'))end
end
local function label(position,text,after,combo)
 local anchor=Instance.new('Part');anchor.Name='PoseLabel';anchor.Size=Vector3.one*.1;anchor.Transparency=1
 anchor.Anchored=true;anchor.CanCollide=false;anchor.Position=position;anchor.Parent=board
 anchor:SetAttribute('ReviewCombo',combo)
 local gui=Instance.new('BillboardGui');gui.Size=UDim2.fromOffset(195,44);gui.AlwaysOnTop=true;gui.Parent=anchor
 local textLabel=Instance.new('TextLabel');textLabel.Size=UDim2.fromScale(1,1);textLabel.BackgroundColor3=Color3.fromRGB(23,29,38)
 textLabel.BackgroundTransparency=.12;textLabel.BorderSizePixel=0;textLabel.Font=Enum.Font.GothamSemibold;textLabel.TextSize=15
 textLabel.TextColor3=after and Color3.fromRGB(120,220,182)or Color3.fromRGB(224,225,231);textLabel.Text=text;textLabel.Parent=gui
end

local report={rig='R15',kind='KNIGHT_WIDE_CAPTURE_READY',snapshots={},armor=armorEvidence,
 disabledProductionScripts=disabledScripts,
 baseline='6bd625ce6f69339726194e26143458c9e13ed536',scope='Frozen production native FK, not live animation or user acceptance',cameras={}}
for combo=1,3 do
 if selected and selected~=combo then continue end
 local row=selected and 0 or combo-1
 local d=Config.BasicAttackProfiles.knight.attacks[combo]
 local samples={{'Loaded',d.windup*.45},{'Contact',d.windup+(d.hitDelay or 0)},
  {'Follow',combo==3 and d.windup+.112 or d.windup+d.active+d.recovery*.15}}
 for version=1,2 do for phase,sample in samples do
  local character=template:Clone();character.Name=(version==1 and'Before'or'After')..'_'..combo..'_'..sample[1]
  character:SetAttribute('ReviewCombo',combo)
  character.Parent=board;character:PivotTo(CFrame.new(0,500,100))
  local appearance=character:FindFirstChild('TLT_K0_KnightAppearance')
  if not appearance then appearance=Instance.new('Model');appearance.Name='TLT_K0_KnightAppearance';appearance.Parent=character end
  local weapon=assert(Appearance.attachInto(appearance,character,'knight'))
  assert(Appearance.attachShieldInto(appearance,character))
  character:SetAttribute('K0State','Attack');character:SetAttribute('K0AttackKind','Basic')
  character:SetAttribute('K0SkillId',nil);character:SetAttribute('K0Combo',combo)
  character:SetAttribute('K0BasicAttackRate',1);character:SetAttribute('K0AttackStartedAt',100)
  local humanoid=character:FindFirstChildOfClass('Humanoid')
  humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
  local renderer=version==1 and BaselineVisual or Visual
  renderer.renderArms(character,1/60,100+sample[2]);renderer.renderCharacter(character,1/60,100+sample[2])
  -- Capture the graph before assigning any CFrames. WeldConstraint rest
  -- offsets include real armor and all original blade/shield mesh pieces.
  local links={}
  local function link(a,b,offset)
   links[a]=links[a]or{};links[b]=links[b]or{}
   table.insert(links[a],{part=b,offset=offset});table.insert(links[b],{part=a,offset=offset:Inverse()})
  end
  local constraints={}
  for _,node in character:GetDescendants()do
   if(node:IsA('Motor6D')or node:IsA('AnimationConstraint')or node:IsA('Weld'))and node.Part0 and node.Part1 then
    local transform=(node:IsA('Motor6D')or node:IsA('AnimationConstraint'))and node.Transform or CFrame.identity
    link(node.Part0,node.Part1,node.C0*transform*node.C1:Inverse());table.insert(constraints,node)
   elseif node:IsA('WeldConstraint')and node.Part0 and node.Part1 then
    link(node.Part0,node.Part1,node.Part0.CFrame:ToObjectSpace(node.Part1.CFrame));table.insert(constraints,node)
   end
  end
  local root=character.HumanoidRootPart
  local frames={[root]=root.CFrame};local queue={root};local cursor=1
  while cursor<=#queue do
   local part=queue[cursor];cursor+=1
   for _,edge in links[part]or{}do
    if not frames[edge.part]then frames[edge.part]=frames[part]*edge.offset;table.insert(queue,edge.part)end
   end
  end
  local tip=root.CFrame:PointToObjectSpace(frames[weapon.grip]:PointToWorldSpace(weapon.tip.Position))
  for _,node in character:GetDescendants()do
   if node:IsA('BasePart')then node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false
    if frames[node]then node.CFrame=frames[node]end
   elseif node:IsA('Trail')or node:IsA('ParticleEmitter')then node.Enabled=false
   elseif node:IsA('Animator')or node:IsA('IKControl')then node:Destroy()end
  end
  for _,constraint in constraints do constraint:Destroy()end
  local column=(version-1)*3+phase
  -- From the front (-Z looking+Z), screen-right points toward negative world X.
  -- Reverse world placement so the PNG reads Before Loaded/Contact/Follow,
  -- then After Loaded/Contact/Follow, exactly as its metadata declares.
  local location=Vector3.new((3.5-column)*11,500,row*14)
  character:PivotTo(CFrame.new(location))
  label(location+Vector3.new(0,6.4,0),(version==1 and'BEFORE'or'AFTER')..' | '..combo..' '..sample[1],version==2,combo)
  table.insert(report.snapshots,{version=version==1 and'Before'or'After',combo=combo,phase=sample[1],age=sample[2],
   swordSource=appearance:GetAttribute('WeaponSourceKey'),shieldSource=appearance:GetAttribute('ShieldSourceKey'),
   tip={tip.X,tip.Y,tip.Z},evaluatedParts=#queue})
 end end
 local focus=Vector3.new(0,501.6,row*14)
 table.insert(report.cameras,{combo=combo,camera_position={focus.X+4,focus.Y+20,focus.Z-57},look_at_position={focus.X,focus.Y,focus.Z}})
 task.wait()
end
template:Destroy()
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=48
local center=Vector3.new(0,501.6,selected and 0 or 14)
local position=center+Vector3.new(4,selected and 20 or 38,selected and-57 or-76)
camera.CFrame=CFrame.lookAt(position,center)
report.camera_position={position.X,position.Y,position.Z};report.look_at_position={center.X,center.Y,center.Z}
task.wait(.2)
print('KNIGHT_WIDE_CAPTURE_READY '..game.HttpService:JSONEncode(report))

-- Freeze native FK before running the scheduler. No combat, Player, saving or
-- live input is involved; Run enables the same screenshot route as VFX review.
if not game.RunService:IsRunning()then game.RunService:Run()end
local originalTransparency={}
for _,child in board:GetChildren()do
 if child:GetAttribute('ReviewCombo')then for _,node in child:GetDescendants()do
  if node:IsA('BasePart')then originalTransparency[node]=node.Transparency end
 end
 if child:IsA('BasePart')then originalTransparency[child]=child.Transparency end
 end
end
local capturedImages=0
for _,view in report.cameras do
 for _,child in board:GetChildren()do
  local combo=child:GetAttribute('ReviewCombo')
  if combo then
   for _,node in child:GetDescendants()do
    if node:IsA('BasePart')then node.Transparency=combo==view.combo and originalTransparency[node]or 1
    elseif node:IsA('BillboardGui')then node.Enabled=combo==view.combo end
   end
   if child:IsA('BasePart')then child.Transparency=combo==view.combo and originalTransparency[child]or 1 end
  end
 end
 local eye=Vector3.new(unpack(view.camera_position));local focus=Vector3.new(unpack(view.look_at_position))
 camera.CFrame=CFrame.lookAt(eye,focus)
 task.wait(.25)
 local completed=false;local captureError
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local image=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pixels=image:ReadPixelsBuffer(Vector2.zero,image.Size)
   local width=math.min(_G.KnightWideCaptureWidth or 960,image.Size.X)
   local height=math.floor(image.Size.Y/image.Size.X*width)
   print('KNIGHT_WIDE_CAPTURE_META '..game.HttpService:JSONEncode({index=view.combo,width=width,height=height,
    sourceWidth=image.Size.X,sourceHeight=image.Size.Y,rig='R15',poses={'Loaded','Contact','Follow'},
    order={'Before Loaded','Before Contact','Before Follow','After Loaded','After Contact','After Follow'},
    baseline=report.baseline,scope=report.scope,camera=view}))
   local hex={}
   for y=0,height-1 do for x=0,width-1 do
    local offset=(math.floor(y/height*image.Size.Y)*image.Size.X+math.floor(x/width*image.Size.X))*4
    hex[#hex+1]=string.format('%02x%02x%02x',buffer.readu8(pixels,offset),buffer.readu8(pixels,offset+1),buffer.readu8(pixels,offset+2))
   end end
   local data=table.concat(hex)
   for i=1,#data,20000 do
    print('KNIGHT_WIDE_CAPTURE_RGB '..view.combo..' '..data:sub(i,i+19999))
    -- run-in-roblox drains Output on scheduler ticks. Yield each20KB chunk
    -- so a full image never exceeds the plugin's1MB HTTP request limit.
    task.wait()
   end
   image:Destroy();capturedImages+=1
  end)
  if not ok then captureError=tostring(err);print('KNIGHT_WIDE_CAPTURE_ERROR '..captureError)end
  completed=true
 end)
 local deadline=os.clock()+45
 while not completed and os.clock()<deadline do task.wait(.05)end
 assert(completed,'native knight screenshot timeout')
 assert(not captureError,captureError)
end
_G.KnightWideCaptureCleanup()
print('KNIGHT_WIDE_CAPTURE_COMPLETE '..game.HttpService:JSONEncode({images=capturedImages,cleanup=true}))
