local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local Content=require(ReplicatedStorage.Shared.DeepwoodContent)
local Progress=require(ReplicatedStorage.Shared.DeepwoodProgress)
local Rig=require(script.Parent.Parent.World.TrainingField)
local QuestLog=require(ReplicatedStorage.Shared.DeepwoodQuestLog)
local Service={}
local offers={}
local activities,access
local options,remote,encounters,queues,lastRequest={},{},{},{},{}
local function context(player)
 local c=options.heroSession.getCombatContext(player,player.Character)
 local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 if not human or human.Health<=0 then return nil,root end
 return c,root
end
local function state(player,heroId) return options.inventory.storyState(player,heroId) end
local function active(player) return options.heroSession.getActiveHero(player) end
-- Read-only encounter projection: clients can explain the current blocker,
-- but cannot declare a kill or complete an objective from this data.
function Service.encounterState(player,heroId)
 local result={}
 for key,e in pairs(encounters) do
  if e.participants[player]==heroId then
   result[key]={wave=e.wave,waves=e.waveCount,remaining=e.remaining,pillars=e.shield and e.pillars or 0}
  end
 end
 return result
end
local function publish(player,message,notice,completion)
 local h=active(player);if not h then return end
 local s=state(player,h.heroId);if not s then return end
 local activityState,dialogue
 if activities then activityState,dialogue=activities.projection(player,h.heroId) end
 local offer=offers[player];local ctx,root=context(player)
 if offer and (not ctx or ctx.heroId~=offer.heroId or player.Character~=offer.character or not root or (root.Position-offer.node.part.Position).Magnitude>16) then offers[player]=nil;offer=nil end
 remote:FireClient(player,{questOffer=offer and {id=offer.node.chapter.id,discovery=offer.discovery} or nil,completion=completion,notice=notice,activities=activityState,dialogue=dialogue,heroId=h.heroId,training=h.training,journal=s,encounters=Service.encounterState(player,h.heroId),message=message,mode=player:GetAttribute('K0SessionPhase')})
end
function Service.destination(player,heroId)
 local s=state(player,heroId)
 local c=Content.chapters[math.min(7,(s and s.main or 0)+1)]
 if s and s.flags['DW-07:separate'] then return options.world.spawns['DW-03'] end
 return options.world.spawns[c.zone]
end
local function enqueue(player,heroId,c,g,choice,stepId)
 queues[player]=queues[player] or {events={},keys={}}
 local q=queues[player];local key=heroId..':'..c.id..':'..g.id..':'..tostring(stepId)
 if q.keys[key] then return end
 q.keys[key]=true;table.insert(q.events,{heroId=heroId,c=c,g=g,choice=choice,stepId=stepId,key=key})
 if q.running then return end;q.running=true
 task.spawn(function()
  while player.Parent==Players and #q.events>0 do
   local e=q.events[1];local before=state(player,e.heroId);local reason=options.inventory.storyEvent(player,e.heroId,e.c.id,e.g.id,e.choice,e.stepId)
   if reason=='Busy' or reason=='SaveUnknown' then
    publish(player,'Saving progress. Please wait; the same event will retry.');task.wait(1)
   elseif reason then
    publish(player,'Progress could not be saved. Return to the checkpoint or rejoin to retry.')
    q.keys[e.key]=nil;table.remove(q.events,1)
   else
    q.keys[e.key]=nil;table.remove(q.events,1)
    local after=state(player,e.heroId)
    if e.g.id=='@accept' then
     publish(player,nil,'Optional quest accepted: '..e.c.title,{kind='Accepted',id=e.c.id})
    else
    local text=e.g.text
    if e.stepId then for _,step in ipairs(e.g.activity.steps) do if step.id==e.stepId then
     text=step.text
     for _,answer in ipairs(step.choices or {}) do if answer.id==e.choice then text=answer.text end end
    end end end
    local complete=after and after.clears[e.c.id] and before and not before.clears[e.c.id]
    publish(player,text~='' and text or nil,nil,complete and {id=e.c.id,title=e.c.quest.title or e.c.title,kind=e.c.side and 'Side quest' or 'Story',xp=e.c.reward.xp,coins=e.c.reward.coins,outcome=e.c.quest.outcome} or nil)
    end
   end
  end
  q.running=false
 end)
end
local function eligible(player,c,g,radius,position)
 local ctx,root=context(player)
 if not ctx or not root or (root.Position-position).Magnitude>radius then return nil end
 local s=state(player,ctx.heroId)
 if not s or not Progress.available(s,c,g) then return nil end
 return ctx
end
local function destroyEncounter(e)
 if encounters[e.key]~=e then return end
 encounters[e.key]=nil
 for _,m in ipairs(e.models) do if m.Parent then m:Destroy() end end
 for _,p in ipairs(e.parts or {}) do if p.Parent then p:Destroy() end end
end
local function support(e,kind,level,offset)
 local p=e.position+offset;local m=Rig.makeEnemy(options.enemies,kind,p.X,p.Z,1,1)
 m:PivotTo(m:GetPivot()+Vector3.new(0,p.Y-1,0));m:SetAttribute('DeepwoodEncounter',e.key)
 m:SetAttribute('StoryLevel',level);m:SetAttribute('StoryHealth',100+level*25);m:SetAttribute('StoryDamage',10+level)
 m:FindFirstChildOfClass('Humanoid').DisplayName=kind=='Shaman' and 'Goblin Shaman' or 'Goblin'
 table.insert(e.models,m);e.remaining=e.remaining+1;options.combat.addStoryEnemy(m)
end
local function pillar(e,index)
 local p=Instance.new('Part');p.Name='TemporarySealPillar';p.Size=Vector3.new(4,9,4);p.Position=e.position+Vector3.new(index==1 and -22 or 22,3,0)
 p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.Color=Color3.fromRGB(160,70,220);p.Material=Enum.Material.Neon;p.Parent=options.world.folder
 e.parts=e.parts or {};table.insert(e.parts,p)
 local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ObjectText='Temporary seal pillar';prompt.ActionText='Break the shield link';prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.HoldDuration=.6;prompt.Parent=p
 e.pillarParts=e.pillarParts or {};e.pillarParts[index]=p
 prompt.Triggered:Connect(function(player) Service.breakPillar(player,e.key,index) end)
end
function Service.breakPillar(player,key,index)
 local e=encounters[key];local p=e and e.pillarParts and e.pillarParts[index]
 if not p or not p.Parent or not e.shield then return false end
 local ctx,root=context(player)
 if not ctx or not root or e.participants[player]~=ctx.heroId or (root.Position-p.Position).Magnitude>16 then return false end
 e.pillarParts[index]=nil;e.pillars=e.pillars-1;p:Destroy()
 if e.pillars==0 then e.shield=false;e.boss:SetAttribute('StoryShield',false)
  for ally in pairs(e.participants) do publish(ally,'The shield is broken. King Shaman is vulnerable!') end
 end
 return true
end
function Service.bossDamage(model,damage)
 local e=encounters[model:GetAttribute('DeepwoodEncounter')]
 if not e or e.boss~=model then return damage end
 if e.shield then return 0 end
 local humanoid=model:FindFirstChildOfClass('Humanoid');local hp,max=humanoid.Health,humanoid.MaxHealth
 local kind=model:GetAttribute('EnemyKind')
 if kind=='Warlord' and not e.reinforced and hp-damage<=max*.5 then
  e.reinforced=true;support(e,'Shaman',9,Vector3.new(-20,0,12))
  for p in pairs(e.participants) do publish(p,'The Warlord calls a shaman! Clear the support or move to the flank.') end
 end
 if kind=='KingShaman' then
  if not e.reinforced then e.reinforced=true;support(e,'Goblin',11,Vector3.new(-18,0,12));support(e,'Goblin',11,Vector3.new(18,0,12)) end
  if not e.phase2 and hp-damage<=max*.7 then
   e.phase2=true;e.shield=true;e.pillars=2;model:SetAttribute('StoryShield',true);model:SetAttribute('StoryPhase',2)
   pillar(e,1);pillar(e,2)
   for p in pairs(e.participants) do publish(p,'King Shaman is shielded. Break both temporary pillars, one at a time.') end
   return math.max(0,hp-max*.7)
  elseif not e.phase3 and hp-damage<=max*.35 then
   e.phase3=true;e.nextHazard=os.clock()+2;model:SetAttribute('StoryPhase',3)
   for p,heroId in pairs(e.participants) do
    local s=state(p,heroId)
    if s and s.flags['DW-07:rescue_captives'] and not e.ogreHelp then
     e.ogreHelp=true;model:SetAttribute('StoryPauseUntil',workspace:GetServerTimeNow()+5)
     publish(p,'The freed ogre breaks through the roots! King Shaman is exposed for a moment.')
    else publish(p,'The altar is collapsing. Move away from the violet warning zones!') end
   end
   return math.max(0,hp-max*.35)
  end
 end
 return damage
end
local function floorHazard(e)
 if not e.boss or not e.boss.Parent or e.boss:FindFirstChildOfClass('Humanoid').Health<=0 then return end
 local pos=e.position+Vector3.new(math.sin(os.clock())*18,-.7,math.cos(os.clock())*18)
 local p=Instance.new('Part');p.Name='CorruptionWarning';p.Shape=Enum.PartType.Cylinder;p.Size=Vector3.new(.15,14,14);p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Color=Color3.fromRGB(180,65,240);p.Material=Enum.Material.Neon;p.Transparency=.5;p.Parent=options.world.folder
 e.parts=e.parts or {};table.insert(e.parts,p)
 task.delay(2,function()
  if encounters[e.key]==e then
   for ally,heroId in pairs(e.participants) do local ctx,root=context(ally)
    if ctx and ctx.heroId==heroId and root and (Vector3.new(root.Position.X,pos.Y,root.Position.Z)-pos).Magnitude<7
     and not ally.Character:GetAttribute('K0Invulnerable') then ally.Character:FindFirstChildOfClass('Humanoid'):TakeDamage(32) end
   end
  end
  p:Destroy()
 end)
end

local function spawnWave(e)
 local position=e.position
 local total=0 for _,spec in ipairs(e.pendingSpecs) do total=total+1 end
 local index=0
 for n=1,total do local spec=e.pendingSpecs[n]
  if n>=e.waveFirst and n<=e.waveLast then
  index=index+1;local a=index*math.pi*2/math.max(1,total)
  local p=position+Vector3.new(math.cos(a)*13,-1,math.sin(a)*13)
  local kind=spec.kind;local boss=kind=='Warlord' or kind=='GoblinKing' or kind=='KingOgre' or kind=='EnragedWarlord' or kind=='KingShaman'
  local scale=(kind=='Ogre' or kind=='KingOgre') and 1.8 or 1
  local m=Rig.makeEnemy(options.enemies,kind,p.X,p.Z,scale,boss and 1.3 or 1)
  m:PivotTo(m:GetPivot()+Vector3.new(0,p.Y,0));m:SetAttribute('DeepwoodEncounter',e.key)
  m:SetAttribute('StoryLevel',spec.level);m:SetAttribute('StoryBoss',boss)
  m:SetAttribute('StoryHealth',math.floor((boss and 1000+spec.level*100 or 100+spec.level*25)*(boss and ({1,1.7,2.3,2.8})[e.partySize] or 1)))
  m:SetAttribute('StoryDamage',boss and 28+spec.level*2 or 10+spec.level)
  m:FindFirstChildOfClass('Humanoid').DisplayName=({Orc='Orc Warrior',Slime='Cave Slime',Shaman='Goblin Shaman',Warlord='Orc Warlord',GoblinKing='Goblin King',KingOgre='King Ogre',KingShaman='King Shaman',EnragedWarlord='Enraged Warlord'})[kind] or kind
  table.insert(e.models,m);e.remaining=e.remaining+1;if boss then e.boss=m end;options.combat.addStoryEnemy(m)
 end end
end
local function begin(player,node,automatic)
 local c,g=node.chapter,node.goal;local position=node.part.Position
 local ctx=eligible(player,c,g,automatic and 36 or 16,position);if not ctx then publish(player,'Complete the earlier objectives and move closer to this marker.');return end
 local key=c.id..':'..g.id;local e=encounters[key]
 if e then
  local n=0 for _ in pairs(e.participants) do n=n+1 end
  if not e.participants[player] and n>=4 then publish(player,'This encounter already has four heroes. Wait for the next attempt.');return end
  e.participants[player]=ctx.heroId;publish(player,'Encounter joined. Defeat the remaining guards.');return end
 e={key=key,chapter=c,goal=g,position=position,models={},participants={[player]=ctx.heroId},remaining=0,started=os.clock(),lastPresent=os.clock()};encounters[key]=e
 -- Eligible nearby allies can help through combat, protection or interaction.
 local count=1
 for _,p in ipairs(Players:GetPlayers()) do if p~=player then
  local ally=eligible(p,c,g,65,position)
  if ally and count<4 then e.participants[p]=ally.heroId;count=count+1 end
 end end
 e.partySize=count;e.pendingSpecs={}
 for _,spec in ipairs(g.enemies) do for _=1,spec.count do table.insert(e.pendingSpecs,spec) end end
 e.waveCount=math.min(g.activity and g.activity.waves or 1,#e.pendingSpecs);e.wave=1
 e.waveFirst=1;e.waveLast=math.ceil(#e.pendingSpecs/e.waveCount);spawnWave(e)
 for ally in pairs(e.participants) do publish(ally,g.activity and g.activity.intro or 'Encounter started. Watch enemy attack warnings and use the open ground.') end
end
local function offerQuest(player,node,discovery)
 local ctx,root=context(player);local hero=active(player)
 if not ctx or not root or not hero or hero.training or (root.Position-node.part.Position).Magnitude>16 then return end
 local journal=state(player,ctx.heroId)
 if not journal or not Progress.canAccept(journal,node.chapter) then return end
 offers[player]={heroId=ctx.heroId,character=player.Character,node=node,discovery=discovery};publish(player)
end
function Service.acceptQuest(player,id)
 local offer=offers[player];local ctx,root=context(player)
 if not offer or offer.node.chapter.id~=id or not ctx or ctx.heroId~=offer.heroId or player.Character~=offer.character or not root or (root.Position-offer.node.part.Position).Magnitude>16 then return false end
 local journal=state(player,ctx.heroId)
 if not journal or not Progress.canAccept(journal,offer.node.chapter) then return false end
 offers[player]=nil
 enqueue(player,ctx.heroId,offer.node.chapter,{id='@accept'},offer.discovery)
 return true
end
local function interact(player,node)
 if node.chapter.side then
  local ctx,root=context(player);local hero=active(player)
  if not ctx or not root or not hero or hero.training or (root.Position-node.part.Position).Magnitude>16 then return end
  local journal=state(player,ctx.heroId);if not journal then return end
  if node.offer then
   if Progress.canAccept(journal,node.chapter) then offerQuest(player,node,false)
   elseif Progress.accepted(journal,node.chapter) then
    local report=Progress.goal(node.chapter,node.chapter.quest.turnIn)
    if Progress.available(journal,node.chapter,report) then enqueue(player,ctx.heroId,node.chapter,report)
    else publish(player,journal.clears[node.chapter.id] and node.chapter.quest.outcome or node.chapter.quest.brief) end
   else publish(player,nil,'Continue the main story before taking this request.') end
   return
  elseif node.goal==node.chapter.goals[1] and Progress.canAccept(journal,node.chapter) then offerQuest(player,node,true);return end
 end
 local ctx=eligible(player,node.chapter,node.goal,16,node.part.Position)
 if not ctx then publish(player,'Complete the earlier objectives and move closer to this marker.');return end
 if activities and activities.interact(player,node) then return end
 if #node.goal.enemies>0 then begin(player,node)
 elseif node.goal.choice then publish(player,node.goal.text)
 else enqueue(player,ctx.heroId,node.chapter,node.goal) end
end
-- Server API for proximity-validated interactions (also used by native QA).
function Service.interact(player,chapterId,goalId)
 local node=options.world.nodes[chapterId..':'..goalId]
 if node then return interact(player,node) end
end
function Service.interactStep(player,chapterId,goalId,stepId,choice)
 return activities.interactStep(player,chapterId,goalId,stepId,choice)
end
function Service.stepActivities(dt) activities.update(dt) end
function Service.defeated(model,_winner)
 local key=model:GetAttribute('DeepwoodEncounter');local e=encounters[key]
 if not e or e.dead and e.dead[model] then return end
 local owned=false for _,m in ipairs(e.models) do if m==model then owned=true end end
 if not owned then return end
 e.dead=e.dead or {};e.dead[model]=true;e.remaining=e.remaining-1
 -- Per-attempt kill XP is a server reward, distinct from the quest's fixed XP.
 for p,heroId in pairs(e.participants) do
  local ctx=eligible(p,e.chapter,e.goal,100,e.position)
  if ctx and ctx.heroId==heroId then
   local level=model:GetAttribute('StoryLevel') or 1;local multiplier=model:GetAttribute('StoryBoss') and 5 or 1
   options.inventory.awardXP(p,heroId,(8+2*level)*multiplier,true,(3+math.floor(level/2))*(model:GetAttribute("StoryBoss") and 10 or 1))
   if e.remaining==0 and e.wave==e.waveCount then enqueue(p,heroId,e.chapter,e.goal) end
  end
 end
 if e.remaining==0 then
  if e.wave<e.waveCount then
   e.wave+=1;e.waveFirst=e.waveLast+1;e.waveLast=math.ceil(#e.pendingSpecs*e.wave/e.waveCount);spawnWave(e)
   for p in pairs(e.participants) do publish(p,'Reinforcements are approaching from the trees. Hold the supply road!') end
  else task.delay(3,function() destroyEncounter(e) end) end
 end
end
function Service.start(settings)
 options=settings;remote=Instance.new('RemoteEvent');remote.Name='DeepwoodState';remote.Parent=ReplicatedStorage.Remotes
 activities=require(script.Parent.DeepwoodActivities).create({active=active,context=context,state=state,world=options.world,enemies=options.enemies,enqueue=enqueue,publish=publish})
 access=require(script.Parent.DeepwoodRegionAccess).create({heroSession=options.heroSession,inventory=options.inventory,world=options.world,combat=options.combat,notice=function(p,required,name) publish(p,nil,string.format('Complete Story %d before entering %s.',required,name)) end})
 for _,node in pairs(options.world.activityNodes or {}) do if node.prompt then node.prompt.Triggered:Connect(function(p) Service.interactStep(p,node.chapter.id,node.goal.id,node.step.id) end) end end

 local request=Instance.new('RemoteEvent');request.Name='DeepwoodRequest';request.Parent=ReplicatedStorage.Remotes
 for _,node in pairs(options.world.nodes) do
  node.prompt.Triggered:Connect(function(player)
   local t=os.clock();if t-(lastRequest[player] or 0)<.4 then return end;lastRequest[player]=t
   interact(player,node)
  end)
 end
 request.OnServerEvent:Connect(function(player,action,argument,...)
  if select('#',...)~=0 or type(action)~='string' or argument~=nil and type(argument)~='string' then return end
  local t=os.clock();local gap=(action=='AcceptQuest' or action=='LaterQuest') and .05 or .4;if t-(lastRequest[player] or 0)<gap then return end;lastRequest[player]=t
  if action=='AcceptQuest' and argument and #argument<=16 then Service.acceptQuest(player,argument)
  elseif action=='LaterQuest' and offers[player] and offers[player].node.chapter.id==argument then offers[player]=nil;publish(player)
  elseif action=='Answer' and argument and #argument<=160 then activities.answer(player,argument)
  elseif action=='GetState' and argument==nil then publish(player)
  elseif action=='Retry' and argument==nil then
   local ctx=context(player);if ctx then options.heroSession.restartAdventure(player) end
  elseif action=='Choose' and (argument=='sanctuary' or argument=='shared') then
   local node=options.world.nodes['DW-07:restoration']
   local ctx=eligible(player,node.chapter,node.goal,16,node.part.Position)
   if ctx then enqueue(player,ctx.heroId,node.chapter,node.goal,argument) end
  end
 end)
 options.combat.setStoryDefeatHandler(Service.defeated,Service.bossDamage)
 Players.PlayerRemoving:Connect(function(p) activities.remove(p);access.remove(p);offers[p]=nil;queues[p]=nil;lastRequest[p]=nil;for _,e in pairs(encounters) do e.participants[p]=nil end end)
 local activityElapsed=0
 RunService.Heartbeat:Connect(function(dt)
  activityElapsed+=dt;if activityElapsed<.2 then return end
  local tick=activityElapsed;activityElapsed=0
  for _,p in ipairs(Players:GetPlayers()) do
   access.update(p)
   local hero=active(p);local ctx,root=context(p)
   if hero and not hero.training and ctx and root then
    local s=state(p,ctx.heroId)
    if s then for _,c in ipairs(Content.chapters) do if not c.side then for _,g in ipairs(c.goals) do
     if g.activity and g.activity.mode=='battle' and Progress.available(s,c,g) and not encounters[c.id..':'..g.id] then
      local node=options.world.nodes[c.id..':'..g.id]
      if (root.Position-node.part.Position).Magnitude<32 then begin(p,node,true) end
     end
    end end end end
   end
  end
  activities.update(tick)
 end)
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;if elapsed<2 then return end;elapsed=0
  for _,p in ipairs(Players:GetPlayers()) do publish(p) end
  for _,e in pairs(encounters) do
   local present=false
   for p,heroId in pairs(e.participants) do local ctx,root=context(p);if ctx and ctx.heroId==heroId and root and (root.Position-e.position).Magnitude<110 then present=true end end
   if present then e.lastPresent=os.clock() end
   if e.phase3 and os.clock()>=(e.nextHazard or math.huge) then e.nextHazard=os.clock()+6;floorHazard(e) end
   if os.clock()-e.lastPresent>8 then destroyEncounter(e) end
  end
 end)
end
return Service
