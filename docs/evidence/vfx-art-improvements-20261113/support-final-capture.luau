assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
-- ART review of common production effects in an isolated fixture. Not live/device acceptance.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.PixelFX)
local Curated=require(Client.CuratedVFX)
local Visual=require(Client.AdvancedSkillVisual)
local Hero=require(Client.HeroVFX)
local Wind=require(Client.WindLanceVisual)
local Hit=require(Client.K0HitEffects)
local Focus=require(Client.K0MageFocus)
local Level=require(game.ServerScriptService.HeroLevelUpEffect)
local Sword=require(Client.K0SwordVisual)
local Selene=require(Client.SelenePresentation)
if not game.RunService:IsRunning()then game.RunService:Run()end
task.wait(.3)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=48
game.Lighting.ClockTime=12;game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(150,153,165)
local floor=Instance.new('Part');floor.Name='CuratedReviewFloor';floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Color=Color3.fromRGB(44,53,63);floor.Material=Enum.Material.Slate;floor.Parent=workspace
local char=Instance.new('Model');char.Name='CuratedReviewActor';char.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(1.4,2,1);root.Position=Vector3.new(0,3,0);root.Anchored=true;root.CanCollide=false;root.Color=Color3.fromRGB(125,135,148);root.Parent=char
local head=Instance.new('Part');head.Anchored=true;head.CanCollide=false;head.Shape=Enum.PartType.Ball;head.Size=Vector3.one;head.Position=Vector3.new(0,4.5,0);head.Color=root.Color;head.Parent=char
char:SetAttribute('K0State','Attack');char:SetAttribute('K0AttackSeq',8000)
for side=-1,1,2 do local leg=Instance.new('Part');leg.Name=side<0 and'ReviewLegL'or'ReviewLegR';leg.Anchored=true;leg.CanCollide=false;leg.Size=Vector3.new(.6,1.9,.8);leg.Position=Vector3.new(side*.4,1,0);leg.Color=root.Color;leg.Parent=char end
local human=Instance.new('Humanoid');human.RequiresNeck=false;human.HipHeight=2;human.Parent=char
local victim=char:Clone();victim.Name='CommonReviewVictim';victim.Parent=workspace;victim:PivotTo(char:GetPivot()+Vector3.new(0,0,-7))
local function capture(index,row)
 local captured=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pix=img:ReadPixelsBuffer(Vector2.zero,img.Size);local hex={};local w,h=320,240
   for y=0,h-1 do for x=0,w-1 do
    local offset=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
    for channel=0,2 do hex[#hex+1]=string.format('%02x',buffer.readu8(pix,offset+channel))end
   end end
   local data=table.concat(hex)
   print('CURATED_META '..game.HttpService:JSONEncode({index=index,id=row[1],name=row[2],width=w,height=h}))
   for i=1,#data,20000 do print('CURATED_RGB '..index..' '..data:sub(i,i+19999))end
   img:Destroy()
  end)
  if not ok then print('CURATED_CAPTURE_ERROR '..tostring(err))end
  captured=true
 end)
 local timeout=os.clock()+8;while not captured and os.clock()<timeout do task.wait(.05)end
 assert(captured,'capture timeout')
end
local samples={{'basic_knight','Basic Knight Hit','hit','knight',false},{'basic_dwarf','Basic Dwarf Hit','hit','dwarf',false},{'basic_elf','Basic Elf Hit','hit','elf',false},{'basic_mage','Basic Mage Hit','hit','mage',false},{'mage.pyro.ember_lance','Fire Hit Composite','hit','mage','mage.pyro.ember_lance'},{'mage.common.water_ball','Water Hit Composite','hit','mage','mage.common.water_ball'},{'mage.cryo.frost_lance','Frost Hit Composite','hit','mage','mage.cryo.frost_lance'},{'mage.cryo.lightning_line','Lightning Hit Composite','hit','mage','mage.cryo.lightning_line'},{'mage.pyro.stone_lance','Earth Hit Composite','hit','mage','mage.pyro.stone_lance'},{'mage.common.gravity','Gravity Hit Composite','hit','mage','mage.common.gravity'},{'dwarf.common.overhead','Dwarf Overhead Contact','hit','dwarf','dwarf.common.overhead'},{'dwarf.iron_axe.armor_splitter','Dwarf Armor Splitter Contact','hit','dwarf','dwarf.iron_axe.armor_splitter'},{'focus_arcane','Arcane Staff Focus','focus','arcane',false},{'focus_water','Water Staff Focus','focus','water',false},{'focus_wind','Wind Staff Focus','focus','wind',false},{'focus_fire','Fire Staff Focus','focus','fire',false},{'focus_frost','Frost Staff Focus','focus','frost',false},{'focus_earth','Earth Staff Focus','focus','earth',false},{'focus_lightning','Lightning Staff Focus','focus','lightning',false},{'support_Heal','Heal Pixel Accent','support','Heal',false},{'support_Protect','Protect Pixel Accent','support','Protect',false},{'support_Cleanse','Cleanse Pixel Accent','support','Cleanse',false},{'hero_level_up','Hero Level Up','level','knight',false},{'trail_knight','Knight Native Trail','trail','knight',false},{'trail_dwarf','Dwarf Native Trail','trail','dwarf',false},{'trail_mage','Mage Native Trail','trail','mage',false},{'trail_elf','Elf Native Arrow Trail','trail','elf',false},{'selene_Heal','Selene Full Heal','selene','Heal',false},{'selene_Protect','Selene Full Protect','selene','Protect',false},{'selene_Cleanse','Selene Full Cleanse','selene','Cleanse',false},{'elf.magic_archer.storm_arrow','Elf Storm Arrow Hit Composite','hit','elf','elf.magic_archer.storm_arrow'}}
for index,row in ipairs(samples)do
 if row[1]~="support_Heal"and row[1]~="support_Protect"and row[1]~="support_Cleanse"and row[1]~="selene_Heal"then continue end
 if _G.CuratedCaptureGroup and math.ceil(index/2)~=_G.CuratedCaptureGroup then continue end
 FX.clear();Hero.clear();Wind.clear()
 local center=row[3]=='hit'and victim.HumanoidRootPart.Position or root.Position
 local focus=center-Vector3.new(0,1,0)
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(7,6,10),focus)
 task.wait(.1)
 char:SetAttribute('K0AttackSeq',8000+index)
 local before={};for _,node in ipairs(workspace:GetChildren())do before[node]=true end
 local now=workspace:GetServerTimeNow()
 local weapon,seleneRecord
 if row[3]=='trail'then
  local carrier=Instance.new('Model');carrier.Name='TrailCarrierFixture';carrier:SetAttribute('K0ClassId',row[4]);carrier:SetAttribute('K0State','Attack');carrier.Parent=workspace
  local cr=root:Clone();cr.Transparency=1;cr.Parent=carrier
  local m
  if row[4]=='elf'then
   carrier:SetAttribute('K0ArrowVisual','100|0|3|0|0|3|-9')
   Sword.renderCharacter(carrier,1/60,now);m=assert(workspace:FindFirstChild('K0VisualArrow'))
  else
   m=Instance.new('Model');m.Name='NativeWeaponTrailFixture';m:SetAttribute('WeaponClassId',row[4]);m.Parent=carrier
   local grip=Instance.new('Part');grip.Name=row[4]=='knight'and'SwordGrip'or'WeaponGrip';grip.Anchored=true;grip.CanCollide=false;grip.Size=Vector3.new(.3,2.6,.3);grip.CFrame=CFrame.new(root.Position+Vector3.new(2,0,0));grip.Color=Color3.fromRGB(160,150,130);grip.Parent=m
   local tip=Instance.new('Attachment');tip.Name='WeaponTip';tip.Position=Vector3.new(0,1.6,0);tip.Parent=grip
   local joint=Instance.new('Motor6D');joint.Name=row[4]=='knight'and'K0SwordJoint'or'PlayerWeaponJoint';joint.Part0=cr;joint.Part1=grip;joint.Parent=grip
   if row[4]=='knight'then local blade=grip:Clone();blade:ClearAllChildren();blade.Name='SwordBlade';blade.Size=Vector3.new(.35,2.8,.15);blade.Parent=m end
   assert(Sword.render(m,'Active',1,1/60,'Basic',now))
  end
  local rest=m:GetPivot();local alive=true;local started=os.clock()
  task.spawn(function()while alive and m.Parent and os.clock()-started<4 do
   local t=(os.clock()-started)*4
   if row[4]=='elf'then m:PivotTo(rest+Vector3.new(0,0,-(t%1)*8))
   else m:PivotTo(CFrame.new(root.Position)*CFrame.Angles(0,math.sin(t*2)*1.2,0)*CFrame.new(2,0,-1)*rest.Rotation)end
   task.wait(1/60)
  end end)
  task.wait(.09)
  local diagnostics={}
  for _,node in ipairs(m:GetDescendants())do if node:IsA('Trail')then
   local colors={};for _,k in ipairs(node.Color.Keypoints)do colors[#colors+1]={k.Time,k.Value.R,k.Value.G,k.Value.B}end
   diagnostics[#diagnostics+1]={name=node.Name,lifetime=node.Lifetime,color=colors,enabled=node.Enabled}
  end end
  print('COMMON_ART_STATE '..game.HttpService:JSONEncode({index=index,id=row[1],mode='live_native_trail_manual_fixture_transform',diagnostics=diagnostics}))
  capture(index,row);alive=false
  for _,node in ipairs(workspace:GetChildren())do if not before[node]then node:Destroy()end end
  continue
 end
 if row[3]=='hit'then
  assert(Hit.show(victim,center,25,row[4],'Goblin',Vector3.new(0,0,-1),row[5]or nil))
 elseif row[3]=='support'then assert(FX.support(char,row[4]))
 elseif row[3]=='selene'then
  local npc=Instance.new('Model');npc.Name='SeleneSupportFixture';npc.Parent=workspace
  local nr=root:Clone();nr.CFrame=CFrame.new(root.Position+Vector3.new(-4,0,1));nr.Transparency=1;nr.Parent=npc;npc.PrimaryPart=nr
  local visual
  for i,name in ipairs({'VisualRoot','ReviewHead','ReviewArmL','ReviewArmR'})do
   local part=Instance.new('Part');part.Name=name;part.Anchored=true;part.CanCollide=false;part.Size=i==1 and Vector3.new(1.2,1.7,1)or Vector3.new(.6,.8,.6)
   local offset=i==1 and Vector3.zero or i==2 and Vector3.new(0,1.3,0)or Vector3.new(i==3 and -1 or 1,.15,0)
   part.CFrame=nr.CFrame+CFrame.new(offset).Position;part.Color=Color3.fromRGB(215,204,173);part:SetAttribute('SeleneRest',CFrame.new(offset));part.Parent=npc;if i==1 then visual=part end
  end
  for _,name in ipairs({'Root','Pelvis','Spine','Head','UpperL','ForearmL','HandL','UpperR','ForearmR','HandR','Lantern','LegL','FootL','LegR','FootR'})do
   local bone=Instance.new('Bone');bone.Name=name;if name=='HandL'then bone.Position=Vector3.new(-1,.2,0)end;bone.Parent=visual
  end
  seleneRecord=assert(Selene.bind(npc,function()return char end));seleneRecord:play(now,row[4],12,char);seleneRecord:update(.055,now+.055)
 elseif row[3]=='focus'then
  weapon=Instance.new('Model');weapon.Name='ReviewStaff';weapon.Parent=workspace
  local staff=Instance.new('Part');staff.Name='Staff';staff.Anchored=true;staff.CanCollide=false;staff.Size=Vector3.new(.18,2.8,.18);staff.Position=root.Position+Vector3.new(1.2,0,0);staff.Color=Color3.fromRGB(104,75,50);staff.Parent=weapon
  local stone=Instance.new('Part');stone.Name='SmallCrystal';stone.Anchored=true;stone.CanCollide=false;stone.Size=Vector3.new(.45,.6,.45);stone.Position=staff.Position+Vector3.yAxis*1.5;stone.Color=Color3.fromRGB(150,150,150);stone.Parent=weapon
  local tip=Instance.new('Attachment');tip.Name='WeaponTip';tip.Parent=stone
  Focus.render(weapon,{focus=1,element=row[4]},false);Focus.flash(weapon)
 else Level.play(char)end
 local sample=.055
 task.wait(sample)
 FX.step(sample);Hero.step(now+sample);Wind.step(now+sample)

 -- Freeze the generated instances while UI images finish decoding. This is a
 -- still-image review, not evidence of live animation timing or first-use latency.
 local originals={}
 for _,node in ipairs(workspace:GetChildren())do if not before[node]then originals[#originals+1]=node end end
 local bundle=Instance.new('Folder');bundle.Name='CommonEffectOriginals';bundle.Parent=workspace
 for _,node in ipairs(originals)do node.Parent=bundle end
 local snapshot=bundle:Clone();snapshot.Name='CuratedReviewSnapshot'
 FX.clear();Hero.clear();Wind.clear();bundle:Destroy();snapshot.Parent=workspace
 local imageDeadline=os.clock()+5
 local function imagesReady()
  for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ImageLabel')and not node.IsLoaded then return false end end
  return true
 end
 while not imagesReady()and os.clock()<imageDeadline do task.wait(.05)end
 for _,node in ipairs(snapshot:GetDescendants())do
  if node:IsA('BillboardGui')and node.Name=='CuratedSprite'then Curated.step({sprite=node,duration=Curated.duration('blast')},.055)end
  if node:IsA('ParticleEmitter')then node:Clear();node:Emit(node:GetAttribute('ReviewBurstCount')or(node.Name=='UpgradeSparkles'and 28 or node.Name=='K0StaffFocus'and 10 or node.Name=='SupportMotes'and(node.Parent.Name=='SeleneHealingHand'and 12 or 24)or 0))end
 end
 task.wait(.07)
 for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ParticleEmitter')then node.TimeScale=0 end end
 local diagnostics={}
 for _,holder in ipairs(snapshot:GetChildren())do if holder:GetAttribute('CuratedVFXKey')then
  local gui=holder:FindFirstChild('CuratedSprite')
  table.insert(diagnostics,{key=holder:GetAttribute('CuratedVFXKey'),position=tostring(holder.Position),image=gui and gui.Frame.Image,loaded=gui and gui.Frame.IsLoaded,frame=gui and tostring(gui.Frame.ImageRectOffset)})
 end end
 for _,node in ipairs(snapshot:GetDescendants())do
  if node:IsA('ImageLabel')then table.insert(diagnostics,{name=node.Name,image=node.Image,loaded=node.IsLoaded})
  elseif node:IsA('ParticleEmitter')then table.insert(diagnostics,{name=node.Name,texture=node.Texture,loaded='notExposedByParticleEmitterAPI'})
  elseif node:IsA('BasePart')and(node.Name=='K0ImpactFlash'or node.Name=='K0ImpactSpark'or node.Name=='ContactVolume'or node.Name=='SmallCrystal')then table.insert(diagnostics,{name=node.Name,color={node.Color.R,node.Color.G,node.Color.B}})end
 end
 print('COMMON_ART_STATE '..game.HttpService:JSONEncode({index=index,id=row[1],sample=.055,actualElapsed=workspace:GetServerTimeNow()-now,diagnostics=diagnostics}))
 capture(index,row)
 snapshot:Destroy();if weapon then Focus.clear(weapon)end;if seleneRecord then seleneRecord:destroy()end
end
FX.clear();Hero.clear();Wind.clear();char:Destroy();victim:Destroy();floor:Destroy()
print('CURATED_CAPTURE_COMPLETE')
