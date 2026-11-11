-- Streaming owns residency; this only reduces optional work in already loaded scenery.
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local ForestMood=require(script.Parent.DeepwoodAtmosphere)
local Budget={}
local function isNPCVisual(object)
 local parent=object.Parent
 while parent and parent~=workspace do
  if parent:GetAttribute('TLTNPC') then return true end
  parent=parent.Parent
 end
 return false
end
function Budget.start()
 local tracked={}
 -- Stream-out unparents instances without destroying them. Keep authored values
 -- weakly so stream-in never mistakes our distant override for the original.
 local originals=setmetatable({},{__mode='k'})
 local function add(v)
  if v:IsA('BasePart') and v:GetAttribute('TLTDecorative') then originals[v]=originals[v] or {shadow=v.CastShadow};tracked[v]=originals[v]
  elseif (v:IsA('Light') or v:IsA('ParticleEmitter')) and v:GetAttribute('TLTDecorative') then originals[v]=originals[v] or {enabled=v.Enabled};tracked[v]=originals[v] end
 end
 for _,v in ipairs(workspace:GetDescendants()) do add(v) end
 workspace.DescendantAdded:Connect(add)
 workspace.DescendantRemoving:Connect(function(v) tracked[v]=nil end)
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.5 then return end;elapsed=0
  local c=Players.LocalPlayer.Character;local root=c and c:FindFirstChild('HumanoidRootPart');if not root then return end
  local sceneryLimit=Players.LocalPlayer:GetAttribute('K0SessionPhase')=='Tutorial' and Players.LocalPlayer:GetAttribute('TLTRoute')~='Training' and ForestMood.fogEnd or 280
  local count,hidden,disabled=0,0,0
  for v,original in pairs(tracked) do
   if v.Parent then
    count+=1;local p=v:IsA('BasePart') and v or v:FindFirstAncestorWhichIsA('BasePart')
    if p then
     local distance=(p.Position-root.Position).Magnitude
     if v:IsA('BasePart') then
      v.CastShadow=original.shadow and distance<100
      local limit=math.clamp(tonumber(v:GetAttribute('TLTSceneryDistance')) or sceneryLimit,48,900)
      -- A large wall/trunk must remain visible wherever it still blocks a hero.
      -- NPC selection owns its mask, including nested face surfaces.
      -- Scenery culling must neither reveal hidden actors nor remove only their bodies.
      local scenery=not isNPCVisual(v)
      local hide=scenery and not v.CanCollide and distance>limit
      if scenery then v.LocalTransparencyModifier=hide and 1 or 0 end
      if hide then hidden+=1 end
     else v.Enabled=original.enabled and distance<100;if not v.Enabled then disabled+=1 end end
    end
   else tracked[v]=nil end
  end
  workspace:SetAttribute('TLTLoadedDecorations',count);workspace:SetAttribute('TLTHiddenDecorations',hidden);workspace:SetAttribute('TLTDisabledEffects',disabled)
 end)
end
return Budget
