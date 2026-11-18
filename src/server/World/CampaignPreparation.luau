-- Build a region into its own scene/tables. Failed attempts never publish nodes
-- into the live world, and cannot delete concurrent encounters or followers.
local P={}
function P.new(name)
 local root=Instance.new('Model');root.Name=name or 'DeepwoodCampaign';root.Parent=workspace
 local terrain=Instance.new('Folder');terrain.Name='TerrainBlockout';terrain.Parent=root
 local objectives=Instance.new('Folder');objectives.Name='Objectives';objectives.Parent=root
 return {folder=root,terrain=terrain,nodes={},spawns={},positions={},loadedEpics={},readyEpics={},geometryEpics={}}
end
local function mergeScene(source,destination)
 for _,child in ipairs(source:GetChildren())do
  local existing=destination:FindFirstChild(child.Name)
  if child:IsA('Folder') and existing and existing:IsA('Folder')then
   mergeScene(child,existing);child:Destroy()
  else child.Parent=destination end
 end
 for name,value in pairs(source:GetAttributes())do destination:SetAttribute(name,value)end
end
local function mergeWorld(stage,world)
 mergeScene(stage.folder,world.folder)
 for key,value in pairs(stage)do
  if key~='folder' and key~='terrain' and key~='staging' and key~='loadedEpics' and key~='readyEpics' and key~='geometryEpics' then
   if type(value)=='table' then
    world[key]=world[key]or {}
    if key=='lateCompanionCamps'then for _,entry in ipairs(value)do table.insert(world[key],entry)end
    else for id,entry in pairs(value)do world[key][id]=entry end end
   else world[key]=value end
  end
 end
 stage.folder:Destroy()
end
function P.prepare(epic,world)
 if world.loadedEpics[epic]then return world end
 if not world.geometryEpics[epic]then
  local stage=P.new('CampaignPreparing');stage.staging=true
  local ok,err=xpcall(function()require(script.Parent.CampaignWorld).create(epic,stage)end,debug.traceback)
  if not ok then
   if epic==1 then
    local deepwood=require(script.Parent.DeepwoodWorld)
    if deepwood.current==stage then deepwood.current=nil end
   end
   stage.folder:Destroy()
   -- Deterministic terrain fills are rebuilt on retry. Until then no spawn,
   -- node or readiness is published for this region. Existing scenes survive.
   error(err)
  end
  stage.folder:SetAttribute('Epic'..epic..'Ready',nil)
  mergeWorld(stage,world)
  if epic==1 then require(script.Parent.DeepwoodWorld).current=world end
  world.geometryEpics[epic]=true
 end
 -- Committed geometry is reused if a connecting-road/finalization pass fails.
 -- Incomplete roads are discarded by connectOverland before retrying them.
 require(script.Parent.EpicWorldArt).connectOverland(world)
 require(script.Parent.RegionalConceptArt).finish(world)
 require(script.Parent.CampaignSurfaceFinish).apply(world)
 world.loadedEpics[epic]=true
 return world
end
return P
