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
 local character=Instance.new('Model');character.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local human=Instance.new('Humanoid');human.Parent=character;human.MaxHealth=1000;human.Health=1000
 local player={Parent=Players,Character=character,GetAttribute=function() return 'Tutorial' end}
 local valid=true;local xp=0
 local hero={getActiveHero=function() return {heroId='qa'} end,getCombatContext=function() return valid and {heroId='qa'} end,restartAdventure=function() return true end}
 local inventory={storyState=function() return P.copy(profile.heroes.qa.deepwood or P.new()) end,
  storyEvent=function(_,id,c,g,choice) local n,e=Rules.story(profile,id,c,g,choice,Catalog);if n then profile=n end;return e end,
  awardXP=function(_,_,amount) xp=xp+amount end}
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession=hero,combat={addStoryEnemy=function() end,setStoryDefeatHandler=function() end}})
 local function near(c,g) root.Position=world.nodes[c..':'..g].part.Position end
 local function models(key) local r={} for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren()) do if m:GetAttribute('DeepwoodEncounter')==key then table.insert(r,m) end end return r end
 root.Position=Vector3.new(2000,100,2000);story.interact(player,'DW-01','trail_guards');check(#models('DW-01:trail_guards')==0,'remote prompt distance cannot start fight')
 near('DW-01','trail_guards');valid=false;story.interact(player,'DW-01','trail_guards');check(#models('DW-01:trail_guards')==0,'inactive hero cannot start fight');valid=true
 story.interact(player,'DW-01','tracks');check(not inventory.storyState().flags['DW-01:tracks'],'future investigation cannot skip combat')
 near('DW-01','trail_guards');story.interact(player,'DW-01','trail_guards');check(#models('DW-01:trail_guards')==2,'two actual TD goblin rigs')
 for _,m in ipairs(models('DW-01:trail_guards')) do story.defeated(m);story.defeated(m) end;task.wait(.2)
 check(inventory.storyState().flags['DW-01:trail_guards'],'encounter event saves');check(xp==36,'duplicate death does not award XP twice')
 -- Native service walk through every non-combat objective and spawn/defeat group.
 for _,c in ipairs(C.chapters) do if not c.side then for _,g in ipairs(c.goals) do
  if not g.optional and not inventory.storyState().flags[c.id..':'..g.id] then
   near(c.id,g.id)
   if g.choice then check(story.destination(player,'qa')==world.spawns['DW-03'],'core aftercare resumes at outpost');inventory.storyEvent(nil,'qa',c.id,g.id,'shared')
   else
    story.interact(player,c.id,g.id)
    if #g.enemies>0 then
     local key=c.id..':'..g.id;local boss
     for _,m in ipairs(models(key)) do if m:GetAttribute('StoryBoss') then boss=m end end
     if boss and g.id=='king_shaman' then
      local h=boss:FindFirstChildOfClass('Humanoid');h.MaxHealth=boss:GetAttribute('StoryHealth');h.Health=h.MaxHealth
      local cap=story.bossDamage(boss,h.MaxHealth);check(cap==h.MaxHealth*.3,'boss cannot skip shield phase');h.Health=h.Health-cap
      check(story.bossDamage(boss,99999)==0,'shield denies damage')
      check(not story.breakPillar(player,key,1),'pillar distance independently checked')
      for i=1,2 do root.Position=world.folder:FindFirstChild('TemporarySealPillar').Position;check(story.breakPillar(player,key,i),'sequential pillar interaction') end
      check(story.bossDamage(boss,h.MaxHealth)==h.MaxHealth*.35,'boss cannot skip final phase')
     end
     for _,m in ipairs(models(key)) do story.defeated(m) end
    end
   end
   task.wait(.1)
   check(inventory.storyState().flags[c.id..':'..g.id],c.id..g.id..' service objective saved')
  end
 end end end
 local s=inventory.storyState();check(s.main==7 and s.choice=='shared','native server full main chain')
 check(s.coins==2290,'first-clear Coins exact');check(profile.items['qa-DW-07-bossseal'].quantity==1,'seal once')
 character:Destroy();copy:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('DEEPWOOD_SERVICE_NATIVE '..game:GetService('HttpService'):JSONEncode(report));assert(report.pass,'Deepwood service fixture failed')
