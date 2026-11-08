-- Real generated terrain/objects/GUI and escort motion in an isolated edit engine.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local P=require(Shared.DeepwoodProgress)
local Bounds=require(Shared.CampaignBounds)
local Access=require(Shared.CampaignAccess)
local CP=require(Shared.CheckpointTravel)
local World=game.ServerScriptService.Server.World
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local report={checks=0,samples=0,parts=0,incidents=0,steps=0,blockers={},scope='isolated geometry, server activity/escort, saved checkpoints and native TD map; no live DataStore or real device acceptance'}
local function check(v,m)report.checks+=1;assert(v,m)end
local world
for epic=1,5 do world=require(World.CampaignWorld).create(epic,world);print('EXPANSION_NATIVE_EPIC',epic)end
local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.folder};params.RespectCanCollide=true
local rays=RaycastParams.new();rays.FilterType=Enum.RaycastFilterType.Include;rays.FilterDescendantsInstances={world.terrain};rays.RespectCanCollide=true
local function sample(c,g,at)
 report.samples+=1
 local y=Bounds.surface(at.X,at.Z);at=Vector3.new(at.X,y or at.Y,at.Z)
 local hit=workspace:Raycast(at+Vector3.new(0,8,0),Vector3.new(0,-24,0),rays)
 if not hit or math.abs(hit.Position.Y-at.Y)>1 then table.insert(report.blockers,{chapter=c.id,goal=g.id,kind='floor',at={at.X,at.Y,at.Z},part=hit and hit.Instance:GetFullName()})end
 local parts=workspace:GetPartBoundsInBox(CFrame.new(at+Vector3.new(0,3.5,0)),Vector3.new(4,5.5,4),params)
 for _,part in ipairs(parts)do table.insert(report.blockers,{chapter=c.id,goal=g.id,kind='body',at={at.X,at.Y,at.Z},part=part:GetFullName()})end
 check(Bounds.supported(at.X,at.Y+3,at.Z),'authority includes incident floor')
 check(Access.region(at.X,at.Z)==c.zone,'incident remains in its own story zone')
end
for _,c in ipairs(C.chapters)do
 for _,g in ipairs(c.expansionGoals)do
  report.incidents+=1
  check(world.nodes[c.id..':'..g.id]~=nil,'objective anchor exists '..c.id..g.id)
  local area;for _,a in ipairs(C.zones[c.zone].expansionAreas)do if a.id==g.area then area=a end end
  local entry,center=Vector3.new(table.unpack(area.entry)),Vector3.new(table.unpack(area.center))
  local n=math.max(1,math.ceil((center-entry).Magnitude/12))
  for i=0,n do sample(c,g,entry:Lerp(center,i/n))end
  for _,step in ipairs(g.activity.steps)do
   report.steps+=1;check(world.activityNodes[c.id..':'..g.id..':'..step.id]~=nil,'actual activity step exists')
   sample(c,g,Vector3.new(table.unpack(step.position)))
  end
 end
 task.wait()
end
for _,v in ipairs(world.folder:GetDescendants())do if v:IsA('BasePart')then report.parts+=1 end end
print('EXPANSION_NATIVE_GEOMETRY '..game.HttpService:JSONEncode({samples=report.samples,parts=report.parts,blockers=report.blockers}))
check(#report.blockers==0,'new wings and connectors have no holes or body blockers')
-- A genuine story actor walks Finn's new route, saves steps, and resumes after removal.
local function finish(s,c)
 for _,g in ipairs(c.goals)do if P.required(s,g)then for _,step in ipairs(g.activity and g.activity.steps or {false})do
  s=assert(P.apply(s,c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared',step and step.id or nil))
 end end end
 return s
end
local journal=P.new()
for i=1,12 do journal=finish(journal,C.mainChapters[i])end
journal=assert(P.enableExpansion(journal))
local chapter=C.byId['GW-06'];local escort=chapter.expansionGoals[2]
for _,g in ipairs(chapter.goals)do
 if g==escort then break end
 if P.required(journal,g)then for _,step in ipairs(g.activity and g.activity.steps or {false})do journal=assert(P.apply(journal,chapter.id,g.id,step and step.choices and step.choices[1].id or nil,step and step.id or nil))end end
end
check(escort.activity.mode=='escort'and escort.activity.actor=='Finn','Finn participates as a real moving escort')
local root=Instance.new('Part');root.Anchored=true;root.Position=Vector3.new(table.unpack(escort.position));root.Parent=workspace
local fake={UserId=194};local enemies=Instance.new('Folder');enemies.Parent=workspace
local engine=require(game.ServerScriptService.Server.Story.DeepwoodActivities).create({players=function()return {fake}end,
 active=function()return {heroId='hero'}end,context=function()return {heroId='hero'},root end,state=function()return journal end,
 world=world,enemies=enemies,publish=function()end,enqueue=function(_,_,c,g,choice,id)journal=assert(P.apply(journal,c.id,g.id,choice,id))end})
engine.startEscort(fake,chapter,escort)
local key=chapter.id..':'..escort.id
local data=engine.projection(fake,'hero');check(data[key]~=nil,'live escort created')
local initial=data[key].actorPosition
local restarted=false
for tick=1,800 do
 local view=engine.projection(fake,'hero');local state=view[key]
 if not state then break end
 root.Position=state.actorPosition
 engine.update(.25)
 if tick==5 then local moved=engine.projection(fake,'hero');check(moved[key]and (moved[key].actorPosition-initial).Magnitude>1,'Finn walks rather than teleporting')end
 local count=(journal.activities or {})[key]or 0
 if count==1 and not restarted then
  restarted=true
  engine.remove(fake)
  local saved=Vector3.new(table.unpack(escort.activity.steps[count].position));root.Position=saved
  engine.update(.25)
  local restored=engine.projection(fake,'hero');check(restored[key]and (restored[key].actorPosition-saved).Magnitude<3,'escort resumes from the saved substep')
 end
 if tick%20==0 then task.wait()end
end
check(journal.flags[key],'Finn reaches every authored rescue marker')
check(CP.allowed(journal,key)and CP.allowed(journal,'exit:'..key),'completed escort opens only its saved checkpoints')
require(World.StoryCheckpointPortal).ensure(world,journal,function()end)
check(world.folder.ExpansionReturnPoints:FindFirstChild('exit:'..key)~=nil,'actual local return point constructed')
engine.remove(fake);root:Destroy();enemies:Destroy()
-- Personal before/after visuals and late stream-in use confirmed journal flags.
local presentation=require(Client.CampaignExpansionPresentation)
local scene=world.folder.CampaignExpansion.Epic2:FindFirstChild('GW-06_exp_2')
local before=scene.UnresolvedIncident;local after=scene.RestoredIncident
presentation.update({journal=P.new()})
check(after:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'unearned restoration hidden')
presentation.update({journal=journal})
check(after:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'saved restoration visible')
check(before:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'old state hidden after solution')
local clone=after:Clone();clone.Name='StreamingRejoin';clone.Parent=scene;task.wait()
check(clone:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'streamed result reprojects from saved state')
clone:Destroy()
-- Map bounds include every new space at small/large viewport sizes.
local gui=Instance.new('ScreenGui');gui.Name='ExpandedMapNativeQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Parent=gui
for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
 host.Size=UDim2.fromOffset(size.X,size.Y)
 for epic=1,5 do
  local ids={};for id,z in pairs(C.zones)do if z.epic==epic then ids[id]=true end end
  local mapRoot=Instance.new('Frame');mapRoot.Size=UDim2.fromScale(1,1);mapRoot.Parent=host
  local canvas=require(Client.DeepwoodMapCanvas).create(mapRoot,ids,false,function()end)
  for _,c in ipairs(C.chapters)do if c.epic==epic then for _,g in ipairs(c.expansionGoals)do for _,step in ipairs(g.activity.steps)do
   local at=canvas.project(step.position[1],step.position[3]);check(at.X>=0 and at.X<=1 and at.Y>=0 and at.Y<=1,'new objective fits actual map projection')
  end end end end
  task.wait();mapRoot:Destroy()
 end
end
gui:Destroy()
-- All five prior regions have a reunion greeting, derived from existing final clear.
local lobby={folder=Instance.new('Folder'),origin=Vector3.new(0,96,512)};lobby.folder.Name='ExpansionLobbyQA';lobby.folder.Parent=workspace
local function prompt()local p=Instance.new('Part');p.Parent=lobby.folder;local x=Instance.new('ProximityPrompt');x.Parent=p;return x end
local residents=require(World.LobbyResidents).create(lobby,{training={prompt=prompt()},portal={prompt=prompt()}},nil)
local reunion=lobby.folder.HomecomingReunion
presentation.update({journal=P.new()});check(reunion:FindFirstChild('Torso',true).Transparency==1,'reunion locked before final clear')
local all=P.new();for _,c in ipairs(C.mainChapters)do all=finish(all,c)end
presentation.update({journal=all});check(reunion:FindFirstChild('Torso',true).Transparency<1,'old completed hero sees reunion without replay')
for i=1,5 do check(residents['homecoming'..i]and residents['homecoming'..i].text~='','five actual reunion dialogues')end
lobby.folder:Destroy()
print('CAMPAIGN_EXPANSION_NATIVE '..game.HttpService:JSONEncode(report))
return report
