assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local C=require(game.ReplicatedStorage.Shared.NPCCatalog)
local V=require(game.ServerScriptService.Server.World.NPCVisual)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local View=require(Client.NPCMotionPresentation)
local Motion=require(game.ReplicatedStorage.Shared.NPCMotion)
local checks=0
local function check(v,message) checks+=1;assert(v,message) end
local folder=Instance.new('Folder');folder.Name='MotionQA';folder.Parent=workspace
local characters=0
for _,c in ipairs(C.characters) do
 if c.id~='selene' then
  local model=V.create(folder,c.id,Vector3.new(12,5,20),{yaw=.7,label=false})
  local root=model.PrimaryPart;local rootCF=root.CFrame
  check(game.CollectionService:HasTag(model,'TLTAnimatedNPC'),'lobby and story NPCs registered')
  local r=View.bind(model);check(r~=nil,'bind '..c.id)
  local head=model.FaceRig.Head;local hair=model.FaceRig:FindFirstChild('Hair',true)
  local restHead=root.CFrame:ToObjectSpace(head.CFrame)
  local prop=model:FindFirstChild('HammerHandle') or model:FindFirstChild('Record') or model:FindFirstChild('LanternHandle')
  local hand
  for _,p in ipairs(r.parts) do
   if p.part.Name=='Hand' and p.group=='HandR' then hand=p.part end
  end
  local grip=prop and hand.CFrame:ToObjectSpace(prop.CFrame)
  local crown=model:FindFirstChild('ToyCrownBand')
  for i=1,24 do
   model:PivotTo(CFrame.new(12,5,20-i*.12)*CFrame.Angles(0,.7,0))
   r:update(1/60,i/60,root.Position+root.CFrame.LookVector*5+root.CFrame.RightVector*3)
   check((root.Position-Vector3.new(12,5,20-i*.12)).Magnitude<.001,'visuals never move authority root')
   if prop then
    local current=hand.CFrame:ToObjectSpace(prop.CFrame)
    check((current.Position-grip.Position).Magnitude<.0001,'rigid hand prop grip')
   end
   for _,p in ipairs(r.parts) do
    check(p.part.CFrame.Position.Magnitude<100,'finite bounded pose')
    if p.group=='FootL' or p.group=='FootR' then
     local cf=root.CFrame:ToObjectSpace(p.part.CFrame)
     local sole=cf.Position.Y-p.part.Size.Y/2
     check(sole>=-.001 and sole<.3*model:GetScale(),'feet do not penetrate floor')
     check(cf.UpVector:Dot(Vector3.yAxis)>.999,'soles remain level')
    end
    check(p.part.Anchored and not p.part.CanCollide and not p.part.CanQuery,'decorative collision contract')
   end
  end
  if crown then
   for _,p in ipairs(r.parts) do if p.part.Name=='Hand' then
    local localGrip=crown.CFrame:PointToObjectSpace(p.part.Position)
    check(math.abs(math.abs(localGrip.X)-crown.Size.X/2)<p.part.Size.X/2,'crown supported by both hands '..tostring(localGrip)..' size '..tostring(crown.Size))
    check(math.abs(localGrip.Y)<.15*model:GetScale(),'crown at hand height')
   end end
  end
  local moved=root.CFrame:ToObjectSpace(head.CFrame)
  check((moved.Position-restHead.Position).Magnitude>.001,'articulated head moves')
  r:reset()
  for _,p in ipairs(r.parts) do check((p.part.CFrame.Position-(root.CFrame*p.rest).Position).Magnitude<.0001,'cleanup restores rest') end
  model:PivotTo(CFrame.new(1000,5,0));r:update(1/60,5)
  check(r.weight<.001,'teleport never becomes walk velocity')
  model:Destroy();characters+=1
 end
end
-- Reconstruct the same stride at multiple frame rates; feet/props must agree.
for _,hz in ipairs({30,60,144}) do
 local m=V.create(folder,'eryn',Vector3.zero,{label=false});local r=View.bind(m)
 for i=1,hz do m:PivotTo(CFrame.new(0,0,-7*i/hz));r:update(1/hz,1+i/hz) end
 check(math.abs(r.phase-(-r.cf.Position.Z)/(3.2*m:GetScale())*math.pi*2)<.0001,'distance-based gait '..hz)
 check((r.cf.Position-m.PrimaryPart.Position).Magnitude<.5,'bounded visual interpolation lag '..hz)
 local p=Motion.pose(1,r.phase,1,m:GetScale(),1,'bow',0)
 check(p.FootL.UpVector:Dot(Vector3.yAxis)>.999,'frame-rate independent foot orientation')
 m:Destroy()
end
-- Existing TD Selene remains on her separate mesh/animation path.
local selene=V.create(folder,'selene',Vector3.zero,{label=false})
check(not selene:GetAttribute('NPCArticulated') and View.bind(selene)==nil,'no double animation of Selene')
folder:Destroy()
print('NPC_MOTION_NATIVE '..game.HttpService:JSONEncode({pass=true,checks=checks,characters=characters}))
