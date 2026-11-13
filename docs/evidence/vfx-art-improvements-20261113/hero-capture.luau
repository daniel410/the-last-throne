assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
_G.SkillVFXReviewIds={["dwarf.common.overhead"]=true,["dwarf.gunner.field_mortar"]=true,["dwarf.gunner.scatter_shot"]=true,["dwarf.gunner.shell_burst"]=true,["dwarf.gunner.siege_barrage"]=true,["dwarf.gunner.siege_pattern"]=true,["dwarf.iron_axe.armor_splitter"]=true,["dwarf.iron_axe.crag_cleave"]=true,["dwarf.iron_axe.mountain_collapse"]=true,["dwarf.iron_axe.mountain_strike"]=true,["dwarf.iron_axe.mountain_sweep"]=true,["dwarf.iron_axe.shatter_blow"]=true,["dwarf.iron_axe.stonebound_leap"]=true,["dwarf.iron_axe.tremor_guard"]=true,["dwarf_hooking_chop"]=true,["dwarf_low_sweep"]=true,["elf.magic_archer.rooting_fan"]=true,["elf.magic_archer.spirit_arrowfall"]=true,["elf.magic_archer.vine_burst"]=true,["elf.magic_archer.vine_trap"]=true,["elf.marksman.grand_volley"]=true,["knight.paladin.oath_challenge"]=true,["knight.paladin.oath_of_dawn"]=true,["knight.paladin.radiant_sweep"]=true,["knight.steel_knight.steel_sweep"]=true,["knight.steel_knight.unyielding_front"]=true,["knight.steel_knight.warcry_assault"]=true,["knight_crescent_cut"]=true,["mage.cryo.eternal_tempest"]=true,["mage.pyro.caldera_s_judgment"]=true,["mage.pyro.cinder_ring"]=true,["mage.pyro.ember_step"]=true,["mage.pyro.lava_eruption"]=true,["mage.pyro.searing_ward"]=true,["mage.pyro.steam_burst"]=true}
-- Local, frozen production VFX samples. Not a gameplay/motion acceptance test.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
-- Run the isolated fixture so burst particles advance through engine frames.
if not game:GetService('RunService'):IsRunning()then game:GetService('RunService'):Run()end
task.wait(1)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)
local Wind=require(Client.WindLanceVisual)
local Pixel=require(Client.PixelFX)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=48
local lighting=game.Lighting;lighting.ClockTime=12;lighting.Brightness=2;lighting.Ambient=Color3.fromRGB(150,153,165)
local stage=Instance.new('Folder');stage.Name='VFXReviewStage';stage.Parent=workspace
local floor=Instance.new('Part');floor.Name='ReviewFloor';floor.Size=Vector3.new(150,.5,150);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Color=Color3.fromRGB(44,53,63);floor.Material=Enum.Material.Slate;floor.Parent=stage
local char=Instance.new('Model');char.Name='VFXReviewActor';char.Parent=stage
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.Size=Vector3.new(1.4,2,1);root.Position=Vector3.new(0,3,0);root.Color=Color3.fromRGB(125,135,148);root.Parent=char
local head=Instance.new('Part');head.Anchored=true;head.CanCollide=false;head.Shape=Enum.PartType.Ball;head.Size=Vector3.one;head.Position=Vector3.new(0,4.5,0);head.Color=root.Color;head.Parent=char
char:SetAttribute('K0State','Attack')
local index=0
local lastOnly=_G.SkillVFXReviewLastPulse==true
local captured=0
for _,classId in ipairs({'knight','dwarf','elf','mage'})do for _,d in ipairs(Config.Skills[classId])do
 index+=1
 local pulse=lastOnly and(d.pulses or d.shotCount or 1)or 1
 if lastOnly and pulse<=1 then continue end
 if _G.SkillVFXReviewIds and not _G.SkillVFXReviewIds[d.id]then continue end
 captured+=1
 local origin=Vector3.new(0,3,0)
 local center=(d.form=='area'or d.form=='self')and origin or Vector3.new(0,3,-math.min(d.range,12))
 local extent=d.form=='ground'and math.max(d.radius*1.2,10)or d.form=='cone'and math.min(d.range,45)*.8 or d.form=='area'and math.max(d.range*1.3,10)or 11
 local focus=(d.form=='ground')and center or (origin+center)*.5
 if d.effect=='provoke'then focus=origin;extent=d.range*1.3 end
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(extent*.85,extent*1.15,extent*1.25),focus)
 char:SetAttribute('K0ClassId',classId);char:SetAttribute('K0SkillId',d.id)
 task.wait(.12)
 local before={};for _,node in ipairs(workspace:GetChildren())do before[node]=true end
 local points=d.form=='chain'and{center,center+Vector3.new(3,0,-2),center+Vector3.new(-2,0,-4)}or{}
 if d.id=="elf.common.multi"then points=require(Client.SkillEffectGeometry).sector(origin,Vector3.new(0,0,-1),12,70,4)end
 local targetGuides=Instance.new('Folder');targetGuides.Name='TargetGuides';targetGuides.Parent=stage
 for _,at in ipairs(points)do local guide=Instance.new('Part');guide.Name='SyntheticTargetGuide';guide.Anchored=true;guide.CanCollide=false;guide.CanQuery=false;guide.Color=Color3.fromRGB(120,130,140);guide.Size=Vector3.new(1,2,1);guide.Position=at;guide.Transparency=.4;guide.Parent=targetGuides end
 local now=workspace:GetServerTimeNow()
 if d.advanced then Visual.play(char,d.id,origin,center,pulse,points,nil,now,now-d.windup)
 else FX.skill(char,d.id,origin,center,pulse,points)end
 local sampleAge=.10
 FX.step(now+sampleAge);Wind.step(now+sampleAge);Pixel.step(sampleAge)
 -- Snapshot before yielding so short lightning survives scheduler delays.
 local originals={};local clones={}
 for _,node in ipairs(workspace:GetChildren())do if not before[node]then
  table.insert(originals,node);local clone=node:Clone();table.insert(clones,clone)
 end end
 FX.clear();Wind.clear();Pixel.clear()
 for _,node in ipairs(originals)do node:Destroy()end
 local snapshot=Instance.new('Folder');snapshot.Name='FrozenSkillVFX';snapshot.Parent=workspace
 for _,node in ipairs(clones)do node.Parent=snapshot end
 -- Cloning instances does not clone live particles. Recreate the same burst
 -- and let the engine advance normally.
 for _,node in ipairs(snapshot:GetDescendants())do
  if node:IsA("ParticleEmitter")then
   node:Clear();node:Emit(node:GetAttribute("ReviewBurstCount")or 0)
  end
 end
 task.wait(.08)
 for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ParticleEmitter')then node.TimeScale=0 end end
 local done=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pix=img:ReadPixelsBuffer(Vector2.zero,img.Size);local hex={};local w,h=320,240
   for y=0,h-1 do for x=0,w-1 do
    local at=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
    for channel=0,2 do hex[#hex+1]=string.format('%02x',buffer.readu8(pix,at+channel))end
   end end
   local data=table.concat(hex)
   local diagnostics={parts=0,beams=0,images={}}
   for _,node in ipairs(snapshot:GetDescendants())do
    if node:IsA('BasePart')then diagnostics.parts+=1 elseif node:IsA('Beam')then diagnostics.beams+=1 elseif node:IsA('ImageLabel')then diagnostics.images[#diagnostics.images+1]={name=node.Name,image=node.Image,loaded=node.IsLoaded,rect=tostring(node.ImageRectOffset),size=tostring(node.ImageRectSize),transparency=node.ImageTransparency,visible=node.Visible}end
   end
   print('VFX_META '..game.HttpService:JSONEncode({index=index,id=d.id,name=d.name,classId=classId,pulse=pulse,width=w,height=h,sampleAge=sampleAge,diagnostics=diagnostics}))
   for i=1,#data,20000 do print('VFX_RGB '..index..' '..data:sub(i,i+19999))end
   img:Destroy()
  end)
  if not ok then print('VFX_CAPTURE_ERROR',index,err)end
  done=true
 end)
 local timeout=os.clock()+8;while not done and os.clock()<timeout do task.wait(.05)end
 assert(done,'capture timed out '..d.id)
 snapshot:Destroy();targetGuides:Destroy()
end end
stage:Destroy();print('VFX_CAPTURE_COMPLETE',captured)
