-- Persistent, observer-local crowd-control cues from server-owned attributes.
local RunService=game:GetService('RunService')
local Workspace=game:GetService('Workspace')
local Style=require(script.Parent.CombatVFXStyle)
local Effects={}
local colors={knight=Color3.fromRGB(125,220,255),dwarf=Color3.fromRGB(255,205,91)}
local v=Vector3.new
-- Points describe one side in root space. Mirroring the other side keeps
-- the open shapes legible without drawing a filled field under the enemy.
local slowStyles={
 steel={Color3.fromRGB(182,214,232),v(.25,.23,1.08),v(1.46,.30,.67),v(1.18,.08,-.56),v(.43,0,-.98)},
 earth={Color3.fromRGB(239,174,93),v(.36,0,1.05),v(1.52,.63,.50),v(.79,-.13,-.52),v(1.12,.24,-.90)},
 arrow={Color3.fromRGB(222,237,158),v(.42,.62,.84),v(.78,.50,.58),v(.94,.09,-.43),v(1.12,0,-.84)},
 nature={Color3.fromRGB(151,229,133),v(.34,.10,1.02),v(1.78,.04,.84),v(1.26,.73,-.68),v(.58,1.02,-.62)},
 water={Color3.fromRGB(121,219,252),v(.18,.12,1.26),v(1.72,-.06,.87),v(1.34,.18,-.63),v(.48,.08,-1.06)},
 frost={Color3.fromRGB(175,237,255),v(.42,0,.92),v(.74,.12,.73),v(.74,.37,-.58),v(1.39,.78,-.65)},
 fire={Color3.fromRGB(255,153,71),v(.47,0,1.14),v(1.76,.19,.83),v(.77,-.04,-.24),v(1.05,.90,-.91)},
 arcane={Color3.fromRGB(185,156,247),v(.42,.68,.97),v(1.52,.62,.64),v(.91,-.13,-.69),v(1.19,.48,-1.07)},
}
local slowFade=NumberSequence.new({
 NumberSequenceKeypoint.new(0,.72),
 NumberSequenceKeypoint.new(.30,.16),
 NumberSequenceKeypoint.new(.70,.22),
 NumberSequenceKeypoint.new(1,.86),
})
local function clearStun(s)
 for _,a in ipairs(s.stars or {})do a:Destroy()end
 s.stars=nil
 if s.marker then s.marker:Destroy();s.marker=nil end
end
local function clearSlow(s)
 if s.slow then
  for _,node in s.slow.nodes do node:Destroy() end
  s.slow=nil
 end
end
function Effects.clear(s)
 clearStun(s)
 clearSlow(s)
end
function Effects.bind(model)
 local root=model:FindFirstChild('HumanoidRootPart');local human=model:FindFirstChildOfClass('Humanoid')
 if not root or not root:IsA('BasePart') or not human then return nil end
 return {model=model,root=root,human=human}
end
function Effects.update(s,current)
 local untilTime=s.model:GetAttribute('K0EnemyStunUntil')
 if not s.model:IsDescendantOf(Workspace) or not s.root.Parent or s.human.Health<=0 or type(untilTime)~='number' or untilTime<=current then clearStun(s);return false end
 if not s.stars then
  s.stars={};s.marker=Instance.new('Folder');s.marker.Name='ControlStunFX';s.marker.Parent=s.model
  for i=1,3 do
   local a=Instance.new('Attachment');a.Name='StunOrbit'..i;a.Parent=s.root
   local gui=Instance.new('BillboardGui');gui.Name='StunStar';gui.Adornee=a;gui.Size=UDim2.fromOffset(25,25);gui.MaxDistance=100;gui.AlwaysOnTop=false;gui.Parent=a
   local star=Instance.new('TextLabel');star.Name='Star';star.BackgroundTransparency=1;star.Size=UDim2.fromScale(1,1);star.Text='';star.AutoLocalize=false;star.Parent=gui
   -- GUI rays avoid platform-dependent star glyph fallback squares.
   for ray=1,4 do
    local line=Instance.new('Frame');line.Name='Ray'..ray;line.AnchorPoint=Vector2.new(.5,.5);line.Position=UDim2.fromScale(.5,.5);line.Size=UDim2.fromOffset(3,ray%2==0 and 16 or 23);line.Rotation=(ray-1)*45;line.BorderSizePixel=0;line.Parent=star
   end
   table.insert(s.stars,a)
  end
 end
 local class=s.model:GetAttribute('K0EnemyStunClass');local color=colors[class] or colors.dwarf
 local height=(s.model:GetAttribute('TdMonsterTargetHeight') or 5)-s.root.Size.Y*1.5+.45
 local radius=math.clamp(s.root.Size.X*.6,.65,1.8)
 for i,a in ipairs(s.stars)do
  local angle=current*3.8+(i-1)*math.pi*2/3
  a.Position=Vector3.new(math.cos(angle)*radius,height+.12*math.sin(angle*2),math.sin(angle)*radius)
  local star=a.StunStar.Star;star.TextColor3=color;star.Rotation=-current*90+(i-1)*120
  local fade=math.clamp((.18-(untilTime-current))/.18,0,1)
  for _,ray in ipairs(star:GetChildren())do ray.BackgroundColor3=color;ray.BackgroundTransparency=fade end
 end
 s.marker:SetAttribute('SourceClass',class);return true
end

local function createSlow(s,kind,current)
 local layer={kind=kind,startedAt=current,nodes={},beams={}}
 if kind=='gravity' then
  local glow=Instance.new('Highlight')
  glow.Name,glow.Adornee='GravityEffect',s.model
  glow.FillColor,glow.OutlineColor=Color3.fromRGB(98,43,168),Color3.fromRGB(199,152,255)
  glow.FillTransparency,glow.OutlineTransparency=.65,.1
  glow.DepthMode,glow.Parent=Enum.HighlightDepthMode.Occluded,s.model
  table.insert(layer.nodes,glow)
  return layer
 end
 local profile=slowStyles[kind]
 local root=s.root
 local radius=math.clamp(math.max(root.Size.X,root.Size.Z)*.50,.80,2.4)
 local height=math.clamp(root.Size.Y*.62,.72,2.4)
 for side=-1,1,2 do
  local function point(index)
   local p=profile[index]
   return v(p.X*side*radius,p.Y*math.sqrt(radius)-height,p.Z*side*radius)
  end
  local p0,p1,p2,p3=point(2),point(3),point(4),point(5)
  local a,b=Instance.new('Attachment'),Instance.new('Attachment')
  a.Name,b.Name='SlowContactStart','SlowContactEnd'
  a.CFrame,b.CFrame=Style.frame(p0,p1-p0),Style.frame(p3,p3-p2)
  a.Parent,b.Parent=root,root
  local beam=Instance.new('Beam')
  beam.Name='SlowContact'
  beam:SetAttribute('Style',kind)
  beam.Attachment0,beam.Attachment1=a,b
  beam.CurveSize0,beam.CurveSize1=(p1-p0).Magnitude,(p3-p2).Magnitude
  beam.FaceCamera,beam.Segments,beam.LightEmission=true,5,.65
  beam.Color=ColorSequence.new(profile[1],profile[1]:Lerp(Color3.new(1,1,1),.4))
  beam.Transparency,beam.Parent=slowFade,a
  table.insert(layer.beams,beam)
  table.insert(layer.nodes,a)
  table.insert(layer.nodes,b)
 end
 return layer
end

function Effects.updateSlow(s,current,observerPosition)
 local expires=s.model:GetAttribute('K0GravityUntil')
 if type(expires)~='number' or expires<=current or s.human.Health<=0
  or s.root.Parent~=s.model or not s.model:IsDescendantOf(Workspace)
  or (observerPosition and (observerPosition-s.root.Position).Magnitude>95) then
  clearSlow(s)
  return false
 end
 local kind=s.model:GetAttribute('K0SlowStyle')
 if not slowStyles[kind] then kind='gravity' end
 if not s.slow or s.slow.kind~=kind then
  clearSlow(s)
  s.slow=createSlow(s,kind,current)
 end
 if #s.slow.beams>0 then
  local opening=1-math.clamp((current-s.slow.startedAt)/.22,0,1)
  local closing=math.clamp((expires-current)/.18,0,1)
  for _,beam in s.slow.beams do
   beam.Width0=(.19+.15*opening)*closing
   beam.Width1=(.06+.07*opening)*closing
  end
 end
 return true
end

function Effects.start(enemies)
 local states,pending={},{}
 local function queue(m)
  if states[m] or pending[m] or m.Parent~=enemies then return end;pending[m]=true
  task.defer(function()pending[m]=nil;if m.Parent==enemies and not states[m]then local s=Effects.bind(m);if s then states[m]=s end end end)
 end
 local added=enemies.ChildAdded:Connect(queue)
 local descendants=enemies.DescendantAdded:Connect(function(o)local m=o;while m.Parent and m.Parent~=enemies do m=m.Parent end;if m.Parent==enemies then queue(m)end end)
 local removed=enemies.ChildRemoved:Connect(function(m)local s=states[m];if s then Effects.clear(s);states[m]=nil end;pending[m]=nil end)
 for _,m in ipairs(enemies:GetChildren())do queue(m)end
 local elapsed=0
 local heartbeat=RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<1/30 then return end;elapsed=0
  local current=Workspace:GetServerTimeNow()
  local camera=Workspace.CurrentCamera
  local observerPosition=camera and camera.CFrame.Position
  for m,s in pairs(states)do
   if s.root.Parent~=m or s.human.Parent~=m then
    Effects.clear(s);states[m]=nil;queue(m)
   else
    Effects.update(s,current)
    Effects.updateSlow(s,current,observerPosition)
   end
  end
 end)
 return function()added:Disconnect();descendants:Disconnect();removed:Disconnect();heartbeat:Disconnect();for _,s in pairs(states)do Effects.clear(s)end;table.clear(states);table.clear(pending)end
end
return Effects
