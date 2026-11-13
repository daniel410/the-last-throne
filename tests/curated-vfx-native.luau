-- Actual imported emitters and production event path, in an isolated local Place.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.PixelFX)
local Curated=require(Client.CuratedVFX)
local Visual=require(Client.AdvancedSkillVisual)
local report={checks=0,failures={},assets={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,7,12)
local stage=Instance.new('Folder');stage.Name='CuratedQA';stage.Parent=workspace
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(100,1,100);floor.Position=Vector3.new(0,-.5,0);floor.Parent=stage
local char=Instance.new('Model');char.Parent=stage
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.new(0,3,0);root.Anchored=true;root.Parent=char
local human=Instance.new('Humanoid');human.Parent=char
char:SetAttribute('K0State','Attack');char:SetAttribute('K0AttackSeq',9001)
local function current(key)
 for _,p in ipairs(workspace:GetChildren())do if p:GetAttribute('CuratedVFXKey')==key then return p end end
end
local function inspect(key,count)
 local holder=current(key);check(holder~=nil,key..' created')
 check(not holder.CanCollide and not holder.CanTouch and not holder.CanQuery,key..' presentation only')
 check(not holder:FindFirstChild('PixelFXSprite'),key..' no duplicate pixel layer')
 local emitters=0;local particles=0
 for _,e in ipairs(holder:GetDescendants())do
  if e:IsA('ParticleEmitter')then
   emitters+=1;particles+=e:GetAttribute('ReviewBurstCount')
   check(not e.Enabled and e.Rate==0,key..' burst only')
   check(e.ZOffset==0,key..' normal occlusion')
   check(e.Lifetime.Max<=1.25,key..' bounded lifetime')
   report.assets[e.Texture]=true
  end
  check(not e:IsA('LuaSourceContainer'),key..' no imported scripts')
 end
 local sprite=holder:FindFirstChild('CuratedSprite')
 if sprite then
  check(not sprite.AlwaysOnTop,'sprite world occlusion')
  check(sprite.Frame.ResampleMode==Enum.ResamplerMode.Default,'smooth source sampling')
  report.assets[sprite.Frame.Image]=true
 end
 check(particles+(sprite and 1 or 0)==count,key..' reservation matches burst or sprite')
 check(Curated.count()==count,key..' reserved count')
 return holder,emitters
end
local ok,err=xpcall(function()
 FX.clear();check(FX.support(char,'Heal'),'confirmed healing route')
 local holder,emitters=inspect('heal',16);check(emitters==4,'four source-derived healing emitters')
 local plus=holder:FindFirstChild('Plus',true);check(plus.Texture=='rbxassetid://9937082969','Yuruzuu plus texture')
 local at=holder.Position;root.Position+=Vector3.new(2,0,0);FX.step(.1)
 check(holder.Position==root.Position and holder.Position~=at,'heal follows recipient')
 FX.step(1.3);check(Curated.count()==0 and FX.count()==0,'expiry releases shared and particle reservations')
 local ids={['elf.magic_archer.spirit_rain']='spiritRain',['mage.cryo.frost_ring']='frost',['dwarf.gunner.bomb_toss']='blast'}
 for id,key in pairs(ids)do
  FX.clear();char:SetAttribute('K0AttackSeq',9002)
  local now=workspace:GetServerTimeNow()
  Visual.play(char,id,root.Position,Vector3.new(0,3,-5),1,{},9002,now,now-1)
  local cost=key=='spiritRain'and 15 or 1
  local p,n=inspect(key,cost)
  check(key~='spiritRain'or n==15,'five localized arrow contacts')
  if key~='spiritRain'then
   local sprite=p.CuratedSprite
   check(sprite.Frame.ImageRectSize==Vector2.new(128,128),'64-frame atlas cell size')
   FX.step(Curated.duration(key)*.5)
   check(sprite.Frame.ImageRectOffset==Vector2.new(0,512),'atlas reaches frame32 once')
  end
  check(math.abs(p.Position.Y-(key=='blast'and 1.72 or key=='frost'and 1.52 or .12))<.01,'ground-relative burst placement')
  Visual.play(char,id,root.Position,Vector3.new(0,3,-5),1,{},9002,now,now-1)
  check(FX.count()==1,'duplicate confirmed pulse suppressed')
  char:SetAttribute('K0State','Dodge');FX.step(.01)
  check(FX.count()==0 and Curated.count()==0,'action cancellation releases particles')
  char:SetAttribute('K0State','Attack')
 end
 FX.clear();check(FX.support(char,'Protect'),'protect unchanged');check(current('heal')==nil,'protect not healing');FX.clear()
 for _=1,30 do FX.support(char,'Heal')end
 check(FX.count()<=24 and Curated.count()<=(game.UserInputService.TouchEnabled and 96 or 192),'shared and particle limits')
 FX.clear();check(Curated.count()==0,'clear releases all reservations')
 check(FX.support(char,'Heal'),'repeat heal');human.Health=0;FX.step(.01)
 check(FX.count()==0 and Curated.count()==0,'death cleanup');human.Health=100
 check(FX.support(char,'Heal'),'stream-out candidate');root.Parent=nil;FX.step(.01)
 check(FX.count()==0 and Curated.count()==0,'recipient stream-out cleanup');root.Parent=char
 camera.CFrame=CFrame.new(1000,0,0)
 check(not FX.support(char,'Heal')and Curated.count()==0,'distant effects allocate nothing')
end,debug.traceback)
FX.clear();stage:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=ok
print('CURATED_VFX_NATIVE '..game.HttpService:JSONEncode(report))
assert(ok,err)
