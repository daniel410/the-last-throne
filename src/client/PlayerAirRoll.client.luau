--!strict
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Settings = require(Shared:WaitForChild("PlayerAirRollSettings"))
local airRoll = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerAirRoll") :: RemoteEvent

local player = Players.LocalPlayer
local humanoid: Humanoid? = nil
local jumpAvailable = false
local stateConnection: RBXScriptConnection? = nil

type Joint = AnimationConstraint | Motor6D
type JointPose = { joint: Joint, basis: CFrame, pitch: number?, base: CFrame? }
type Roll = { humanoid: Humanoid, startedAt: number, joints: { JointPose } }
local rolls: { [Model]: Roll } = {}

local LEG_PITCH = {
	LeftHip = math.rad(48), RightHip = math.rad(48),
	["Left Hip"] = math.rad(42), ["Right Hip"] = math.rad(42),
	LeftKnee = math.rad(-70), RightKnee = math.rad(-70),
}

local function playRoll(character: Model, rigHumanoid: Humanoid, startedAt: number)
	local root = rigHumanoid.RootPart
	if not root then return end
	local joints: { JointPose } = {}
	local hasRootJoint = false
	for _, item in character:GetDescendants() do
		if not (item:IsA("Motor6D") or (item:IsA("AnimationConstraint") and item.IsKinematic)) then continue end
		local child = item.Part1
		if not child then continue end
		if item.Part0 == root and (child.Name == "LowerTorso" or child.Name == "Torso") then
			hasRootJoint = true
			table.insert(joints, { joint = item, basis = item.C0 })
		else
			local pitch = LEG_PITCH[item.Name]
			if pitch then table.insert(joints, { joint = item, basis = item.C0.Rotation, pitch = pitch }) end
		end
	end
	if hasRootJoint then rolls[character] = { humanoid = rigHumanoid, startedAt = startedAt, joints = joints } end
end

local function tryJump()
	local currentHumanoid = humanoid
	local character = player.Character
	if not jumpAvailable or not character or not currentHumanoid or currentHumanoid.Parent ~= character
		or currentHumanoid.Health <= 0 or currentHumanoid.SeatPart or currentHumanoid.FloorMaterial ~= Enum.Material.Air
		or not currentHumanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
		or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox()
		or player:GetAttribute("TLTTravelLock") or player:GetAttribute("TLTCheckpointLoading")
		or player:GetAttribute("TLTLobbyPanelOpen") then return end
	local state = currentHumanoid:GetState()
	if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then return end
	local root = currentHumanoid.RootPart
	if not root or root.Anchored then return end

	jumpAvailable = false
	local boost = math.max(0, Settings.LAUNCH_SPEED - root.AssemblyLinearVelocity.Y)
	root:ApplyImpulse(Vector3.new(0, root.AssemblyMass * boost, 0))
	playRoll(character, currentHumanoid, workspace:GetServerTimeNow())
	airRoll:FireServer(character)
end

local function bindCharacter(character: Model)
	local found = character:WaitForChild("Humanoid", 10)
	if player.Character ~= character or not found or not found:IsA("Humanoid") then return end
	if stateConnection then stateConnection:Disconnect() end
	humanoid = found
	jumpAvailable = false
	stateConnection = found.StateChanged:Connect(function(previous, state)
		if state == Enum.HumanoidStateType.Jumping then
			jumpAvailable = previous == Enum.HumanoidStateType.Running
				or previous == Enum.HumanoidStateType.RunningNoPhysics
				or previous == Enum.HumanoidStateType.Landed
		elseif state ~= Enum.HumanoidStateType.Freefall then
			jumpAvailable = false
		end
	end)
end

local function bindTouchJump(playerGui: PlayerGui)
	local buttons: { [GuiButton]: RBXScriptConnection } = {}
	local jumpTouch: InputObject? = nil
	local function watch(item: Instance)
		if not item:IsA("GuiButton") or item.Name ~= "JumpButton" or buttons[item] then return end
		local touchGui = item:FindFirstAncestor("TouchGui")
		if not touchGui or not touchGui:IsA("ScreenGui") then return end
		buttons[item] = item.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch or input.UserInputState ~= Enum.UserInputState.Begin
				or jumpTouch or not touchGui.Enabled or GuiService.MenuIsOpen then return end
			jumpTouch = input
			tryJump()
		end)
	end
	UserInputService.InputEnded:Connect(function(input)
		if input == jumpTouch then jumpTouch = nil end
	end)
	GuiService.MenuOpened:Connect(function() jumpTouch = nil end)
	playerGui.DescendantAdded:Connect(watch)
	playerGui.DescendantRemoving:Connect(function(item)
		if not item:IsA("GuiButton") then return end
		local connection = buttons[item]
		if connection then
			connection:Disconnect()
			buttons[item] = nil
			jumpTouch = nil
		end
	end)
	for _, item in playerGui:GetDescendants() do watch(item) end
end

local function start()
	player.CharacterAdded:Connect(bindCharacter)
	if player.Character then task.spawn(bindCharacter, player.Character) end
	local spaceDown = false
	UserInputService.InputBegan:Connect(function(input, processed)
		if input.KeyCode ~= Enum.KeyCode.Space or spaceDown then return end
		spaceDown = true
		if not processed then tryJump() end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Space then spaceDown = false end
	end)
	UserInputService.WindowFocusReleased:Connect(function() spaceDown = false end)
	-- The default gamepad controller consumes ButtonA. Observe it before that
	-- binding and pass it through so the stock ground jump still runs.
	ContextActionService:BindActionAtPriority("PlayerAirRoll", function(_, state)
		if state == Enum.UserInputState.Begin and not GuiService.SelectedObject then tryJump() end
		return Enum.ContextActionResult.Pass
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonA)
	local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
	bindTouchJump(playerGui)

	airRoll.OnClientEvent:Connect(function(character: Model, startedAt: number)
		if not character or not character.Parent or character == player.Character then return end
		if workspace:GetServerTimeNow() - startedAt >= Settings.DURATION then return end
		local otherHumanoid = character:FindFirstChildOfClass("Humanoid")
		if otherHumanoid then playRoll(character, otherHumanoid, startedAt) end
	end)

	-- Remove our previous pose before Animator runs, including joints it leaves untouched.
	RunService.PreAnimation:Connect(function()
		for _, roll in rolls do
			for _, pose in roll.joints do
				if pose.base and pose.joint.Parent then pose.joint.Transform = pose.base end
				pose.base = nil
			end
		end
	end)
	RunService.PreSimulation:Connect(function()
		if next(rolls) == nil then return end
		local now = workspace:GetServerTimeNow()
		for character, roll in rolls do
			local t = math.clamp((now - roll.startedAt) / Settings.DURATION, 0, 1)
			if t == 1 or not character.Parent or roll.humanoid.Health <= 0
				or (roll.humanoid == humanoid and roll.humanoid.FloorMaterial ~= Enum.Material.Air) then
				rolls[character] = nil
				continue
			end
			local forward = -2 * math.pi * t * t * (3 - 2 * t)
			local tuck = math.sin(math.pi * t) ^ 2
			for _, pose in roll.joints do
				local joint = pose.joint
				if not joint.Parent then continue end
				local base = joint.Transform
				local pitch = if pose.pitch then pose.pitch * tuck else forward
				pose.base = base
				joint.Transform = pose.basis:Inverse() * CFrame.Angles(pitch, 0, 0) * pose.basis * base
			end
		end
	end)
end

start()
