-- Local presentation contract: sharp confirmed contacts, direction and cleanup.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Hero=require(game.StarterPlayer.StarterPlayerScripts.Client.HeroVFX)
local report={checks=0,failures={},coverage='Native geometry and timing; no GPU, multiplayer or user art acceptance'}
local function check(v,label)report.checks+=1;assert(v,label)end
local camera=workspace.CurrentCamera;local old=camera.CFrame
local at=Vector3.new(0,3,0);local direction=Vector3.new(0,0,-1)
local ok,err=xpcall(function()
 for _,offset in ipairs({Vector3.new(0,8,16),Vector3.new(15,6,0),Vector3.new(0,20,.01)})do
  camera.CFrame=CFrame.lookAt(at+offset,at)
  for _,classId in ipairs({'knight','dwarf','elf'})do
   Hero.clear();local now=workspace:GetServerTimeNow()
   local m=assert(Hero.contact(at,classId,nil,direction,1))
   check(m:GetAttribute('ContactStyle')~=nil,'physical contact gets an arcade silhouette')
   local star=assert(m:FindFirstChild('ArcadeImpactStar',true))
   local core=assert(m:FindFirstChild('ArcadeImpactCore',true))
   check(not m:FindFirstChild('ImpactFlare',true),'soft physical halo does not wash out the star')
   local facing=(camera.CFrame.Position-at).Unit
   local maxSize=0
   for _,p in ipairs(m:GetDescendants())do if p.Name=='ArcadeImpactStar'or p.Name=='ArcadeImpactCore'then
    check(p:IsA('WedgePart')and p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,'contact is visual only')
    check(math.abs(p.CFrame.RightVector:Dot(facing))>.999,'star remains readable from each camera angle')
    maxSize=math.max(maxSize,(p.Position-at).Magnitude+p.Size.Magnitude*.5)
   end end
   check(maxSize<3,'star is localized at the target')
   check(core.Material==Enum.Material.Neon,'bright centre is independent of scene illumination')
   Hero.step(now+.15)
   check(star.Transparency==1 and core.Transparency==1,'contact is gone before the next combo beat')
   Hero.step(now+1);local a,b,c,d,e,f=Hero.count()
   check(a+b+c+d+e+f==0 and m.Parent==nil,'all geometry and budgets return after expiry')
  end
 end
 camera.CFrame=CFrame.lookAt(at+Vector3.new(0,8,16),at)
 for _,id in ipairs({'knight_crescent_cut','dwarf.common.overhead'})do
  Hero.clear();local now=workspace:GetServerTimeNow()
  local m=assert(Hero.skill(nil,id,at,at+direction*6,1,{}))
  local edge=m:FindFirstChild('BladeCuttingEdge',true)or m:FindFirstChild('CleaveCuttingEdge',true)
  check(edge~=nil,'cut has a separate bright cutting edge '..id)
  Hero.step(now+.24);check(edge.Transparency==1,'cutting edge does not linger through recovery')
 end
 Hero.clear()
 local Hits=require(game.StarterPlayer.StarterPlayerScripts.Client.K0HitEffects)
 for _,classId in ipairs({'knight','dwarf','elf'})do
  check(Hits.show(nil,at,75,classId,'Goblin',direction),'confirmed hit entry accepts '..classId)
  local holder
  for _,node in ipairs(workspace:GetChildren())do if node.Name=='K0HitEffect'then holder=node end end
  check(holder~=nil and holder.K0DamageNumber.Amount.Text=='75','server-confirmed amount is preserved')
  check(not holder:FindFirstChild('K0ContactRay')and not holder:FindFirstChild('K0ImpactStreak'),'sharp contact replaces duplicate physical rays')
  local sparks=0
  for _,p in ipairs(holder:GetChildren())do if p.Name=='K0ImpactSpark'then
   sparks+=1;check(p.CFrame.LookVector:Dot(direction)>.5,'sparks carry the confirmed attack direction')
  end end
  check(sparks==3,'directional fan keeps the existing three-spark budget')
  holder:Destroy();Hero.clear()
 end
 for i=1,50 do Hero.contact(at,i%2==0 and'knight'or'dwarf',nil,direction,1)end
 local n,b,c,g,p,f=Hero.count()
 check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'crowded impacts obey existing global budgets')
 Hero.clear();check(select(6,Hero.count())==0,'clear releases the surface budget')
end,debug.traceback)
Hero.clear();camera.CFrame=old
if not ok then report.failures[1]=err end
report.pass=ok;print('ARCADE_IMPACT_VFX_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
