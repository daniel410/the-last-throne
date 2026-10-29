-- The normal Throne Defense track, reused without changing the source experience.
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Music = {}

function Music.start()
	local sound = SoundService:FindFirstChild("TLTBackgroundMusic")
	if sound and not sound:IsA("Sound") then return end
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = "TLTBackgroundMusic"
		sound.Parent = SoundService
	end
	sound.SoundId = "rbxassetid://73105938035554"
	sound.Looped = true
	if not sound.IsPlaying then
		sound.Volume = 0
		sound:Play()
		TweenService:Create(sound, TweenInfo.new(1.5), { Volume = 0.2 }):Play()
	end
end

return Music
