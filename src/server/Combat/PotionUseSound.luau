-- Presentation only, called after the server applies a committed potion use.
local Debris = game:GetService("Debris")

local PotionUseSound = {}

function PotionUseSound.play(character)
	local head = character:FindFirstChild("Head")
	local emitter = head and head:IsA("BasePart") and head or character:FindFirstChild("HumanoidRootPart")
	if not emitter or not emitter:IsA("BasePart") then return end
	local previous = emitter:FindFirstChild("PotionDrinkSound")
	if previous then previous:Destroy() end
	local sound = Instance.new("Sound")
	sound.Name = "PotionDrinkSound"
	-- Single 1.76-second edit: two gulps, +12 dB; see assets/audio/potion-drink-v1.
	sound.SoundId = "rbxassetid://103385691872375"
	sound.Volume = 0.4
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance, sound.RollOffMaxDistance = 16, 60
	sound.Parent = emitter
	sound.Ended:Once(function() sound:Destroy() end)
	Debris:AddItem(sound, 5)
	sound:Play()
end

return PotionUseSound
