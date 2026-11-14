-- Review regressions in an isolated, account-free Studio fixture.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Effects=require(Client.EnemyPatternEffects)
local Hero=require(Client.HeroVFX)
local Spell=require(Client.EnemySpellVFX)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local Runtime=require(game.ServerScriptService.Server.Combat.EnemyPatternRuntime)
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local report={checks=0,failures={},attacks=0,dashes=0}
local function check(value,message)
 report.checks+=1;if not value then table.insert(report.failures,message)end
end
local camera=workspace.CurrentCamera;local oldCamera=camera.CFrame;camera.CFrame=CFrame.new(0,18,25)
-- Attribute-bearing viewer fixture; no Player or account capability is needed.
local viewer=Instance.new('Folder');viewer.Name='RangePreferenceQA'
local world=Instance.new('Folder');world.Name='DeepwoodCampaign';world.Parent=workspace
local floor=Instance.new('Part');floor.Name='Ground';floor.Size=Vector3.new(180,.5,180);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Parent=world
local actor=Instance.new('Model');actor.Name='RangeLifetimeQA';actor.Parent=world
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Position=Vector3.new(0,3,0);root.Anchored=true;root.Parent=actor
local human=Instance.new('Humanoid');human.Parent=actor
local socket=Instance.new('Attachment');socket.Name='EnemyCastSocket';socket.Parent=root
local target=Instance.new('Model');target.Name='DashCollisionQA';target.Parent=world
local targetRoot=Instance.new('Part');targetRoot.Name='HumanoidRootPart';targetRoot.Anchored=true;targetRoot.Parent=target
local original=game.HttpService:JSONEncode(Patterns.profiles)
local now=workspace:GetServerTimeNow();local seq=0
local function begin(kind,d)
 seq+=1;root.Position=Vector3.new(0,3,0)
 actor:SetAttribute('EnemyKind',kind);actor:SetAttribute('K0AttackSeq',seq);actor:SetAttribute('K0PatternId',d.id)
 Effects.receive({kind='begin',model=actor,sequence=seq,id=d.id,origin=root.Position,direction=-Vector3.zAxis,aim=Vector3.new(0,3,-8),at=now})
end
local function warning()return workspace:FindFirstChild('EnemyPatternWarning')end
for kind,p in pairs(Patterns.profiles)do for _,d in ipairs(p.attacks)do
 report.attacks+=1
 viewer:SetAttribute('TLTAttackRangesEnabled',false);begin(kind,d)
 Effects.render(now+d.windup*.4,viewer)
 check(not warning(),'OFF before attack hides outline '..d.id)
 if d.element~='physical'then check(Spell.count()>0,'OFF preserves magic charge '..d.id)end
 viewer:SetAttribute('TLTAttackRangesEnabled',true);Effects.render(now+d.windup*.4,viewer)
 check(warning()~=nil,'ON during windup restores outline immediately '..d.id)
 viewer:SetAttribute('TLTAttackRangesEnabled',false);Effects.render(now+d.windup*.4,viewer)
 check(not warning(),'OFF during windup hides outline immediately '..d.id)
 viewer:SetAttribute('TLTAttackRangesEnabled',true);Effects.render(now+d.windup*.4,viewer)
 if d.motion=='dash'then
  report.dashes+=1
  -- Exercise the actual server runtime at the former invisible collision time.
  local enemy={model=actor,root=root,spawnPosition=root.Position,attackSeq=seq,
   config={leashRange=100,attacks={{damage=20}}}}
  targetRoot.Position=Vector3.new(0,3,-d.dashDistance*.55)
  local hits=0
  local began
  Runtime.begin(enemy,{root=targetRoot},d,now,function(message)began=message;Effects.receive(message)end)
  -- Use the real emitted event clock, not time spent inspecting earlier attacks.
  seq=enemy.attackSeq
  enemy.attack.fired=d.pulses
  Runtime.step(enemy,now+d.windup+.30,{{root=targetRoot,character=target}},
   {valid=function()return true end,raycast=function()return nil end,
    floor=function()return {Position=Vector3.zero}end,hit=function()hits+=1 end,emit=function()end})
  Effects.render(began.at+d.windup+.30,viewer)
  check(hits==1,'server still collides after old warning deadline '..d.id)
  check(warning()~=nil,'outline covers the late dash collision '..d.id)
  Effects.render(began.at+d.windup+.51,viewer)
  check(not warning(),'outline ends after actual dash '..d.id)
 end
 Effects.receive({kind='cancel',model=actor,sequence=seq})
 check(not warning(),'cancellation clears outline '..d.id)
end end
check(report.attacks==146 and report.dashes==11,'all attack definitions and dash regressions covered')
check(game.HttpService:JSONEncode(Patterns.profiles)==original,'server attack catalog remains unchanged')
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-8)
local function cast(id)
 Hero.clear();local m=assert(Hero.skill(nil,id,first,last,1,{last}))
 local parts={};for _,v in ipairs(m:GetDescendants())do if v:IsA('BasePart')then parts[v]=true end end
 local n,b,c,g,p,f=Hero.count()
 check(n==1 and b<=48 and c<=7 and g<=96 and p<=192 and f<=160,'single-effect budgets '..id)
 for v in pairs(parts)do check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'cosmetic authority '..id)end
 return m
end
for _,id in ipairs({'knight.common.whirlwind','knight.steel_knight.twin_cyclone','knight.steel_knight.blade_storm'})do
 local m=cast(id);local lines={};local low,high=math.huge,-math.huge
 for _,v in ipairs(m:GetDescendants())do if v:IsA('Beam')and v.Name=='BladeRibbon'then
  table.insert(lines,v);low=math.min(low,v.Attachment0.WorldPosition.Y);high=math.max(high,v.Attachment0.WorldPosition.Y)
 end end
 if id=='knight.common.whirlwind'then check(high-low<.01,'whirlwind stays in one waist plane')
 elseif id=='knight.steel_knight.twin_cyclone'then check(high-low>1,'twin cyclones cross tilted planes')
 else
  check(#lines==30 and high-low>.5,'blade storm has three separated fragment lanes')
  if #lines>=10 then check((lines[1].Attachment0.WorldPosition-lines[10].Attachment1.WorldPosition).Magnitude>2,'blade storm leaves a visible gap in each arc')end
 end
 local line=assert(m:FindFirstChild('BladeRibbon',true));local start=line.Attachment0.WorldPosition
 Hero.step(workspace:GetServerTimeNow()+.08)
 check((line.Attachment0.WorldPosition-start).Magnitude>.1,'spin moves through time '..id)
end
for _,id in ipairs({'mage.pyro.cinder_ring','mage.pyro.ember_step','mage.pyro.searing_ward'})do
 local m=cast(id);local minX,maxX,minZ,maxZ,high=math.huge,-math.huge,math.huge,-math.huge,-math.huge
 for _,v in ipairs(m:GetDescendants())do if v:IsA('BasePart')and v.Name=='AreaFlameTongue'then
  minX=math.min(minX,v.Position.X);maxX=math.max(maxX,v.Position.X)
  minZ=math.min(minZ,v.Position.Z);maxZ=math.max(maxZ,v.Position.Z);high=math.max(high,v.Position.Y)
 end end
 if id=='mage.pyro.ember_step'then check(maxX-minX>(maxZ-minZ)*2,'ember step leaves a short transverse wake')
 elseif id=='mage.pyro.searing_ward'then check(high>2,'searing ward rises into a protective crown')
 else check(maxZ-minZ>1 and maxX-minX>1,'cinder flames retain radial distribution')end
end
for _,row in ipairs({{'elf.marksman.weakpoint_shot','WeakpointBracket'},{'elf.marksman.heavy_draw','HeavyDrawFletching'},
 {'elf.marksman.grand_volley','VolleyCrownLimb'},{'elf.magic_archer.spirit_arrowfall','SpiritCanopyCrownLeaf'}})do
 local m=cast(row[1]);check(m:FindFirstChild(row[2],true)~=nil,'recognizable signature '..row[1])
end
local siege=cast('dwarf.gunner.siege_barrage');local shell=assert(siege:FindFirstChild('MortarShellBody',true))
check(shell.Size.X>=1 and shell.Size.Y>=2,'siege has a substantial metal shell')
local start=shell.Position;Hero.step(workspace:GetServerTimeNow()+.12)
check(shell.Position.Y<start.Y,'siege shell still descends')
Hero.clear();Spell.clear();Effects.receive({kind='cancel',model=actor,sequence=seq})
check(Hero.count()==0 and Spell.count()==0,'effect records clear after inspection')
world:Destroy();viewer:Destroy();camera.CFrame=oldCamera
report.pass=#report.failures==0
print('VFX_REVIEW_FOLLOWUP_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,table.concat(report.failures,'\n'))
