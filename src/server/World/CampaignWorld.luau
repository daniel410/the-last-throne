local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local W={}
function W.scope(epic)
 assert(type(epic)=='number' and Content.epics[epic], 'Unknown campaign epic')
 local content={zones={},chapters={},byId=Content.byId};local access={edges={}}
 for _,chapter in ipairs(Content.chapters)do
  if (chapter.epic or 1)==epic then
   table.insert(content.chapters,chapter);content.zones[chapter.zone]=Content.zones[chapter.zone]
  end
 end
 for _,edge in ipairs(Access.edges)do
  if content.zones[edge[1]] and content.zones[edge[2]]then table.insert(access.edges,edge)end
 end
 return {epic=epic,content=content,access=access}
end
function W.create(epic,world)
 require(script.Parent.StoryGateTemplates).prepare()
 -- No-argument creation is retained for offline art/QA tools only.
 if not epic then for id=1,#Content.epics do world=W.create(id,world)end;return world end
 local scope=W.scope(epic)
 if world and world.loadedEpics and world.loadedEpics[epic]then
  require(script.Parent.CampaignRouteClearance).retireBlockouts(world)
  require(script.Parent.CampaignSceneryCollision).apply(world.folder.EpicWorldArt['EpicWorldArt_'..epic])
  require(script.Parent.CampaignSceneryCollision).apply(world.folder.CampaignExpansion['Epic'..epic])
  return world
 end
 if epic==1 then
  local forest=require(script.Parent.DeepwoodWorld).create(world)
  world=forest
 elseif not world then
  local root=Instance.new('Model');root.Name='DeepwoodCampaign';root.Parent=workspace
  local terrain=Instance.new('Folder');terrain.Name='TerrainBlockout';terrain.Parent=root
  local objectives=Instance.new('Folder');objectives.Name='Objectives';objectives.Parent=root
  world={folder=root,terrain=terrain,nodes={},spawns={},positions={}}
 end
 world.loadedEpics=world.loadedEpics or {}
 if epic==3 then require(script.Parent.FrozenValeWorld).create(world)
 elseif epic==4 then require(script.Parent.EmberCalderaWorld).create(world)
 elseif epic==2 or epic==5 then require(script.Parent.LateEpicWorld).create(world,epic)end
 require(script.Parent.CampaignExpansionWorld).create(world,scope)
 require(script.Parent.CampaignCombatRouteWorld).create(world,scope)
 -- Archived Deepwood geometry still supplies anchors; live story metadata comes
 -- from the canonical campaign so outcomes and expansion gates agree with saves.
 for _,node in pairs(world.nodes)do
  local c=node.chapter and Content.byId[node.chapter.id]
  local g=c and node.goal and require(Shared.DeepwoodProgress).goal(c,node.goal.id)
  if g then node.chapter=c;node.goal=g end
 end
 require(script.Parent.DeepwoodActivityWorld).create(world)
 require(script.Parent.EpicWorldArt).create(world,scope)
 require(script.Parent.CampaignExpansionWorld).openEntrances(world,scope)
 require(script.Parent.CampaignSceneryPlacement).openGalleries(world,world.folder.CampaignExpansion['Epic'..epic])
 require(script.Parent.CampaignSceneryCollision).apply(world.folder.EpicWorldArt['EpicWorldArt_'..epic])
 require(script.Parent.CampaignSceneryCollision).apply(world.folder.CampaignExpansion['Epic'..epic])
 require(script.Parent.CampaignSceneryPlacement).apply(world,world.folder.EpicWorldArt['EpicWorldArt_'..epic])
 require(script.Parent.CampaignCombatRouteWorld).finish(world,scope)
 if epic==1 then require(script.Parent.DeepwoodConceptArt).finish(world)end
 world.loadedEpics[epic]=true
 world.folder:SetAttribute('Epic'..epic..'Ready',true)
 return world
end
return W
