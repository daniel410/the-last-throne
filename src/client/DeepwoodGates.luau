local RS=game:GetService('ReplicatedStorage')
local Content=require(RS.Shared.CampaignContent)
local Access=require(RS.Shared.CampaignAccess)
local Bounds=require(RS.Shared.CampaignBounds)
local Gates={}
local biomes={'CliffRock','CliffRock','SnowCliff','VolcanoCliff','CemeteryCliff'}
-- Overlapping, irregular boulders span the former 30 x 14 road seal.
local rocks={
 {x=-10,z=0,w=13,h=12,d=10,turn=-12},
 {x=0,z=1,w=14,h=14,d=11,turn=15},
 {x=10,z=-.5,w=13,h=11,d=10,turn=-22},
}
local function obstacle(g,templates)
 local model=Instance.new('Model');model.Name='StoryRockslide'
 model:SetAttribute('StoryZone',g.zone)
 model:SetAttribute('TDEnvironmentSource',biomes[g.epic])
 for i,spec in ipairs(rocks) do
  local rock=templates[biomes[g.epic]]:Clone();rock.Name='Boulder'..i
  local cf,size=rock:GetBoundingBox()
  local scale=Vector3.new(spec.w/size.X,spec.h/size.Y,spec.d/size.Z)
  local target=g.frame*CFrame.new(spec.x,spec.h/2,spec.z)*CFrame.Angles(0,math.rad(spec.turn),0)
  for _,part in ipairs(rock:GetChildren()) do
   if part:IsA('BasePart') then
    local relative=cf:ToObjectSpace(part.CFrame)
    part.Size=part.Size*scale
    part.CFrame=target*CFrame.new(relative.Position*scale)*relative.Rotation
   end
  end
  rock.Parent=model
 end
 local anchor=model.Boulder2:FindFirstChildWhichIsA('BasePart')
 local gui=Instance.new('BillboardGui');gui.Name='RoadBlocked';gui.Size=UDim2.fromOffset(240,60)
 gui.MaxDistance=75;gui.StudsOffsetWorldSpace=Vector3.new(0,10,0);gui.Parent=anchor
 local text=Instance.new('TextLabel');text.BackgroundTransparency=1;text.Size=UDim2.fromScale(1,1)
 text.Font=Enum.Font.GothamBold;text.TextSize=15;text.TextColor3=Color3.fromRGB(255,231,161)
 text.TextStrokeTransparency=.2;text.Text=string.format('ROAD BLOCKED\nComplete Story %d',g.required)
 text.AutoLocalize=false;text.Parent=gui
 return model
end
function Gates.create()
 local folder=Instance.new('Folder');folder.Name='PersonalStoryGates';folder.Parent=workspace
 local gates={}
 for _,edge in ipairs(Access.edges) do
  local a,b=Content.zones[edge[1]],Content.zones[edge[2]]
  if a.epic==b.epic then
   -- Zone-center midpoints can sit inside the camp or an incident connector.
   -- Put the seal inside the locked destination, beyond neighboring incident wings.
   local aa,bb=Bounds.ends(edge)
   local first,second=Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb))
   local direction=Vector3.new(second.X-first.X,0,second.Z-first.Z).Unit
   local middle=second+direction*20
   table.insert(gates,{frame=CFrame.lookAt(middle,middle+direction),zone=edge[2],required=b.requiresMain,epic=b.epic})
  end
 end
 local current,destroyed
 local function refresh()
  if destroyed then return end
  local templates=RS:FindFirstChild('StoryGateTemplates')
  if templates then
   for _,name in ipairs({'CliffRock','SnowCliff','VolcanoCliff','CemeteryCliff'})do
    local model=templates:FindFirstChild(name)
    if not model or not model:FindFirstChildWhichIsA('BasePart')then templates=nil;break end
   end
  end
  local journal=current and current.journal
  local chapter=journal and (Content.byId[journal.expeditionMission] or Content.mainChapters[math.min(Content.mainCount,journal.main+1)])
  for _,g in ipairs(gates) do
   local locked=chapter and not current.training and chapter.epic==g.epic and not Access.allowed(journal,g.zone)
   if locked and templates then
    if not g.model then g.model=obstacle(g,templates);g.model.Parent=folder end
   elseif g.model then
    -- Remove the scenery and every collision surface immediately.
    g.model:Destroy();g.model=nil
   end
  end
 end
 -- Snapshots can arrive before the template folder finishes replicating.
 local queued=false
 local added=RS.DescendantAdded:Connect(function(child)
  local templates=RS:FindFirstChild('StoryGateTemplates')
  if not queued and templates and (child==templates or child:IsDescendantOf(templates))then
   queued=true;task.defer(function()queued=false;refresh()end)
  end
 end)
 return {update=function(value) current=value;refresh() end,destroy=function()
  destroyed=true;added:Disconnect();folder:Destroy()
 end}
end
return Gates
