assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local C=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(C.HeroVFX);local Enemy=require(C.EnemySpellVFX)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local old=workspace.CurrentCamera.CFrame;workspace.CurrentCamera.CFrame=CFrame.new(0,12,18)
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-8)
local ok,err=xpcall(function()
 for _,row in ipairs({{'radiant_sweep','RadiantFan','RadiantOpeningFan'},{'guardian_slash','GuardianWing','GuardianShelteringWing'},{'oathbound_assault','OathboundAdvance','OathboundForwardCut'}})do
  for pulse=1,3 do
   FX.clear();local m=assert(FX.skill(nil,'knight.paladin.'..row[1],first,last,pulse,{}))
   check(m:GetAttribute('HolyMotion')==row[2] and m:FindFirstChild(row[3],true),'distinct holy main silhouette '..row[1])
   if row[1]=='oathbound_assault'then
    local count=0;for _,v in ipairs(m:GetDescendants())do if v.Name=='OathboundForwardCut'then count+=1 end end
    check(count==5,'one five-span slash per confirmed pulse, never a fabricated triple hit')
   end
  end
 end
 local Pixel=require(C.PixelFX);Pixel.clear()
 check(Pixel.skill(nil,'knight.paladin.oathbound_assault',first,last,1,{}),'oath contact accent resolves')
 Pixel.step(.15);check(Pixel.count()==0,'oath contact sparkle clears before the next short slash');Pixel.clear()
 FX.clear();local m=assert(FX.skill(nil,'mage.cryo.frost_lance',first,last,1,{}))
 local p=assert(m:FindFirstChild('IceLanceLuminousSpine',true))
 check(p.Material==Enum.Material.Neon and p.Size.X<.1,'small colored spine preserves dark-scene crystal readability')
 FX.clear();m=assert(FX.skill(nil,'knight.common.whirlwind',first,last,1,{}))
 local b=assert(m:FindFirstChild('BladeRibbon',true))
 check(b.Texture==''and m:FindFirstChild('SoftGlow',true).Texture=='rbxassetid://8196169974','continuous cutting edge is separate from the approved textured wake')
 FX.clear();m=assert(FX.skill(nil,'mage.pyro.caldera_s_judgment',first,last,1,{}))
 local plume=assert(m:FindFirstChild('CalderaCentralPlume',true))
 local gui=assert(plume:FindFirstChildOfClass('BillboardGui'))
 check(not gui.AlwaysOnTop and gui.MaxDistance==100,'organic flame obeys world depth and culling')
 check(gui.FlowingMaterial.Image=='rbxassetid://125374985892345'and gui.FlowingMaterial.ImageRectSize==Vector2.new(96,96),'approved animated flame atlas replaces a solid central plate')
 FX.clear();local P=require(game.ReplicatedStorage.Shared.EnemyPatterns)
 local r=assert(Enemy.projectile(P.get('IceElf').attacks[1],nil,nil,first,-Vector3.zAxis,workspace:GetServerTimeNow()))
 check(r.parts[1].part.Material==Enum.Material.Glass,'enemy ice keeps translucent facets')
 check(r.model:FindFirstChild('IceLuminousVein',true).Material==Enum.Material.Neon,'bounded ice vein is separately emissive')
 Enemy.clear();FX.clear();check(FX.count()==0 and Enemy.count()==0,'all new layers use normal cleanup')
end,debug.traceback)
FX.clear();Enemy.clear();workspace.CurrentCamera.CFrame=old
if not ok then report.failures[1]=err end
report.pass=ok;print('RPG_VFX_GAP_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
