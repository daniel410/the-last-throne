-- Research-driven curves, temporal layering and authored movement in the real engine.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Style=require(Client.CombatVFXStyle)
local Hero=require(Client.HeroVFX)
local Wind=require(Client.WindLanceVisual)
local Spell=require(Client.EnemySpellVFX)
local Art=require(Client.EnemySpellArt)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,10,18)
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-10)
local function cubic(p,q,a,b,c0,c1,t)
 local u=1-t
 return p*u^3+(p+a.Unit*c0)*3*u*u*t+(q-b.Unit*c1)*3*u*t*t+q*t^3
end
local ok,err=xpcall(function()
 -- A quarter-circle's midpoint must follow the curve rather than its chord.
 local path=function(t)return Vector3.new(math.cos(t*math.pi/2),0,math.sin(t*math.pi/2))*4 end
 local p,q,a,b,c0,c1=Style.span(path,0,.5,0)
 local middle=cubic(p,q,a,b,c0,c1,.5)
 check((p-path(0)).Magnitude<.00001 and(q-path(.5)).Magnitude<.00001,'curve preserves authored endpoints')
 check((middle-path(.25)).Magnitude<.008,'cubic follows the circular arc between endpoints')
 local _,_,nextA=Style.span(path,.5,1,0)
 check(b.Unit:Dot(nextA.Unit)>.99999,'adjacent spans share a tangent')
 local flat=function()return first end
 local x,y,_,_,c,d=Style.span(flat,0,1,0)
 check(x==y and c==0 and d==0,'collapsed path cannot produce loops or NaN')
 for _,id in ipairs({'knight_crescent_cut','knight.common.whirlwind','mage.common.water_ball','mage.pyro.ember_lance','elf.magic_archer.spirit_arrowfall','mage.cryo.eternal_tempest'})do
  Hero.clear();local now=workspace:GetServerTimeNow();local m=assert(Hero.skill(nil,id,first,last,1,{last}))
  local curved=0;local hasGlow=false
  for _,age in ipairs({.02,.09,.17})do
   Hero.step(now+age)
   for _,v in ipairs(m:GetDescendants())do if v:IsA('Beam')then
    check(v.Segments<=3,'curve tessellation is bounded independently of quality')
    if v.Segments==3 then
     curved+=1
     check(v.CurveSize0>=0 and v.CurveSize1>=0,'hero cubic control lengths are finite and forward')
     check(v.Attachment0.WorldAxis.Magnitude>.99 and v.Attachment1.WorldAxis.Magnitude>.99,'native attachment axes define the controls')
    end
    if v.Name=='SoftGlow'then hasGlow=true end
   end end
  end
  check(curved>0,'curved silhouette is present '..id)
  if hasGlow then
   local glow=m:FindFirstChild('SoftGlow',true)
   check(glow.Transparency.Keypoints[1].Value>.7,'broad halo recedes before the narrow core')
  end
  local core=m:FindFirstChild('WhiteHotCore',true)
  if core then check(core.ImageTransparency==1,'bright flash expires before .09 seconds')end
  Hero.step(now+.09);local position
  for _,v in ipairs(m:GetDescendants())do if v:IsA('Beam')then position=v.Attachment0.WorldPosition;break end end
  Hero.step(now+.03);Hero.step(now+.09)
  for _,v in ipairs(m:GetDescendants())do if v:IsA('Beam')then check((v.Attachment0.WorldPosition-position).Magnitude<.002,'curve pose is frame-history independent');break end end
 end
 Hero.clear()
 local now=workspace:GetServerTimeNow()
 local w=assert(Wind.play(nil,first,last,1,{last},nil,now,nil,nil,now))
 Wind.step(now+.08);local curveCount=0
 for _,v in ipairs(w:GetDescendants())do if v:IsA('Beam')and v.Name=='AirSpiral'then
  curveCount+=1;check(v.Segments==3 and v.CurveSize0>0 and v.CurveSize1>0,'air spirals are continuous cubic ribbons')
 end end
 check(curveCount==60,'wind retains the original three 20-span spirals');Wind.clear()
 for _,kind in ipairs({'Imp','IceElf','Shaman','Lich','Veyr','VenomcoilKing','Silkweaver'})do
  Spell.clear();now=workspace:GetServerTimeNow();local d=Patterns.get(kind).attacks[1]
  local r=assert(Spell.impact(d,last,now,nil,nil,Vector3.zAxis))
  Spell.pose(r,CFrame.new(last),.1,1)
  if r.art.flare then
   check(r.art.flare.images[3].image.ImageTransparency==1,'enemy white core is gone by .1 seconds '..kind)
   check(r.art.flare.images[1].image.ImageTransparency<1,'faint colored residue follows the initial contact '..kind)
  end
  for _,line in ipairs(r.art.lines)do
   if line.soft then check(line.beam.Transparency.Keypoints[1].Value>.76,'soft enemy afterglow stays subordinate')end
  end
  if d.shape=='projectile'then
   Spell.clear();r=assert(Spell.projectile(d,nil,nil,first,-Vector3.zAxis,now))
   local trail=assert(r.parts[1].part:FindFirstChild('SpellWake'))
   check(trail.WidthScale.Keypoints[#trail.WidthScale.Keypoints].Value==0,'enemy projectile wake ends in a fine tip')
  end
 end
 Spell.clear();local n,pCount=Spell.count();local bCount,mCount,lCount,fCount=Art.count()
 check(n+pCount+bCount+mCount+lCount+fCount==0,'enemy layer reservations fully return')
 for _,kind in ipairs({'weapon','enemy','spell'})do
  local t=Instance.new('Trail');Style.trail(t,kind)
  check(t.WidthScale.Keypoints[1].Value>t.WidthScale.Keypoints[3].Value and t.WidthScale.Keypoints[4].Value==0,'moving blade has a thick leading edge and fine tail '..kind)
  check(t.Transparency.Keypoints[3].Value==1 and t.FaceCamera,'short trail dissolves across its age '..kind);t:Destroy()
 end
 -- Exercise the touch branch without changing Studio's real input services.
 local surface=Client.HeroVFXSurfaces:Clone();surface.Name='PolishTouchSurfaces'
 surface.Source=surface.Source:gsub("local Input=game:GetService%('UserInputService'%)","local Input={TouchEnabled=true}")
 surface.Parent=Client
 local hero=Client.HeroVFX:Clone();hero.Name='PolishTouchHero'
 hero.Source=hero.Source:gsub('local Input=game:GetService%("UserInputService"%)','local Input={TouchEnabled=true}')
 hero.Source=hero.Source:gsub('script.Parent.HeroVFXSurfaces%)','script.Parent.PolishTouchSurfaces)');hero.Parent=Client
 local touch=require(hero)
 for _,id in ipairs({'knight_crescent_cut','knight.common.whirlwind','knight.steel_knight.twin_cyclone','mage_tidal_ring'})do
  touch.clear();local m=assert(touch.skill(nil,id,first,last,1,{}));local faces=select(6,touch.count())
  check(faces<=80,'complete primary stays inside the existing touch face cap '..id)
  if id=='knight.steel_knight.twin_cyclone'then
   local faces,edges=0,0
   for _,v in ipairs(m:GetDescendants())do
    if v.Name=='BladeSurface'then faces+=1 end
    if v.Name=='BladeRibbon'then edges+=1 end
   end
   check(edges==12 and faces>=24 and faces<=32,'the confirmed pulse gets one complete ribbon and one filled blade surface on touch')
  end
 end
 touch.clear();hero:Destroy();surface:Destroy()
end,debug.traceback)
Hero.clear();Wind.clear();Spell.clear();camera.CFrame=old
if not ok then report.failures[1]=err end
report.pass=ok;print('ROBLOX_VFX_POLISH_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
