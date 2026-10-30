-- Streaming owns residency; this only reduces optional work in already loaded scenery.
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Budget={}
function Budget.start()
 local tracked={}
 local function add(v)
  if v:IsA('BasePart') and v:GetAttribute('TLTDecorative') then tracked[v]={shadow=v.CastShadow}
  elseif (v:IsA('Light') or v:IsA('ParticleEmitter')) and v:GetAttribute('TLTDecorative') then tracked[v]={enabled=v.Enabled} end
 end
 for _,v in ipairs(workspace:GetDescendants()) do add(v) end
 workspace.DescendantAdded:Connect(add)
 workspace.DescendantRemoving:Connect(function(v) tracked[v]=nil end)
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.5 then return end;elapsed=0
  local c=Players.LocalPlayer.Character;local root=c and c:FindFirstChild('HumanoidRootPart');if not root then return end
  local count,hidden,disabled=0,0,0
  for v,original in pairs(tracked) do
   if v.Parent then
    count+=1;local p=v:IsA('BasePart') and v or v:FindFirstAncestorWhichIsA('BasePart')
    if p then
     local distance=(p.Position-root.Position).Magnitude
     if v:IsA('BasePart') then
      v.CastShadow=original.shadow and distance<100
      v.LocalTransparencyModifier=distance>280 and 1 or 0
      if distance>280 then hidden+=1 end
     else v.Enabled=original.enabled and distance<100;if not v.Enabled then disabled+=1 end end
    end
   else tracked[v]=nil end
  end
  workspace:SetAttribute('TLTLoadedDecorations',count);workspace:SetAttribute('TLTHiddenDecorations',hidden);workspace:SetAttribute('TLTDisabledEffects',disabled)
 end)
end
return Budget
