-- Isolated local Studio only; actual world nodes/TD models, fixture player/account storage.
return function(sources)
 assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
 local RS=game:GetService('ReplicatedStorage');local SSS=game:GetService('ServerScriptService')
 local report={kind='SIDE_QUEST_REVIEW_NATIVE',checks=0,quests={},pass=false}
 local function check(v,m)report.checks+=1;assert(v,m)end
 local function fresh(path,original,overrides)
  local fn=assert(loadstring(sources[path],path));setfenv(fn,setmetatable({script=original,require=function(m)return overrides and overrides[m.Name] or require(m)end},{__index=getfenv()}));return fn()
 end
 local character,world
 local ok,err=xpcall(function()
  local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress);local R=require(SSS.Server.Inventory.InventoryRules)
  local Catalog=require(RS.Shared.ItemCatalog);local A=require(RS.Shared.AdventureRules);local G=require(RS.Shared.HeroProgression)
  local Log=fresh('src/shared/DeepwoodQuestLog.luau',RS.Shared.DeepwoodQuestLog)
  local profile=assert(R.addHero(R.new(938),'hero','elf',Catalog));profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
  for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do if not g.optional then
   for _,s in ipairs(g.activity and g.activity.steps or {false})do profile=assert(R.story(profile,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',Catalog,s and s.id or nil))end
  end end end
  local gui=Instance.new('ScreenGui');gui.Name='SideQuestBookQA';gui.Parent=game.CoreGui
  local bookModule=fresh('src/client/DeepwoodQuestBook.luau',game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodQuestBook,{DeepwoodQuestLog=Log})
  local book=bookModule.create(gui,function()end);book.setTab('Side');book.render({journal=profile.heroes.hero.deepwood})
  local clues,npcs=0,0
  for _,card in ipairs(book.panel.Chapters:GetChildren())do if card:IsA('GuiObject')then
   local caption=card:FindFirstChild('Track') and card.Track.Caption.Text
   if caption=='FIND CLUE'then
    clues+=1;local location=false
    for _,text in ipairs(card:GetChildren())do if text:IsA('TextLabel')then
     check(not text.Text:find('Elder Tree Outpost',1,true),'regional clue has no false outpost instruction')
     if text.Text:find('Find the field clue in ',1,true)then location=true end
    end end
    check(location,'discovery card names its field location')
   elseif caption=='FIND QUEST GIVER'then npcs+=1 end
  end end
  check(clues==8 and npcs==3,'eight field discoveries and three NPC requests; hidden marsh discovery stays hidden')
  gui:Destroy()
  for epic=1,3 do world=require(SSS.Server.World.CampaignWorld).create(epic,world);task.wait()end
  local enemies=Instance.new('Folder');enemies.Name='SideQuestReviewEnemies';enemies.Parent=world.folder
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
  local fn=assert(loadstring(source,'SideQuestServiceQA'))
  setfenv(fn,setmetatable({script=SSS.Server.Story.DeepwoodService,fixturePlayers={player}},{__index=getfenv()}));local service=fn()
  local awards=0
  local inventory={storyState=function()return A.projection(profile.heroes.hero)end,growth=function()return {level=80}end,
   expedition=function()return profile.heroes.hero.expeditions and profile.heroes.hero.expeditions.active end,
   storyEvent=function(_,id,c,g,choice,step,run)
    local p,why=A.event(profile,id,c,g,choice,step,R,Catalog,run);if p then profile=p end;return why
   end,awardXP=function()awards+=1 end}
  service.qa({world=world,enemies=enemies,inventory=inventory,
   heroSession={getActiveHero=function()return {heroId='hero'}end,getCombatContext=function()return {heroId='hero'}end},
   combat={addStoryEnemy=function(m)local h=m:FindFirstChildOfClass('Humanoid');h.MaxHealth=m:GetAttribute('StoryHealth');h.Health=h.MaxHealth end}})
  for _,c in ipairs(C.chapters)do if c.side then
   local run='native_'..c.id;profile=assert(A.begin(profile,'hero',c.id,'Easy',run,profile.revision,R,Catalog))
   local spawned=0
   for _,g in ipairs(c.goals)do
    local node=assert(world.nodes[c.id..':'..g.id]);check(node.prompt and node.prompt.Parent==node.part,'real interaction node exists')
    root.Position=node.part.Position+Vector3.new(0,3,0)
    if #g.enemies>0 then
     if g.activity and g.activity.mode=='battle'then service.scan(.2)else service.interact(player,c.id,g.id)end
     local key=c.id..':'..g.id..':'..run
     check(service.encounterState(player,'hero')[c.id..':'..g.id]~=nil,'actual proximity/manual battle starts')
     for wave=1,100 do
      local alive={};for _,m in ipairs(enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key and m:FindFirstChildOfClass('Humanoid').Health>0 then table.insert(alive,m)end end
      if #alive==0 then break end
      for _,m in ipairs(alive)do
       check(m.PrimaryPart~=nil and m:GetAttribute('StoryHealth')>0,'TD model and combat stats exist')
       spawned+=1;m:FindFirstChildOfClass('Humanoid').Health=0
       local before=awards;service.defeated(m);check(awards==before+1,'defeat has one reward callback');service.defeated(m);check(awards==before+1,'duplicate defeat ignored')
      end
      task.wait()
     end
    else
     local actual=node
     if g.id==c.quest.turnIn and c.quest.offerPosition and not c.quest.discoveryOnly then actual=assert(world.nodes[c.id..':request'])end
     root.Position=actual.part.Position+Vector3.new(0,3,0);service.interact(player,c.id,actual.offer and 'request' or g.id)
    end
    local deadline=os.clock()+3
    repeat task.wait()until inventory.storyState().flags[c.id..':'..g.id]or os.clock()>deadline
    check(inventory.storyState().flags[c.id..':'..g.id],c.id..':'..g.id..' saved through service queue')
   end
   check(inventory.storyState().clears[c.id] and profile.heroes.hero.deepwood.main==35,'actual report completes side without changing main')
   check(Log.tracker(inventory.storyState()).title=='SIDE QUEST COMPLETE','postgame side tracker correct')
   table.insert(report.quests,{id=c.id,goals=#c.goals,spawned=spawned})
  end end
  report.pass=true
 end,debug.traceback)
 if character then character:Destroy()end;if world then world.folder:Destroy()end
 if not ok then report.error=tostring(err)end
 return report
end
