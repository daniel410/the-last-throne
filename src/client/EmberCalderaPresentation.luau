-- Personal saved mechanism state; no remote completion or damage authority.
local V={}
function V.update(journal)
 local world=workspace:FindFirstChild('DeepwoodCampaign');local props=world and world:FindFirstChild('EmberStoryProps')
 if not props then return end
 for _,part in ipairs(props:GetChildren())do if part:IsA('BasePart')then
  local done=journal.flags[part:GetAttribute('StoryVisualKey')]==true
  part.Color=done and Color3.fromRGB(85,202,196) or part.Name=='FurnaceCore' and Color3.fromRGB(255,124,43) or Color3.fromRGB(194,147,83)
 end end
 local activities=world:FindFirstChild('AdventureActivities')
 if activities then for _,model in ipairs(activities:GetChildren()) do
  local key=model:GetAttribute('StoryVisualKey')
  if key then
   local done=journal.flags[key]==true
   for _,piece in ipairs(model:GetChildren()) do if piece:IsA('BasePart') and
    (piece.Name=='ValveHandwheel' or piece.Name=='HandwheelSpoke' or piece.Name=='WinchCrank' or piece.Name=='CrankGrip') then
     -- Personal completion changes the operative handle only; wood/iron keep their authored materials.
     piece.Color=done and Color3.fromRGB(85,202,196) or Color3.fromRGB(163,125,63)
   end end
  end
 end end
end
return V
