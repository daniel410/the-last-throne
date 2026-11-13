assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local artifact only')
local checks=0
local function check(v,m) checks+=1;assert(v,m) end
local Shared=game.ReplicatedStorage.Shared
local World=game.ServerScriptService.Server.World
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local C,P=require(Shared.CampaignContent),require(Shared.DeepwoodProgress)
local E=require(Shared.CampaignExpansionCheckpoints)
local CP=require(Shared.CheckpointTravel)
local Access=require(Shared.CampaignAccess)
require(World.StoryGateTemplates).prepare()
local templates=game.ReplicatedStorage.StoryGateTemplates
require(World.StoryGateTemplates).prepare()
check(game.ReplicatedStorage.StoryGateTemplates==templates,'idempotent template publication')
for _,m in ipairs(templates:GetChildren())do
 for _,p in ipairs(m:GetDescendants())do
  check(not p:IsA('LuaSourceContainer'),'no executable content replicated')
  if p:IsA('BasePart') then
   check(p:IsA('MeshPart') and p.MeshId~='' and p.TextureID~='','pinned original mesh and texture')
  end
 end
end
local Gates=require(Client.DeepwoodGates)
local a,b=Gates.create(),Gates.create()
local folders={};for _,f in ipairs(workspace:GetChildren())do if f.Name=='PersonalStoryGates'then table.insert(folders,f)end end
local fresh={version=2,main=0,flags={},clears={},coins=0,choice='',expansionVersion=1}
a.update({journal=fresh});b.update({journal=fresh})
local blocked=#folders[1]:GetChildren();check(blocked>=6 and blocked<12,'only active epic roadblocks projected')
for _,m in ipairs(folders[1]:GetChildren())do
 local zone=C.zones[m:GetAttribute('StoryZone')]
 check(not Access.allowed(fresh,m:GetAttribute('StoryZone')),'only locked destinations blocked')
 check(m:GetAttribute('TDEnvironmentSource')==({'CliffRock','CliffRock','SnowCliff','VolcanoCliff','CemeteryCliff'})[zone.epic],'regional TD asset')
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then
  check(p.Transparency==0 and p.Material~=Enum.Material.ForceField,'opaque scenery replaces glass')
  check(p.CanCollide and p.Anchored and not p.CanTouch,'actual solid roadblock')
 end end
end
for epic=1,5 do
 local journal={version=2,main=(epic-1)*7,flags={},clears={}}
 a.update({journal=journal})
 check(#folders[1]:GetChildren()>0,'each epic has locked roadblocks')
 for _,m in ipairs(folders[1]:GetChildren())do
  local id=m:GetAttribute('StoryZone');local zone=C.zones[id]
  check(zone.epic==epic or epic<5 and id==C.overlandLinks[epic][2],'only current epic and its outgoing boundary allocate meshes')
  check(m:GetAttribute('TDEnvironmentSource')==({'CliffRock','CliffRock','SnowCliff','VolcanoCliff','CemeteryCliff'})[zone.epic],'each biome uses its original TD asset')
 end
end
local cleared={version=2,main=35,flags={},clears={}}
a.update({journal=cleared})
check(#folders[1]:GetChildren()==0,'unlock removes every model and collision surface')
check(#folders[2]:GetChildren()==blocked,'another personal projection remains locked')
a.update({journal=fresh});check(#folders[1]:GetChildren()==blocked,'hero switch restores earned gate state')
a.update({journal=fresh,training=true});check(#folders[1]:GetChildren()==0,'training has no story roadblocks')
a.update({journal=fresh});a.update(nil);check(#folders[1]:GetChildren()==0,'leaving adventure removes roadblocks')
a.destroy();b.destroy();a.update({journal=fresh});check(folders[1].Parent==nil,'destroy disconnects late updates')
-- A saved snapshot arriving before template replication is recovered.
templates.Parent=nil
local delayed=Gates.create();delayed.update({journal=fresh})
local delayedFolder=workspace:FindFirstChild('PersonalStoryGates')
check(#delayedFolder:GetChildren()==0,'no invisible placeholder while templates load')
templates.Parent=game.ReplicatedStorage;task.wait()
check(#delayedFolder:GetChildren()==blocked,'late templates apply existing snapshot')
delayed.destroy()
-- Real progression: verify every incident sends the hero to the next required
-- goal/step, never the expansion entrance, with no progress/reward mutation.
local function finish(s,c,g)
 for _,step in ipairs(g.activity and g.activity.steps or {false})do
  s=assert(P.apply(s,c.id,g.id,step and (step.solution or step.choices and step.choices[1].id) or g.choice and 'shared',step and step.id or nil))
 end
 return s
end
local s=assert(P.enableExpansion(P.new()))
local exits,minDistance=0,math.huge
for _,c in ipairs(C.mainChapters)do
 for _,g in ipairs(c.goals)do if P.required(s,g)then
  s=finish(s,c,g)
  if g.expansion then
   local id='exit:'..c.id..':'..g.id
   local target=assert(CP.allowed(s,id),'completed incident has an onward route')
   local nextGoal
   for _,candidate in ipairs(c.goals)do if P.required(s,candidate)and P.available(s,c,candidate)then nextGoal=candidate;break end end
   check(nextGoal and target.goalId==nextGoal.id,'target is the next required saved objective')
   local step=P.nextStep(s,c,nextGoal)
   local position=step and step.position or nextGoal.position
   check(Vector3.new(table.unpack(target.position))==Vector3.new(table.unpack(position)),'destination matches next action location')
   check(Access.allowed(s,target.zone),'no locked region skip')
   local source=Vector3.new(table.unpack(g.activity.steps[#g.activity.steps].position))
   local distance=(source-Vector3.new(table.unpack(target.position))).Magnitude
   minDistance=math.min(minDistance,distance)
   check(distance>20,'onward travel is more than a few steps')
   exits+=1
  end
 end end
end
check(exits>50,'coverage across all five epics')
check(not CP.allowed(s,'exit:DW-01:forged'),'forged route denied')
-- Build the exact first-aid scene from the screenshot.
local chapter=C.byId['DW-02'];local goal=P.goal(chapter,'exp_1')
local area;for _,candidate in ipairs(C.zones[chapter.zone].expansionAreas)do if candidate.id==goal.area then area=candidate end end
local scene=Instance.new('Model');scene.Name='FirstAidSceneQA';scene.Parent=workspace
require(World.CampaignIncidentScenes).create(scene,chapter,goal,area)
check(not scene:FindFirstChild('PreparedReliefBench',true),'remove the board beneath the NPCs')
local cloth=assert(scene:FindFirstChild('BlueClothClue',true))
check(cloth.Material==Enum.Material.Fabric and cloth.Size.Y<.1,'replace sign board with grounded cloth')
check(cloth.NarrativeClue.TextLabel.Text:find('missing driver',1,true)~=nil,'retain story clue')
local selene=scene.SeleneStoryAction
local survivor=scene['Convoy SurvivorStoryAction']
for stage=0,3 do
 local a=selene:GetAttribute('ExpansionPose'..stage)
 local b=survivor:GetAttribute('ExpansionPose'..stage)
 check((a.Position-b.Position).Magnitude>=7,'actors remain separated at every saved stage')
 check(a.Y==area.center[2] and b.Y==area.center[2],'actor feet pivots are at the authored floor')
 check(a==selene:GetAttribute('ExpansionPose0') and b==survivor:GetAttribute('ExpansionPose0'),'no sliding cast through props')
end
for _,part in ipairs(scene:GetDescendants())do if part.Name=='ClothTrail'then
 check(part.Size.Y<.1 and math.abs(part.Position.Y-area.center[2])<.1,'trail cloth rests on the floor')
end end
scene:Destroy()
-- The validated player and hero are forwarded to authoritative destination resolution.
local travelled=false
local travel=require(game.ServerScriptService.Server.Story.CheckpointTravelService).create({
 context=function()return {heroId='hero'}end,active=function()return {heroId='hero'}end,
 ready=function()return true end,pending=function()return false end,inEncounter=function()return false end,
 state=function()return fresh end,rules={allowed=function()return {id='saved'}end},
 destination=function(target,player,heroId)
  check(target.id=='saved' and player=='player' and heroId=='hero','server resolver gets validated identity')
  return CFrame.new(100,104,200)
 end,relocate=function(player,pivot)travelled=player=='player' and pivot.Position==Vector3.new(100,104,200);return travelled end})
check(travel('player','saved') and travelled,'server uses resolved destination')
for _,root in ipairs({Shared,game.ServerScriptService.Server,Client})do for _,m in ipairs(root:GetDescendants())do
 if m:IsA('LuaSourceContainer')then check(loadstring(m.Source,m:GetFullName())~=nil,'Luau syntax '..m:GetFullName())end
end end
print('STORY_OBSTACLES_TRAVEL '..game.HttpService:JSONEncode({checks=checks,roadblocks=blocked,onwardRoutes=exits,minDistance=minDistance}))
