-- Native real TD rigs/scene + fake Player/account dependency. No input/real save claim.
local RS=game:GetService('ReplicatedStorage');local SSS=game:GetService('ServerScriptService');local Run=game:GetService('RunService');local Players=game:GetService('Players')
local report={kind='DEEPWOOD_SERVICE_NATIVE',checks=0,failures={}}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,err=xpcall(function()
 Run:Run();task.wait(3)
 local world=require(SSS.Server.World.DeepwoodWorld).create();local C=require(RS.Shared.DeepwoodContent);local P=require(RS.Shared.DeepwoodProgress)
 local Rules=require(SSS.Server.Inventory.InventoryRules);local Catalog=require(RS.Shared.ItemCatalog)
 local profile=Rules.addHero(Rules.new(91),'qa','knight',Catalog)
 local original=SSS.Server.Story.DeepwoodService;local copy=original:Clone();copy.Name='DeepwoodServiceQA'
 local source=copy.Source;local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true))
 copy.Source=source:sub(1,first-1).."local function publish(player,message) player.message=message end\n"..source:sub(last);copy.Parent=original.Parent
 local story=require(copy)
 local combat=require(SSS.Server.Combat.CombatService)
 local character=Instance.new('Model');character.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local human=Instance.new('Humanoid');human.Parent=character;human.MaxHealth=1000;human.Health=1000
 local player={UserId=911,Parent=Players,Character=character,GetAttribute=function() return 'Tutorial' end}
 local valid=true;local xp,gold=0,0;local unknownSelene=false
 local hero={getActiveHero=function() return {heroId='qa'} end,getCombatContext=function() return valid and {heroId='qa'} end,restartAdventure=function() return true end}
 local inventory={storyState=function() return P.copy(profile.heroes.qa.deepwood or P.new()) end,
  storyEvent=function(_,id,c,g,choice,stepId) local n,e;if g=='@selene' then if unknownSelene then unknownSelene=false;return 'SaveUnknown' end;n,e=Rules.selectSelene(profile,id,choice) elseif g=='@accept' then n,e=Rules.acceptQuest(profile,id,c,choice==true) else n,e=Rules.story(profile,id,c,g,choice,Catalog,stepId) end;if n then profile=n end;return e end,
  awardXP=function(_,_,amount,_,coins) xp=xp+amount;gold=gold+(coins or 0) end}
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession=hero,combat=combat})
 local function near(c,g) root.Position=world.nodes[c..':'..g].part.Position end
 root.Position=world.seleneCamp+Vector3.new(0,3,0);check(not story.selectSelene(player,true),'cannot recruit at camp before rescue report')
 local seenBossBadges={}
 local function models(key) local r={} for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren()) do if m:GetAttribute('DeepwoodEncounter')==key then
   local bar=m:FindFirstChild('EnemyHealthBar')
   check(bar and bar.BossBadge.Visible==(m:GetAttribute('StoryBoss')==true),'actual story boss badge excludes bodyguards')
   check(bar.EnemyLevel.Text=='Lv.'..m:GetAttribute('StoryLevel'),'overhead level matches server combat level')
   check(bar.EnemyLevel.Position.Y.Offset==bar.HpBg.Position.Y.Offset and bar.EnemyLevel.Size.X.Offset<=bar.HpBg.Position.X.Offset,'level sits beside HP without overlap')
   if m:GetAttribute('StoryBoss') then seenBossBadges[m:GetAttribute('EnemyKind')]=true end
   table.insert(r,m)
  end end return r end
 local function reinforceBoss(boss,key,initial,total,gates)
  check(#models(key)==initial,key..' starts with its bodyguard group')
  local h=boss:FindFirstChildOfClass('Humanoid');h.MaxHealth=boss:GetAttribute('StoryHealth');h.Health=h.MaxHealth
  story.bossDamage(boss,0);check(#models(key)==initial,'no reinforcements before health gate')
  for _,gate in ipairs(gates) do
   local hit=story.bossDamage(boss,h.Health-h.MaxHealth*gate+.001);h.Health-=hit
   local count=#models(key);story.bossDamage(boss,0)
   check(#models(key)==count,'repeated damage cannot duplicate a reinforcement wave')
  end
  check(#models(key)==total,key..' finite complete population')
  check(story.encounterState(player,'qa')[key].remaining==total,'remaining includes every guard')
  local paused=0;for _,m in ipairs(models(key)) do if not m:GetAttribute('StoryBoss') and (m:GetAttribute('StoryPauseUntil') or 0)>workspace:GetServerTimeNow() then paused+=1 end end
  check(paused>0,'reinforcements give time to reposition before attacking')
 end
 root.Position=Vector3.new(2000,100,2000);story.interact(player,'DW-01','trail_guards');check(#models('DW-01:trail_guards')==0,'remote prompt distance cannot start fight')
 near('DW-01','trail_guards');valid=false;story.interact(player,'DW-01','trail_guards');check(#models('DW-01:trail_guards')==0,'inactive hero cannot start fight');valid=true
 story.interact(player,'DW-01','tracks');check(not inventory.storyState().flags['DW-01:tracks'],'future investigation cannot skip combat')
 near('DW-01','trail_guards');story.interact(player,'DW-01','trail_guards');check(#models('DW-01:trail_guards')==6,'six actual TD goblin rigs')
 local status=story.encounterState(player,'qa')['DW-01:trail_guards']
 check(status and status.remaining==6,'server reports all six enemies left')
 check(next(story.encounterState(player,'another-hero'))==nil,'encounter state never leaks across hero identity')
 for _,m in ipairs(models('DW-01:trail_guards')) do
  m:FindFirstChildOfClass('Humanoid').Health=0;task.wait(.05)
  story.defeated(m);story.defeated(m)
 end;task.wait(.2)
 check(story.encounterState(player,'qa')['DW-01:trail_guards'].remaining==0,'real CombatService Died callback updates encounter')
 check(inventory.storyState().flags['DW-01:trail_guards'],'encounter event saves');check(xp==36 and gold==10,'larger group preserves original total XP/Gold and duplicate death pays once')
 -- Native service walk through every non-combat objective and spawn/defeat group.
 for _,c in ipairs(C.chapters) do if not c.side then for _,g in ipairs(c.goals) do
  if not g.optional and not inventory.storyState().flags[c.id..':'..g.id] then
   near(c.id,g.id)
   if g.choice then check(story.destination(player,'qa')==world.spawns['DW-03'],'supply return resumes at outpost');inventory.storyEvent(nil,'qa',c.id,g.id,'shared')
   else
    story.interact(player,c.id,g.id)
    if g.activity and g.activity.steps then
     if g.activity.mode=='escort' then
      local actor=assert(world.folder:FindFirstChild(g.activity.actor),'escort starts a resident')
      local initial=actor.PrimaryPart.Position;root.Position=initial+Vector3.new(60,0,0);story.stepActivities(.25)
      check(actor.PrimaryPart.Position==initial,'resident waits when player falls behind')
      for _=1,1600 do
       if inventory.storyState().flags[c.id..':'..g.id] then break end
       if not actor.Parent then break end
       root.Position=actor.PrimaryPart.Position+Vector3.new(2,0,0);story.stepActivities(.25);task.wait(.001)
      end
     else
      for _,step in ipairs(g.activity.steps) do
       root.Position=world.activityNodes[c.id..':'..g.id..':'..step.id].part.Position
       story.interactStep(player,c.id,g.id,step.id,step.choices and step.choices[1].id);task.wait(.03)
      end
     end
    elseif #g.enemies>0 then
     local key=c.id..':'..g.id;local boss
     for _,m in ipairs(models(key)) do if m:GetAttribute('StoryBoss') then boss=m end end
     if boss and g.id=='warlord' then reinforceBoss(boss,key,10,19,{.5}) end
     if boss and g.id=='king_shaman' then
      check(#models(key)==10,'King Shaman starts with nine guards')
      local h=boss:FindFirstChildOfClass('Humanoid');h.MaxHealth=boss:GetAttribute('StoryHealth');h.Health=h.MaxHealth
      local cap=story.bossDamage(boss,h.MaxHealth);check(cap==h.MaxHealth*.3,'boss cannot skip shield phase');h.Health=h.Health-cap
      check(#models(key)==19,'shield phase adds nine guards without skipping final wave')
      check(story.bossDamage(boss,99999)==0,'shield denies damage')
      check(not story.breakPillar(player,key,1),'pillar distance independently checked')
      for i=1,2 do root.Position=world.folder:FindFirstChild('TemporarySealPillar').Position;check(story.breakPillar(player,key,i),'sequential pillar interaction') end
      check(story.bossDamage(boss,h.MaxHealth)==h.MaxHealth*.35,'boss cannot skip final phase')
      check(#models(key)==28,'final phase adds the last nine guards')
     end
     for _=1,3 do
      for _,m in ipairs(models(key)) do m:FindFirstChildOfClass('Humanoid').Health=0 end
      task.wait(.1)
     end
    end
   end
   task.wait(.1)
   check(inventory.storyState().flags[c.id..':'..g.id],c.id..g.id..' service objective saved')
   if c.id=='DW-03' and g.id=='report' then
    check(P.seleneUnlocked(inventory.storyState()) and not inventory.storyState().seleneFollowing,'saved rescue unlocks without forced selection')
    root.Position=world.seleneCamp+Vector3.new(0,3,0);unknownSelene=true
    check(story.selectSelene(player,true),'camp invite accepted for current owner');task.wait(.15)
    check(not inventory.storyState().seleneFollowing,'unacknowledged preference is not published as selected')
    task.wait(1.1);check(inventory.storyState().seleneFollowing,'same queued preference retries after unknown save')
    local beforeRest=profile.revision
    check(story.selectSelene(player,false),'rest accepted at camp');task.wait(.15)
    check(not inventory.storyState().seleneFollowing and P.seleneUnlocked(inventory.storyState()),'rest retains recruitment')
    check(profile.revision==beforeRest+1,'rest commits one personal preference write')
   end
  end
 end end end
 local s=inventory.storyState();check(s.main==7 and s.choice=='shared','native server full main chain')
 check(s.coins==2290,'first-clear Coins exact');check(profile.items['qa-DW-07-bossseal'].quantity==1,'seal once')
 local Access=require(RS.Shared.DeepwoodAccess)
 local gate=require(SSS.Server.Story.DeepwoodRegionAccess).create({heroSession=hero,inventory=inventory,world=world,combat={relocateForStoryGate=function(_,pivot) character:PivotTo(pivot) end},notice=function() end})
 -- Offers do not execute field goals; acceptance is proximity- and hero-bound.
 local quest=C.byId['DW-Q2'];local questStart=quest.goals[1]
 near(quest.id,'request');story.interact(player,quest.id,'request')
 check(not inventory.storyState().flags[quest.id..':'..questStart.id],'hearing NPC request never executes field clue')
 local beforeAccept=profile.revision
 local originalCharacter=player.Character;local replacement=originalCharacter:Clone();player.Character=replacement
 check(not story.acceptQuest(player,quest.id),'offer does not survive character replacement');player.Character=originalCharacter;replacement:Destroy()
 root.Position+=Vector3.new(100,0,0)
 check(not story.acceptQuest(player,quest.id),'cannot accept offer after leaving NPC')
 near(quest.id,'request');check(story.acceptQuest(player,quest.id),'nearby current hero can accept request');task.wait(.1)
 check(P.accepted(inventory.storyState(),quest) and not inventory.storyState().flags[quest.id..':'..questStart.id],'NPC acceptance and field completion remain separate')
 check(profile.revision==beforeAccept+1,'one accepted request changes account once')
 check(not story.acceptQuest(player,quest.id),'replayed offer token is consumed')
 near(quest.id,'request');story.interact(player,quest.id,'request');task.wait(.05)
 check(not inventory.storyState().flags[quest.id..':'..questStart.id],'talking to active quest giver cannot skip fieldwork')
 -- Discovery is accepted only at the actual clue and atomically records that clue.
 near('DW-Q1','waterproof_log');story.interact(player,'DW-Q1','waterproof_log')
 check(not inventory.storyState().flags['DW-Q1:waterproof_log'],'reading a discovery opens an optional offer')
 check(story.acceptQuest(player,'DW-Q1'),'field clue can be accepted');task.wait(.1)
 check(inventory.storyState().accepted['DW-Q1'] and inventory.storyState().flags['DW-Q1:waterproof_log'],'accepting discovery records clue once')
 near('DW-Q1','marsh_report');story.interact(player,'DW-Q1','marsh_report');task.wait(.1)
 check(inventory.storyState().clears['DW-Q1'],'reporting optional discovery completes quest')
 -- Optional bosses use real TD rigs and the same server death/reward path.
 for _,spec in ipairs({{'DW-Q2','goblin_king',6,9,{.5}},{'DW-Q3','king_ogre',5,8,{.5}},{'DW-Q4','enraged_warlord',6,12,{.6,.3}}}) do
  local c=C.byId[spec[1]]
  if not P.accepted(inventory.storyState(),c) then near(c.id,'request');story.interact(player,c.id,'request');check(story.acceptQuest(player,c.id),'optional boss quest accepted');task.wait(.1) end
  for _,g in ipairs(c.goals) do if not g.optional then
   near(c.id,g.id);story.interact(player,c.id,g.id);task.wait(.05)
   if g.id==spec[2] then
    local key=c.id..':'..g.id;local boss
    for _,m in ipairs(models(key)) do if m:GetAttribute('StoryBoss') then boss=m end end
    reinforceBoss(assert(boss),key,1+(spec[3]-1)*3,1+(spec[4]-1)*3,spec[5])
    boss:FindFirstChildOfClass('Humanoid').Health=0;task.wait(.1)
    check(not inventory.storyState().flags[key],'boss death alone cannot skip surviving guards')
    for _,m in ipairs(models(key)) do m:FindFirstChildOfClass('Humanoid').Health=0;story.defeated(m);story.defeated(m) end
    task.wait(.15)
   end
   check(inventory.storyState().flags[c.id..':'..g.id],c.id..g.id..' saves after all guards fall')
  end end
  check(inventory.storyState().clears[c.id],c.id..' still requires resident report')
 end
 for _,kind in ipairs({'Warlord','KingShaman','GoblinKing','KingOgre','EnragedWarlord'})do check(seenBossBadges[kind],kind..' actual encounter has a boss badge')end
 check(inventory.storyState().coins==2290,'more enemies do not change fixed quest Coins')
 local savedProfile=profile;profile=Rules.addHero(Rules.new(92),'qa','knight',Catalog)
 root.Position=world.spawns['DW-01'].Position;gate.update(player);local safe=root.Position;local health=human.Health
 root.Position=Vector3.new(table.unpack(C.zones['DW-02'].center));gate.update(player)
 check((root.Position-safe).Magnitude<1,'server returns hero who bypasses region gate')
 check(human.Health==health,'gate does not heal or damage hero')
 check(not Access.allowed(inventory.storyState(),'DW-02'),'gate cannot manufacture completion')
 profile=savedProfile;gate.remove(player)
 character:Destroy();copy:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('DEEPWOOD_SERVICE_NATIVE '..game:GetService('HttpService'):JSONEncode(report));assert(report.pass,'Deepwood service fixture failed')
