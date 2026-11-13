-- Verify element identity in real engine instances, not color names alone.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Hero=require(Client.HeroVFX);local Wind=require(Client.WindLanceVisual)
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Hit=require(Client.K0HitEffects)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local char=Instance.new('Model');char.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(0,3,0);root.Parent=char
local floor=Instance.new('Part');floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Parent=workspace
local first,last=root.Position,root.Position+Vector3.new(0,0,-8)
local function cast(id)
 Hero.clear();return assert(Hero.skill(char,id,first,last,1,{last,last+Vector3.new(3,0,-2)}))
end
local ok,err=xpcall(function()
 local fire=cast('mage.pyro.ember_lance')
 check(fire:FindFirstChild('FlameJet',true)~=nil and not fire:FindFirstChild('SpellVolume',true),'fire uses flame tongues instead of generic sphere')
 local plume=fire:FindFirstChild('ElementalPlume',true)
 check(plume.Texture:find('fire_main',1,true)~=nil and plume.Acceleration.Y>0 and plume.SpreadAngle.X<30,'fire rises with narrow flame emission')
 local water=cast('mage.common.water_ball');local drops={}
 for _,p in ipairs(water:GetDescendants())do if p.Name=='WaterSpray'then
  check(p:IsA('Part')and p.Shape==Enum.PartType.Ball and p.Material==Enum.Material.Glass,'water droplets are smooth glass, not ice shards')
  drops[#drops+1]={p=p,pos=p.Position}
 end end
 check(water:FindFirstChild('WaterCrest',true)~=nil and water:FindFirstChild('WaterFoam',true)~=nil,'water has rolling crests and pale foam');check(#drops>0,'water has visible splash droplets');Hero.step(workspace:GetServerTimeNow()+.12)
 for _,d in ipairs(drops)do check((d.p.Position-d.pos).Magnitude>.1,'splash moves outward')end
 for _,id in ipairs({'mage.cryo.frost_lance','mage.cryo.glacial_spike'})do
  local ice=cast(id);local lance=ice:FindFirstChild('IceLanceVolume',true)
  check(lance and lance:IsA('WedgePart')and lance.Material==Enum.Material.Ice,'ice projectile has hard facets')
 end
 for _,id in ipairs({'mage.cryo.frost_step','mage.cryo.ice_ward','mage.cryo.froststorm','mage.cryo.eternal_tempest'})do
  local ice=cast(id)
  check(not ice:FindFirstChild('ElementalSurface',true)and ice:FindFirstChild('FrostRimFacet',true)~=nil,'ice area does not share a water pool')
 end
 local rock=cast('mage.pyro.stone_lance');local lance=rock:FindFirstChild('StoneLanceVolume',true)
 check(lance and lance:IsA('WedgePart')and lance.Material==Enum.Material.Slate,'earth projectile has solid rock facets')
 local rise=cast('mage.pyro.earth_rise');local crag=rise:FindFirstChild('RisingCrag',true)
 check(crag and crag.Material==Enum.Material.Slate,'earth erupts as rough stone');local y=crag.Position.Y
 Hero.step(workspace:GetServerTimeNow()+.12);check(crag.Position.Y>y,'stone rises from ground')
 local bolt=cast('mage.cryo.lightning_line');local branch=bolt:FindFirstChild('LightningBranch',true)
 check(branch~=nil and branch.Color.B>branch.Color.R,'electric bolt branches in blue, distinct from violet arcane')
 Hero.step(workspace:GetServerTimeNow()+.18);check(branch.Transparency==1,'electric discharge is short')
 local holyCount=0
 for id,row in pairs(Catalog.byId)do if row.definition.element=='holy'then
  holyCount+=1;check(row.key=='holy','holy element wins over generic shield mapping: '..id)
  local m=cast(id)
  local flare=m:FindFirstChild('ElementalFlare',true);local core=m:FindFirstChild('WhiteHotCore',true)
  check(flare.ImageColor3.R>.95 and flare.ImageColor3.G>.6 and flare.ImageColor3.B<.25,'holy body is golden: '..id)
  check(core.ImageColor3.B<.6 and core.ImageColor3.G>.8,'holy highlight stays warm gold: '..id)
  local contact=assert(Hero.contact(last,'knight',id,Vector3.new(0,0,-1),1))
  check(contact:FindFirstChild('ContactVolume',true).Color.B<.6,'holy contact stays gold')
 end end
 check(holyCount==13,'all thirteen paladin skills checked')
 check(Catalog.byId['knight.common.bash'].key=='shield','physical shield remains unchanged')
 Hero.clear()
 check(Hit.show(char,last,25,'knight','Goblin',Vector3.new(0,0,-1),'knight.paladin.shield_verdict'),'golden hit event accepted')
 local hit=workspace:FindFirstChild('K0HitEffect');check(hit and hit:FindFirstChild('K0ImpactSpark').Color.B<.25,'legacy hit spark also stays gold');hit:Destroy()
 local now=workspace:GetServerTimeNow()
 local gust=assert(Wind.play(char,first,last,1,{last},99000,now,nil,.25,now))
 local attachment=gust.WindCarrier:FindFirstChild('AirSpiral2');local at=attachment.Position
 Wind.step(now+.1);check((attachment.Position-at).Magnitude>.01,'wind rotates along the path')
 check(gust:FindFirstChild('WindSurface',true)~=nil and gust.WindCarrier:FindFirstChild('HitGust')~=nil,'wind has filled airflow and hit gust, not elemental fire')
 Wind.clear();Hero.clear();check(Hero.count()==0,'element review releases hero budget')
end,debug.traceback)
Hero.clear();Wind.clear();char:Destroy();floor:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=ok;print('ELEMENT_VFX_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
