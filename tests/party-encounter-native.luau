-- Run in Studio Edit with changed module sources passed by the local test driver.
return function(sources)
 local RS=game:GetService('ReplicatedStorage');local SSS=game:GetService('ServerScriptService')
 local P=require(RS.Shared.DeepwoodProgress);local C=require(RS.Shared.CampaignContent)
 local checks=0;local function check(v,m) checks+=1;assert(v,m) end
 local folder=Instance.new('Folder');folder.Name='PartyEncounterQA';folder.Parent=game:GetService('ServerStorage')
 local function module(path,original,overrides)
  local fn=assert(loadstring(sources[path],path))
  local env=setmetatable({script=original,require=function(m)return overrides and overrides[m.Name] or require(m)end},{__index=getfenv()})
  setfenv(fn,env);return fn()
 end
 local ok,result=xpcall(function()
  local difficulty=module('src/shared/Difficulty.luau',RS.Shared.Difficulty)
  local balance=module('src/shared/DeepwoodEncounterBalance.luau',RS.Shared.DeepwoodEncounterBalance,{Difficulty=difficulty})
  local party=module('src/server/Story/PartyStory.luau',SSS.Server.Story.DeepwoodService)
  local players,journals,awards={},{},{}
  local c=C.byId['DW-05'];local g=P.goal(c,'warlord');local key='DW-05:warlord:qa-party'
  for i=1,5 do
   local character=Instance.new('Model');character.Parent=folder
   local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(i==2 and 500 or 0,0,0);root.Parent=character
   local h=Instance.new('Humanoid');h.Parent=character;if i==3 then h.Health=0 end
   players[i]={UserId=i,Parent=game:GetService('Players'),Character=character,GetAttribute=function()return 'Adventure'end}
   journals[players[i]]={main=4,flags={},clears={}}
   for _,required in ipairs(g.requires)do journals[players[i]].flags[c.id..':'..required]=true end
  end
  local source=sources['src/server/Story/DeepwoodService.luau']
  local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true))
  source=source:sub(1,first-1)..'local function publish() end\n'..source:sub(last)
  -- Inject fixture-only startup, retaining production begin/spawn/death/queue logic.
  source=source:gsub('Players:GetPlayers%(%)','fixturePlayers')
  source=source:gsub('return Service\n','function Service.qa(settings) options=settings end\nreturn Service\n')
  local fn=assert(loadstring(source,'DeepwoodServiceQA'))
  local rig={makeEnemy=function(parent,kind,x,z)
   local m=Instance.new('Model');m.Name=kind
   local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Position=Vector3.new(x,0,z);r.Anchored=true;r.Parent=m;m.PrimaryPart=r
   local h=Instance.new('Humanoid');h.Parent=m;m:SetAttribute('EnemyKind',kind);m.Parent=parent;return m
  end}
  local dependencies={CampaignContent=C,DeepwoodProgress=P,DeepwoodEncounterBalance=balance,Difficulty=difficulty,TrainingField=rig,StoryMonsterSizing={forStory=function()return 1 end},PartyStory=party}
  -- The new sibling module is absent in older open Studio sources.
  local sibling=Instance.new('ModuleScript');sibling.Name='PartyStory';sibling.Parent=folder
  source=source:gsub('script.Parent.PartyStory','partyModule')
  fn=assert(loadstring(source,'DeepwoodServiceQA'))
  setfenv(fn,setmetatable({script=SSS.Server.Story.DeepwoodService,fixturePlayers=players,partyModule=sibling,require=function(m)return dependencies[m.Name]or require(m)end},{__index=getfenv()}))
  local service=fn();local enemies=Instance.new('Folder');enemies.Parent=folder
  local marker=Instance.new('Part');marker.Parent=folder
  local inventory={storyState=function(p)return journals[p]end,expedition=function(p)return {runId=p==players[5]and 'other'or 'qa-party',difficultyId='Easy',balanceVersion=2}end,
   storyEvent=function(p,_,cid,gid)journals[p].flags[cid..':'..gid]=true end,
   awardXP=function(p)awards[p]=(awards[p]or 0)+1 end}
  service.qa({world={nodes={['DW-05:warlord']={chapter=c,goal=g,part=marker}},folder=folder},enemies=enemies,inventory=inventory,
   heroSession={getActiveHero=function(p)return {heroId=tostring(p.UserId)}end,getCombatContext=function(p)return {heroId=tostring(p.UserId)}end},
   combat={addStoryEnemy=function(m)local h=m:FindFirstChildOfClass('Humanoid');h.MaxHealth=m:GetAttribute('StoryHealth');h.Health=h.MaxHealth end}})
  service.interact(players[1],c.id,g.id)
  local sawBoss=false;local total=0
  for wave=1,100 do
   local alive={};for _,m in ipairs(enemies:GetChildren())do if m:FindFirstChildOfClass('Humanoid').Health>0 then table.insert(alive,m)end end
   if #alive==0 then break end
   local projection=service.encounterState(players[1],'1')['DW-05:warlord']
   check(#alive<=9,'four-player concurrent cap')
   for _,m in ipairs(alive)do
    if m:GetAttribute('StoryBoss')then
     check(not sawBoss and #alive==1 and projection.wave==projection.waves,'boss is the unique final spawn');sawBoss=true
    else check(not sawBoss,'no guard ever spawns after boss')end
    total+=1;m:FindFirstChildOfClass('Humanoid').Health=0;service.defeated(m);service.defeated(m)
   end
  end
  task.wait(.1)
  check(sawBoss and total==73,'four-player Warlord encounter has 72 guards then one boss')
  for i=1,4 do check(journals[players[i]].flags['DW-05:warlord'],'all members complete, including distant and downed allies');check(awards[players[i]]==73,'duplicate deaths cannot pay twice')end
  check(not journals[players[5]].flags['DW-05:warlord']and not awards[players[5]],'other expedition stays isolated')
  return 'Party encounter native: '..checks..' checks passed'
 end,debug.traceback)
 folder:Destroy();assert(ok,result);return result
end
