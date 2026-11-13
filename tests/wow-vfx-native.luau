-- School identity, camera independence, bounded geometry and cleanup in engine.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Hero=require(game.StarterPlayer.StarterPlayerScripts.Client.HeroVFX)
local Surfaces=require(game.StarterPlayer.StarterPlayerScripts.Client.HeroVFXSurfaces)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local floor=Instance.new('Part');floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Parent=workspace
local char=Instance.new('Model');char.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.new(0,3,0);root.Anchored=true;root.Parent=char
local ok,err=xpcall(function()
 for _,id in ipairs({'knight.paladin.dawn_burst','knight.paladin.dawn_spiral','knight.paladin.oath_of_dawn','mage_arcane_ward'})do
  Hero.clear();local now=workspace:GetServerTimeNow()
  local m=assert(Hero.skill(char,id,root.Position,root.Position,1,{}))
  local holy=id~='mage_arcane_ward';local rays,facets=0,0;local tracked={}
  check(not m:FindFirstChild('ElementalSurface',true),'holy no longer shares a water-like disc')
  check(not m:FindFirstChild('GuardSurface',true),'magical barrier does not use martial shield silhouette')
  for _,p in ipairs(m:GetDescendants())do
   if p:IsA('BasePart')then
    check(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,'presentation has no physics authority')
    if p.Name=='DawnAscendingLight'then rays+=1;tracked[#tracked+1]={p=p,cf=p.CFrame}
    elseif p.Name=='ArcaneWardFacet'then facets+=1;tracked[#tracked+1]={p=p,cf=p.CFrame};check((p.Position-root.Position).Magnitude<3.5,'ward surrounds caster')end
   end
  end
  check(holy and rays==6 and facets==0 or not holy and facets>=12 and rays==0,'class-specific silhouette')
  local _,beams,_,_,_,faces=Hero.count()
  check(beams<=24 and faces<=24,'decorations remain within per-cast budget')
  for _,cf in ipairs({CFrame.new(12,5,0),CFrame.new(0,18,.1)})do
   camera.CFrame=cf
   for _,v in ipairs(tracked)do check(v.p.CFrame==v.cf,'camera cannot rotate world-space forms')end
  end
  Hero.step(now+.2)
  if holy then for _,v in ipairs(tracked)do check(v.p.Position.Y>v.cf.Position.Y,'holy light rises')end end
  Hero.step(now+2);check(m.Parent==nil and Surfaces.count()==0,'expiry releases surfaces')
 end
 Hero.clear();camera.CFrame=CFrame.new(0,8,12)
 local control=assert(Hero.skill(char,'knight.common.bash',root.Position,root.Position,1,{}))
 check(control:FindFirstChild('GuardSurface',true)~=nil,'martial guard preserved')
 Hero.clear()
 for i=1,30 do Hero.skill(char,i%2==0 and'mage_arcane_ward'or'knight.paladin.dawn_burst',root.Position,root.Position,1,{})end
 local active,beams,chips,glows,particles,faces=Hero.count()
 check(active<=12 and beams<=240 and chips<=48 and glows<=96 and particles<=192 and faces<=160,'mixed casts honor global budgets')
 Hero.clear();check(Surfaces.count()==0 and Hero.count()==0,'clear releases all mixed casts')
end,debug.traceback)
Hero.clear();char:Destroy();floor:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=ok
print('WOW_VFX_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
