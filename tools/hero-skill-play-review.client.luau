local Run=game:GetService("RunService")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Visual=require(Client.K0SwordVisual)
local Effects=require(Client.AdvancedSkillVisual)
local control=game.ReplicatedStorage:WaitForChild("SkillReviewControl")
local folder=workspace:WaitForChild("LiveHeroSkillReview")
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable
camera.CFrame=CFrame.lookAt(Vector3.new(24,514,-39),Vector3.new(0,501,-8));camera.FieldOfView=58
local gui=Instance.new("ScreenGui");gui.Name="SkillReviewOnly";gui.Parent=game.Players.LocalPlayer:WaitForChild("PlayerGui")
local text=Instance.new("TextLabel");text.Size=UDim2.new(1,0,0,60);text.BackgroundColor3=Color3.fromRGB(20,28,38);text.TextColor3=Color3.new(1,1,1);text.TextSize=18;text.Font=Enum.Font.GothamMedium;text.Parent=gui
Visual.start() -- advances starter arrows/axes/orbs and cleans their lifetimes
Effects.start()
local frames,errors=0,{}
Run.PreSimulation:Connect(function(dt)
 local now=workspace:GetServerTimeNow()
 for _,c in ipairs(folder:GetChildren()) do if c:IsA("Model") and c:GetAttribute("K0ClassId") then
  local id=c:GetAttribute("K0SkillId");local d
  for _,candidate in ipairs(Config.Skills[c:GetAttribute("K0ClassId")]) do if candidate.id==id then d=candidate;break end end
  if d then
   local age=now-(c:GetAttribute("K0AttackStartedAt") or now)
   c:SetAttribute("K0AttackPhase",age<d.windup and "Windup" or age<d.windup+d.active and "Active" or "Recovery")
   local ok,err=pcall(Visual.renderArms,c,dt,now);if not ok then errors[#errors+1]=tostring(err) end
  end
 end end
 frames+=1
end)
Run.RenderStepped:Connect(function(dt)
 for _,c in ipairs(folder:GetChildren()) do if c:IsA("Model") then
  local ok,err=pcall(Visual.renderCharacter,c,dt,workspace:GetServerTimeNow());if not ok then errors[#errors+1]=tostring(err) end
 end end
 text.Text="LOCAL SKILL REVIEW  /  "..tostring(control:GetAttribute("Index") or 0).." / 32   |   Knight · Dwarf · Elf · Mage"
 gui:SetAttribute("Frames",frames);gui:SetAttribute("Errors",#errors)
end)
control:GetAttributeChangedSignal("Completed"):Connect(function() print("HERO_SKILL_PLAY_CLIENT",frames,"frames",#errors,"errors",table.concat(errors," | ")) end)
