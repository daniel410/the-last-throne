-- Production enemy/wind/support code in a local fixture. Geometry snapshots and live trails are distinct.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Spells={require(Client.EnemySpellVFXBefore),require(Client.EnemySpellVFX)}
local Winds={require(Client.WindLanceVisualBefore),require(Client.WindLanceVisual)}
local Selenes={require(Client.SelenePresentationBefore),require(Client.SelenePresentation)}
local Pixels={require(Client.PixelFXBefore),require(Client.PixelFX)}
local Swords={require(Client.K0SwordVisualBefore),require(Client.K0SwordVisual)}
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
if not game.RunService:IsRunning()then game.RunService:Run()end
task.wait(.3)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=42
game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(90,98,115)
local stage=Instance.new('Folder');stage.Name='ResearchVFXCapture';stage.Parent=workspace
local function part(parent,name,at,size)
 local p=Instance.new('Part');p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 p.Size=size or Vector3.new(1.4,2,1);p.Position=at;p.Color=Color3.fromRGB(113,128,145);p.Parent=parent;return p
end
local floor=part(stage,'Ground',Vector3.new(0,-.25,0),Vector3.new(180,.5,180));floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(47,54,65)
task.wait(1.5)
local index=0
local function clear()
 for _,v in ipairs(Spells)do v.clear()end;for _,v in ipairs(Winds)do v.clear()end;for _,v in ipairs(Pixels)do v.clear()end
end
local function capture(meta,variant)
 if not meta.live then task.wait(.08)end
 local done=false;local captured=false
 game:GetService('CaptureService'):CaptureScreenshot(function(uri)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(uri))
   local pixels=img:ReadPixelsBuffer(Vector2.zero,img.Size);local w,h=480,320;local chunks={}
   for y=0,h-1 do for x=0,w-1 do
    local at=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
    for c=0,2 do chunks[#chunks+1]=string.format('%02x',buffer.readu8(pixels,at+c))end
   end end
   local row=table.clone(meta);row.index=index;row.variant=variant;row.width=w;row.height=h
   local data=table.concat(chunks);print('ART_META '..game.HttpService:JSONEncode(row))
   for i=1,#data,20000 do print('ART_RGB '..index..' '..variant..' '..data:sub(i,i+19999))end
   img:Destroy();captured=true
  end)
  if not ok then print('ART_CAPTURE_ERROR '..tostring(err))end;done=true
 end)
 local deadline=os.clock()+12;while not done and os.clock()<deadline do task.wait(.05)end
 assert(captured,'capture failed '..meta.id)
end
local function freeze(nodes)
 local frozen=Instance.new('Folder');frozen.Name='FrozenVFX'
 for _,node in ipairs(nodes)do node:Clone().Parent=frozen end
 -- Support links may point to external hand/recipient attachments. Freeze those positions too.
 local holder=part(frozen,'FrozenSockets',Vector3.zero,Vector3.one*.01);holder.Transparency=1
 for _,v in ipairs(frozen:GetDescendants())do if v:IsA('Beam')then
  for _,key in ipairs({'Attachment0','Attachment1'})do
   local old=v[key]
   if old and not old:IsDescendantOf(frozen)then
    local a=Instance.new('Attachment');a.CFrame=old.WorldCFrame;a.Parent=holder;v[key]=a
   end
  end
 end end
 frozen.Parent=workspace;return frozen
end
local function pair(id,name,category,age,extent,focus,make)
 if _G.PolishCaptureCategory and _G.PolishCaptureCategory~=category then return end
 if _G.PolishCaptureIds and not _G.PolishCaptureIds[id]then return end
 index+=1;clear();game.Lighting.ClockTime=index%2==0 and 0 or 12
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(extent*.8,extent*.6,extent),focus)
 task.wait(.2)
 for variant=1,2 do
  local nodes,finish=make(variant)
  local frozen=freeze(nodes);if finish then finish()end;clear()
  for _,v in ipairs(frozen:GetDescendants())do if v:IsA('ParticleEmitter')then
   v:Clear();v:Emit(v:GetAttribute('ReviewBurstCount')or 0)
  end end
  capture({id=id,name=name,category=category,age=age,pulse=1,clockTime=game.Lighting.ClockTime,extent=extent,mode='frozen geometry; particle bursts re-emitted'},variant)
  frozen:Destroy()
 end
end
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-9)
for _,kind in ipairs({'Imp','IceElf','Shaman','Lich','Veyr','VenomcoilKing','Silkweaver'})do
 local d=Patterns.get(kind).attacks[1]
 if d.shape=='projectile'then
  pair('enemy.'..kind..'.flight',kind..' Flight','Enemy spell',.12,5,first,function(variant)
   local v=Spells[variant];local now=workspace:GetServerTimeNow();local r=assert(v.projectile(d,nil,nil,first,-Vector3.zAxis,now))
   v.pose(r,CFrame.lookAt(first,first-Vector3.zAxis)*CFrame.Angles(.12,0,.15),.12,1,0)
   return {r.model}
  end)
 end
 for _,age in ipairs({.035,.18})do
  if kind=='Imp'or kind=='Lich'or age==.18 then
   pair('enemy.'..kind..'.contact',kind..' Contact','Enemy spell',age,5,first,function(variant)
    local v=Spells[variant];local now=workspace:GetServerTimeNow();local r=assert(v.impact(d,first,now,nil,nil,Vector3.zAxis))
    v.pose(r,CFrame.new(first),age,1,age/r.life)
    return {r.model}
   end)
  end
 end
end
pair('mage_wind_lance','Wind Lance','Air ribbons',.12,10,(first+last)*.5,function(variant)
 local v=Winds[variant];local now=workspace:GetServerTimeNow();local m=assert(v.play(nil,first,last,1,{last},nil,now,nil,nil,now))
 v.step(now+.12);return {m}
end)
local npc=Instance.new('Model');npc.Name='SeleneFixture';npc.Parent=stage
local nr=part(npc,'HumanoidRootPart',Vector3.new(-3,3,0));npc.PrimaryPart=nr
local visual
for i,name in ipairs({'VisualRoot','ReviewHead','ReviewArmL','ReviewArmR'})do
 local offset=i==1 and Vector3.zero or i==2 and Vector3.new(0,1.3,0)or Vector3.new(i==3 and -1 or 1,.15,0)
 local p=part(npc,name,nr.Position+offset);p:SetAttribute('SeleneRest',CFrame.new(offset));if i==1 then visual=p end
end
for _,name in ipairs({'Root','Pelvis','Spine','Head','UpperL','ForearmL','HandL','UpperR','ForearmR','HandR','Lantern','LegL','FootL','LegR','FootR'})do
 local b=Instance.new('Bone');b.Name=name;if name=='HandL'then b.Position=Vector3.new(-1,.2,0)end;b.Parent=visual
end
local actor=Instance.new('Model');actor.Name='Recipient';actor.Parent=stage
local root=part(actor,'HumanoidRootPart',Vector3.new(1,3,0));local human=Instance.new('Humanoid');human.RequiresNeck=false;human.HipHeight=2;human.Parent=actor
part(actor,'Head',Vector3.new(1,4.5,0),Vector3.one)
for _,action in ipairs({'Heal','Protect','Cleanse'})do
 for _,age in ipairs({.12,.45})do
  pair('support.'..action,action,'Selene support',age,8,Vector3.new(0,2.4,0),function(variant)
   local view=assert(Selenes[variant].bind(npc,function()return actor end));view:play(10,action,12,actor);view:update(.016,10+age)
   return {view.effect.folder},function()view:destroy()end
  end)
 end
end
npc:Destroy();actor:Destroy();clear()
-- Actual equipped meshes + production weapon/motion modules. Live capture timestamps may differ slightly.
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
for _,classId in ipairs({'knight','dwarf'})do
 if _G.PolishCaptureCategory and _G.PolishCaptureCategory~='Equipped weapon'then continue end
 index+=1;game.Lighting.ClockTime=12
 for variant=1,2 do
  local desc=Instance.new('HumanoidDescription');local char=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R6);desc:Destroy()
  char.Parent=stage;char:PivotTo(CFrame.new(0,3,0));char.HumanoidRootPart.Anchored=true
  for _,p in ipairs(char:GetChildren())do if p:IsA('BasePart')then p.Color=Color3.fromRGB(113,128,145)end end
  char:SetAttribute('K0ClassId',classId);char:SetAttribute('TLTEquippedWeapon',classId..'_weapon_fine')
  char:SetAttribute('K0State','Attack');char:SetAttribute('K0AttackKind','Basic');char:SetAttribute('K0AttackPhase','Active')
  char:SetAttribute('K0Combo',1);char:SetAttribute('K0AttackSeq',1000+variant)
  local weapon=Instance.new('Model');weapon.Name='WeaponPreview';weapon:SetAttribute('WeaponClassId',classId);weapon.Parent=char
  assert(Appearance.attachInto(weapon,char,classId))
  camera.CFrame=CFrame.lookAt(Vector3.new(9,8,12),Vector3.new(0,3,0))
  local config=require(game.ReplicatedStorage.Shared.K0Config).BasicAttackProfiles[classId].attacks[1]
  local started=workspace:GetServerTimeNow();char:SetAttribute('K0AttackStartedAt',started)
  local sampledAge=0;local tipTravel=0;local previousTip
  local connection=game.RunService.PreSimulation:Connect(function(dt)
   local clock=workspace:GetServerTimeNow();local sample=(clock-started)%(config.windup+config.active+config.recovery)
   sampledAge=sample
   char:SetAttribute('K0AttackStartedAt',clock-sample)
   Swords[variant].renderArms(char,dt,clock);Swords[variant].renderCharacter(char,dt,clock)
   local tip=weapon:FindFirstChild('K0TrailTop',true)
   if tip then
    if previousTip then tipTravel=(tip.WorldPosition-previousTip).Magnitude end
    previousTip=tip.WorldPosition
   end
  end)
  local deadline=os.clock()+4;local trail
  repeat
   task.wait()
   trail=weapon:FindFirstChild(classId=='knight'and'K0SwordTrail'or'K0WeaponTrail',true)
  until trail and trail.Enabled and sampledAge>config.windup+.035 and sampledAge<config.windup+config.active-.025 and tipTravel>.02 or os.clock()>deadline
  assert(trail and trail.Enabled and tipTravel>.02,'production cutting phase must move an emitting trail')
  capture({id='basic.'..classId,name=classId=='knight'and'Sword Trail'or'Axe Trail',category='Equipped weapon',age=config.windup+.04,pulse=1,clockTime=12,extent=12,live=true,sampledAge=sampledAge,tipTravel=tipTravel,mode='live production animation; callback is not exact frame synchronization'},variant)
  connection:Disconnect();char:Destroy()
 end
end
clear();stage:Destroy();print('ART_CAPTURE_COMPLETE '..index)
