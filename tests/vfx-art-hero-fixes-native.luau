-- ART follow-up: semantic silhouettes, motion, authority separation and cleanup.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Hero=require(Client.HeroVFX)
local Profiles=require(Client.SkillVFXProfiles)
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Palette=require(game.ReplicatedStorage.Shared.CombatVFXPalette)
local report={checks=0,failures={},coverage='Procedural engine geometry and motion; not final art/device acceptance'}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(120,.5,120);floor.Position=Vector3.new(0,-.25,0);floor.Parent=workspace
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-8)
local forward=Vector3.new(0,0,-1)
local fields={'damage','range','radius','element','pulses','interval','manaCost','cooldown','level','windup','active','recovery','slow','shield','stunDuration'}
local unchanged={}
for id,row in pairs(Catalog.byId)do unchanged[id]={};for _,key in ipairs(fields)do unchanged[id][key]=row.definition[key]end end
local function cast(id)
 Hero.clear();return assert(Hero.skill(nil,id,first,last,1,{last}))
end
local ok,err=xpcall(function()
 for _,id in ipairs({'knight.paladin.oath_challenge','knight.steel_knight.warcry_assault','elf.magic_archer.rooting_fan'})do
  local m=cast(id);check(m:GetAttribute('ForwardOnly')==true,'forward semantic marker '..id)
  check(not m:FindFirstChild('WarcrySurface',true)and not m:FindFirstChild('VineSurface',true),'no full disc or spring '..id)
  Hero.step(workspace:GetServerTimeNow()+.15)
  for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then check((p.Position-first):Dot(forward)>-.05,'decoration stays ahead of caster '..id)end end
 end
 local shot=cast('dwarf.gunner.scatter_shot');local pellets=0
 check(not shot:FindFirstChild('ArrowEdge',true)and not shot:FindFirstChild('ProjectileSurface',true),'gun cone has no arrowhead surfaces')
 for _,p in ipairs(shot:GetDescendants())do if p.Name=='ShotPelletBody'then pellets+=1;check(p.Size.X<=.11,'pellets are small metal bodies')end end
 check(pellets==5,'five authored gun lanes retain small pellet bodies')
 local mortar=cast('dwarf.gunner.field_mortar');local body=assert(mortar:FindFirstChild('MortarShellBody',true));local tail=assert(mortar:FindFirstChild('MortarShortWake',true))
 check(body.Material==Enum.Material.Metal and not mortar:FindFirstChild('MortarDescent',true),'shell is metal rather than a sky laser')
 local y=body.Position.Y;Hero.step(workspace:GetServerTimeNow()+.15)
 check(body.Position.Y<y-.3,'shell body descends');check((tail.Attachment0.WorldPosition-tail.Attachment1.WorldPosition).Magnitude<.8,'mortar wake remains short')
 for _,id in ipairs({'elf.magic_archer.vine_trap','elf.magic_archer.rooting_fan','elf.magic_archer.vine_burst'})do
  local m=cast(id);check(m:FindFirstChild('GroundRootBody',true)and m:FindFirstChild('RootThorn',true),'root has grounded branches and thorns '..id)
  check(not m:FindFirstChild('VineSurface',true),'large spring silhouette removed '..id)
  local root=assert(m:FindFirstChild('GroundRootBody',true));local tip=assert(m:FindFirstChild('RootAscendingTip',true))
  check(root.Size.X>=.22 and root.Color.G>.6,'ground root retains readable body width and contrast '..id)
  check(tip.Color.G>.85 and tip.Material==Enum.Material.Neon,'root tip has a local mint contrast cue '..id)
 end
 local steam=cast('mage.pyro.steam_burst');local vapor=assert(steam:FindFirstChild('SteamVapor',true))
 check(not steam:FindFirstChild('WaterVolume',true)and not steam:FindFirstChild('SteamJet',true),'steam does not reuse a water mass or white rods')
 check(not vapor.Enabled and vapor.Rate==0 and vapor.EmissionDirection==Enum.NormalId.Top and vapor.Lifetime.Max<=.32,'steam is a short bounded upward burst')
 for _,id in ipairs({'mage.pyro.cinder_ring','mage.pyro.ember_step','mage.pyro.searing_ward'})do
  local m=cast(id);check(m:FindFirstChild('AreaFlameTongue',true)and not m:FindFirstChild('FlameVolume',true),'flame tongues replace upright panels '..id)
 end
 local lava=cast('mage.pyro.lava_eruption');check(lava:FindFirstChild('LavaVent',true)and lava:FindFirstChild('MoltenSeam',true),'lava combines hot seams and rising vents')
 check(Catalog.byId['mage.pyro.lava_eruption'].definition.element=='earth','composite lava retains its actual earth element')
 local signatures={};local ultimates=0
 for id,row in pairs(Catalog.byId)do if row.definition.ultimate then
  local m=cast(id);local key=m:GetAttribute('UltimateSignature')
  check(type(key)=='string'and not signatures[key],'ultimate owns a unique focal form '..id);signatures[key]=true;ultimates+=1
  check(key==Profiles.get(id).signature,'signature follows the authored profile '..id)
  if key=='FrontWall'then check(m:FindFirstChild('UltimateFrontPanel',true).Transparency<=.6,'front panels retain contrast')
  elseif key=='DawnBlade'then check(m:FindFirstChild('DawnBladeSpine',true).Position.X-first.X>1,'solar blade focus is offset from the actor silhouette')
  elseif key=='MountainRidge'then Hero.step(workspace:GetServerTimeNow()+.15);check(m:FindFirstChild('MountainRidgeFocus',true).Size.Y>3,'mountain focus grows into a heavy ridge')
  elseif key=='SiegeShells'then check(m:FindFirstChild('MortarShellBody',true).Size.X>=.6,'siege shell keeps a visible metal body')
  elseif key=='VolleyCrown'then check((m:FindFirstChild('VolleyDrawCrown',true).Attachment0.WorldPosition-first).Magnitude>3,'volley crown occupies a readable forward focus')
  elseif key=='SpiritCanopy'then check(m:FindFirstChild('SpiritCanopyBough',true)and m:FindFirstChild('SpiritCanopyLeaf',true).Size.Y>=1.8,'spirit canopy has body branches and distinct leaves')
  elseif key=='CalderaVents'then local high=0;for _,v in ipairs(m:GetDescendants())do if v.Name=='CalderaEruptionTongue'and v:IsA('BasePart')then high=math.max(high,v.Position.Y)end end;check(high>3,'caldera focal flames retain vertical presence')
  elseif key=='FrostFunnel'then local high=0;for _,v in ipairs(m:GetDescendants())do if v.Name=='TempestSpiral'and v:IsA('Beam')then high=math.max(high,v.Attachment0.WorldPosition.Y,v.Attachment1.WorldPosition.Y)end end;check(high>5,'tempest spiral retains a vertical focus')end
  local n,b,c,g,p,f=Hero.count();check(n==1 and b<=48 and c<=7 and g<=96 and p<=192 and f<=160,'signature obeys original budgets '..id)
  for _,part in ipairs(m:GetDescendants())do if part:IsA('BasePart')then check(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery,'ultimate has no physics authority')end end
 end end
 check(ultimates==8,'all eight ultimate signatures inspected')
 local blade=cast('knight_crescent_cut');local surface=assert(blade:FindFirstChild('BladeSurface',true))
 check(surface.Material==Enum.Material.SmoothPlastic and surface.Transparency>=.35,'blade fill is subdued while edge highlights remain')
 for _,classId in ipairs({'knight','dwarf','elf','mage'})do
  Hero.clear();local m=assert(Hero.contact(last,classId,nil,forward,1))
  check(not m:FindFirstChild('ContactPressure',true),'basic contact does not resemble a generic shield '..classId)
 end
 Hero.clear();local hit=assert(Hero.contact(last,'dwarf','dwarf.iron_axe.armor_splitter',forward,1))
 local cut=assert(hit:FindFirstChild('AxeCutContact',true));local warm=Palette.get('steel','dwarf')
 check(cut.Color.Keypoints[1].Value==warm,'dwarf steel contact matches the warm skill palette')
 for id,row in pairs(Catalog.byId)do for _,key in ipairs(fields)do check(row.definition[key]==unchanged[id][key],'server definition preserved '..id..'/'..key)end end
 Hero.clear()
 for i=1,40 do Hero.skill(nil,i%2==0 and'mage.pyro.caldera_s_judgment'or'elf.magic_archer.rooting_fan',first,last,1,{last})end
 local n,b,c,g,p,f=Hero.count();check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'mixed silhouettes obey global limits')
 Hero.clear();local a,b2,c2,g2,p2,f2=Hero.count();check(a+b2+c2+g2+p2+f2==0,'clear returns every presentation budget')
end,debug.traceback)
Hero.clear();floor:Destroy();camera.CFrame=old
if not ok then report.failures[#report.failures+1]=err end
report.pass=ok;print('VFX_ART_HERO_FIXES_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
