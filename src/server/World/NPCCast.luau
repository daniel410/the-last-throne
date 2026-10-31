-- Future regions require authored anchors; never spawn later-epic inhabitants in Deepwood.
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local Visual=require(script.Parent.NPCVisual)
local Cast={}
function Cast.templates()
 local storage=game:GetService('ServerStorage');local old=storage:FindFirstChild('NPCCastV1')
 if old then return old end
 local folder=Instance.new('Folder');folder.Name='NPCCastV1'
 for i,c in ipairs(Catalog.characters) do
  Visual.create(folder,c.id,Vector3.zero,{name=c.id,label=false})
  if i%5==0 then task.wait() end
 end
 folder.Parent=storage;return folder
end
function Cast.region(parent,region,anchors)
 local members=assert(Catalog.byRegion[region],'Unknown NPC region')
 -- Validate the full input before mutation so a missing anchor cannot leave half a cast.
 for _,c in ipairs(members) do assert(typeof(anchors[c.id])=='CFrame','Missing NPC anchor: '..c.id) end
 local folder=Instance.new('Folder');folder.Name='NPCs_'..region
 for _,c in ipairs(members) do
  local cf=anchors[c.id];local model=Visual.create(folder,c.id,Vector3.zero)
  model:PivotTo(cf)
 end
 folder.Parent=parent;return folder
end
function Cast.preview(parent,origin)
 local folder=Instance.new('Folder');folder.Name='NPCCastPreview';folder:SetAttribute('PreviewOnly',true);folder.Parent=parent
 for row,region in ipairs({'dawnspire','deepwood','frozen-vale','ember-caldera','gloamwood','haunted-graveyard'}) do
  local anchors={};local members=Catalog.byRegion[region]
  for i,c in ipairs(members) do anchors[c.id]=CFrame.new(origin+Vector3.new((i-(#members+1)/2)*8,0,(row-1)*16)) end
  Cast.region(folder,region,anchors);task.wait()
 end
 return folder
end
return Cast
