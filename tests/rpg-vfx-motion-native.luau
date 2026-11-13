-- Presentation timing and bounded cleanup in the real engine.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Hero=require(game.StarterPlayer.StarterPlayerScripts.Client.HeroVFX)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-8)
local ok,err=xpcall(function()
 for _,row in ipairs({{'knight_crescent_cut','BladeSurface'},{'mage.pyro.ember_lance','FlameWake'},{'mage_tidal_ring','ElementalSurface'},{'mage.pyro.earth_rise','RuptureShockwave'}})do
  Hero.clear();local model=assert(Hero.skill(nil,row[1],first,last,1,{}))
  local face=assert(model:FindFirstChild(row[2],true),row[1])
  local faces={};for _,v in ipairs(model:GetDescendants())do if v.Name==row[2]and v:IsA('BasePart')then faces[#faces+1]={part=v}end end
  local rest=face.CFrame;local now=workspace:GetServerTimeNow()
  Hero.step(now+.04);local early=face.CFrame
  for _,v in ipairs(faces)do v.early=v.part.Position end
  Hero.step(now+.16);local later=face.CFrame
  local travel=0;for _,v in ipairs(faces)do travel=math.max(travel,(v.part.Position-v.early).Magnitude)end
  check(travel>.02,'sweep/expansion moves in world space '..row[1])
  Hero.step(now+.04);check((face.CFrame.Position-early.Position).Magnitude<.001,'sampling is independent of frame history '..row[1])
  check(rest~=later,'animation is not a static decal '..row[1])
 end
 Hero.clear();local hit=assert(Hero.contact(last,'knight','knight.paladin.oathblade',Vector3.new(0,0,-1),1))
 local core=assert(hit:FindFirstChild('ContactVolume',true));local wave=assert(hit:FindFirstChild('ContactPressure',true))
 local now=workspace:GetServerTimeNow();Hero.step(now+.1)
 check(core.Transparency==1 and wave.Transparency<1,'impact core disappears before open pressure tail')
 check(wave.Color.B<.25,'holy impact stays golden')
 Hero.step(now+.24);check(wave.Transparency==1,'pressure tail ends without re-flashing')
 Hero.step(now+1);check(hit.Parent==nil and Hero.count()==0,'impact expires completely')
 for i=1,40 do Hero.skill(nil,i%2==0 and'mage.pyro.ember_lance'or'knight_crescent_cut',first,last,1,{})end
 local n,b,c,g,p,f=Hero.count()
 check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'mixed motion retains all global caps')
 for _,m in ipairs(workspace:GetChildren())do if m.Name=='HeroVFX'then for _,v in ipairs(m:GetDescendants())do
  if v:IsA('BasePart')then check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'decoration has no hit authority')end
 end end end
 Hero.clear();local a,b2,c2,g2,p2,f2=Hero.count();check(a+b2+c2+g2+p2+f2==0,'clear recovers every budget after saturation')
end,debug.traceback)
Hero.clear();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=ok;print('RPG_VFX_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
