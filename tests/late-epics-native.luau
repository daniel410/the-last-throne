-- Run only in a newly opened, unpublished test fixture with no human players.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture only')
local RS=game.ReplicatedStorage;local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(3)end
local report={kind='LATE_EPICS_NATIVE',checks=0,models={},scope='real-engine-with-fake-account-and-player'}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='LateEpicsNativeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress)
 require(Server.World.TrainingField).create()
 local world=require(Server.World.CampaignWorld).create()
 check(world.lateEpicsReady and #world.lateCompanionCamps==2,'late world bootstrap and companion camps')
 local late=require(RS.Shared.LateEpicContent);local Bounds=require(RS.Shared.CampaignBounds)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain};params.RespectCanCollide=true
 for id,z in pairs(late.zones)do
  local p=Vector3.new(table.unpack(z.center));local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
  check(hit and math.abs(hit.Position.Y-p.Y)<.1,'actual ground '..id);check(world.spawns[id]~=nil,'checkpoint '..id)
 end
 for _,edge in ipairs(late.edges)do
  local a,b=Bounds.ends(edge);a,b=Vector3.new(table.unpack(a)),Vector3.new(table.unpack(b))
  for i=0,10 do local p=a:Lerp(b,i/10);local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
   check(hit and math.abs(hit.Position.Y-p.Y)<.3,'continuous trail and authoritative height '..edge[1]..':'..i)
  end
 end
 local Field=require(Server.World.TrainingField);local Motion=require(Client.K0EnemyMotion);local profiles=require(RS.Shared.LateEpicCombat).profiles
 for kind in pairs(profiles)do
  local m=Field.makeEnemy(folder,kind,10000+report.checks*2,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m),kind..' motion binding');local cf=m.HumanoidRootPart.CFrame;local hp=m.Humanoid.Health
  for _,hz in ipairs({30,60,144})do
   m:SetAttribute('K0EnemyState','Chase');Motion.step(s,1/hz,100)
   for sequence=1,4 do
    m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock',sequence..'|500|1.2|.18|1.5|'..(sequence>=3 and '1'or '0'))
    for _,age in ipairs({.1,.9,1.2,1.35,2.5})do Motion.step(s,1/hz,500+age);check(m.Humanoid.Health==hp and m.HumanoidRootPart.CFrame==cf,'motion never owns roots or damage')end
   end
  end
  check(m:FindFirstChild('TdMonsterVisual')~=nil,kind..' actual visual')
  for _,p in ipairs(m.TdMonsterVisual:GetDescendants())do if p:IsA('BasePart')then check(not p.CanCollide and not p.CanQuery and p.Massless,'cosmetic geometry does not block combat')end end
  local entry={kind=kind,template=m:GetAttribute('TdMonsterTemplate'),prototype=m:GetAttribute('GloamwoodPrototypeVersion')~=nil,parts=#m.TdMonsterVisual:GetChildren()}
  if entry.prototype then check(s.gloam and #s.gloam>0,'prototype appendage animation bound')else check(m.TdMonsterVisual.Body:IsA('MeshPart'),'HG uses TD MeshParts')end
  table.insert(report.models,entry);Motion.unbind(s);m:Destroy();task.wait()
 end
 local journal=P.new()
 for n=1,21 do local c=C.mainChapters[n];for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
  else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary'))end
 end end end
 local Rules=require(Server.Inventory.InventoryRules);local Catalog=require(RS.Shared.ItemCatalog)
 local profile=assert(Rules.addHero(Rules.new(911),'qa','knight',Catalog));profile.heroes.qa.deepwood=journal
 local original=Server.Story.DeepwoodService;local copy=original:Clone();copy.Name='LateEpicServiceQA'
 local source=copy.Source;local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true))
 copy.Source=source:sub(1,first-1)..'local function publish(player,message)player.message=message end\n'..source:sub(last);copy.Parent=original.Parent
 local story=require(copy);local combat=table.clone(require(Server.Combat.CombatService));local faults={'SaveUnknown','Busy'};local retries=0;local xp,gold=0,0;local activeMission
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local human=Instance.new('Humanoid');human.MaxHealth=1000;human.Health=1000;human.Parent=character
 local player={UserId=911,Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
 local inventory={storyState=function()return P.copy(profile.heroes.qa.deepwood)end,expedition=function()return activeMission end,
  storyEvent=function(_,hero,c,g,choice,step)
   if c=='GW-01' and g=='maeve'then retries+=1;local fault=table.remove(faults,1);if fault then return fault end end
   local nextState,reason=Rules.story(profile,hero,c,g,choice,Catalog,step);if nextState then profile=nextState end;return reason
  end,supportState=function()return {active=true,credits=0}end,activateSupport=function()end,
  awardXP=function(_,_,amount,_,coins)xp+=amount;gold+=coins or 0 end}
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession={getActiveHero=function()return {heroId='qa',training=false}end,getCombatContext=function()return {heroId='qa'}end},combat=combat})
 check(story.destination(player,'qa')==world.spawns['GW-01'],'existing EC complete save resumes at Gloamwood')
 root.Position=world.lateCompanionCamps[2].model.PrimaryPart.Position;check(not story.supportCampAccess(player,'qa'),'late camp cannot bypass story gate')
 local function alive(key)
  local out={};for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key..':legacy' and m.Humanoid.Health>0 then table.insert(out,m)end end;return out
 end
 local function drain(c,g)
  local key=c.id..':'..g.id
  for _=1,100 do
   local models=alive(key);if #models==0 then break end
   check(#models<=require(RS.Shared.DeepwoodEncounterBalance).packSize(c,g),'bounded active pack')
   for _,m in ipairs(models)do
    local h=m.Humanoid;local max=h.MaxHealth;local kind=m:GetAttribute('EnemyKind')
    if kind=='Veyr'then
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.7)<.0001 and m:GetAttribute('StoryShield'),'Veyr clamps lethal hit at shield stage')
     check(story.bossDamage(m,max)==0,'shield stops damage')
     root.Position+=Vector3.new(500,0,0);check(not story.breakPillar(player,key..':legacy',1),'distant player cannot break shield link')
     for index=1,2 do root.Position=m.HumanoidRootPart.Position+Vector3.new(index==1 and -22 or 22,0,0);check(story.breakPillar(player,key..':legacy',index),'solo breaks each link')end
     check(not story.breakPillar(player,key..':legacy',2),'duplicate link interaction ignored')
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.35)<.0001,'Veyr final phase preserves boundary')
    elseif kind=='WidowQueen'then
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.65)<.0001,'queen first phase boundary')
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.30)<.0001,'queen second phase boundary')
    end
    h:TakeDamage(story.bossDamage(m,max*5));task.wait(.003);story.defeated(m);story.defeated(m)
   end
   task.wait(.01)
  end
  check(#alive(key)==0,'finite battle ends');task.wait(.1)
 end
 for n=22,35 do
  local c=C.mainChapters[n]
  for _,g in ipairs(c.goals)do
   local node=assert(world.nodes[c.id..':'..g.id]);check(node.prompt~=nil,'actual objective anchor')
   root.Position=node.part.Position+Vector3.new(500,0,0);story.interact(player,c.id,g.id);check(not inventory.storyState().flags[c.id..':'..g.id],'distant interaction rejected')
   root.Position=node.part.Position
   if #g.enemies>0 then story.interact(player,c.id,g.id);drain(c,g)
   elseif g.activity.mode=='escort'then
    story.interact(player,c.id,g.id)
    for _=1,350 do
     if inventory.storyState().flags[c.id..':'..g.id]then break end
     local actor;for _,m in ipairs(world.folder:GetChildren())do if m:IsA('Model')and m:GetAttribute('NPCPrivateOwnerUserId')==911 then actor=m;break end end
     check(actor and actor.PrimaryPart,'personal Tali rescue actor');root.Position=actor.PrimaryPart.Position+Vector3.new(0,3,0);story.stepActivities(.2);task.wait(.001)
    end
   elseif g.activity.mode=='dialogue'then story.interact(player,c.id,g.id)
   else story.interactStep(player,c.id,g.id,g.activity.steps[1].id)end
   if n==22 and g.id=='maeve'then
    check(story.hasPendingEvents(player)and not inventory.storyState().flags['GW-01:maeve'],'save failure cannot advance story')
    local deadline=os.clock()+5;repeat task.wait(.05)until not story.hasPendingEvents(player)or os.clock()>deadline
    check(retries==3 and #faults==0,'same event retries unknown/busy save')
   else task.wait(.1)end
   check(inventory.storyState().flags[c.id..':'..g.id],'server saves '..c.id..':'..g.id)
  end
  check(inventory.storyState().main==n and P.validate(inventory.storyState()),'checkpoint valid after chapter')
  if n==28 then check(story.destination(player,'qa')==world.spawns['HG-01'],'forest completion resumes at final epic')end
 end
 check(story.destination(player,'qa')==world.spawns['HG-02'],'complete campaign resumes at final safe hub')
 check(inventory.storyState().coins==16570,'story Gold awarded once')
 check(xp>0 and gold>0,'battle rewards use server kills')
 activeMission={missionId='HG-07',runId='qa-resume'}
 -- A completed campaign still uses the safe hub; real mission entry handles active run context.
 check(inventory.storyState().flags['HG-07:crownheart']and inventory.storyState().flags['HG-07:portal'],'final recovery and portal closure saved')
 local registry=world.folder.NPCActors
 local maeves=0;for _,actor in ipairs(registry:GetChildren())do if actor:GetAttribute('NPCActorScope')and actor:GetAttribute('NPCActorIdentity')then
  check(actor.PrimaryPart~=nil,'late named actor at authored scene anchor');if actor.Name=='Maeve'then maeves+=1 end
 end end
 report.scopedMaeves=maeves;report.finalMain=inventory.storyState().main;report.finalGold=inventory.storyState().coins
 copy:Destroy()
end,debug.traceback)
report.ok=ok;report.error=not ok and err or nil
folder:Destroy()
print(game.HttpService:JSONEncode(report))
assert(ok,err)
return report
