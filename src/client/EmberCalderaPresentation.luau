-- Personal saved mechanism state; no remote completion or damage authority.
local V={}
function V.update(journal)
 local world=workspace:FindFirstChild('DeepwoodCampaign');local props=world and world:FindFirstChild('EmberStoryProps')
 if not props then return end
 for _,part in ipairs(props:GetChildren())do if part:IsA('BasePart')then
  local done=journal.flags[part:GetAttribute('StoryVisualKey')]==true
  part.Color=done and Color3.fromRGB(85,202,196) or part.Name=='FurnaceCore' and Color3.fromRGB(255,124,43) or Color3.fromRGB(194,147,83)
 end end
end
return V
