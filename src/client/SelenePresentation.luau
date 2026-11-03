-- Presentation only. HP, support eligibility, cooldown and routes remain server-owned.
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Tags=game:GetService('CollectionService')
local Skin=require(script.Parent.SeleneSkinMotion)
local View={}
local GOLD=Color3.fromRGB(255,223,132)
local MINT=Color3.fromRGB(145,255,200)
local function smooth(a,b,t) return a+(b-a)*t end
local function part(parent,name,size,color)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.Color=color;p.Material=Enum.Material.Neon
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
 return p
end
local function emitter(parent,color)
 local e=Instance.new('ParticleEmitter');e.Name='SupportMotes';e.Texture='rbxasset://textures/particles/sparkles_main.dds'
 e.Color=ColorSequence.new(color);e.LightEmission=.85;e.Rate=0;e.Lifetime=NumberRange.new(.65,1.2)
 e.Speed=NumberRange.new(1,3);e.SpreadAngle=Vector2.new(180,180);e.Acceleration=Vector3.new(0,2,0)
 e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.35,.22),NumberSequenceKeypoint.new(1,0)})
 e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.2),NumberSequenceKeypoint.new(.7,.35),NumberSequenceKeypoint.new(1,1)})
 e.Parent=parent;return e
end
local function clearEffect(record)
 local e=record.effect;if not e then return end
 e.folder:Destroy();e.source:Destroy();e.target:Destroy();record.effect=nil
end
function View.bind(model,resolveCharacter)
 local root=model.PrimaryPart;if not root then return end
 local record={model=model,root=root,cf=root.CFrame,speed=0,phase=0,parts={},seen=nil}
 for _,p in ipairs(model:GetDescendants()) do
  local rest=p:IsA('BasePart') and p:GetAttribute('SeleneRest')
  if rest then table.insert(record.parts,{part=p,rest=rest,shoulder=p:GetAttribute('SeleneShoulder'),hip=p:GetAttribute('SeleneHip')}) end
 end
 record.skin=Skin.bind(model,root)
 if #record.parts~=4 or not record.skin then return end -- Atomic stream-in; retry when ready.
 function record:play(at,action,amount,character)
  clearEffect(self)
  local targetRoot=character and character:FindFirstChild('HumanoidRootPart')
  local humanoid=character and character:FindFirstChildOfClass('Humanoid')
  local arm=self.skin.visual
  if not arm or not targetRoot or not humanoid or humanoid.Health<=0 then return end
  local folder=Instance.new('Folder');folder.Name='SeleneSupportEffect';folder.Parent=workspace
  local color=action=='Heal' and MINT or action=='Protect' and GOLD or Color3.fromRGB(187,224,255)
  local source=Instance.new('Attachment');source.Name='SeleneHealingHand';source.CFrame=arm.CFrame:ToObjectSpace(Skin.hand(self.skin));source.Parent=arm
  local target=Instance.new('Attachment');target.Name='SeleneSupportRecipient';target.Parent=targetRoot
  emitter(source,GOLD):Emit(12);emitter(target,color):Emit(action=='Heal' and 32 or 24)
  local beam=Instance.new('Beam');beam.Name='BlessingLink';beam.Attachment0=source;beam.Attachment1=target
  beam.FaceCamera=true;beam.Segments=16;beam.CurveSize0=1.4;beam.CurveSize1=-1.4
  beam.Width0=.18;beam.Width1=.4;beam.LightEmission=1;beam.Color=ColorSequence.new(GOLD,color)
  beam.Transparency=NumberSequence.new(.25);beam.Parent=folder
  local light=Instance.new('PointLight');light.Color=GOLD;light.Brightness=1.5;light.Range=7;light.Parent=source
  local glow=part(folder,'HealingFocus',Vector3.one*.24,GOLD);glow.Shape=Enum.PartType.Ball
  local ring={}
  for i=1,24 do ring[i]=part(folder,'BlessingRing',Vector3.new(.07,.045,.55),color) end
  local shield
  if action=='Protect' then shield=part(folder,'ProtectiveBlessing',Vector3.new(4.5,5.6,4.5),GOLD);shield.Shape=Enum.PartType.Ball;shield.Material=Enum.Material.ForceField;shield.Transparency=.75 end
  local gui=Instance.new('BillboardGui');gui.Name='SupportResult';gui.Size=UDim2.fromOffset(180,40);gui.StudsOffsetWorldSpace=Vector3.new(0,3.2,0);gui.AlwaysOnTop=false;gui.MaxDistance=65;gui.Parent=target
  local label=Instance.new('TextLabel');label.BackgroundTransparency=1;label.Size=UDim2.fromScale(1,1);label.Font=Enum.Font.GothamBold
  label.TextSize=20;label.TextColor3=color;label.TextStrokeTransparency=.4;label.AutoLocalize=false
  label.Text=action=='Heal' and ('+'..tostring(amount)..' HP') or action=='Protect' and 'PROTECTED' or 'CLEANSED';label.Parent=gui
  self.effect={folder=folder,source=source,target=target,root=targetRoot,character=character,at=at,beam=beam,light=light,glow=glow,ring=ring,shield=shield,gui=gui,label=label,duration=action=='Protect' and 3 or 1.65}
 end
 function record:update(dt,now)
  if not root.Parent then return end
  dt=math.min(dt,.1)
  local alpha=1-math.exp(-16*dt)
  self.cf=self.cf:Lerp(root.CFrame,alpha)
  self.speed=smooth(self.speed,model:GetAttribute('SeleneMoveSpeed') or 0,1-math.exp(-9*dt))
  self.phase+=self.speed*dt/4.8*math.pi*2
  local weight=math.clamp(self.speed/13,0,1)
  local supportAt=model:GetAttribute('SupportAt')
  local age=supportAt and now-supportAt or math.huge
  local cast=age>=0 and age<1.25 and math.sin(math.clamp(age/1.25,0,1)*math.pi)^2 or 0
  for _,p in ipairs(self.parts)do
   if p.part.Parent then p.part.CFrame=self.cf*p.rest end
  end
  Skin.step(self.skin,self.phase,weight,cast,now)
  -- Only a fresh server-confirmed event may display support. Late stream-in
  -- does not replay an old heal; a not-yet-streamed recipient gets a short retry.
  if supportAt and supportAt~=self.seen then
   if age>=0 and age<.6 then
    local character=resolveCharacter(model:GetAttribute('SupportTargetUserId'))
    if character then self:play(supportAt,model:GetAttribute('LastSupport'),model:GetAttribute('SupportAmount') or 0,character);self.seen=supportAt end
   elseif age>=.6 then self.seen=supportAt end
  end
  local e=self.effect
  if e then
   local t=now-e.at
   local alive=e.character:FindFirstChildOfClass('Humanoid')
   if t>e.duration or not e.root.Parent or not alive or alive.Health<=0 or root.LocalTransparencyModifier>=1 then clearEffect(self);return end
   local fade=math.clamp((t-e.duration+.5)/.5,0,1)
   e.beam.Transparency=NumberSequence.new(math.clamp(.2+t*.8,.2,1));e.light.Brightness=1.5*(1-fade)
   e.source.CFrame=self.skin.visual.CFrame:ToObjectSpace(Skin.hand(self.skin))
   e.glow.CFrame=e.source.WorldCFrame;e.glow.Transparency=math.clamp(t,0,1)
   local h=e.character:FindFirstChildOfClass('Humanoid')
   local foot=e.root.Position.Y-(h and h.HipHeight+e.root.Size.Y*.5 or 3)+.08
   local radius=1.8+math.min(t,.55)*.9
   for i,p in ipairs(e.ring) do
    local a=i/24*math.pi*2
    p.CFrame=CFrame.new(e.root.Position.X,foot,e.root.Position.Z)*CFrame.Angles(0,a,0)*CFrame.new(radius,0,0)
    p.Size=Vector3.new(.07,.045,radius*math.pi*2/24+.04);p.Transparency=.18+fade*.82
   end
   if e.shield then e.shield.CFrame=e.root.CFrame;e.shield.Transparency=.7+fade*.3 end
   e.gui.StudsOffsetWorldSpace=Vector3.new(0,3.2+math.min(t,1)*.9,0);e.label.TextTransparency=fade;e.label.TextStrokeTransparency=.4+.6*fade
  end
 end
 function record:destroy()
  clearEffect(self)
  Skin.reset(self.skin)
  for _,p in ipairs(self.parts) do if p.part.Parent and root.Parent then p.part.CFrame=root.CFrame*p.rest end end
 end
 return record
end
function View.start()
 local records={};local pending={}
 local function add(model)
  if model:GetAttribute('NPCId')=='selene' then pending[model]=true end
 end
 for _,m in ipairs(Tags:GetTagged('TLTStoryNPC')) do add(m) end
 Tags:GetInstanceAddedSignal('TLTStoryNPC'):Connect(add)
 Tags:GetInstanceRemovedSignal('TLTStoryNPC'):Connect(function(m)
  pending[m]=nil;if records[m] then records[m]:destroy();records[m]=nil end
 end)
 local function resolve(id) local p=id and Players:GetPlayerByUserId(id);return p and p.Character end
 Run.RenderStepped:Connect(function(dt)
  for model in pairs(pending) do
   if not model:IsDescendantOf(workspace) then pending[model]=nil
   else local r=View.bind(model,resolve);if r then records[model]=r;pending[model]=nil end end
  end
  local now=workspace:GetServerTimeNow()
  for model,r in pairs(records) do
   if not model:IsDescendantOf(workspace) then r:destroy();records[model]=nil
   else r:update(dt,now) end
  end
 end)
end
return View
