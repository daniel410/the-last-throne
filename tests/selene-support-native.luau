-- Real engine/model/service code; identity, account and clock fixtures only.
local RS=game:GetService('ReplicatedStorage');local SSS=game:GetService('ServerScriptService');local Players=game:GetService('Players')
local report={checks=0,failures={}};local function check(v,m) report.checks+=1;assert(v,m) end
local ok,err=xpcall(function()
 game:GetService('RunService'):Run();task.wait(3)
 local Rules=require(SSS.Server.Inventory.InventoryRules);local C=require(RS.Shared.ItemCatalog);local P=require(RS.Shared.DeepwoodProgress);local Content=require(RS.Shared.DeepwoodContent)
 local profile=Rules.addHero(Rules.new(91),'qa','knight',C);local s=P.new()
 for i=1,2 do local c=Content.chapters[i];s.main=i;s.clears[c.id]=true;s.coins+=c.reward.coins;for _,g in ipairs(c.goals) do if not g.optional then s.flags[c.id..':'..g.id]=true end end end
 s.flags['DW-03:report']=true;profile.heroes.qa.deepwood=s
 local original=SSS.Server.Combat.CombatService;local clone=original:Clone();clone.Name='SeleneCombatQA'
 clone.Source=clone.Source:gsub('\nreturn CombatService%s*$',[[
CombatService.qa={states=playerStates,setContext=function(f) contextResolver=f end,setClock=function(t) now=function() return t end end}
return CombatService
]]);clone.Parent=original.Parent;local combat=require(clone)
 local folder=Instance.new('Folder');folder.Name='SeleneNativeQA';folder.Parent=workspace
 local center=Vector3.new(20000,1000,20000);local ground=Instance.new('Part');ground.Anchored=true;ground.Size=Vector3.new(200,2,200);ground.Position=center-Vector3.new(0,1,0);ground.Parent=folder
 local hero={heroId='qa',baseClassId='knight',epoch=1,characterGeneration=1}
 local active={};local roots={};local journals={};local count=1
 for i=1,4 do
  local char=Instance.new('Model');char.Name='Owner'..i;char:SetAttribute('K0SpawnReady',true);char.Parent=folder
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Position=center+Vector3.new(i*4,3,0);root.Anchored=true;root.CanCollide=false;root.Parent=char;char.PrimaryPart=root
  local h=Instance.new('Humanoid');h.MaxHealth=100;h.Health=40;h.Parent=char
  local player={UserId=i,Parent=Players,Character=char};active[i]=player;roots[player]=root;journals[player]=P.copy(s)
  combat.qa.states[player]={player=player,heroId='qa',heroEpoch=1,characterGeneration=1,baseClassId='knight',character=char,root=root,humanoid=h,mode='Idle'}
 end
 combat.qa.setContext(function() return hero end);combat.qa.setClock(10)
 local player=active[1];local root=roots[player];local h=player.Character:FindFirstChildOfClass('Humanoid')
 check(combat.applySeleneSupport(player,'wrong',true)==nil and h.Health==40,'identity cannot cross hero')
 check(combat.applySeleneSupport(player,'qa',false)=='Heal' and h.Health==52,'server-limited heal')
 h.Health=100;check(combat.applySeleneSupport(player,'qa',true)=='Protect','protection action')
 local state=combat.qa.states[player];check(state.branchShield.amount==10 and state.branchShield.expires==13,'bounded shield')
 state.branchShield={amount=40,expires=20};combat.applySeleneSupport(player,'qa',true);check(state.branchShield.amount==40 and state.branchShield.expires==20,'stronger Paladin shield preserved')
 state.mode='Stunned';state.stunnedUntil=12;check(combat.applySeleneSupport(player,'qa',true)=='Cleanse' and state.mode=='Idle','cleanse current interrupt')
 local enemies=Instance.new('Folder');enemies.Parent=folder
 local selectionCount=0;local calls=0;local selectionTime=0
 local fakeCombat={applySeleneSupport=function(...) calls+=1;return combat.applySeleneSupport(...) end}
 local companion=require(SSS.Server.Story.SeleneCompanion).create({clock=function() selectionTime+=1;return selectionTime end,world={folder=folder,positions={['DW-03']=center+Vector3.new(45,0,-45)}},enemies=enemies,combat=fakeCombat,
  active=function() return hero end,context=function(p) return p.Character and hero,roots[p] end,state=function(p) return journals[p] end,
  players=function() local r={};for i=1,count do table.insert(r,active[i]) end;return r end,publish=function() end,
  select=function(p,_,follow) journals[p]=assert(P.selectSelene(journals[p],follow));selectionCount+=1 end})
 check(folder.SeleneCamp:GetAttribute('NPCId')=='selene' and folder.SeleneCamp:GetAttribute('TDSourceModel')=='nun','original TD nun mounted as Selene')
 local meshes=0;for _,v in ipairs(folder.SeleneCamp:GetDescendants()) do if v:IsA('MeshPart') then
  meshes+=1;local original=game.ServerStorage.TDSeleneModels.nun:FindFirstChild(v.Name,true)
  check(original and original.MeshId==v.MeshId and original.TextureID==v.TextureID and original.Color==v.Color,'original TD mesh, texture and color preserved')
 end end
 check(meshes==3,'original TD body and both arms reused')
 root.Position=center+Vector3.new(100,3,0);check(not companion.select(player,true) and selectionCount==0,'distance cannot invite')
 root.Position=center+Vector3.new(0,3,0);local old=journals[player];journals[player]=P.new();check(not companion.select(player,true),'rescue gate enforced at camp');journals[player]=old
 check(companion.select(player,true) and journals[player].seleneFollowing,'nearby unlocked hero can select')
 h.Health=40;companion.update(.2);check(folder:FindFirstChild('Selene_1')~=nil,'one follower spawned');check(calls==1 and h.Health==52,'service grants support only once ready')
 companion.update(.2);check(calls==1,'support cooldown suppresses repeated updates')
 companion.select(player,false);companion.update(.2);check(not folder:FindFirstChild('Selene_1'),'rest removes follower')
 companion.select(player,true);companion.update(.2);check(calls==1,'reinvite cannot reset cooldown')
 for i=2,4 do journals[active[i]]=assert(P.selectSelene(journals[active[i]],true)) end
 count=2;companion.update(.2);check(folder:FindFirstChild('Selene_1') and folder:FindFirstChild('Selene_2'),'two players may have two total supporters')
 count=3;companion.update(.2);check(folder:FindFirstChild('Selene_1') and not folder:FindFirstChild('Selene_2'),'three players have only one total supporter')
 count=4;companion.update(.2);check(folder:FindFirstChild('Selene_1'),'four players may have one supporter');for i=2,4 do check(not folder:FindFirstChild('Selene_'..i),'four players cannot exceed one supporter') end
 check(journals[active[2]].seleneFollowing and companion.projection(active[2]):find('slots are full',1,true),'unselected owners retain preference and see slot explanation')
 count=1;companion.update(.2);check(folder:FindFirstChild('Selene_1'),'slot returns when party shrinks')
 local follower=folder:FindFirstChild('Selene_1');local start=follower.PrimaryPart.Position
 root.Position+=Vector3.new(28,0,0)
 for _=1,50 do companion.update(.25);task.wait(.08) end
 check((follower.PrimaryPart.Position-start).Magnitude>10,'native pathfinding moves the cast supporter toward its owner')
 check((follower.PrimaryPart.Position-root.Position).Magnitude<12,'follower reaches a support distance')
 player.Character=nil;companion.update(.2);check(not folder:FindFirstChild('Selene_1'),'character switch removes old actor')
 -- Client completion presentation never destroys the shared portal.
 local campaign=workspace:WaitForChild('DeepwoodCampaign');local portal=campaign:WaitForChild('MonsterPortal')
 local energy
 for _,part in ipairs(portal:GetDescendants()) do local zone=part:FindFirstChild('ForestKitZone');if part:IsA('BasePart') and (part:GetAttribute('ForestKitZone')=='PortalEnergy' or zone and zone.Value=='PortalEnergy') then energy=part;break end end
 assert(energy,'Actual TD portal energy missing')
 local view=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodStoryPresentation)
 view.update({flags={['DW-07:stabilize']=true}});check(energy.LocalTransparencyModifier==1 and portal.Parent==campaign,'personal completed portal closes without deletion')
 view.update({flags={}});check(energy.LocalTransparencyModifier==0,'unfinished player retains portal')
 folder:Destroy();clone:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
report.pass=#report.failures==0;print('SELENE_SUPPORT_NATIVE '..game:GetService('HttpService'):JSONEncode(report));assert(report.pass,'Selene native support failed')
