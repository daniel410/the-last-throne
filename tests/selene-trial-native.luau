-- Real companion service, TD actor, pass rules and journal. In-memory accounts
-- and player identities isolate this from DataStore and live sessions.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local fixture')
local Shared=game.ReplicatedStorage.Shared;local Server=game.ServerScriptService.Server
local R=require(Server.Inventory.InventoryRules);local Items=require(Shared.ItemCatalog)
local Content=require(Shared.DeepwoodContent);local Pass=require(Shared.SupportPassRules);local Text=require(Shared.SupporterText)
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='SeleneTrialQA';folder.Parent=workspace
local remotes=game.ReplicatedStorage:FindFirstChild('Remotes');local ownRemotes=not remotes
if ownRemotes then remotes=Instance.new('Folder');remotes.Name='Remotes';remotes.Parent=game.ReplicatedStorage end
local companion
local ok,err=xpcall(function()
 local center=Vector3.new(20000,1000,20000)
 local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(200,2,200);floor.Position=center-Vector3.new(0,1,0);floor.Parent=folder
 local enemies=Instance.new('Folder');enemies.Parent=folder
 local hero={heroId='hero',training=false};local players,accounts,roots={},{},{}
 local function finish(profile,id)
  local chapter=Content.byId[id]
  for _,g in ipairs(chapter.goals)do if not g.optional then
   for _,step in ipairs(g.activity and g.activity.steps or {false})do
    profile=assert(R.story(profile,'hero',id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared' or nil,Items,step and step.id or nil))
   end
  end end
  return profile
 end
 for i=1,2 do
  local char=Instance.new('Model');char.Parent=folder
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Size=Vector3.new(2,2,1);root.Position=center+Vector3.new(i*2,3,0);root.Parent=char;char.PrimaryPart=root
  local human=Instance.new('Humanoid');human.MaxHealth=100;human.Health=40;human.Parent=char
  local p={UserId=i,Character=char};players[i]=p;roots[p]=root
  local profile=assert(R.addHero(R.new(i),'hero','knight',Items))
  for j=1,3 do profile=finish(profile,'DW-0'..j)end
  accounts[p]=profile
 end
 local notices={};local activations=0;local tick=0;local population=players
 companion=require(Server.Story.SeleneCompanion).create({frameDriven=true,world={folder=folder,seleneCamp=center},enemies=enemies,
  clock=function()tick+=1;return tick end,players=function()return population end,
  active=function()return hero end,context=function(p)return p.Character and hero,roots[p]end,state=function(p)return accounts[p].heroes.hero.deepwood end,
  passState=function(p)return Pass.view(accounts[p],'hero')end,publish=function()end,notice=function(p,message)table.insert(notices,{player=p,message=message})end,
  activate=function(p)
   activations+=1;local v=Pass.view(accounts[p],'hero')
   local nextProfile,reason=R.supportPass(accounts[p],{action='Activate',heroId='hero',story=v.story,scope=v.scope,requestId='native_trial_'..activations},{inAdventure=true,hasCampAccess=true,maxStories=35},Items)
   if nextProfile then accounts[p]=nextProfile end;return reason
  end,
  select=function(p,_,following)accounts[p]=assert(R.selectSelene(accounts[p],'hero',following))end,
  combat={applySeleneSupport=function(p)local h=p.Character:FindFirstChildOfClass('Humanoid');h.Health+=12;return 'Heal'end}})
 local first,second=players[1],players[2]
 local gold=accounts[first].wallet.gold
 companion.update(.2)
 check(activations==1 and folder:FindFirstChild('Selene_1') and not folder:FindFirstChild('Selene_2'),'one free supporter automatically joins after rescue')
 check(Pass.view(accounts[first],'hero').trial and accounts[first].wallet.gold==gold,'automatic trial consumes no Gold')
 check(Pass.view(accounts[second],'hero').trialAvailable,'full party slot preserves second hero trial')
 check(first.Character:FindFirstChildOfClass('Humanoid').Health==52,'spawned trial supporter enters support loop')
 check(notices[1] and notices[1].message==Text.trialStarted,'introduction explains abilities and later lobby visit')
 check(companion.details(first).key=='TrialFollowing','details label free support')
 companion.update(.2);check(activations==1,'subsequent updates cannot activate twice')
 companion.select(first,false);companion.update(.2)
 check(not folder:FindFirstChild('Selene_1') and Pass.view(accounts[first],'hero').active,'rest removes actor but preserves trial')
 -- Keep the resting owner's slot free from other new introductions for this check.
 population={first};companion.select(first,true);companion.update(.2)
 check(folder:FindFirstChild('Selene_1') and accounts[first].supportPasses.trials.hero,'same-story resume preserves used marker')
 local char=first.Character;first.Character=nil;companion.update(.2)
 check(not folder:FindFirstChild('Selene_1') and Pass.view(accounts[first],'hero').active,'death pause retains entitlement')
 first.Character=char;companion.update(.2);check(folder:FindFirstChild('Selene_1'),'rejoin recreates current trial follower')
 accounts[first]=finish(accounts[first],'DW-04');companion.update(.2)
 check(not folder:FindFirstChild('Selene_1') and not Pass.view(accounts[first],'hero').trialAvailable,'completed trial cannot renew itself')
 check(notices[#notices].message==Text.trialEnded,'end notice directs player to lobby Selene')
 companion.update(.2);check(not folder:FindFirstChild('Selene_1'),'next story remains unsupported until paid invitation')
end,debug.traceback)
if companion then companion.remove({})end
folder:Destroy();if ownRemotes then remotes:Destroy()end;assert(ok,err)
print('SELENE_TRIAL_NATIVE '..game.HttpService:JSONEncode({checks=checks,pass=true}))
