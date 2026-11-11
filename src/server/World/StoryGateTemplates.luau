-- Pinned TD meshes only; provenance: td-deepwood-environment/manifest.json.
local Templates={}
function Templates.prepare()
 local storage=game:GetService('ReplicatedStorage')
 if storage:FindFirstChild('StoryGateTemplates') then return end
 local folder=Instance.new('Folder');folder.Name='StoryGateTemplates'
 local source=game:GetService('ServerStorage').TDMapModels
 for _,name in ipairs({'CliffRock','SnowCliff','VolcanoCliff','CemeteryCliff'}) do
  local model=Instance.new('Model');model.Name=name
  for _,part in ipairs(source[name]:GetDescendants()) do
   if part:IsA('MeshPart') then
    local copy=part:Clone();copy:ClearAllChildren()
    copy.Anchored=true;copy.CanCollide=true;copy.CanTouch=false;copy.CanQuery=false
    copy.Transparency=0;copy.CastShadow=true;copy.Parent=model
   end
  end
  assert(#model:GetChildren()>0,'Missing pinned roadblock mesh: '..name)
  model.Parent=folder
 end
 folder.Parent=storage
end
return Templates
