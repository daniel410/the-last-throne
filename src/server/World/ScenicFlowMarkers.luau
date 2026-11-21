-- Authored path data for client-side animation of decorative water and lava.
local CollectionService = game:GetService('CollectionService')
local Markers = {}

function Markers.track(part, from, to, speed, phase, mode)
	part:SetAttribute('ScenicFlowStart', from)
	part:SetAttribute('ScenicFlowEnd', to)
	part:SetAttribute('ScenicFlowSpeed', speed)
	part:SetAttribute('ScenicFlowPhase', phase)
	part:SetAttribute('ScenicFlowSize', part.Size)
	part:SetAttribute('ScenicFlowAlpha', part.Transparency)
	part:SetAttribute('ScenicFlowMode', mode or 'current')
	part.CFrame = CFrame.new(from:Lerp(to, phase)) * part.CFrame.Rotation
	CollectionService:AddTag(part, 'TLTScenicFlow')
end

return Markers
