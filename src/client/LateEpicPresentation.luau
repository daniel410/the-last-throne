-- Per-hero visuals from confirmed saves; streamed props reapply the last snapshot.
local V={}
local current,connected
local function apply(object)
 if not current then return end
 local hide=object:GetAttribute('LateStoryHideKey');local restore=object:GetAttribute('LateStoryRestoreKey')
 if not hide and not restore then return end
 local pieces=object:IsA('BasePart') and {object} or object:GetDescendants()
 for _,p in ipairs(pieces)do if p:IsA('BasePart')then
  if hide then p.LocalTransparencyModifier=current.flags[hide] and 1 or 0 end
  if restore and p.Material==Enum.Material.Neon then p.Color=current.flags[restore] and Color3.fromRGB(109,222,198) or Color3.fromRGB(181,97,232)end
 end end
end
function V.update(journal)
 current=journal
 if not connected then
  connected=workspace.DescendantAdded:Connect(function(object)
   if object:GetAttribute('LateStoryHideKey') or object:GetAttribute('LateStoryRestoreKey') then task.defer(apply,object)
   elseif object:IsA('BasePart') and object.Parent and object.Parent:GetAttribute('LateStoryHideKey')then task.defer(apply,object.Parent)end
  end)
 end
 local world=workspace:FindFirstChild('DeepwoodCampaign');local props=world and world:FindFirstChild('LateEpicProps')
 if props then for _,object in ipairs(props:GetChildren())do apply(object)end end
end
return V
