-- Isolated Studio GUI fixture using the actual HUD and lobby modules. Only
-- LocalPlayer is replaced with a PlayerGui double; rendering/input is not tested.
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "UI fixture requires an empty local place")

local client = assert(StarterPlayer.StarterPlayerScripts:FindFirstChild("Client"))
local fixture = Instance.new("Folder")
fixture.Name = "K0ResourceUiFixture"
fixture.Parent = workspace
local playerGui = Instance.new("Folder")
playerGui.Name = "PlayerGui"
playerGui.Parent = fixture
local copies = {}
local report = { kind = "K0_RESOURCE_UI_NATIVE", checks = 0, failures = {},
	coverage = "Actual GUI constructors and state refresh, native GUI instances, LocalPlayer double; no rendered client or device" }

local function check(condition, message)
	report.checks += 1
	assert(condition, message)
end
local function copyModule(name, mobileViewport, touch)
	local original = assert(client:FindFirstChild(name))
	local replacement = [[local Players = { LocalPlayer = { WaitForChild = function(_, name)
  assert(name == "PlayerGui"); return script.FixturePlayerGui.Value
end,
 GetAttribute=function(_,name) return script.FixturePlayerGui.Value:GetAttribute(name) end,
 SetAttribute=function(_,name,value) script.FixturePlayerGui.Value:SetAttribute(name,value) end,
 GetAttributeChangedSignal=function(_,name) return script.FixturePlayerGui.Value:GetAttributeChangedSignal(name) end,
} }]]
	local source, count = original.Source:gsub('local Players = game:GetService%("Players"%)', function() return replacement end)
	assert(count == 1, name .. " LocalPlayer binding changed")
	if mobileViewport then
		source=source:gsub('local UserInputService = game:GetService%("UserInputService"%)','local UserInputService = {TouchEnabled='..tostring(touch)..'}')
		source=source:gsub('local viewport = root.AbsoluteSize',string.format('local viewport = Vector2.new(%d,%d)',mobileViewport.X,mobileViewport.Y))
	end
	local copy = Instance.new("ModuleScript")
	copy.Name, copy.Source = "ResourceUiQa" .. name, source
	local value = Instance.new("ObjectValue")
	value.Name, value.Value, value.Parent = "FixturePlayerGui", playerGui, copy
	copy.Parent = client
	table.insert(copies, copy)
	return require(copy)
end


for _,touch in ipairs({true,false}) do
 for _,size in ipairs({Vector2.new(1280,591),Vector2.new(1050,506),Vector2.new(844,390),Vector2.new(740,360),Vector2.new(568,320),Vector2.new(1920,1080)}) do
  local hud=copyModule("K0Hud",size,touch).create()
  local root=playerGui.DeepwoodTrainingHud.Root
  local bar=root.SkillBar
  check(bar.Position.Y.Scale==1 and bar.Position.Y.Offset==(touch and -12 or -24),'bottom anchor '..tostring(size))
  local scale=bar.UIScale.Scale
  local left=size.X/2+bar.Position.X.Offset-528*scale/2
  local top=size.Y+bar.Position.Y.Offset-68*scale
  local actions=root.Actions
  local controlScale=actions.UIScale.Scale
  local rightControlsLeft=size.X-20+(8-172)*controlScale
  local count=0
  for _,b in ipairs(bar:GetChildren()) do if b:IsA('GuiButton') then
   count+=1
   check(b.Position.Y.Offset==0,'single bottom row '..b.Name)
   check(top>=0 and top+64*scale<=size.Y,'vertical bounds '..b.Name)
   check(left+b.Position.X.Offset*scale>=0 and left+(b.Position.X.Offset+64)*scale<=rightControlsLeft,'clear right controls '..b.Name..tostring(size))
  end end
  check(count==7,'two potions and five skills')
 end
end
for _,m in ipairs(copies) do m:Destroy() end
fixture:Destroy()
print('HUD_BOTTOM_NATIVE '..report.checks..' checks PASS')
