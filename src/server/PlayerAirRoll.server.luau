--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage.Shared.PlayerAirRollSettings)
local airRoll = ReplicatedStorage.Remotes.PlayerAirRoll
local lastAirRollAt: { [Player]: number } = {}

airRoll.OnServerEvent:Connect(function(player: Player, character: any)
	local now = workspace:GetServerTimeNow()
	local last = lastAirRollAt[player]
	if last and now - last < Settings.DURATION then return end
	if character == nil or character ~= player.Character or player:GetAttribute("TLTTravelLock") then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = humanoid and humanoid.RootPart
	if not humanoid or not root or root.Anchored or humanoid.Health <= 0 or humanoid.SeatPart then return end
	local state = humanoid:GetState()
	-- The owner's jump state can arrive before their new root position.
	if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then return end

	-- Replicate the visual pose. Physics and combat are unaffected by this request.
	lastAirRollAt[player] = now
	airRoll:FireAllClients(character, now)
end)

Players.PlayerRemoving:Connect(function(player)
	lastAirRollAt[player] = nil
end)
