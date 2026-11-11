assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local P=require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
for _,p in ipairs(world.terrain:GetDescendants())do check(p:GetAttribute('StoryPropKey')~='PrisonCage','no unused shared cages')end
local templates=game.ReplicatedStorage.CaptiveSceneTemplates
for _,p in ipairs(templates:GetDescendants())do check(not p:IsA('LuaSourceContainer'),'script-free captive templates')end
local factory=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodCaptivePresentation)
local view=factory.create()
local folder=workspace:FindFirstChild('PersonalCaptiveScenes')
local c=C.byId['DW-04'];local g
for _,goal in ipairs(c.goals)do if goal.id=='spirit'then g=goal end end
local key='DW-04:spirit'
local journal=assert(P.enableExpansion(P.new()))
local function applyGoal(chapter,goal)
 for _,step in ipairs(goal.activity and goal.activity.steps or {false})do
  journal=assert(P.apply(journal,chapter.id,goal.id,step and step.choices and step.choices[1].id or goal.choice and 'shared',step and step.id or nil))
 end
end
for i=1,3 do local chapter=C.mainChapters[i];for _,goal in ipairs(chapter.goals)do if P.required(journal,goal)then applyGoal(chapter,goal)end end end
local before=P.copy(journal)
view.update({heroId='a',journal=journal})
local scene=folder[key]
check(scene and not scene:GetAttribute('RescueOpen'),'captive visible before devices are stopped')
local pos=Vector3.new(table.unpack(g.position))
check((scene.CaptiveResident.PrimaryPart.Position-pos).Magnitude<1,'NPC actually inside cage at interaction')
local door=scene.RescueCage.RescueDoor;local closed=door:GetPivot()
local char=Instance.new('Model');char.Name='CaptiveRescueAudit';char.Parent=workspace
local root=Instance.new('Part');root.Anchored=true;root.Position=pos;root.Parent=char;char.PrimaryPart=root
local player={UserId=999,Character=char}
local hero={heroId='a',training=false}
local enemies=Instance.new('Folder');enemies.Parent=workspace
local saves=0
local engine=require(game.ServerScriptService.Server.Story.DeepwoodActivities).create({world=world,enemies=enemies,
 active=function()return hero end,context=function()return hero,root end,state=function()return journal end,
 players=function()return {player}end,publish=function()end,
 enqueue=function(_,_,chapter,goal,choice,step)
  journal=assert(P.apply(journal,chapter.id,goal.id,choice,step));saves+=1
 end})
engine.startEscort(player,c,g)
check(next(engine.projection(player,'a'))==nil,'cannot unlock before required portal devices')
for _,goal in ipairs(c.goals)do if goal==g then break end;if P.required(journal,goal)then applyGoal(c,goal)end end
engine.startEscort(player,c,g)
local attempt=engine.projection(player,'a')
check(attempt[key]~=nil,'server-validated unlock creates real escort')
view.update({heroId='a',journal=journal,activities=attempt})
check(scene:GetAttribute('RescueOpen')and door:GetPivot().LookVector:Dot(closed.LookVector)<.1,'door swings open on confirmed escort')
check(scene.CaptiveResident.Torso.LocalTransparencyModifier==1,'no duplicate NPC while real escort moves')
for i=1,180 do
 local projection=engine.projection(player,'a');if not projection[key]then break end
 local at=projection[key].actorPosition
 if at.Z<pos.Z+6 then check(math.abs(at.X-pos.X)<.1,'resident exits through opened door, never side bars')end
 root.Position=at;engine.update(.25)
 if saves==1 then break end
end
check(saves==1,'first rescue step saved by actual escort motion')
engine.remove(player)
view.update({heroId='a',journal=journal})
check(scene:GetAttribute('RescueOpen'),'saved unlock survives attempt removal/reconnect')
root.Position=Vector3.new(table.unpack(g.activity.steps[1].position))
for i=1,240 do
 engine.update(.25)
 local projection=engine.projection(player,'a');if projection[key]then root.Position=projection[key].actorPosition end
 if journal.flags[key]then break end
end
check(journal.flags[key]and saves==3,'NPC completes server-owned rescue and all saved checkpoints')
engine.remove(player);view.update({heroId='a',journal=journal})
check(scene:GetAttribute('RescueOpen'),'completed cage remains open')
check((scene.CaptiveResident.PrimaryPart.Position-Vector3.new(table.unpack(g.activity.steps[3].position))).Magnitude<.1,'freed NPC stands outside cage at refuge')
local fresh=P.copy(before)
view.update({heroId='b',journal=fresh})
check(not folder[key]:GetAttribute('RescueOpen'),'another hero retains their own locked cage')
view.update({heroId='b',journal=fresh,training=true})
check(#folder:GetChildren()==0,'training removes captive scene and collision')
view.update({heroId='b',journal=fresh})
check(#folder:GetChildren()==1,'restoring adventure does not duplicate cages')
view.destroy();engine.remove(player);char:Destroy();enemies:Destroy()
local late=factory.create();templates.Parent=nil;late.update({heroId='b',journal=fresh});templates.Parent=game.ReplicatedStorage;task.wait()
check(#workspace.PersonalCaptiveScenes:GetChildren()==1,'late template replication reprojects current snapshot')
late.destroy()
print('CAPTIVE_RESCUE_QA '..game.HttpService:JSONEncode({checks=checks,saves=saves,passed=true}))
