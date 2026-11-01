-- Isolated engine fixture: real source/meshes/raycast/effects, no live saves.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated unpublished fixture only')
local report={checks=0,failures={}}
local function check(ok,label) report.checks+=1;assert(ok,label) end
local folder=Instance.new('Folder');folder.Name='SeleneMotionQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local Visual=require(game.ServerScriptService.Server.World.SeleneVisual)
 local Follow=require(game.ServerScriptService.Server.Story.SeleneFollow)
 local Presentation=require(game.StarterPlayer.StarterPlayerScripts.Client.SelenePresentation)
 local floor=Instance.new('Part');floor.Size=Vector3.new(180,2,180);floor.Position=Vector3.new(0,499,0);floor.Anchored=true;floor.Parent=folder
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.CFrame=CFrame.new(0,503,0);root.Anchored=true;root.CanCollide=false;root.Parent=character
 local h=Instance.new('Humanoid');h.HipHeight=2;h.Health=40;h.Parent=character
 local enemies=Instance.new('Folder');enemies.Parent=folder
 local model=Visual.create(folder,Vector3.new(0,500,10),'SeleneMotionQA',{label=false})
 local params=Follow.params(model,character,enemies)
 local actor={model=model}
 local assets={}
 for _,p in ipairs(model:GetDescendants()) do if p:IsA('MeshPart') then table.insert(assets,p) end end
 game.ContentProvider:PreloadAsync(assets,function(id,status) check(status==Enum.AssetFetchStatus.Success,'local mesh/texture preload: '..id) end)
 local meshes=0
 for _,p in ipairs(model:GetDescendants()) do if p:IsA('MeshPart') then
  meshes+=1;check(typeof(p:GetAttribute('SeleneRest'))=='CFrame','every mesh has stable rest space')
  local source=game.ServerStorage.SeleneArticulatedModels.nun:FindFirstChild(p.Name,true)
  check(source and source.MeshId==p.MeshId and source.TextureID==p.TextureID,'pinned TD appearance remains exact')
 end end
 check(meshes==6,'TD-derived six-piece articulated silhouette')
 check(model.ArmL:GetAttribute('SeleneRest').Position.X<0,'canonical left sleeve remains on original side')
 check(model.Head:GetAttribute('SeleneRest').LookVector.Z>.99,'segmented hood retains corrected front orientation')
 root.Position+=Vector3.new(28,0,0)
 local previous=model.PrimaryPart.Position;local maximumStep=0
 for i=1,100 do
  Follow.step(actor,root,.05,params,false)
  local pos=model.PrimaryPart.Position
  maximumStep=math.max(maximumStep,(pos-previous).Magnitude)
  check(math.abs(pos.Y-500)<.01,'feet follow actual ground')
  check((pos-previous).Magnitude<=28*.05+.001,'no position teleport')
  previous=pos
 end
 check((model.PrimaryPart.Position-root.Position).Magnitude<12,'reaches support formation')
 check(maximumStep>0.3,'accelerates to follow speed')
 local stop=model.PrimaryPart.Position
 for i=1,40 do root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,i*.2,0);Follow.step(actor,root,.05,params,false) end
 check((model.PrimaryPart.Position-stop).Magnitude<.1,'stationary owner turning cannot orbit follower')
 root.Position+=Vector3.new(12,0,0);stop=model.PrimaryPart.Position
 Follow.step(actor,root,.2,params,true)
 check((model.PrimaryPart.Position-stop).Magnitude<.001,'danger/casting holds before any movement')
 local wall=Instance.new('Part');wall.Size=Vector3.new(2,12,180);wall.CFrame=CFrame.new(stop.X+2,506,stop.Z);wall.Anchored=true;wall.Parent=folder
 actor.waypoints={{Position=stop},{Position=stop+Vector3.new(8,0,0)}};actor.index=2;actor.nextPath=math.huge;actor.moving=true
 for _=1,20 do Follow.step(actor,root,.1,params,false) end
 check(model.PrimaryPart.Position.X<wall.Position.X-1,'stale route cannot cross solid wall')
 wall:Destroy()
 model:SetAttribute('SeleneMoveSpeed',12)
 for _,fps in ipairs({30,60,144}) do
  local view=Presentation.bind(model,function()return character end);check(view~=nil,'bind actual articulated model')
  local rest=model.PrimaryPart.CFrame*model.ArmL:GetAttribute('SeleneRest')
  for i=1,math.floor(fps*.36) do view:update(1/fps,i/fps) end
  check((model.ArmL.CFrame.Position-rest.Position).Magnitude>.02,'shoulder gait moves visible sleeve at '..fps..'Hz')
  local left=model.LegL.CFrame.Position-(model.PrimaryPart.CFrame*model.LegL:GetAttribute('SeleneRest')).Position
  local right=model.LegR.CFrame.Position-(model.PrimaryPart.CFrame*model.LegR:GetAttribute('SeleneRest')).Position
  check(left.Z*right.Z<0,'feet stride in opposite directions at '..fps..'Hz')
  check(math.min(left.Y,right.Y)<.01 and math.max(left.Y,right.Y)>.02,'stance stays planted while swing foot lifts at '..fps..'Hz')
  for _,action in ipairs({'Heal','Protect','Cleanse'}) do
   local health=h.Health
   view:play(10,action,12,character);view:update(1/fps,10.4)
   check(view.effect and view.effect.beam.Attachment0.Parent==model.ArmL,'effect originates at animated healing hand')
   check(view.effect.beam.Attachment1.Parent==root,'effect tracks actual recipient')
   check(#view.effect.ring==24,'bounded readable ground ring')
   check(view.effect.label.Text==(action=='Heal' and '+12 HP' or action=='Protect' and 'PROTECTED' or 'CLEANSED'),'distinct actual support result')
   check(h.Health==health,'presentation cannot grant health')
   view:update(1/fps,14)
   check(view.effect==nil,'all effect references cleaned at expiry')
   check(not root:FindFirstChild('SeleneSupportRecipient') and not model.ArmL:FindFirstChild('SeleneHealingHand'),'recipient and caster attachments cleaned')
  end
  view:play(20,'Heal',12,character);view:destroy();check(view.effect==nil,'stream out cleans active effect')
 end
 local eventView=Presentation.bind(model,function()return character end)
 model:SetAttribute('SupportTargetUserId',1);model:SetAttribute('LastSupport','Heal');model:SetAttribute('SupportAmount',12);model:SetAttribute('SupportAt',30)
 eventView:update(.016,30.1);local one=eventView.effect
 check(one~=nil,'fresh server support stamp triggers effect')
 eventView:update(.016,30.2);check(eventView.effect==one,'same server event never duplicates')
 eventView:destroy()
 local lateView=Presentation.bind(model,function()return character end);lateView:update(.016,40)
 check(lateView.effect==nil,'late stream-in never replays historical healing')
 lateView:destroy()
 check(not workspace:FindFirstChild('SeleneSupportEffect'),'no leaked effect containers')
end,debug.traceback)
folder:Destroy();if not ok then table.insert(report.failures,err) end
report.pass=ok;print('SELENE_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
