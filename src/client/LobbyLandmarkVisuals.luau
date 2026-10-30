local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local RS=game:GetService('ReplicatedStorage')
local Text=require(RS.Shared.LobbyText)
local HeroText=require(RS.Shared.K0Text).Lobby.Errors
local V={}
function V.start()
 local player=Players.LocalPlayer;local runes,veils,fires={},{},{}
 local function add(v)
  if v:IsA('BasePart') and v:GetAttribute('TLTPortalOrbit') then runes[v]={center=v:GetAttribute('OrbitCenter'),angle=v:GetAttribute('OrbitAngle')}
  elseif v:IsA('BasePart') and v.Name=='PortalVeil' then veils[v]=true
  elseif v:IsA('Fire') and v.Name=='ForgeFire' then fires[v]=true end
 end
 for _,v in ipairs(workspace:GetDescendants()) do add(v) end
 workspace.DescendantAdded:Connect(add)
 workspace.DescendantRemoving:Connect(function(v) runes[v]=nil;veils[v]=nil;fires[v]=nil end)
 local elapsed,time=0,0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.05 then return end;time+=elapsed;elapsed=0
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if not root then return end
  for part,orbit in pairs(runes) do
   if (root.Position-orbit.center).Magnitude<110 then
    local a=orbit.angle+time*.65
    part.CFrame=CFrame.new(orbit.center+Vector3.new(math.cos(a)*6.8,math.sin(a)*6.8,0))*CFrame.Angles(0,0,a)
   end
  end
  for part in pairs(veils) do if (root.Position-part.Position).Magnitude<110 then part.Transparency=.65+math.sin(time*1.4)*.08 end end
  for fire in pairs(fires) do fire.Enabled=(root.Position-fire.Parent.Position).Magnitude<100 end
 end)
 local gui=Instance.new('ScreenGui');gui.Name='LobbyFacilityNotice';gui.ResetOnSpawn=false;gui.DisplayOrder=65;gui.Parent=player:WaitForChild('PlayerGui')
 local notice=Instance.new('TextLabel');notice.Name='Notice';notice.AnchorPoint=Vector2.new(.5,0);notice.Position=UDim2.new(.5,0,0,66);notice.Size=UDim2.new(1,-40,0,54)
 notice.BackgroundColor3=Color3.fromRGB(15,27,46);notice.BackgroundTransparency=.16;notice.TextColor3=Color3.fromRGB(255,231,169);notice.Font=Enum.Font.GothamBold;notice.TextSize=15;notice.TextWrapped=true;notice.AutoLocalize=false;notice.Visible=false;notice.Parent=gui
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(660,54);cap.Parent=notice
 local serial=0
 RS:WaitForChild('Remotes'):WaitForChild('LobbyFacilityState').OnClientEvent:Connect(function(data)
  if type(data)~='table' or not data.error then return end
  serial+=1;local current=serial;notice.Text=Text[data.error] or HeroText[data.error] or Text.Busy;notice.Visible=true
  task.delay(6,function() if serial==current then notice.Visible=false end end)
 end)
end
return V
