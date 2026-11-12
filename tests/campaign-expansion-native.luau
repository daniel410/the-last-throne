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
local world;local generationStart=os.clock()
for epic=1,5 do world=require(World.CampaignWorld).create(epic,world);print('EXPANSION_NATIVE_EPIC',epic)end
report.generationSeconds=os.clock()-generationStart
local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.folder};params.RespectCanCollide=true
local rays=RaycastParams.new();rays.FilterType=Enum.RaycastFilterType.Include;rays.FilterDescendantsInstances={world.terrain,workspace.Terrain};rays.RespectCanCollide=true
local bodyProbe=Instance.new('Part');bodyProbe.Size=Vector3.new(4,5.5,4);bodyProbe.Anchored=true;bodyProbe.CanCollide=false;bodyProbe.CanQuery=false;bodyProbe.Transparency=1;bodyProbe.Parent=workspace
local function sample(c,g,at)
 report.samples+=1
 local y=Bounds.surface(at.X,at.Z);at=Vector3.new(at.X,y or at.Y,at.Z)
 local hit=workspace:Raycast(at+Vector3.new(0,8,0),Vector3.new(0,-24,0),rays)
 if not hit or math.abs(hit.Position.Y-at.Y)>1 then table.insert(report.blockers,{chapter=c.id,goal=g.id,kind='floor',at={at.X,at.Y,at.Z},part=hit and hit.Instance:GetFullName()})end
 bodyProbe.CFrame=CFrame.new(at+Vector3.new(0,3.5,0))
 local parts=workspace:GetPartsInPart(bodyProbe,params)
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
  local incidentScene=world.folder.CampaignExpansion:FindFirstChild('Epic'..c.epic):FindFirstChild(c.id..'_'..g.id)
  local payoffPost=incidentScene.RestoredIncident:FindFirstChild('ConfirmedRouteSignal')
  check((payoffPost.Position-Vector3.new(table.unpack(g.activity.steps[#g.activity.steps].position))).Magnitude<40,'default final action keeps its visible payoff nearby')
  local n=math.max(1,math.ceil((center-entry).Magnitude/12))
  for i=0,n do sample(c,g,entry:Lerp(center,i/n))end
  local Route=require(Shared.CampaignIncidentRoute)
  local last=area.entry
  for _,step in ipairs(g.activity.steps)do
   local route=Route.route(last,step.position)
   for j=2,#route do
    local a,b=Vector3.new(table.unpack(route[j-1])),Vector3.new(table.unpack(route[j]))
    local segments=math.max(1,math.ceil((b-a).Magnitude/12))
    for k=0,segments do sample(c,g,a:Lerp(b,k/segments))end
   end
   last=step.position
   report.steps+=1;check(world.activityNodes[c.id..':'..g.id..':'..step.id]~=nil,'actual activity step exists')
   sample(c,g,Vector3.new(table.unpack(step.position)))
  end
 end
 task.wait()
end
for _,v in ipairs(world.folder:GetDescendants())do if v:IsA('BasePart')then report.parts+=1 end end
bodyProbe:Destroy()
print('EXPANSION_NATIVE_GEOMETRY '..game.HttpService:JSONEncode({samples=report.samples,parts=report.parts,blockerCount=#report.blockers,blockers={table.unpack(report.blockers,1,math.min(80,#report.blockers))}}))
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
local carried
for _,model in ipairs(world.folder:GetDescendants())do if model:IsA('Model')and model:GetAttribute('NPCPrivateOwnerUserId')==194 then carried=model:FindFirstChild('ThreeBarScoutLantern')end end
check(carried and carried:GetAttribute('StoryMotif')=='FinnThreeBarLight','real moving Finn carries the recurring scout lantern')
local bars=0;for _,part in ipairs(carried:GetChildren())do if part.Name=='RecognizableGoldBar'then bars+=1 end end
check(bars==3,'Finn carries the same readable three-bar shape used by his allies')
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
-- Saved mechanical stages and two-option circuit UI through the real server engine.
local function applyGoal(s,c,g)
 for _,step in ipairs(g.activity and g.activity.steps or {false})do
  s=assert(P.apply(s,c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared',step and step.id or nil))
 end
 return s
end
local function reach(cid,gid)
 local c=C.byId[cid];local s=P.new()
 for i=1,c.number-1 do s=finish(s,C.mainChapters[i])end
 s=assert(P.enableExpansion(s))
 for _,g in ipairs(c.goals)do if g.id==gid then return s,c,g end;if P.required(s,g)then s=applyGoal(s,c,g)end end
 error('Unreachable goal')
end
local bridgeState,bc,bg=reach('FV-03','exp_2')
local bridge=world.folder.CampaignExpansion.Epic3['FV-03_exp_2'].DeployingRavineBridge
presentation.update({journal=bridgeState});presentation.tick(1);local raised=bridge:GetPivot()
bridgeState=assert(P.apply(bridgeState,bc.id,bg.id,nil,'step1'));presentation.update({journal=bridgeState});presentation.tick(1)
check((bridge:GetPivot().Position-raised.Position).Magnitude>5,'bridge lowers after confirmed first mechanism step')
bridgeState=assert(P.apply(bridgeState,bc.id,bg.id,nil,'step2'));presentation.update({journal=bridgeState});presentation.tick(1)
check((bridge:GetPivot().Position-bridge:GetAttribute('ExpansionPose2').Position).Magnitude<.1,'bridge reaches saved walking pose')
local bridgeClone=bridge:Clone();bridgeClone.Name='RestreamedBridge';bridgeClone.Parent=bridge.Parent;task.wait()
check((bridgeClone:GetPivot().Position-bridgeClone:GetAttribute('ExpansionPose2').Position).Magnitude<.1,'mid-circuit bridge restream restores saved pose')
bridgeClone:Destroy()
local puzzle,circuitChapter,circuit=reach('EC-05','exp_2')
local control=world.folder.CampaignExpansion.Epic4['EC-05_exp_2'].CircuitControl1
local puzzleRoot=Instance.new('Part');puzzleRoot.Anchored=true;puzzleRoot.Parent=workspace
local messages={};local player={UserId=195}
local circuitEngine=require(game.ServerScriptService.Server.Story.DeepwoodActivities).create({players=function()return {player}end,
 active=function()return {heroId='hero'}end,context=function()return {heroId='hero'},puzzleRoot end,state=function()return puzzle end,
 world=world,enemies=Instance.new('Folder'),publish=function(_,text)table.insert(messages,text)end,
 enqueue=function(_,_,c,g,choice,id)
  local before=puzzle;puzzle=assert(P.apply(puzzle,c.id,g.id,choice,id))
  table.insert(messages,require(Shared.StoryEventText).resolve(g,id,choice,before,puzzle,c.id))
 end})
presentation.update({journal=puzzle});presentation.tick(1);local unturned=control:GetPivot()
for i,step in ipairs(circuit.activity.steps)do
 puzzleRoot.Position=Vector3.new(table.unpack(step.position))
 circuitEngine.interactStep(player,circuitChapter.id,circuit.id,step.id)
 local _,dialog=circuitEngine.projection(player,'hero');check(dialog and #dialog.choices==2,'mechanism opens two circuit choices at actual step position')
 local count=(puzzle.activities or {})['EC-05:exp_2']or 0
 circuitEngine.answer(player,'EC-05:exp_2:'..step.id..':'..step.choices[2].id)
 check(((puzzle.activities or {})['EC-05:exp_2']or 0)==count,'wrong answer does not save or advance')
 check(messages[#messages]==step.failure,'wrong circuit explains safe retry')
 circuitEngine.answer(player,'EC-05:exp_2:'..step.id..':'..step.choices[1].id)
 check(puzzle.activities['EC-05:exp_2']==i,'correct answer saves the next circuit stage')
 presentation.update({journal=puzzle});presentation.tick(1)
end
check(control:GetPivot().LookVector:Dot(unturned.LookVector)<.1,'actual model control wheel turns with confirmed circuit')
check(messages[#messages]==circuit.text,'native circuit final response includes complete authored outcome')
circuitEngine.remove(player);puzzleRoot:Destroy()
local allies,ac,ag=reach('HG-04','exp_2')
local brann=world.folder.CampaignExpansion.Epic5['HG-04_exp_2'].BrannStoryAction
presentation.update({journal=allies});presentation.tick(1);local waiting=brann:GetPivot().Position
allies=assert(P.apply(allies,ac.id,ag.id,nil,'step1'));presentation.update({journal=allies});presentation.tick(1)
check((brann:GetPivot().Position-waiting).Magnitude>2,'Brann moves to the operating rig after confirmed work')
local gate=world.folder.CampaignExpansion.Epic5['HG-04_exp_2'].AllianceSideGate
check(gate:GetPivot().Position.Y>gate:GetAttribute('ExpansionPose0').Position.Y,'alliance gate physically changes visual pose')
local shield,sc,sg=reach('HG-05','exp_1');shield=applyGoal(shield,sc,sg)
local conduit=world.folder.CampaignExpansion.Epic5['HG-05_exp_1'].ActiveThroneConduit
presentation.update({journal=shield});presentation.tick(1)
check(conduit:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'inspection alone leaves throne shield active')
shield=applyGoal(shield,sc,P.goal(sc,'west'));presentation.update({journal=shield});presentation.tick(1)
check(conduit:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'actual saved western device disables its own shield connection')
-- Existing restored throne was already implemented; verify it instead of claiming it missing.
local home=Instance.new('Folder');home.Name='DawnspireLobbyPrototype';home.Parent=workspace
local throne=Instance.new('Model');throne.Name='DawnspireThrone';throne:SetAttribute('HeartPosition',Vector3.new(0,12,0));throne.Parent=home
require(Client.DawnspireHomecoming).update({heroId='done',heroes={done={deepwood=all}}})
check(throne:FindFirstChild('DawnspireHomecoming')and throne.DawnspireHomecoming:FindFirstChild('Crownheart'),'existing throne and Crownheart restoration render for final clear')
require(Client.DawnspireHomecoming).update({heroId='new',heroes={new={deepwood=P.new()}}})
check(not throne:FindFirstChild('DawnspireHomecoming'),'switching heroes clears personal throne restoration')
home:Destroy()
-- Story causes, earned callbacks, physical circuit controls and side returns.
local medicine,mc,mg=reach('DW-02','exp_1')
local survivorNode=world.nodes['DW-02:survivors']
check(survivorNode.chapter==mc and survivorNode.goal==P.goal(mc,'survivors'),'actual archived Deepwood nodes bind canonical narrative and prerequisite data')
check(not P.available(medicine,survivorNode.chapter,survivorNode.goal),'live core marker cannot bypass the new medicine incident')
medicine=applyGoal(medicine,mc,mg)
check(P.available(medicine,survivorNode.chapter,survivorNode.goal),'saved medicine completion unlocks the original survivor objective')
check(world.nodes['DW-Q2:'..C.byId['DW-Q2'].quest.turnIn].chapter.quest.outcome==C.byId['DW-Q2'].quest.outcome,'actual field report uses the same updated story outcome as Tessa and the journal')
local investigation,ic,ig=reach('FV-04','exp_1')
investigation=assert(P.apply(investigation,ic.id,ig.id,nil,'step3'))
presentation.update({journal=investigation});presentation.tick(1)
local unseen=world.folder.AdventureActivities['FV-04_exp_1_step1_Art']:FindFirstChildWhichIsA('BasePart',true)
local collected=world.folder.AdventureActivities['FV-04_exp_1_step3_Art']:FindFirstChildWhichIsA('BasePart',true)
check(unseen.Color==unseen:GetAttribute('ExpansionOriginalColor'),'out-of-order evidence does not paint an unseen clue as collected')
check(collected.Color==Color3.fromRGB(103,205,184),'actual collected evidence alone receives the saved feedback')
local signals,fc,fg=reach('FV-04','exp_2')
local witnessScene=world.folder.CampaignExpansion.Epic3['FV-04_exp_2']
local guardian=witnessScene.SignalGuardianWitness
check(not guardian:FindFirstChildWhichIsA('Humanoid',true),'signal witness adds no combat humanoid or damage target')
check(guardian:FindFirstChild('NoncombatSignalGuardian'):GetAttribute('StoryWitness')==true,'guardian uses the reviewed noncombat visual')
presentation.update({journal=signals});presentation.tick(1);local initialFacing=guardian:GetPivot().LookVector
check(witnessScene.FalseAlarmAimedAtRefuge:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'wrong warning visibly points at the refuge before the repair')
signals=applyGoal(signals,fc,fg);presentation.update({journal=signals});presentation.tick(1)
check(guardian:GetPivot().LookVector:Dot(initialFacing)<-.99,'guardian visibly changes its protected direction after the real saved signal')
check(witnessScene.FalseAlarmAimedAtRefuge:FindFirstChildWhichIsA('BasePart',true).Transparency==1 and witnessScene.ShelterSignalProtectsTravelers:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'old warning and shelter signal change together')
local signalClone=guardian:Clone();signalClone.Name='GuardianAfterRestream';signalClone.Parent=witnessScene;task.wait()
check(signalClone:GetPivot().LookVector:Dot(guardian:GetPivot().LookVector)>.99,'restreamed guardian restores the earned reaction');signalClone:Destroy()
local payoff=world.folder.CampaignExpansion.Epic5['HG-04_exp_2'].FinnsReturningLantern
presentation.update({journal=P.new()});presentation.tick(1)
check(payoff:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'unearned scout payoff is hidden')
local earned=select(1,reach('HG-04','exp_2'));presentation.update({journal=earned});presentation.tick(1)
check(payoff:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'earlier scout rescue earns the familiar final assault signal')
-- Bind the actual refreshWorld source to actual control metadata, with test-only event buses.
local controlsState,cc,cg=reach('EC-05','exp_2');local controlRoot=Instance.new('Part');controlRoot.Anchored=true;controlRoot.Parent=workspace
local cp={UserId=197};local feedback={};local enqueues=0
local controlEngine=require(game.ServerScriptService.Server.Story.DeepwoodActivities).create({players=function()return {cp}end,
 active=function()return {heroId='hero'}end,context=function()return {heroId='hero'},controlRoot end,state=function()return controlsState end,
 world=world,enemies=Instance.new('Folder'),publish=function(_,message)table.insert(feedback,message)end,
 enqueue=function(_,_,c,g,choice,id)enqueues+=1;controlsState=assert(P.apply(controlsState,c.id,g.id,choice,id))end})
local callbacks={};local fakeWorld={activityChoices={},activityNodes={},nodes={}};local binds=0
for id,node in pairs(world.activityChoices)do
 local record={part=node.part,chapter=node.chapter,goal=node.goal,step=node.step,choice=node.choice}
 record.prompt={Triggered={Connect=function(_,fn)binds+=1;callbacks[id]=fn end}};fakeWorld.activityChoices[id]=record
end
local serviceSource=game.ServerScriptService.Server.Story.DeepwoodService.Source
local binding=assert(serviceSource:match('(function Service.refreshWorld%(%)'..'.-)'..'\nfunction Service.start'))
local env={Service={interactStep=function(p,cid,gid,sid,choice)controlEngine.interactStep(p,cid,gid,sid,choice)end},options={world=fakeWorld},boundNodes={}}
setmetatable(env,{__index=getfenv()});local fn=assert(loadstring(binding..'\nreturn Service.refreshWorld'));setfenv(fn,env);local refresh=fn();refresh();refresh()
check(binds==6,'each physical control binds once to the actual server interaction path')
local journalSource=Client.DeepwoodJournal.Source
local promptBody=assert(journalSource:match('(local function updatePrompts%(%)'..'.-)'..'\n workspace.DescendantAdded:Connect'))
local updatePrompts=assert(loadstring('return function(workspace,current,Content,Progress,Checkpoints,Log)\n'..promptBody..'\nupdatePrompts() end'))()
for i,step in ipairs(cg.activity.steps)do
 local good=world.activityChoices['EC-05:exp_2:'..step.id..':'..step.solution]
 local bad=world.activityChoices['EC-05:exp_2:'..step.id..':'..step.choices[2].id]
 updatePrompts(workspace,{journal=controlsState},C,P,CP,require(Shared.DeepwoodQuestLog))
 check(good.prompt.Enabled and bad.prompt.Enabled,'both choices in the actual client become actionable at the saved step')
 local count=enqueues
 controlRoot.Position=good.part.Position+Vector3.new(1000,0,0);callbacks['EC-05:exp_2:'..step.id..':'..step.solution](cp)
 check(enqueues==count,'forged physical control requests are rejected outside server distance')
 controlRoot.Position=bad.part.Position;callbacks['EC-05:exp_2:'..step.id..':'..step.choices[2].id](cp)
 check(enqueues==count and feedback[#feedback]==step.failure,'wrong physical control is safe and explains the relevant diagram')
 controlRoot.Position=Vector3.new(table.unpack(step.position));controlEngine.interactStep(cp,cc.id,cg.id,step.id)
 local _,dialog=controlEngine.projection(cp,'hero')
 check(dialog and dialog.choices[i==2 and 2 or 1].id==step.solution,'accessible dialog matches the physical left/right order')
 controlRoot.Position=good.part.Position;callbacks['EC-05:exp_2:'..step.id..':'..step.solution](cp)
 check(enqueues==count+1 and controlsState.activities['EC-05:exp_2']==i,'actual physical choice saves exactly one correct step')
 updatePrompts(workspace,{journal=controlsState},C,P,CP,require(Shared.DeepwoodQuestLog));check(not good.prompt.Enabled and not bad.prompt.Enabled,'confirmed controls disable in the real client')
end
check(controlsState.flags['EC-05:exp_2'],'all physical choices complete the original incident without extra goals')
-- A confirmed journal update can arrive from another party member while choices are open.
controlsState=select(1,reach('EC-05','exp_2'));controlRoot.Position=Vector3.new(table.unpack(cg.activity.steps[1].position))
controlEngine.interactStep(cp,cc.id,cg.id,'step1')
local _,waitingChoice=controlEngine.projection(cp,'hero');check(waitingChoice~=nil,'current circuit choice stays open before a confirmed update')
controlsState=assert(P.apply(controlsState,cc.id,cg.id,'inlet','step1'))
local _,staleChoice=controlEngine.projection(cp,'hero');check(staleChoice==nil,'confirmed progress from an ally closes the previous choice')
controlRoot.Position=Vector3.new(table.unpack(cg.activity.steps[2].position));controlEngine.interactStep(cp,cc.id,cg.id,'step2')
controlsState=assert(P.apply(controlsState,cc.id,cg.id,'return','step2'));controlsState=assert(P.apply(controlsState,cc.id,cg.id,'protect','step3'))
local _,completedChoice=controlEngine.projection(cp,'hero');check(completedChoice==nil,'incident completion closes any remaining choice')
controlEngine.remove(cp);controlRoot:Destroy()
local returnFolder=Instance.new('Folder');returnFolder.Parent=workspace
for _,id in ipairs({'DW-Q2','FV-Q1','EC-Q1'})do
 local s=assert(P.enableExpansion(all));local c=C.byId[id];s=assert(P.accept(s,id))
 for _,g in ipairs(c.goals)do if g.id==c.quest.turnIn then break end;if P.required(s,g)then s=applyGoal(s,c,g)end end
 local returnScene=require(World.CampaignReturnScenes).create(returnFolder,Vector3.new(0,96,512),id)
 presentation.update({journal=s});presentation.tick(1)
 check(returnScene:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'pre-report work cannot fabricate a returned meal/person')
 s=applyGoal(s,c,P.goal(c,c.quest.turnIn));presentation.update({journal=s});presentation.tick(1)
 check(returnScene:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'real saved side report unlocks its personal homecoming')
 local clone=returnScene:Clone();clone.Name='SideReturnAfterRestream';clone.Parent=returnFolder;task.wait()
 check(clone:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'reported side return survives stream-in');clone:Destroy()
 presentation.update({journal=P.new()});presentation.tick(1)
 check(returnScene:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'changing to a new hero hides another hero\'s return story')
end
returnFolder:Destroy()
local lobbyStory={folder=Instance.new('Folder'),origin=Vector3.new(0,96,512)};lobbyStory.folder.Name='DawnspireLobbyPrototype';lobbyStory.folder.Parent=workspace
local function lobbyPrompt()local a=Instance.new('Part');a.Parent=lobbyStory.folder;local p=Instance.new('ProximityPrompt');p.Parent=a;return p end
require(World.LobbyResidents).create(lobbyStory,{training={prompt=lobbyPrompt()},portal={prompt=lobbyPrompt()}},nil)
check(#lobbyStory.folder.SideStoryHomecomings:GetChildren()==3,'actual lobby resident creation mounts all three existing side homecomings')
local lobbyJournal=assert(P.enableExpansion(all));lobbyJournal=assert(P.accept(lobbyJournal,'FV-Q1'));lobbyJournal=applyGoal(lobbyJournal,C.byId['FV-Q1'],C.byId['FV-Q1'].goals[1])
for _,g in ipairs(C.byId['FV-Q1'].goals)do if P.required(lobbyJournal,g)and not lobbyJournal.flags['FV-Q1:'..g.id]then lobbyJournal=applyGoal(lobbyJournal,C.byId['FV-Q1'],g)end end
require(Client.DawnspireHomecoming).update({heroId='nell-hero',heroes={['nell-hero']={deepwood=lobbyJournal}}});presentation.tick(1)
local nell=lobbyStory.folder.SideStoryHomecomings:FindFirstChild('ReturnStory_FV-Q1')
check(nell:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'actual selected hero snapshot reveals Nell in the lobby after the report')
require(Client.DawnspireHomecoming).update({heroId='new-hero',heroes={['new-hero']={deepwood=P.new()}}});presentation.tick(1)
check(nell:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'actual hero snapshot switch removes the unearned return scene')
lobbyStory.folder:Destroy()
print('CAMPAIGN_EXPANSION_NATIVE '..game.HttpService:JSONEncode(report))
return report
