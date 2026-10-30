-- Prompt visibility is client-side; always recheck the live server life/location.
local Access={}
function Access.allowed(player,prompt)
 if workspace:GetAttribute('TLTServerRole')~='Lobby' or player:GetAttribute('K0SessionPhase')~='Lobby' or player:GetAttribute('TLTTravelLock') then return false end
 if not prompt or not prompt.Enabled or not prompt:IsDescendantOf(workspace) or not prompt.Parent:IsA('BasePart') then return false end
 local character=player.Character;local root=character and character:FindFirstChild('HumanoidRootPart');local human=character and character:FindFirstChildOfClass('Humanoid')
 if not root or not root:IsA('BasePart') or not human or human.Health<=0 or character:GetAttribute('K0SpawnReady')~=true then return false end
 local distance=(root.Position-prompt.Parent.Position).Magnitude
 return distance==distance and distance<=prompt.MaxActivationDistance+2
end
return Access
