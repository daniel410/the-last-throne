-- Unpublished real Studio geometry, TD MeshParts and server story APIs.
assert(game.PlaceId==0,'Local fixture only')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(4)end
local RS=game.ReplicatedStorage;local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='EMBER_CALDERA_NATIVE',checks=0,failures={},weapons={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='EmberCalderaNativeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress);local Rigs=require(RS.Shared.EmberCalderaRigs)
 local world=require(Server.World.CampaignWorld).create();check(world.folder:GetAttribute('EmberCalderaReady'),'campaign bootstrap')
 local Bounds=require(RS.Shared.CampaignBounds)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain};params.RespectCanCollide=true
 for id,z in pairs(require(RS.Shared.EmberCalderaContent).zones)do
  check(world.spawns[id]~=nil,'checkpoint '..id)
  local center=Vector3.new(table.unpack(z.center));local hit=workspace:Raycast(center+Vector3.new(0,2,0),Vector3.new(0,-6,0),params)
  check(hit and math.abs(hit.Position.Y-center.Y)<.1,'actual snow surface '..id)
 end
 for _,edge in ipairs(require(RS.Shared.EmberCalderaContent).edges)do
  local a,b=Bounds.ends(edge);a,b=Vector3.new(table.unpack(a)),Vector3.new(table.unpack(b))
  for i=0,10 do local p=a:Lerp(b,i/10);local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
   check(hit~=nil,'continuous snow trail '..edge[1]..':'..i)
   check(hit and math.abs(hit.Position.Y-p.Y)<.25,'snow trail and authority height agree')
  end
 end
 local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.EmberCalderaClips);local Field=require(Server.World.TrainingField)
 for kind,spec in pairs(Rigs)do
  local model=Field.makeEnemy(folder,kind,10000+report.checks,10000,1,1);model.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(model));local health=model.Humanoid.Health;local root=model.HumanoidRootPart;local initial=root.CFrame
  check(model:GetAttribute('TdMonsterTemplate')==spec.template,kind..' TD source selected')
  check(s.profile.quadruped==false,kind..' anatomy')
  local count=0;for _ in pairs(s.legs)do count+=1 end
  check(count==((kind=='LavaSlime' or kind=='MagmaWorm' or kind=='VolcanoShaman' or kind=='KingVolcanoShaman') and 0 or 2),kind..' independent legs')
  for _,clip in ipairs({'Idle','Walk','Stunned'})do
   for _,ch in ipairs(Clips.channels)do local a,b=Motion.sample(kind,clip,0)[ch],Motion.sample(kind,clip,1)[ch]
    for i,value in ipairs(a)do check(math.abs(value-b[i])<1e-5,kind..' seamless loop')end
   end
  end
  for _,hz in ipairs({30,60,144})do for sequence=1,4 do
   local heavy=sequence>=3;local clip=(heavy and 'Heavy' or 'Attack')..(sequence%2==0 and 'Alt' or '')
   model:SetAttribute('K0EnemyState','Windup');model:SetAttribute('K0EnemyAttackClock',sequence..'|500|1.2|.15|1.4|'..(heavy and '1' or '0'))
   Motion.step(s,1/hz,500.96)
   local before=s.joints.weapon and s.joints.weapon.Transform
   Motion.step(s,1/hz,501.2)
   for _,ch in ipairs(Clips.channels)do for i,value in ipairs(Motion.sample(kind,clip,.62)[ch])do check(math.abs(s.pose[ch][i]-value)<.0001,kind..' exact server contact at '..hz..'Hz')end end
   if spec.socket then
    check(s.weaponFX and s.weaponFX.trail.Enabled,kind..' actual moving weapon trail')
    local delta=(before:Inverse()*s.joints.weapon.Transform);local _,angle=delta:ToAxisAngle()
    check(math.abs(angle)>.05,kind..' weapon advances at contact')
    check(s.weaponFX.a.Position.Magnitude>0,kind..' authored tip follows original mesh')
   end
   Motion.step(s,1/hz,503)
   check(not s.weaponFX or not s.weaponFX.trail.Enabled,kind..' recovery clears trail')
   check(root.CFrame==initial and model.Humanoid.Health==health,kind..' visual motion cannot move server root or damage')
  end end
  if s.weaponFX then model:SetAttribute('K0EnemyStunUntil',600);Motion.step(s,1/60,550);check(not s.weaponFX.trail.Enabled,kind..' stun clears weapon')end
  Motion.unbind(s);check(not model.TdMonsterVisual:FindFirstChild('K0WeaponPresentation',true),kind..' presentation cleaned on unbind');model:Destroy()
 end
 -- Saved personal journal starts at the old Deepwood boundary, without rewriting old flags.
 local journal=P.new()
 for n=1,14 do local c=C.mainChapters[n];for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
  else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary' or nil))end
 end end end
 check(P.validate(journal) and journal.main==14,'old saved journal before EC')
 local Rules=require(Server.Inventory.InventoryRules);local Catalog=require(RS.Shared.ItemCatalog)
 local profile=assert(Rules.addHero(Rules.new(911),'qa','knight',Catalog));profile.heroes.qa.deepwood=journal
 local original=Server.Story.DeepwoodService;local copy=original:Clone();copy.Name='EmberCalderaServiceQA'
 local source=copy.Source;local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true));copy.Source=source:sub(1,first-1)..'local function publish(player,message)player.message=message end\n'..source:sub(last);copy.Parent=original.Parent
 local story=require(copy);local combat=require(Server.Combat.CombatService);local xp,gold=0,0;local saveUnknown=true
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local h=Instance.new('Humanoid');h.Parent=character;h.MaxHealth=1000;h.Health=1000
 local player={UserId=911,Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
 local inventory={storyState=function()return P.copy(profile.heroes.qa.deepwood)end,
  storyEvent=function(_,hero,c,g,choice,step)
   if saveUnknown then saveUnknown=false;return 'SaveUnknown'end
   local nextState,reason
   if g=='@selene' then nextState,reason=Rules.selectSelene(profile,hero,choice)
   elseif g=='@accept' then nextState,reason=Rules.acceptQuest(profile,hero,c,choice==true)
   else nextState,reason=Rules.story(profile,hero,c,g,choice,Catalog,step)end
   if nextState then profile=nextState end;return reason
  end,
  awardXP=function(_,_,amount,_,coins)xp+=amount;gold+=coins or 0 end}
 local testedCombat=table.clone(combat)
 testedCombat.relocateForStoryGate=function(owner,pivot)check(owner==player and profile.heroes.qa.deepwood.flags['EC-01:lift'],'lift transfer requires confirmed personal save');character:PivotTo(pivot);return true end
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession={getActiveHero=function()return {heroId='qa',training=false}end,getCombatContext=function()return {heroId='qa'}end},combat=testedCombat})
 check(story.destination(player,'qa')==world.spawns['EC-01'],'Frozen Vale save resumes in Ember Caldera')
 root.Position=world.emberCompanionCamp.PrimaryPart.Position;check(not story.selectSelene(player,true),'locked refuge cannot select companion before entry')
 local function alive(key)local out={}for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key and m.Humanoid.Health>0 and not m:GetAttribute('StoryPacified')then table.insert(out,m)end end;return out end
 local function drain(c,g)
  local key=c.id..':'..g.id
  for _=1,80 do local models=alive(key);if #models==0 then break end
   check(#models<=require(RS.Shared.DeepwoodEncounterBalance).packSize(c,g),'finite capped pack')
   for _,m in ipairs(models)do
    if m:GetAttribute('EnemyKind')=='InfernoOverlord'then
     local human=m.Humanoid;local max=human.MaxHealth
     human:TakeDamage(story.bossDamage(m,max*5));check(math.abs(human.Health/max-.65)<.0001,'Inferno phase two clamps first lethal hit')
     human:TakeDamage(story.bossDamage(m,max*5));check(math.abs(human.Health/max-.30)<.0001,'Inferno phase three clamps second lethal hit')
     check(m:GetAttribute('StoryPhase')==3 and not m:GetAttribute('StoryPacified'),'Inferno uses lethal combat, separate from ice guardians')
     human:TakeDamage(story.bossDamage(m,max*5));task.wait(.01);story.defeated(m);story.defeated(m)
    else m.Humanoid.Health=0;task.wait(.003);story.defeated(m);story.defeated(m)end
   end
   task.wait(.01)
  end
  check(#alive(key)==0,'finite encounter drains');task.wait(.1)
 end
 for n=15,21 do local c=C.mainChapters[n]
  for _,g in ipairs(c.goals)do
   local node=world.nodes[c.id..':'..g.id];check(node and node.prompt,'actual objective anchor')
   root.Position=node.part.Position
   if #g.enemies>0 then story.interact(player,c.id,g.id);drain(c,g)
   elseif g.activity and g.activity.mode=='escort'then
    story.interact(player,c.id,g.id)
    for _=1,300 do
     if inventory.storyState().flags[c.id..':'..g.id]then break end
     local escort
     for _,m in ipairs(world.folder:GetChildren())do if m:IsA('Model') and m:GetAttribute('NPCPrivateOwnerUserId')==911 then escort=m;break end end
     check(escort and escort.PrimaryPart,'per-owner dwarf rescue actor')
     root.Position=escort.PrimaryPart.Position+Vector3.new(0,3,0);story.stepActivities(.2);task.wait(.001)
    end
   elseif g.activity and (g.activity.mode=='travel' or g.activity.mode=='mechanism') then story.interactStep(player,c.id,g.id,g.activity.steps[1].id)
   else story.interact(player,c.id,g.id)end
   if saveUnknown==false and n==15 and g==c.goals[1]then task.wait(1.2)else task.wait(.1)end
   check(inventory.storyState().flags[c.id..':'..g.id],'service saves '..c.id..':'..g.id)
   if c.id=='EC-01' and g.id=='lift'then check((root.Position-world.spawns['EC-02'].Position).Magnitude<10,'repaired lift transfers to prepared safe city checkpoint after save')end
  end
  check(inventory.storyState().main==n,'correct checkpoint advancement')
  if n==15 then root.Position=world.emberCompanionCamp.PrimaryPart.Position;check(story.selectSelene(player,true),'safe refuge companion selection');task.wait(.1);check(inventory.storyState().seleneFollowing,'companion preference saved at refuge')end
 end
 check(story.destination(player,'qa')==world.spawns['EC-02'],'completed Ember Caldera resumes at safe forge')
 check(inventory.storyState().coins==10290 and P.validate(inventory.storyState()),'canonical story reward once, compatible journal')
 check(xp>0 and gold>0,'actual battle server rewards')
 -- Optional quest acceptance is personal and distinct from reports.
 for _,c in ipairs(C.chapters)do if c.epic==3 and c.side then
  root.Position=world.nodes[c.id..':'..c.goals[1].id].part.Position;story.interact(player,c.id,c.goals[1].id);check(story.acceptQuest(player,c.id),'optional request acceptance');task.wait(.1)
  for _,g in ipairs(c.goals)do if not inventory.storyState().flags[c.id..':'..g.id]then
   root.Position=world.nodes[c.id..':'..g.id].part.Position;story.interact(player,c.id,g.id);if #g.enemies>0 then drain(c,g)end;task.wait(.1)
  end end
  check(inventory.storyState().clears[c.id],'optional report saved')
 end end
 check(inventory.storyState().coins==10290,'optional quests never invent fixed budgets')
 local expectedXP,expectedGold=0,0;local balance=require(RS.Shared.DeepwoodEncounterBalance)
 local function add(specs)for _,spec in ipairs(specs)do expectedXP+=(8+2*spec.level)*(balance.isBoss(spec.kind)and 5 or 1)*spec.count;expectedGold+=(3+math.floor(spec.level/2))*(balance.isBoss(spec.kind)and 10 or 1)*spec.count end end
 for _,c in ipairs(C.chapters)do if c.epic==3 then for _,g in ipairs(c.goals)do add(g.enemies);for _,wave in ipairs(g.bossEncounter and g.bossEncounter.waves or {})do add(wave.enemies)end end end end
 check(xp==expectedXP and gold==expectedGold,'all kill rewards are exact and duplicate callbacks pay once')
 character:Destroy();copy:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();report.pass=#report.failures==0
print('EMBER_CALDERA_NATIVE '..game.HttpService:JSONEncode(report));return report
