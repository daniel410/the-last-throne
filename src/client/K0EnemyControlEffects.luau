-- Persistent, observer-local crowd-control cues from server-owned attributes.
local RunService=game:GetService('RunService')
local Workspace=game:GetService('Workspace')
local Effects={}
local colors={knight=Color3.fromRGB(125,220,255),dwarf=Color3.fromRGB(255,205,91)}
function Effects.clear(s)
 for _,a in ipairs(s.stars or {})do a:Destroy()end
 s.stars=nil
 if s.marker then s.marker:Destroy();s.marker=nil end
end
function Effects.bind(model)
 local root=model:FindFirstChild('HumanoidRootPart');local human=model:FindFirstChildOfClass('Humanoid')
 if not root or not human then return nil end
 return {model=model,root=root,human=human}
end
function Effects.update(s,current)
 local untilTime=s.model:GetAttribute('K0EnemyStunUntil')
 if not s.model:IsDescendantOf(Workspace) or not s.root.Parent or s.human.Health<=0 or type(untilTime)~='number' or untilTime<=current then Effects.clear(s);return false end
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
  for m,s in pairs(states)do if not m.Parent then Effects.clear(s);states[m]=nil else Effects.update(s,current)end end
 end)
 return function()added:Disconnect();descendants:Disconnect();removed:Disconnect();heartbeat:Disconnect();for _,s in pairs(states)do Effects.clear(s)end;table.clear(states);table.clear(pending)end
end
return Effects
