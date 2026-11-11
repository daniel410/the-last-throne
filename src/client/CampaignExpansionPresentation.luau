-- Personal, saved scene stages. Never changes collision or authoritative progress.
local State=require(game.ReplicatedStorage.Shared.CampaignSceneState)
local M={};local models={};local current
local function paint(m,record)
 if not m.Parent then models[m]=nil;return end
 local s=current and not current.training and current.journal
 local event=m:GetAttribute('ExpansionEvent');local chapter=m:GetAttribute('ExpansionChapter')
 local count=State.count(s,event,chapter)
 local first=m:GetAttribute('ExpansionMin');local last=m:GetAttribute('ExpansionMax')or 3
 local visible=first~=nil and count>=first and count<=last
 if first==nil then visible=m:GetAttribute('ExpansionAfter')==(count==3)end
 visible=visible and State.requires(s,m:GetAttribute('ExpansionRequires'))
 if record.count~=count or record.visible~=visible then
  local pose=m:GetAttribute('ExpansionPose'..count)
  if pose then
   if record.count==nil then m:PivotTo(pose)
   else record.from=m:GetPivot();record.to=pose;record.elapsed=0 end
  end
  record.count=count;record.visible=visible
 end
 for _,v in ipairs(m:GetDescendants())do
  if v:IsA('BasePart')or v:IsA('Decal')or v:IsA('Texture')then v.Transparency=visible and (v:GetAttribute('ExpansionTransparency')or 0)or 1
  elseif v:IsA('BillboardGui')or v:IsA('PointLight')or v:IsA('ProximityPrompt')then v.Enabled=visible end
 end
end
local function paintStep(m)
 local s=current and not current.training and current.journal
 local key=m:GetAttribute('ExpansionStepEvent');local chapter=m:GetAttribute('ExpansionStepChapter')
 local index=m:GetAttribute('ExpansionStepIndex');local count=State.count(s,key,chapter)
 local clues=s and s.clues and s.clues[key]
 local collected=index and (clues and clues['step'..index]==true or not clues and count>=index)
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then
  p.Color=collected and Color3.fromRGB(103,205,184)or p:GetAttribute('ExpansionOriginalColor')or p.Color
 end end
end
local started=false
function M.tick(dt)
 for m,r in pairs(models)do if r.to and m.Parent then
  local duration=math.clamp(m:GetAttribute('ExpansionTransitionSeconds')or .65,.1,10)
  r.elapsed=math.min(duration,r.elapsed+dt);local t=r.elapsed/duration;t=t*t*(3-2*t)
  m:PivotTo(r.from:Lerp(r.to,t));if r.elapsed>=duration then r.from=nil;r.to=nil end
 end end
end
local function start()
 if started then return end;started=true
 local function add(v)
  if v:IsA('Model')and v:GetAttribute('ExpansionEvent')then
   models[v]=models[v]or {};paint(v,models[v])
  elseif v:IsA('Model')and v:GetAttribute('ExpansionStepEvent')then
   models[v]=models[v]or {step=true};paintStep(v)
  end
 end
 for _,v in ipairs(workspace:GetDescendants())do add(v)end
 workspace.DescendantAdded:Connect(function(v)
  add(v)
  -- Descendants can arrive after a server model; reapply its current projection.
  if v:IsA('BasePart')or v:IsA('Decal')or v:IsA('Texture')or v:IsA('PointLight')or v:IsA('ProximityPrompt')or v:IsA('BillboardGui')then
   local p=v.Parent
   while p and p~=workspace do
    local record=models[p]
    if record then if record.step then paintStep(p)else paint(p,record)end;break end
    p=p.Parent
   end
  end
 end)
 workspace.DescendantRemoving:Connect(function(v)models[v]=nil end)
 game:GetService('RunService').Heartbeat:Connect(M.tick)
end
function M.update(value)
 current=value;start()
 for m,record in pairs(models)do if m.Parent then if record.step then paintStep(m)else paint(m,record)end else models[m]=nil end end
 require(script.Parent.DeepwoodAtmosphere).restoration(value and value.journal)
end
return M
