-- Status and debuff presentation accompanying the Blender-authored TD rig motion.
-- Server state remains authoritative.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EnemyVisual = {}
local Text=require(game:GetService('ReplicatedStorage').Shared.K0Text)
local Config=require(game:GetService('ReplicatedStorage').Shared.K0Config)
local PixelFX=require(script.Parent.PixelFX)
function EnemyVisual.statusText(model,current)
 local lines={}
 local stunUntil=model:GetAttribute('K0EnemyStunUntil')
 if type(stunUntil)=='number' and stunUntil>current then table.insert(lines,string.format(Text.EnemyStunned,stunUntil-current)) end
 local tauntUntil=model:GetAttribute('K0ProvokeUntil')
 if type(tauntUntil)=='number' and tauntUntil>current then table.insert(lines,string.format(Text.EnemyTaunted,tauntUntil-current)) end
 local attackUntil=model:GetAttribute('K0AttackDownUntil')
 if type(attackUntil)=='number' and attackUntil>current then
  table.insert(lines,string.format(Text.EnemyAttackDown,math.round((1-(model:GetAttribute('K0AttackDownMultiplier') or 1))*100),attackUntil-current))
 end
 local defenseUntil=model:GetAttribute('K0DefenseBreakUntil')
 if type(defenseUntil)=='number' and defenseUntil>current then
  table.insert(lines,string.format(Text.EnemyVulnerable,math.round((Config.Skills.knight[3].defenseBreakDamageMultiplier-1)*100),defenseUntil-current))
 end
 return table.concat(lines,'\n')
end

local started=false
local mounted=setmetatable({},{__mode='k'})
local function mount(enemies)
  if mounted[enemies] then return end;mounted[enemies]=true
  local stopMotion=require(script.Parent.K0EnemyMotion).start(enemies)
  local stopControl=require(script.Parent.K0EnemyControlEffects).start(enemies)
		local gravityEffects = {}
		local provokeEffects = {}
  local debuffLabels={}
		local render=RunService.RenderStepped:Connect(function(dt)
   local current=Workspace:GetServerTimeNow()
   for model,billboard in pairs(debuffLabels) do
    local human=model:FindFirstChildOfClass('Humanoid')
    if model.Parent~=enemies or not human or human.Health<=0 or EnemyVisual.statusText(model,current)=='' then billboard:Destroy();debuffLabels[model]=nil end
   end
			for model, effect in pairs(gravityEffects) do
				if model.Parent ~= enemies or not model:GetAttribute("K0GravityUntil") then
					effect:Destroy()
					gravityEffects[model] = nil
				end
			end
			for model, effect in pairs(provokeEffects) do
				local untilTime = model:GetAttribute("K0ProvokeUntil")
				if model.Parent ~= enemies or type(untilTime) ~= "number" or Workspace:GetServerTimeNow() >= untilTime then
					effect:Destroy()
					provokeEffects[model] = nil
				end
			end
			for _, model in enemies:GetChildren() do
				PixelFX.enemy(model,current)
				local provokeUntil = model:GetAttribute("K0ProvokeUntil")
				if type(provokeUntil) == "number" and Workspace:GetServerTimeNow() < provokeUntil and not provokeEffects[model] then
					local glow = Instance.new("Highlight")
					glow.Name, glow.Adornee = "ProvokeEffect", model
					glow.FillColor, glow.OutlineColor = Color3.fromRGB(180, 80, 25), Color3.fromRGB(255, 194, 90)
					glow.FillTransparency, glow.OutlineTransparency = 0.8, 0.1
					glow.DepthMode, glow.Parent = Enum.HighlightDepthMode.Occluded, model
					provokeEffects[model] = glow
				end
				if model:GetAttribute("K0GravityUntil") and not gravityEffects[model] then
					local glow = Instance.new("Highlight")
					glow.Name = "GravityEffect"
					glow.Adornee = model
					glow.FillColor = Color3.fromRGB(98, 43, 168)
					glow.OutlineColor = Color3.fromRGB(199, 152, 255)
					glow.FillTransparency, glow.OutlineTransparency = 0.65, 0.1
					glow.DepthMode = Enum.HighlightDepthMode.Occluded
					glow.Parent = model
					gravityEffects[model] = glow
				end
    local status=EnemyVisual.statusText(model,current)
    local anchor=model:FindFirstChild('HumanoidRootPart')
    local human=model:FindFirstChildOfClass('Humanoid')
    if status~='' and anchor and human and human.Health>0 then
     local billboard=debuffLabels[model]
     if not billboard then
      billboard=Instance.new('BillboardGui');billboard.Name='CombatDebuffs';billboard.Adornee=anchor;billboard.Size=UDim2.fromOffset(210,68);billboard.StudsOffsetWorldSpace=Vector3.new(0,(model:GetAttribute('TdMonsterTargetHeight') or 7)-anchor.Size.Y*1.5+4.0+(model:GetAttribute('StoryBoss') and .9 or 0),0);billboard.MaxDistance=100;billboard.AlwaysOnTop=false;billboard.Parent=anchor
      local label=Instance.new('TextLabel');label.Name='Status';label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.TextColor3=Color3.fromRGB(255,209,115);label.TextStrokeColor3=Color3.new();label.TextStrokeTransparency=.15;label.TextSize=12;label.Font=Enum.Font.GothamBold;label.AutoLocalize=false;label.Parent=billboard;debuffLabels[model]=billboard
     end
     billboard.Status.Text=status
    end

			end
		end)
 local ancestry
 ancestry=enemies.AncestryChanged:Connect(function()
  if enemies:IsDescendantOf(Workspace) then return end
  render:Disconnect();ancestry:Disconnect();stopMotion();stopControl();mounted[enemies]=nil
  for _,set in ipairs({gravityEffects,provokeEffects,debuffLabels})do for _,v in pairs(set)do v:Destroy()end end
 end)
end
function EnemyVisual.start()
 if started then return end;started=true
 local function discover(o)
  if o.Name=='Enemies' and o:IsA('Folder') and o.Parent and o.Parent.Name=='DeepwoodK0' then mount(o)end
 end
 Workspace.DescendantAdded:Connect(discover)
 local field=Workspace:FindFirstChild('DeepwoodK0');local enemies=field and field:FindFirstChild('Enemies');if enemies then discover(enemies)end
end

return EnemyVisual
