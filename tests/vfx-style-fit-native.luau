-- World-space form and visual hierarchy, in actual engine instances.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Pixel=require(Client.PixelFX)
local Hero=require(Client.HeroVFX)
local Curated=require(Client.CuratedVFX)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local floor=Instance.new('Part');floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Parent=workspace
local from=Vector3.new(0,3,0);local target=Vector3.new(0,3,-6)
local char=Instance.new('Model');char.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=from;root.Anchored=true;root.Parent=char
char:SetAttribute('K0State','Attack');char:SetAttribute('K0AttackSeq',9100)
local ok,err=xpcall(function()
 Pixel.clear();Hero.clear()
 local m=assert(Hero.skill(char,'mage.cryo.frost_ring',from,from,1,{}))
 check(not m:FindFirstChild('ElementalSurface',true),'Frost Ring has no solid pool disc')
 local facets={}
 for _,p in ipairs(m:GetDescendants())do if p.Name=='FrostRimFacet'then
  table.insert(facets,{part=p,cf=p.CFrame})
  check(p:IsA('WedgePart')and p.Material==Enum.Material.Ice,'ice rim uses faceted solid forms')
  check(p.Position.Y<.6 and not p.CanCollide and not p.CanTouch and not p.CanQuery,'grounded cosmetic rim')
 end end
 check(#facets==8,'eight separated ice facets leave the middle readable')
 Pixel.skill(char,'mage.cryo.frost_ring',from,from,1,{},9100,workspace:GetServerTimeNow())
 local accent
 for _,p in ipairs(workspace:GetChildren())do if p:GetAttribute('CuratedVFXKey')=='frost'then accent=p end end
 check(accent and not accent:FindFirstChildWhichIsA('BillboardGui',true),'Frost Ring has no camera-facing ground image')
 check(Curated.count()==8,'ice glints bounded')
 for _,cf in ipairs({CFrame.new(0,3,12),CFrame.new(12,8,0),CFrame.new(0,18,.1)})do
  camera.CFrame=cf
  for _,entry in ipairs(facets)do check(entry.part.CFrame==entry.cf,'camera movement cannot rotate the ice rim')end
 end
 Pixel.clear();Hero.clear();camera.CFrame=CFrame.new(0,8,12)
 m=assert(Hero.skill(char,'dwarf.gunner.bomb_toss',from,target,1,{}))
 check(not m:FindFirstChild('BlastVolume',true)and not m:FindFirstChild('BlastCore',true),'Bomb Toss does not leave large spherical shells')
 local flash=assert(m:FindFirstChild('BombContactFlash',true));check(flash.Size.X<=.61,'small contact flash')
 local fragments={}
 for _,p in ipairs(m:GetDescendants())do if p.Name=='BombCasingFragment'then table.insert(fragments,{part=p,at=p.Position})end end
 check(#fragments==5,'five bounded casing fragments')
 Hero.step(workspace:GetServerTimeNow()+.1)
 check(flash.Transparency==1,'contact flash gone by 100ms')
 for _,entry in ipairs(fragments)do check((entry.part.Position-entry.at).Magnitude>.2,'casing moves outward after contact')end
 Hero.clear()
 local control=assert(Hero.skill(char,'dwarf.gunner.shell_burst',from,target,1,{}))
 check(control:FindFirstChild('BlastVolume',true)~=nil,'other explosion skills retain their authored surface')
 Hero.clear();Pixel.support(char,'Heal')
 local plus
 for _,p in ipairs(workspace:GetChildren())do if p:GetAttribute('CuratedVFXKey')=='heal'then plus=p:FindFirstChild('Plus',true)end end
 check(plus~=nil and plus:GetAttribute('ReviewBurstCount')==2,'only two small healing crosses')
 local maxSize=0;for _,key in ipairs(plus.Size.Keypoints)do maxSize=math.max(maxSize,key.Value+key.Envelope)end
 check(maxSize<=.21 and plus.LightEmission<=.25,'healing sign stays small and mint')
 check(Curated.count()==12,'healing particle reservation reduced')
 Pixel.clear();check(Curated.count()==0,'style changes release every reservation')
end,debug.traceback)
Pixel.clear();Hero.clear();char:Destroy();floor:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=ok
print('VFX_STYLE_FIT_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
