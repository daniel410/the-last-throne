-- ART support revisions: actual engine geometry/flow, not gameplay or GPU acceptance.
assert(game.PlaceId==0 and game.GameId==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Pixel=require(Client.PixelFX)
local Curated=require(Client.CuratedVFX)
local Selene=require(Client.SelenePresentation)
local Navigation=require(Client.DeepwoodNavigation)
local report={checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local stage=Instance.new('Folder');stage.Name='SupportArtQA';stage.Parent=workspace
local function body(parent,name,position,size)
 local p=Instance.new('Part');p.Name=name;p.Position=position;p.Size=size or Vector3.new(1.4,2,1)
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
end
local char=Instance.new('Model');char.Name='Recipient';char.Parent=stage
local root=body(char,'HumanoidRootPart',Vector3.new(0,3,0))
local human=Instance.new('Humanoid');human.RequiresNeck=false;human.HipHeight=2;human.Parent=char
local npc=Instance.new('Model');npc.Name='SeleneFixture';npc.Parent=stage
local nr=body(npc,'HumanoidRootPart',Vector3.new(-4,3,0));npc.PrimaryPart=nr
local visual
for i,name in ipairs({'VisualRoot','ReviewHead','ReviewArmL','ReviewArmR'})do
 local offset=i==1 and Vector3.zero or i==2 and Vector3.new(0,1.3,0)or Vector3.new(i==3 and -1 or 1,.15,0)
 local p=body(npc,name,nr.Position+offset);p:SetAttribute('SeleneRest',CFrame.new(offset));if i==1 then visual=p end
end
for _,name in ipairs({'Root','Pelvis','Spine','Head','UpperL','ForearmL','HandL','UpperR','ForearmR','HandR','Lantern','LegL','FootL','LegR','FootR'})do
 local b=Instance.new('Bone');b.Name=name;if name=='HandL'then b.Position=Vector3.new(-1,.2,0)end;b.Parent=visual
end
local view=assert(Selene.bind(npc,function()return char end))
local function current(key)
 for _,p in ipairs(workspace:GetChildren())do if p:GetAttribute('CuratedVFXKey')==key then return p end end
end
local function radius(p)return(Vector3.new(p.Position.X,0,p.Position.Z)-Vector3.new(root.Position.X,0,root.Position.Z)).Magnitude end
local ok,err=xpcall(function()
 Pixel.clear();check(Pixel.support(char,'Heal'),'heal accent accepted')
 local holder=assert(current('heal'));local count=0
 for _,e in ipairs(holder:GetDescendants())do if e:IsA('ParticleEmitter')then count+=e:GetAttribute('ReviewBurstCount')end end
 check(count==12 and Curated.count()==12,'heal keeps the original 12-particle reservation')
 local shard=assert(holder:FindFirstChild('Shards',true));local plus=assert(holder:FindFirstChild('Plus',true))
 check(shard.Size.Keypoints[1].Value>0 and shard.Parent.Position.X<-.9 and shard.Parent.Position.Y<-1,'healing begins visible beside the body rather than hidden at its center')
 check(shard.EmissionDirection==Enum.NormalId.Top,'healing life flow rises')
 check(shard.Size.Keypoints[1].Value>=.3 and holder:FindFirstChild('ShardsBigger',true).Size.Keypoints[1].Value>=.3,'standalone healing has readable initial shards without increasing their peak')
 check(shard.Transparency.Keypoints[1].Value<=.05 and holder:FindFirstChild('Specs',true).Size.Keypoints[1].Value>0,'life accents begin visible and fade after the initial rise')
 local largest=0;for _,k in ipairs(plus.Size.Keypoints)do largest=math.max(largest,k.Value+k.Envelope)end
 check(plus:GetAttribute('ReviewBurstCount')==2 and largest<=.21,'no enlarged medical plus or extra crosses')
 root.Position+=Vector3.xAxis*2;Pixel.step(.1);check(holder.Position==root.Position,'heal follows the actual recipient')
 human.Health=0;Pixel.step(.01);check(Pixel.count()==0 and Curated.count()==0,'death releases healing accents');human.Health=100
 check(Pixel.support(char,'Cleanse'),'cleanse accent accepted')
 holder=assert(current('cleanse'));count=0
 check(not holder:FindFirstChild('PixelFXSprite'),'cleanse uses a directional wash rather than an early empty atlas card')
 for _,e in ipairs(holder:GetDescendants())do if e:IsA('ParticleEmitter')then
  count+=e:GetAttribute('ReviewBurstCount')
  check(e.Texture:find('rbxasset://',1,true)==1 and e.EmissionDirection==Enum.NormalId.Front,'cleanse wash uses engine-bundled outward dust')
  check(math.abs(e.Parent.CFrame.LookVector.Y)<.001 and not e.Enabled and e.Rate==0,'cleanse release stays horizontal and burst-only')
 end end
 check(count==12 and Curated.count()==12 and Curated.duration('cleanse')<Curated.duration('heal'),'cleanse is a short separate phase within shared particle caps')
 Pixel.step(.7);check(Pixel.count()==0 and Curated.count()==0,'short cleanse release expires')
 local health=human.Health
 for _,action in ipairs({'Heal','Protect','Cleanse'})do
  Pixel.clear();view:play(10,action,12,char);view:update(.016,10.1)
  local e=assert(view.effect);check(#e.ring==24,'support geometry keeps its original part allowance')
  local parts=0;for _,p in ipairs(e.folder:GetDescendants())do if p:IsA('BasePart')then
   parts+=1;check(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,'support detail has no hit authority')
  end end
  check(parts<=26,'support adds no extra geometry budget')
  if action=='Heal'then
   local stem=assert(e.folder:FindFirstChild('HealingLifeStem'));local y=stem.Position.Y
   check(not e.folder:FindFirstChild('BlessingRing')and not e.shield,'healing is an open life flow rather than the protective shell/ring')
   view:update(.016,10.4);check(stem.Position.Y>y+.5,'life cue actually rises beside the recipient')
  elseif action=='Cleanse'then
   local wash=assert(e.folder:FindFirstChild('CleanseSweep'));local rad,y=radius(wash),wash.Position.Y
   check(not e.folder:FindFirstChild('HealingLifeStem')and not e.shield,'cleansing uses a separate washing silhouette')
   view:update(.016,10.4);check(radius(wash)>rad+.5 and math.abs(wash.Position.Y-y)<.001,'removed-state cue moves outward rather than upward')
   view:update(.016,10.7);check(wash.Transparency==1,'cleanse strokes vanish before the result label')
  else
   check(e.shield and e.shield.Shape==Enum.PartType.Ball and e.shield.Material==Enum.Material.ForceField,'approved protection shell remains')
   check(e.folder:FindFirstChild('BlessingRing')~=nil,'protection keeps its existing ground ring')
  end
  check(e.label.Text==(action=='Heal'and'+12 HP'or action=='Protect'and'PROTECTED'or'CLEANSED'),'server-result wording unchanged')
  check(human.Health==health,'presentation cannot heal or remove gameplay state')
  view:update(.016,14);check(view.effect==nil,'all support geometry expires')
  check(not root:FindFirstChild('SeleneSupportRecipient')and not visual:FindFirstChild('SeleneHealingHand'),'support source/recipient attachments cleaned')
 end
 Pixel.clear();for i=1,40 do Pixel.support(char,i%2==0 and'Heal'or'Cleanse')end
 check(Pixel.count()<=24 and Curated.count()<=(game.UserInputService.TouchEnabled and 96 or 192),'mixed support respects shared record and particle caps')
 Pixel.clear();check(Curated.count()==0,'mixed support reservations return to zero')
 local arrow=Navigation.createChevron(stage)
 check(not arrow.GuideOverlay.AlwaysOnTop,'guidance obeys world depth instead of covering targets and danger')
 check(arrow.Anchored and not arrow.CanCollide and not arrow.CanQuery and arrow.GuideOverlay.Adornee==arrow,'occluded guide retains its nonphysical world geometry')
 check(arrow.Size==Vector3.new(.18,.09,1.65)and arrow.GuideOverlay.Size==arrow.Size,'visible route glyph is preserved')
end,debug.traceback)
view:destroy();Pixel.clear();stage:Destroy();camera.CFrame=old
if not ok then report.failures[#report.failures+1]=err end
report.pass=ok;print('VFX_ART_SUPPORT_FIXES_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
