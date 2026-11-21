assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated Studio fixture only')
local shared=game.ReplicatedStorage.Shared
local content=require(shared.CampaignContent)
local progress=require(shared.DeepwoodProgress)
local activity=require(game.ServerScriptService.Server.Story.DeepwoodActivities)
local guidance=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodJournal).guidance
local checks=0
local function check(ok,message) checks+=1;assert(ok,message) end

local journal=assert(progress.enableExpansion(progress.new()))
local chapter=content.byId['DW-02']
local goal=progress.goal(chapter,'survivors')
local key=chapter.id..':'..goal.id
for _,c in ipairs({content.byId['DW-01'],chapter})do
 for _,g in ipairs(c.goals)do
  if g==goal then break end
  if progress.required(journal,g) then
   for _,step in ipairs(g.activity and g.activity.steps or {false}) do
    local choice=step and step.choices and (step.solution or step.choices[1].id)
    journal=assert(progress.apply(journal,c.id,g.id,choice or nil,step and step.id or nil))
   end
  end
 end
end
journal.expeditionMission=chapter.id;journal.expeditionRunId='escort-test'
check(progress.available(journal,chapter,goal),'route uses the actual DW-02 start conditions')
local folder=Instance.new('Folder',workspace)
local enemies=Instance.new('Folder',folder)
local character=Instance.new('Model',folder)
local root=Instance.new('Part',character);root.Anchored=true
root.Position=Vector3.new(table.unpack(goal.position))
local node={chapter=chapter,goal=goal,part=root}
local player={UserId=21,Character=character}
local hero={heroId='test'}
local contextReady=true
local saves,pending=0,nil
local checkpoints={}
local function confirm()
 local nextJournal=assert(progress.apply(journal,chapter.id,goal.id,nil,pending))
 journal=nextJournal;pending=nil;saves+=1;checkpoints[saves]=journal
end
local engine=activity.create({
 frameDriven=true,world={folder=folder,activityNodes={}},enemies=enemies,players=function()return {player}end,
 active=function()return hero end,context=function()if contextReady then return hero,root end end,
 state=function()return journal end,publish=function()end,
 enqueue=function(_,_,c,g,_,step)
  check(c==chapter and g==goal and not pending,'checkpoint submits one server-authorized event')
  pending=step
 end,
})
local candidate=engine.stepMotion~=nil
local function position() return engine.projection(player,'test')[key] end
local function frame(i)
 if i%12==1 then engine.update(.2) end
 if candidate then engine.stepMotion(1/60) end
end
engine.interact(player,node)
local first=assert(position())
if candidate then
 engine.interact(player,node)
 check(position().actorRoot==first.actorRoot,'interacting again keeps the same moving resident')
 root.Position=first.actorPosition+Vector3.new(60,0,0)
 frame(1);frame(2)
 check(position().actorPosition==first.actorPosition,'escort holds if the player falls behind')
 root.Position=first.actorPosition
 local enemy=Instance.new('Model',enemies)
 local enemyRoot=Instance.new('Part',enemy);enemyRoot.Name='HumanoidRootPart';enemyRoot.Position=root.Position
 Instance.new('Humanoid',enemy)
 frame(1);frame(2)
 check(position().actorPosition==first.actorPosition,'escort still waits when an enemy is close')
 enemy:Destroy()
 frame(1)
 local previous=position().actorPosition
 frame(2)
 local travelled=(position().actorPosition-previous).Magnitude
 check(travelled>.1 and travelled<.3,'frame motion is smaller and continues between activity ticks')
 local route=guidance({journal=journal,activities={[key]=first}},{chapter=chapter,goal=goal},root.Position)
 check(route.position==position().actorPosition,'guidance uses the current streamed actor position over its cached snapshot')
end
local elapsed=0
for i=1,60*55 do
 if journal.flags[key] then break end
 root.Position=assert(position()).actorPosition
 frame(i)
 if pending then
  if candidate and saves==0 then
   local waiting=assert(position())
   contextReady=false;engine.update(.2);engine.stepMotion(.2)
   check(position().actorRoot==waiting.actorRoot and position().actorPosition==waiting.actorPosition,'unconfirmed save holds the resident at their checkpoint')
   contextReady=true;engine.update(.2);engine.stepMotion(.2)
   check(saves==0 and pending==goal.activity.steps[1].id,'no movement or second submit until checkpoint confirms')
  end
  confirm()
 end
 elapsed=i/60
end
check(journal.flags[key] and saves==3,'all three authored checkpoints save in order')
if candidate then
 check(elapsed<6,'the direct escort route takes under six seconds of movement')
 engine.update(.2)
 check(not position(),'completion cleans up the active escort')
 for index=1,2 do
  journal=checkpoints[index]
  local savedPlace=Vector3.new(table.unpack(goal.activity.steps[index].position))
  root.Position=savedPlace
  engine.update(.2)
  check(position() and position().actorPosition==savedPlace,'resume uses the same saved step index at its new waypoint')
  check(progress.nextStep(journal,chapter,goal)==goal.activity.steps[index+1],'resume preserves the next checkpoint ID')
  engine.remove(player)
 end
end
folder:Destroy()

local world=require(game.ServerScriptService.Server.World.CampaignWorld).create(1)
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances={world.folder};overlap.RespectCanCollide=true
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances={world.folder};ray.RespectCanCollide=true
local travelled=0
local previous=Vector3.new(table.unpack(goal.position))
for _,step in ipairs(goal.activity.steps) do
 local finish=Vector3.new(table.unpack(step.position))
 local length=(finish-previous).Magnitude
 local samples=math.ceil(length/2)
 for i=0,samples do
  local point=previous:Lerp(finish,i/samples)
  local floor=workspace:Raycast(point+Vector3.new(0,4,0),Vector3.new(0,-8,0),ray)
  check(floor and floor.Normal.Y>.55 and math.abs(floor.Position.Y-point.Y)<1,'escort route remains at walkable ground: '..tostring(point))
  local obstacles=workspace:GetPartBoundsInBox(CFrame.new(point+Vector3.new(0,3,0)),Vector3.new(2,4,2),overlap)
  check(#obstacles==0,'escort route stays clear of solid props: '..tostring(point)..' '..(obstacles[1]and obstacles[1]:GetFullName()or ''))
 end
 travelled+=length;previous=finish
end
world.folder:Destroy()
print('ESCORT_PACING '..game.HttpService:JSONEncode({checks=checks,seconds=elapsed,saves=saves,studs=travelled,candidate=candidate}))
