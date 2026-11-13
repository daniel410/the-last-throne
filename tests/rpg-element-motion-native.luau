-- Verify readable element motion and confirmed endpoints in the real engine.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Hero=require(game.StarterPlayer.StarterPlayerScripts.Client.HeroVFX)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Parent=workspace
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-8)
local function cast(id,points)
 Hero.clear();return assert(Hero.skill(nil,id,first,last,1,points or{}))
end
local ok,err=xpcall(function()
 local points={last,last+Vector3.new(3,0,-2),last+Vector3.new(-1,0,-5)}
 local chain=cast('mage.cryo.chain_lightning',points)
 local mains,forks={},{}
 for _,v in ipairs(chain:GetDescendants())do if v:IsA('Beam')then
  if v.Name=='ElectricCore'then mains[#mains+1]=v elseif v.Name=='ElectricFork'then forks[#forks+1]=v end
 end end
 check(#mains==18 and #forks==18,'three confirmed chain links have bounded branched discharge')
 for i,target in ipairs(points)do
  check((mains[i*6].Attachment1.WorldPosition-target).Magnitude<.001,'chain ends at confirmed target '..i)
 end
 for i=1,#forks,2 do
  local origin=forks[i].Attachment0.WorldPosition;local joined=false
  for _,beam in ipairs(mains)do if (origin-beam.Attachment0.WorldPosition).Magnitude<.001 or(origin-beam.Attachment1.WorldPosition).Magnitude<.001 then joined=true end end
  check(joined,'fork starts on the actual zigzag rather than a detached center line')
  check((forks[i].Attachment1.WorldPosition-forks[i+1].Attachment0.WorldPosition).Magnitude<.001,'fork segments remain joined')
 end
 local now=workspace:GetServerTimeNow();Hero.step(now+.17)
 for _,v in ipairs(chain:GetDescendants())do if v:IsA('BasePart')and v.Name=='LightningBranch'then check(v.Transparency==1,'electric fork fades by 170ms')end end
 local empty=cast('mage.cryo.chain_lightning',{})
 check(not empty:FindFirstChild('ElectricCore',true)and not empty:FindFirstChild('LightningBranch',true),'empty chain cannot invent a target')
 local ring=cast('mage.cryo.frost_ring');local ice=assert(ring:FindFirstChild('FrostRimFacet',true))
 local base=(ice.CFrame*CFrame.new(0,-ice.Size.Y*.5,0)).Position;local early=ice.Size.Y
 now=workspace:GetServerTimeNow();Hero.step(now+.09);local mid=ice.Size.Y
 Hero.step(now+.21)
 check(early<mid and mid<ice.Size.Y,'ice visibly grows into a tall crystal')
 check((base-(ice.CFrame*CFrame.new(0,-ice.Size.Y*.5,0)).Position).Magnitude<.001,'growing crystal stays planted at its base')
 check(ice.Size.Y>ice.Size.X*1.5 and ice.Material==Enum.Material.Ice,'crystal is faceted upright ice rather than a water tile')
 check(not ring:FindFirstChild('ElementalSurface',true),'frost retains an open center')
 local lance=cast('mage.cryo.frost_lance');check(lance:FindFirstChild('IceLanceFacet',true)~=nil,'ice lance has layered hard facets')
 for _,row in ipairs({{'mage.cryo.hailfall','HailDescent'},{'elf.marksman.arrow_rain','ArrowRain'},{'elf.magic_archer.spirit_rain','ArrowRain'}})do
  local m=cast(row[1]);local shard=assert(m:FindFirstChild('FallingShardVolume',true));local beam=assert(m:FindFirstChild(row[2],true))
  local height=shard.Position.Y;now=workspace:GetServerTimeNow();Hero.step(now+.12)
  check(shard.Position.Y<height-.3,'falling body actually descends '..row[1])
  check(math.abs(shard.Position.Y-(beam.Attachment0.WorldPosition.Y+beam.Attachment1.WorldPosition.Y)*.5)<.01,'body and wake share one trajectory '..row[1])
  check(shard.CFrame.UpVector.Y<-.9,'falling tip faces down '..row[1])
  local position=shard.Position;Hero.step(now+.04);Hero.step(now+.12)
  check((position-shard.Position).Magnitude<.001,'descent is independent of frame history '..row[1])
 end
 Hero.clear()
 for i=1,40 do Hero.skill(nil,i%2==0 and'mage.cryo.chain_lightning'or'mage.cryo.eternal_tempest',first,last,1,points)end
 local n,b,c,g,p,f=Hero.count();check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'crowded elemental casts keep every budget')
 Hero.clear();local a,b2,c2,g2,p2,f2=Hero.count();check(a+b2+c2+g2+p2+f2==0,'all elemental resources released')
end,debug.traceback)
Hero.clear();floor:Destroy();camera.CFrame=old
if not ok then report.failures[#report.failures+1]=err end
report.pass=ok;print('RPG_ELEMENT_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
