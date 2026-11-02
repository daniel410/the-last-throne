local Run=game:GetService('RunService')
local Tags=game:GetService('CollectionService')
local Motion=require(game.ReplicatedStorage.Shared.NPCMotion)
local View={}
function View.bind(model)
 local root=model.PrimaryPart
 if not root or not model:GetAttribute('NPCArticulated') then return end
 local r={parts={},cf=root.CFrame,previous=root.Position,phase=0,weight=0,look=0,model=model,root=root}
 for _,p in ipairs(model:GetDescendants()) do
  local rest=p:IsA('BasePart') and p:GetAttribute('NPCMotionRest')
  if p:IsA('BasePart') and p~=root and (not rest or not p:GetAttribute('NPCMotionGroup')) then return end
  if rest then table.insert(r.parts,{part=p,rest=rest,group=p:GetAttribute('NPCMotionGroup')}) end
 end
 if #r.parts==0 then return end
 local seed=0;for i=1,#model.Name do seed+=string.byte(model.Name,i)*i end
 r.offset=seed%101
 function r:update(dt,now,target)
  if dt<=0 then return end
  local teleported=(root.Position-self.previous).Magnitude>=8
  self.cf=teleported and root.CFrame or self.cf:Lerp(root.CFrame,1-math.exp(-16*math.min(dt,.1)))
  local cf=self.cf;local delta=cf.Position-self.previous;self.previous=cf.Position
  local distance=Vector3.new(delta.X,0,delta.Z).Magnitude
  -- Teleports/stream-in are not a sprint. Bound animation after a stalled frame.
  local speed=not teleported and distance/dt or 0
  local alpha=1-math.exp(-10*math.min(dt,.1))
  self.weight+=(math.clamp(speed/7,0,1)-self.weight)*alpha
  local scale=model:GetScale()
  if not teleported then self.phase+=distance/(3.2*scale)*math.pi*2 end
  local yaw=0
  if target and (target-cf.Position).Magnitude<16 then
   local v=cf:PointToObjectSpace(target)
   if v.Z<0 then yaw=math.clamp(math.atan2(-v.X,-v.Z),-.45,.45) end
  end
  self.look+=(yaw-self.look)*alpha
  local pose=Motion.pose(now+self.offset,self.phase,self.weight,scale,model:GetAttribute('NPCMotionWidth') or 1,model:GetAttribute('NPCMotionProp'),self.look)
  for _,p in ipairs(self.parts) do if p.part.Parent then p.part.CFrame=cf*(pose[p.group] or CFrame.identity)*p.rest end end
 end
 function r:reset()
  self.previous=root.Position;self.cf=root.CFrame;self.weight=0
  for _,p in ipairs(self.parts) do if p.part.Parent and root.Parent then p.part.CFrame=root.CFrame*p.rest end end
 end
 return r
end
function View.start()
 local pending,records={},{}
 local function add(m) if m:IsA('Model') then pending[m]=true end end
 for _,m in ipairs(Tags:GetTagged('TLTAnimatedNPC')) do add(m) end
 Tags:GetInstanceAddedSignal('TLTAnimatedNPC'):Connect(add)
 Tags:GetInstanceRemovedSignal('TLTAnimatedNPC'):Connect(function(m)
  pending[m]=nil;if records[m] then records[m]:reset();records[m]=nil end
 end)
 Run.RenderStepped:Connect(function(dt)
  for m in pairs(pending) do
   if not m:IsDescendantOf(workspace) then pending[m]=nil
   else local r=View.bind(m);if r then records[m]=r;pending[m]=nil end end
  end
  local player=game.Players.LocalPlayer;local character=player and player.Character
  local playerRoot=character and character:FindFirstChild('HumanoidRootPart')
  local camera=workspace.CurrentCamera;local now=workspace:GetServerTimeNow()
  for m,r in pairs(records) do
   if not m:IsDescendantOf(workspace) then r:reset();records[m]=nil
   elseif camera and (r.root.Position-camera.CFrame.Position).Magnitude<100 and r.root.LocalTransparencyModifier<1 then
    r:update(dt,now,playerRoot and playerRoot.Position);r.active=true
   else
    if r.active then r:reset();r.active=false end
    r.previous=r.root.Position;r.cf=r.root.CFrame
   end
  end
 end)
end
return View
