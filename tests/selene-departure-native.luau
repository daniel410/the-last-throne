-- Real service/model/motion/transactions, synthetic players and in-memory accounts.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local RS=game.ReplicatedStorage;local Server=game.ServerScriptService.Server
local R=require(Server.Inventory.InventoryRules);local C=require(RS.Shared.ItemCatalog)
local Content=require(RS.Shared.CampaignContent);local Pass=require(RS.Shared.SupportPassRules)
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='SeleneDepartureQA';fixture.Parent=workspace
local remotes=RS:FindFirstChild('Remotes');local ownRemotes=not remotes
if not remotes then remotes=Instance.new('Folder');remotes.Name='Remotes';remotes.Parent=RS end
local lobby,battle,presentation;local players={}
local ok,err=xpcall(function()
 local center=Vector3.new(20000,1000,20000)
 local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(300,2,300);floor.Position=center-Vector3.new(0,1,0);floor.Parent=fixture
 local lobbyFolder=Instance.new('Folder');lobbyFolder.Name='LobbyFollowers';lobbyFolder.Parent=fixture
 local battleFolder=Instance.new('Folder');battleFolder.Name='BattleFollowers';battleFolder.Parent=fixture
 local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=fixture
 local accounts,roots,phases,ready={},{},{},{}
 local hero={heroId='hero',training=false};local preparations=0
 local function finish(profile,id)
  for _,g in ipairs(Content.byId[id].goals)do if not g.optional then
   for _,s in ipairs(g.activity and g.activity.steps or {false})do
    profile=assert(R.story(profile,'hero',id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared' or nil,C,s and s.id or nil))
   end
  end end
  return profile
 end
 for i=1,4 do
  local char=Instance.new('Model');char:SetAttribute('K0SpawnReady',true);char.Parent=fixture
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.Position=center+Vector3.new(i*5,3,0);root.Parent=char;char.PrimaryPart=root
  local human=Instance.new('Humanoid');human.MaxHealth=100;human.Health=100;human.Parent=char
  local player={UserId=i,Character=char};player.GetAttribute=function(_,key)if key=='K0SessionPhase'then return phases[player]end end
  players[i]=player;roots[player]=root;phases[player]='Lobby';ready[player]=true
  local p=assert(R.addHero(R.new(i),'hero','knight',C))
  for j=1,3 do p=finish(p,'DW-0'..j)end
  p.supportPasses={version=1,credits=2,active={},trials={hero=true}}
  -- Existing credits start unprepared, except the first player buying now.
  if i==1 then
   p.wallet.gold=1000
   p=assert(R.supportPass(p,{action='Buy',heroId='hero',offerId='selene_story_1',revision=p.revision,requestId='native_buy'},{atLobby=true},C))
  end
  accounts[player]=p
 end
 lobby=require(Server.Lobby.SeleneDeparture).create({folder=lobbyFolder,players=function()return players end,
  heroSession={getActiveHero=function()return hero end},inventory={
   available=function(p)return ready[p]end,
   supportState=function(p)return Pass.view(accounts[p],'hero')end,
   prepareSupport=function(p,id)
    preparations+=1
    accounts[p]=assert(R.supportPass(accounts[p],{action='Prepare',heroId=id,requestId='native_prepare_'..preparations},{atLobby=phases[p]=='Lobby'},C))
   end}})
 lobby.update(.1);task.wait();lobby.update(.1)
 check(#lobbyFolder:GetChildren()==4,'each player gets one cosmetic lobby follower; combat party cap is not lobby population')
 check(preparations==3,'old credits prepare automatically; new purchase is already prepared')
 local first=players[1];local actor=lobbyFolder:FindFirstChild('LobbySelene_1')
 check(actor and actor:GetAttribute('TDSourceModel')=='nun' and actor:GetAttribute('OwnerUserId')==1,'approved real Selene model follows its owner')
 check(game.CollectionService:HasTag(actor,'TLTStoryNPC') and actor:GetAttribute('SeleneSkinned'),'existing client skin animation discovers lobby follower')
 check(Pass.view(accounts[first],'hero').credits==3 and not Pass.view(accounts[first],'hero').active,'lobby following consumes no support credits')
 local initial=actor.PrimaryPart.Position;roots[first].Position+=Vector3.new(25,0,0);task.wait()
 for _=1,60 do lobby.update(1/60)end
 check((actor.PrimaryPart.Position-initial).Magnitude>1,'real grounded follow motion advances toward moving owner')
 local before=accounts[first].revision
 for _=1,20 do lobby.update(.1)end
 check(preparations==3 and accounts[first].revision==before,'lobby frames cannot repeat preparation writes')
 ready[first]=false;lobby.update(.1)
 check(not lobbyFolder:FindFirstChild('LobbySelene_1'),'uncertain account cannot project an owned follower')
 ready[first]=true;lobby.update(.1);check(lobbyFolder:FindFirstChild('LobbySelene_1'),'confirmed load restores follower')
 first.Character:FindFirstChildOfClass('Humanoid').Health=0;lobby.update(.1)
 check(not lobbyFolder:FindFirstChild('LobbySelene_1'),'dead owner removes lobby follower')
 first.Character:FindFirstChildOfClass('Humanoid').Health=100;lobby.update(.1)
 check(lobbyFolder:FindFirstChild('LobbySelene_1'),'respawn restores prepared lobby follower without spending')
 for _,p in ipairs(players)do phases[p]='Tutorial'end
 lobby.update(.1);check(#lobbyFolder:GetChildren()==0,'departure removes all lobby actors')
 local prepared=R.copy(accounts[first])
 local activations=0;local population=players;local tick=0
 battle=require(Server.Story.SeleneCompanion).create({frameDriven=true,players=function()return population end,
  clock=function()tick+=1;return tick end,
  world={folder=battleFolder,seleneCamp=center+Vector3.new(1000,0,0)},enemies=enemies,
  active=function()return hero end,context=function(p)return hero,roots[p]end,
  state=function(p)return accounts[p].heroes.hero.deepwood end,passState=function(p)return Pass.view(accounts[p],'hero')end,
  publish=function()end,notice=function()end,combat={},
  activate=function(p)
   activations+=1;local v=Pass.view(accounts[p],'hero')
   local nextProfile,why=R.supportPass(accounts[p],{action='Activate',heroId='hero',story=v.story,scope=v.scope,requestId='native_entry_'..activations},{inAdventure=true,hasCampAccess=battle.atCamp(p,'hero')},C)
   if nextProfile then accounts[p]=nextProfile end;return why
  end,select=function(p,_,following)accounts[p]=assert(R.selectSelene(accounts[p],'hero',following))end})
 battle.update(.2)
 check(activations==1 and battleFolder:FindFirstChild('Selene_1'),'entry starts one supporter far from every camp')
 local follower=battleFolder:FindFirstChild('Selene_1')
 check(not follower:FindFirstChildWhichIsA('ProximityPrompt',true),'moving supporter cannot capture combat clicks, touch or interaction keys')
 local campPrompts=0
 for _,object in ipairs(battleFolder:GetDescendants())do
  if object:IsA('ProximityPrompt') then campPrompts+=1;check(not object:IsDescendantOf(follower),'interaction belongs to stationary camp only')end
 end
 check(campPrompts==3,'camp retains invite, rest and supporter details')
 check(Pass.view(accounts[first],'hero').credits==2 and Pass.view(accounts[first],'hero').active and not Pass.view(accounts[first],'hero').departure,'successful admission spends one credit and clears departure intent')
 for i=2,4 do check(Pass.view(accounts[players[i]],'hero').credits==2 and Pass.view(accounts[players[i]],'hero').departure,'occupied party slot preserves waiting player '..i..' credit and intent')end
 battle.update(.2);check(activations==1,'repeated update cannot spend another credit')
 population={first}
 local camp=battleFolder.NPCActors.Selene
 local campPosition=camp.PrimaryPart.Position
 roots[first].Position=campPosition+Vector3.new(0,3,2)
 follower:PivotTo(CFrame.new(campPosition+Vector3.new(0,0,8)))
 presentation=require(game.StarterPlayer.StarterPlayerScripts.Client.NPCPresentation).create(first,battleFolder,function()
  return {journal=accounts[first].heroes.hero.deepwood,supporter={pass=Pass.view(accounts[first],'hero')}}
 end)
 presentation.update()
 local invite=camp.PrimaryPart.Invite.Invite
 local rest=camp.PrimaryPart.Rest.Rest
 local details=camp.PrimaryPart.SupporterDetails.SupporterDetails
 check(battle.atCamp(first,'hero') and rest.Enabled and details.Enabled and not invite.Enabled,'following owner can rest and inspect at camp')
 check(camp.PrimaryPart.LocalTransparencyModifier==0 and follower.PrimaryPart.LocalTransparencyModifier==1,'camp interaction has one visible Selene')
 check(battle.select(first,false),'camp rest reaches the server selection path')
 battle.update(.2);presentation.update()
 check(not battleFolder:FindFirstChild('Selene_1') and invite.Enabled and not rest.Enabled and details.Enabled,'rest removes follower and exposes invitation')
 check(Pass.view(accounts[first],'hero').active and Pass.view(accounts[first],'hero').credits==2,'rest retains entitlement and credits')
 check(battle.select(first,true),'camp reinvitation succeeds')
 battle.update(.2);presentation.update()
 follower=battleFolder:FindFirstChild('Selene_1')
 check(follower and rest.Enabled and details.Enabled and Pass.view(accounts[first],'hero').credits==2,'reinvitation resumes without another credit')
 roots[first].Position=campPosition+Vector3.new(30,3,0)
 follower:PivotTo(CFrame.new(campPosition+Vector3.new(22,0,0)))
 presentation.update()
 check(not rest.Enabled and not details.Enabled and follower.PrimaryPart.LocalTransparencyModifier==0,'leaving camp restores moving companion presentation')
 presentation.destroy();presentation=nil
 local callsBeforeCompletion=activations
 population={first};accounts[first]=finish(accounts[first],'DW-04');battle.update(.2)
 check(not battleFolder:FindFirstChild('Selene_1') and activations==callsBeforeCompletion and Pass.view(accounts[first],'hero').credits==2,'main-story completion ends support without automatic renewal')
 local side=R.copy(prepared)
 side.supportPasses.trials=nil
 side=assert(require(RS.Shared.AdventureRules).begin(side,'hero','DW-Q1','Easy','side_native',side.revision,R,C))
 accounts[first]=side
 roots[first].Position=campPosition+Vector3.new(0,3,2)
 local callsBeforeSide=activations
 for _=1,3 do battle.update(.2)end
 check(Pass.view(accounts[first],'hero').side and Pass.view(accounts[first],'hero').trialAvailable,'fixture reaches side camp with unused trial')
 check(activations==callsBeforeSide and not battleFolder:FindFirstChild('Selene_1'),'side camp never schedules automatic trial activation')
 check(not battle.select(first,true),'manual side camp invitation is rejected by account transaction')
 check(accounts[first].revision==side.revision and Pass.view(accounts[first],'hero').trialAvailable
  and Pass.view(accounts[first],'hero').credits==3 and Pass.view(accounts[first],'hero').departure,'side camp preserves trial, credits and prepared departure')
 lobby.remove(first);check(not lobbyFolder:FindFirstChild('LobbySelene_1'),'explicit cleanup is safe after departure')
end,debug.traceback)
if presentation then presentation.destroy()end
if battle then for _,p in ipairs(players)do battle.remove(p)end end
if lobby then for _,p in ipairs(players)do lobby.remove(p)end end
fixture:Destroy();if ownRemotes then remotes:Destroy()end
assert(ok,err)
print('SELENE_DEPARTURE_NATIVE '..game.HttpService:JSONEncode({checks=checks,pass=true}))
