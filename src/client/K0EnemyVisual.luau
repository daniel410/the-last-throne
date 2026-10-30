-- Temporary poses for the R6 control rig and its welded TD visual pieces.
-- Server state remains authoritative.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EnemyVisual = {}
local Text=require(game:GetService('ReplicatedStorage').Shared.K0Text)
local Config=require(game:GetService('ReplicatedStorage').Shared.K0Config)
function EnemyVisual.statusText(model,current)
 local lines={}
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

local function legTransform(angle, part)
	-- Conservative clearance of the source mesh's bounding box during its
	-- hip rotation. Presentation only; server position and collision stay put.
	local lift = 0
	if part and part:IsA("MeshPart") then
		lift = math.max(0, part.Size.Z * 0.5 * math.abs(math.sin(angle)) - part.Size.Y * (1 - math.cos(angle)))
	end
	return CFrame.new(0, lift, 0) * CFrame.Angles(angle, 0, 0)
end

function EnemyVisual.start()
	task.spawn(function()
		local field = Workspace:WaitForChild("DeepwoodK0", 30)
		local enemies = field and field:WaitForChild("Enemies", 10)
		if not enemies then return end
		local gravityEffects = {}
		local provokeEffects = {}
  local debuffLabels={}
		RunService.RenderStepped:Connect(function(dt)
			local alpha = math.clamp(dt * 15, 0, 1)
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
      billboard=Instance.new('BillboardGui');billboard.Name='CombatDebuffs';billboard.Adornee=anchor;billboard.Size=UDim2.fromOffset(210,40);billboard.StudsOffset=Vector3.new(0,5.8,0);billboard.MaxDistance=100;billboard.AlwaysOnTop=false;billboard.Parent=anchor
      local label=Instance.new('TextLabel');label.Name='Status';label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.TextColor3=Color3.fromRGB(255,209,115);label.TextStrokeColor3=Color3.new();label.TextStrokeTransparency=.15;label.TextSize=12;label.Font=Enum.Font.GothamBold;label.AutoLocalize=false;label.Parent=billboard;debuffLabels[model]=billboard
     end
     billboard.Status.Text=status
    end
				local torso = model:FindFirstChild("Torso")
				local root = model:FindFirstChild("HumanoidRootPart")
				if not torso or not root then continue end
				local rightArm = torso:FindFirstChild("Right Shoulder")
				local leftArm = torso:FindFirstChild("Left Shoulder")
				local rightLeg = torso:FindFirstChild("Right Hip")
				local leftLeg = torso:FindFirstChild("Left Hip")
				if not rightArm or not leftArm or not rightLeg or not leftLeg then continue end
				local state = model:GetAttribute("K0EnemyState")
				local rightAngle, leftAngle, legAngle = 0, 0, 0
				local velocity = root.AssemblyLinearVelocity
				if model:GetAttribute("EnemyKind") == "Slime" then
					-- Animate only the torso carrying the single TD slime mesh.
					-- These hops do not move the server's collision or hit origin.
					local joint = root:FindFirstChild("RootJoint")
					if joint and joint:IsA("Motor6D") then
						local lift = 0
						if state == "Chase" and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.6 then
							lift = math.abs(math.sin(os.clock() * 7)) * 0.45
						elseif state == "Windup" then lift = -0.10
						elseif state == "Active" then lift = 0.35 end
						joint.Transform = joint.Transform:Lerp(CFrame.new(0, lift, 0), alpha)
					end
				end
				if state == "Chase" and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.6 then
					legAngle = math.sin(os.clock() * 8) * 0.35
					rightAngle, leftAngle = -legAngle * 0.7, legAngle * 0.7
				elseif state == "Windup" or state == "Active" then
					local weapon = if state == "Windup" then 1.15 else -1.35
					local offHand = if model:GetAttribute("K0Telegraph") == "Unblockable"
						then (if state == "Windup" then 0.8 else -0.9) else (if state == "Windup" then 0.15 else 0)
					if model:GetAttribute("TdWeaponShoulder") == "Left Shoulder" then
						leftAngle, rightAngle = weapon, offHand
					else
						rightAngle, leftAngle = weapon, offHand
					end
				end
				rightArm.Transform = rightArm.Transform:Lerp(CFrame.Angles(rightAngle, 0, 0), alpha)
				leftArm.Transform = leftArm.Transform:Lerp(CFrame.Angles(leftAngle, 0, 0), alpha)
				local visual = model:FindFirstChild("TdMonsterVisual")
				local meshRight = visual and visual:FindFirstChild("LegL")
				local meshLeft = visual and visual:FindFirstChild("LegR")
				rightLeg.Transform = rightLeg.Transform:Lerp(legTransform(legAngle, meshRight), alpha)
				leftLeg.Transform = leftLeg.Transform:Lerp(legTransform(-legAngle, meshLeft), alpha)
			end
		end)
	end)
end

return EnemyVisual
