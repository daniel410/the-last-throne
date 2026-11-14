-- Isolated engine: real content/world, saved personal projection and motion.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place required')
local Shared=game.ReplicatedStorage.Shared
local Server=game.ServerScriptService.Server.World
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local C=require(Shared.CampaignContent)
local Bounds=require(Shared.CampaignBounds)
local P=require(Shared.DeepwoodProgress)
local View=require(Client.CampaignExpansionPresentation)
local Setpieces=require(Server.CampaignQuestSetpieces)
local report={checks=0,parts=0,marks=0,scope='isolated edit engine; no live DataStore, human input or device acceptance'}
local function check(v,message)report.checks+=1;assert(v,message)end
local world
for epic=1,5 do world=require(Server.CampaignWorld).create(epic,world);print('SETPIECES_EPIC_READY',epic)end
local root=world.folder.QuestSetpieces
check(#root:GetChildren()==3,'exactly three authored representative scenes')
local function scene(epic,name)return root['Epic'..epic][name]end
local dw=scene(1,'DW-01_ConvoyEvidence')
local fv=scene(3,'FV-03_AnsweringBeacons')
local ec=scene(4,'EC-01_FreightMachinery')
for _,v in ipairs(root:GetDescendants())do if v:IsA('BasePart')then
 report.parts+=1;check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'personal setpiece never changes shared physical authority')
 if v.Name=='LoadedWheelRut'or v.Name=='TravelerFootprint'then
  report.marks+=1;local y=Bounds.surface(v.Position.X,v.Position.Z)
  check(y and math.abs(v.Position.Y-y-.08)<.02,'evidence follows supported terrain rather than floating across gaps')
 end
end end
check(report.parts<650,'bounded decorative scene budget')
check(report.marks>20,'physical evidence extends beyond a single objective marker')
local count=#root:GetDescendants()
for _,epic in ipairs({1,2,3,4,5})do Setpieces.create(world,epic)end
check(#root:GetDescendants()==count,'reloading an epic does not duplicate scenes')
local function visible(m)
 local p=m:FindFirstChildWhichIsA('BasePart',true);return p and p.Transparency<1
end
local function update(flags,clears,activities)
 local journal=P.new();journal.flags=flags or {};journal.clears=clears or {};journal.activities=activities or {}
 View.update({journal=journal});return journal
end
update()
check(not visible(dw.ConfirmedSurvivorRoute),'unreached trail payoff hidden')
check(not visible(fv.WesternBeaconLit)and not visible(fv.EasternBeaconLit),'unearned village flames hidden')
check(not visible(fv.BeaconsAnswerAcrossRavine),'no response before either beacon')
check(not visible(ec.InstalledRecoveredGear)and not visible(ec.FreightLandingReady),'unearned installation and landing indicators hidden')
local carrier=ec.FreightCarrier;local resting=carrier:GetPivot()
update({['FV-03:west_beacon']=true})
check(visible(fv.WesternBeaconLit)and not visible(fv.EasternBeaconLit),'west completion lights only its own village')
check(not visible(fv.BeaconsAnswerAcrossRavine),'one beacon cannot answer itself')
update({['FV-03:east_beacon']=true})
check(not visible(fv.BeaconsAnswerAcrossRavine),'response requires both independent flags')
update({['FV-03:west_beacon']=true,['FV-03:east_beacon']=true})
check(visible(fv.BeaconsAnswerAcrossRavine),'both saved beacons reconnect the sightline')
update(nil,nil,{['DW-01:exp_2']=2})
check(not visible(dw.ConfirmedSurvivorRoute),'partial trail does not claim full arrival')
update({['DW-01:exp_2']=true})
check(visible(dw.ConfirmedSurvivorRoute),'completed trail leaves a confirmed physical route')
update({['EC-01:gear']=true})
check(not visible(ec.InstalledRecoveredGear),'recovering gear does not install it prematurely')
View.tick(5);check((carrier:GetPivot().Position-resting.Position).Magnitude<.01,'gear recovery alone does not start the lift')
update({['EC-01:lift']=true})
check(not visible(ec.InstalledRecoveredGear),'installation also requires recovered gear')
update({['EC-01:gear']=true,['EC-01:lift']=true})
check(visible(ec.InstalledRecoveredGear)and visible(ec.FreightLandingReady),'saved repair installs gear and confirms landing')
View.tick(2)
check((carrier:GetPivot().Position-resting.Position).Magnitude>1,'confirmed repair animates freight carrier')
View.tick(3)
local raised=carrier:GetPivot()
check(math.abs(raised.Y-resting.Y-12)<.02,'carrier reaches the authored upper stop')
update({['EC-01:gear']=true,['EC-01:lift']=true});View.tick(5)
check((carrier:GetPivot().Position-raised.Position).Magnitude<.01,'duplicate snapshot never repeats or accumulates travel')
-- A genuinely new streamed model starts at the saved final pose without a
-- second journey. Its descendants and a light arrive with the same projection.
local streamed=carrier:Clone();streamed.Name='StreamedSavedCarrier';streamed.Parent=ec
task.wait()
check((streamed:GetPivot().Position-raised.Position).Magnitude<.02,'late stream-in restores saved final pose directly')
streamed:Destroy()
update()
View.tick(5)
check(not visible(ec.InstalledRecoveredGear)and not visible(fv.WesternBeaconLit),'switching to another unfinished hero resets private visuals')
check((carrier:GetPivot().Position-resting.Position).Magnitude<.02,'hero switch restores unearned carrier position')
update(nil,{['DW-01']=true,['FV-03']=true,['EC-01']=true})
View.tick(5)
check(visible(dw.ConfirmedSurvivorRoute)and visible(fv.BeaconsAnswerAcrossRavine)and visible(ec.InstalledRecoveredGear),'old cleared journals reconstruct final results without migration')
-- Simulate enqueue without persistence confirmation: requesting the existing
-- action must not change its personal visual or the journal.
local journal=assert(P.enableExpansion(P.new()))
local function finish(c)
 for _,g in ipairs(c.goals)do if P.required(journal,g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   journal=assert(P.apply(journal,c.id,g.id,step and step.choices and (step.solution or step.choices[1].id)or g.choice and 'shared',step and step.id or nil))
  end
 end end
end
for i=1,21 do finish(C.mainChapters[i])end
local c=C.byId['EC-01'];local lift
for _,g in ipairs(c.goals)do
 if g.id=='lift'then lift=g;break end
 if P.required(journal,g)then for _,step in ipairs(g.activity and g.activity.steps or {false})do
  journal=assert(P.apply(journal,c.id,g.id,step and step.choices and (step.solution or step.choices[1].id),step and step.id or nil))
 end end
end
local control=world.activityNodes['EC-01:lift:operate']
local probe=Instance.new('Part');probe.Anchored=true;probe.Position=control.part.Position;probe.Parent=workspace
local player={UserId=1401};local queued=0
local engine=require(game.ServerScriptService.Server.Story.DeepwoodActivities).create({
 players=function()return {player}end,active=function()return {heroId='test'}end,
 context=function()return {heroId='test'},probe end,state=function()return journal end,
 world=world,publish=function()end,enqueue=function()queued+=1 end,
})
View.update({journal=journal});View.tick(5)
engine.interactStep(player,c.id,lift.id,'operate')
check(queued==1 and not journal.flags['EC-01:lift'],'request is submitted to the existing server save path')
View.update({journal=journal});View.tick(5)
check(not visible(ec.InstalledRecoveredGear),'unconfirmed/failed save cannot display installed gear')
probe.Position=control.part.Position+Vector3.new(100,0,0)
engine.interactStep(player,c.id,lift.id,'operate')
check(queued==1,'out-of-range remote request cannot operate machinery')
probe.Position=control.part.Position
journal=assert(P.apply(journal,c.id,lift.id,nil,'operate'))
View.update({journal=journal});View.tick(5)
check(visible(ec.InstalledRecoveredGear),'confirmed server journal drives the repaired machine')
engine.interactStep(player,c.id,lift.id,'operate')
check(queued==1,'duplicate completed request cannot enqueue another completion')
engine.remove(player);probe:Destroy()
report.completed=true
print('QUEST_SETPIECES_NATIVE_PASS '..game.HttpService:JSONEncode(report))
return report
