assert(game.PlaceId==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.HeroVFX)
local A=require(game.ReplicatedStorage.Shared.AdvancedSkills)
local report={checks=0,failures={},coverage='Native decoration, budgets and Lua update cost; not GPU or device acceptance'}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-10)
local ok,err=xpcall(function()
 local m=assert(FX.skill(nil,A.branches.pyro.skills[1].id,first,last,1,{}))
 local core,glow,emitters,flare=0,0,0,0
 for _,v in ipairs(m:GetDescendants())do
  if v:IsA('Beam')then
   if v.Name=='SoftGlow'then glow+=1;check(v.LightEmission==1 and v.LightInfluence==0,'glow retains element color')else core+=1 end
  elseif v:IsA('ParticleEmitter')then
   emitters+=1;check(not v.Enabled and v.Rate==0,'bursts cannot become continuous emitters')
   check(v.Lifetime.Max<=.36 and (v:GetAttribute('ReviewBurstCount')or 100)<=16,'short bounded burst')
  elseif v:IsA('BillboardGui')then flare+=1;check(not v.AlwaysOnTop and v.MaxDistance<=100,'flare obeys world occlusion')end
 end
 check(core>0 and glow>0 and emitters==2 and flare==1,'fire cast has core, halo, sparks, flame and flash')
 FX.step(workspace:GetServerTimeNow()+.1)
 local image=m:FindFirstChild('ElementalFlare',true);check(image.ImageTransparency>0,'flash fades within the cast')
 FX.clear()
 local blade=assert(FX.skill(nil,'knight_crescent_cut',first,last,1,{}))
 local area=0;local wedges=0
 for _,v in ipairs(blade:GetDescendants())do if v:IsA('WedgePart')and v.Name=='BladeSurface'then
  wedges+=1;area+=v.Size.Y*v.Size.Z*.5
  check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery and v.Transparency<.5,'blade faces have visible fill and no hit authority')
 end end
 check(wedges>=16 and area>4,'crescent is a filled surface rather than a collection of lines')
 FX.step(workspace:GetServerTimeNow()+.1)
 FX.clear()
 for i=1,30 do FX.skill(nil,A.branches.pyro.skills[13].id,first,last,1,{last})end
 local n,b,c,g,p,f=FX.count();check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'crowded burst has independent strict budgets')
 local samples={};local now=workspace:GetServerTimeNow()
 for i=1,60 do local t=os.clock();FX.step(now+i*.001);samples[i]=(os.clock()-t)*1000 end
 table.sort(samples);report.luaUpdateP50ms=samples[30];report.luaUpdateP95ms=samples[57]
 FX.clear();local n2,b2,c2,g2,p2,f2=FX.count();check(n2+b2+c2+g2+p2+f2==0,'cleanup releases every decoration budget')
 check(not workspace:FindFirstChild('HeroVFX'),'cleanup removes particles, flares and glows')
end,debug.traceback)
FX.clear();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=#report.failures==0
print('HERO_VFX_FLOURISH_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'flourish regressions')
