-- Isolated local Studio only; actual TD models, synthetic objective markers/player/account storage.
return function(sources)
 assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
 local RS=game:GetService('ReplicatedStorage');local SSS=game:GetService('ServerScriptService')
 local report={kind='BOSS_FINAL_ESCORT_NATIVE',checks=0,quests={},pass=false}
 local function check(v,m)report.checks+=1;assert(v,m)end
 local function fresh(path,original,overrides)
  local fn=assert(loadstring(sources[path],path));setfenv(fn,setmetatable({script=original,require=function(m)return overrides and overrides[m.Name] or require(m)end},{__index=getfenv()}));return fn()
 end
 local character,world
 local ok,err=xpcall(function()
  local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress);local R=require(SSS.Server.Inventory.InventoryRules)
  local Catalog=require(RS.Shared.ItemCatalog);local A=require(RS.Shared.AdventureRules);local G=require(RS.Shared.HeroProgression)
  local profile=assert(R.addHero(R.new(938),'hero','elf',Catalog));profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
  for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do if not g.optional then
   for _,s in ipairs(g.activity and g.activity.steps or {false})do profile=assert(R.story(profile,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',Catalog,s and s.id or nil))end
  end end end
  world={folder=Instance.new('Folder'),nodes={},spawns={}};world.folder.Name='BossEscortQA';world.folder.Parent=workspace
  local enemies=Instance.new('Folder');enemies.Name='BossEscortEnemies';enemies.Parent=world.folder
  character=Instance.new('Model');character.Parent=workspace
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
  local h=Instance.new('Humanoid');h.Parent=character
  local player={UserId=938,Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
  local source=sources['src/server/Story/DeepwoodService.luau']
  local a=assert(source:find('local function publish',1,true));local b=assert(source:find('function Service.destination',a,true))
  source=source:sub(1,a-1)..'local function publish()end\n'..source:sub(b)
  source=source:gsub('Players:GetPlayers%(%)','(fixturePlayers)')
  local first=assert(source:find(' local activityElapsed=0',1,true));local last=assert(source:find(' local elapsed=0',first,true))
  local scan=source:sub(first,last-1):gsub('RunService.Heartbeat:Connect%(', 'qaConnect(')
  source=source:gsub('return Service\n',[[function Service.qa(settings)
 options=settings
 companion={stepMotion=function()end,update=function()end};access={update=function()end}
 activities={interact=function()return false end,update=function()end}
 local qaConnect=function(f)Service.scan=f end
 ]]..scan..'\nend\nreturn Service\n')
  local Balance=fresh('src/shared/DeepwoodEncounterBalance.luau',RS.Shared.DeepwoodEncounterBalance)
  local base=R.copy(profile)
  local fn=assert(loadstring(source,'BossEscortServiceQA'))
  setfenv(fn,setmetatable({script=SSS.Server.Story.DeepwoodService,fixturePlayers={player},require=function(m)if m.Name=='DeepwoodEncounterBalance'then return Balance end;return require(m)end},{__index=getfenv()}));local service=fn()
  local awards=0
  local inventory={storyState=function()return A.projection(profile.heroes.hero)end,growth=function()return {level=80}end,
   expedition=function()return profile.heroes.hero.expeditions and profile.heroes.hero.expeditions.active end,
   storyEvent=function(_,id,c,g,choice,step,run)
    local p,why=A.event(profile,id,c,g,choice,step,R,Catalog,run);if p then profile=p end;return why
   end,awardXP=function()awards+=1 end}
  service.qa({world=world,enemies=enemies,inventory=inventory,
   heroSession={getActiveHero=function()return {heroId='hero'}end,getCombatContext=function()return {heroId='hero'}end},
   combat={addStoryEnemy=function(m)local h=m:FindFirstChildOfClass('Humanoid');h.MaxHealth=m:GetAttribute('StoryHealth');h.Health=h.MaxHealth end}})
  for _,c in ipairs(C.chapters)do for _,goal in ipairs(c.goals)do
   local plan=Balance.encounterWaves(c,goal,1);local hasBoss=false
   for _,wave in ipairs(plan)do for _,spec in ipairs(wave)do if Balance.isBoss(spec.kind)then hasBoss=true end end end
   if hasBoss then
    profile=R.copy(base);local run='native_'..c.id..'_'..goal.id
    profile=assert(A.begin(profile,'hero',c.id,'Easy',run,profile.revision,R,Catalog))
    for _,g in ipairs(c.goals)do
     if g==goal then break end
     if not g.optional then for _,s in ipairs(g.activity and g.activity.steps or {false})do
      profile=assert(A.event(profile,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',s and s.id or nil,R,Catalog,run))
     end end
    end
    local marker=Instance.new('Part');marker.Anchored=true;marker.Position=Vector3.new(0,4,0);marker.Parent=world.folder
    world.nodes[c.id..':'..goal.id]={chapter=c,goal=goal,part=marker}
    root.Position=marker.Position;service.scan(.2)
    local key=c.id..':'..goal.id..':'..run;local spawned=0;local bossSeen=0
    check(service.encounterState(player,'hero')[c.id..':'..goal.id]~=nil,'actual boss encounter starts')
    for wave=1,#plan do
     local alive={};local boss
     for _,m in ipairs(enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key and m:FindFirstChildOfClass('Humanoid').Health>0 then
      if m:GetAttribute('StoryBoss')then boss=m else table.insert(alive,m)end
     end end
     check(#alive+(boss and 1 or 0)==#plan[wave],'actual wave population matches finite plan')
     if boss then
      bossSeen+=1;check(wave==#plan and #alive>0,'boss spawns with guards in final wave')
      boss:FindFirstChildOfClass('Humanoid').Health=0
      local before=awards;service.defeated(boss);service.defeated(boss);check(awards==before+1,'boss reward callback once')
      task.wait();check(not inventory.storyState().flags[c.id..':'..goal.id],'boss death cannot skip surviving guards')
      spawned+=1
     end
     for _,m in ipairs(alive)do
      spawned+=1;m:FindFirstChildOfClass('Humanoid').Health=0
      local before=awards;service.defeated(m);service.defeated(m);check(awards==before+1,'guard reward callback once')
     end
     task.wait()
    end
    local deadline=os.clock()+3
    repeat task.wait()until inventory.storyState().flags[c.id..':'..goal.id]or os.clock()>deadline
    check(inventory.storyState().flags[c.id..':'..goal.id],'goal confirms after final surviving guard')
    check(bossSeen==1,'one boss only; no post-boss waves')
    table.insert(report.quests,{id=c.id..':'..goal.id,waves=#plan,spawned=spawned,finalSize=#plan[#plan]})
    marker:Destroy()
   end
  end end
  report.pass=true
 end,debug.traceback)
 if character then character:Destroy()end;if world then world.folder:Destroy()end
 if not ok then report.error=tostring(err)end
 return report
end
