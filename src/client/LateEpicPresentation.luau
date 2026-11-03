-- Per-hero visuals from confirmed saves; never changes shared progression.
local V={}
function V.update(journal)
 local world=workspace:FindFirstChild('DeepwoodCampaign');local props=world and world:FindFirstChild('LateEpicProps')
 if not props then return end
 for _,object in ipairs(props:GetChildren())do
  local hide=object:GetAttribute('LateStoryHideKey');local restore=object:GetAttribute('LateStoryRestoreKey')
  local pieces=object:IsA('BasePart') and {object} or object:GetDescendants()
  for _,p in ipairs(pieces)do if p:IsA('BasePart')then
   if hide then p.LocalTransparencyModifier=journal.flags[hide] and 1 or 0 end
   if restore and p.Material==Enum.Material.Neon then p.Color=journal.flags[restore] and Color3.fromRGB(109,222,198) or Color3.fromRGB(181,97,232)end
  end end
 end
end
return V
