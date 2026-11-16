-- Same world coordinates/camera for each before/after. Frozen engine geometry, not live player QA.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local after=require(Client.HeroVFX);local before=require(Client.HeroVFXBefore)
local afterVisual=require(Client.AdvancedSkillVisual);local beforeVisual=require(Client.AdvancedSkillVisualBefore)
local Pixel=require(Client.PixelFX)
local PixelBefore=require(Client.PixelFXBefore)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local defs={};for _,list in pairs(Config.Skills)do for _,d in ipairs(list)do defs[d.id]=d end end
if not game.RunService:IsRunning()then game.RunService:Run()end
task.wait(.3)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=42
local oldCamera=camera.CFrame
local floor=Instance.new('Part');floor.Name='ArtReviewGround';floor.Size=Vector3.new(180,.5,180);floor.Anchored=true;floor.Position=Vector3.new(0,-.25,0);floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(47,54,65);floor.Parent=workspace
local actor=Instance.new('Model');actor.Name='ArtReviewActor';actor.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(1.5,2,1);root.Position=Vector3.new(0,3,1);root.Color=Color3.fromRGB(113,128,145);root.Anchored=true;root.CanCollide=false;root.Parent=actor
local head=Instance.new('Part');head.Shape=Enum.PartType.Ball;head.Size=Vector3.one;head.Position=Vector3.new(0,4.5,1);head.Color=root.Color;head.Anchored=true;head.CanCollide=false;head.Parent=actor
actor:SetAttribute('K0State','Attack')
local samples={
 'mage.pyro.molten_line','mage.common.water_ball','mage.common.gravity','mage.pyro.steam_burst',
 'mage.cryo.frost_lance','mage.cryo.ice_shard','mage.cryo.shatter_dart','mage.cryo.glacial_spike',
 'mage.pyro.ember_lance','mage.pyro.flame_dart','mage.pyro.magma_spear','mage.pyro.stone_lance',
 'mage.cryo.ice_ward','mage.cryo.froststorm','mage.cryo.thunder_spear','mage.cryo.lightning_line',
 'dwarf.iron_axe.returning_echo','dwarf.iron_axe.iron_shoulder','elf.magic_archer.bloom_shot',
 'elf.magic_archer.vine_trap','elf.magic_archer.vine_burst','mage.pyro.earth_rise','knight.common.provoke',
 'mage.pyro.searing_ward','elf.marksman.grand_volley','elf.magic_archer.spirit_arrowfall',
 'mage.pyro.caldera_s_judgment','mage.cryo.eternal_tempest',
}
if _G.ArtReviewSamples then samples=_G.ArtReviewSamples end
local times=_G.ArtReviewTimes or {.06,.18}
local sampleIndex=0
for _,id in ipairs(samples)do for _,age in ipairs(times)do
 sampleIndex+=1
 local d=assert(defs[id]);local origin=Vector3.new(0,3,0)
 local center=(d.form=='area'or d.form=='self')and origin or Vector3.new(0,3,-math.min(d.range,10))
 local ground=d.form=='ground'
 local focus=ground and Vector3.new(center.X,1.6,center.Z)or (origin+center)*.5
 -- Same fixed scale for related projectiles; ultimates get a separate game-distance framing.
 local extent=d.ultimate and 19 or ground and 13 or d.form=='area' and 13 or 11
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(extent*.8,extent*.7,extent),focus)
 game.Lighting.ClockTime=sampleIndex%2==0 and 0 or 12
 game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(90,98,115)
 -- Warm material/lighting before either variant, while no live VFX can expire.
 task.wait(sampleIndex==1 and 1.5 or .2)
 actor:SetAttribute('K0ClassId',id:match('^(%a+)'));actor:SetAttribute('K0SkillId',id)
 for variant,fx in ipairs({before,after})do
  before.clear();after.clear();Pixel.clear();PixelBefore.clear()
  local oldNodes={};for _,node in ipairs(workspace:GetChildren())do oldNodes[node]=true end
  local now=workspace:GetServerTimeNow();local pulse=_G.ArtReviewPulse or 1
  local points={center,center+Vector3.new(3,0,-2)}
  if d.advanced then
   local visual=variant==1 and beforeVisual or afterVisual
   visual.play(actor,id,origin,center,pulse,points,nil,now,now-d.windup)
  else fx.skill(actor,id,origin,center,pulse,points)end
  fx.step(now+age);(variant==1 and PixelBefore or Pixel).step(age)
  -- Freeze before yielding: engine capture latency can exceed short VFX lifetimes.
  assert(workspace:FindFirstChild('HeroVFX'),'primary expired before snapshot '..id)
  local snapshot=Instance.new('Folder');snapshot.Name='ArtReviewFrozen';local originals={}
  for _,node in ipairs(workspace:GetChildren())do if not oldNodes[node]then
   table.insert(originals,node);local copy=node:Clone();copy.Parent=snapshot
  end end
  before.clear();after.clear();Pixel.clear();PixelBefore.clear()
  for _,node in ipairs(originals)do if node.Parent then node:Destroy()end end
  snapshot.Parent=workspace
  for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ParticleEmitter')then
   node:Clear();node:Emit(node:GetAttribute('ReviewBurstCount')or 0)
  end end
  task.wait(.1)
  local done=false;local captured=false
  game:GetService('CaptureService'):CaptureScreenshot(function(uri)
   local ok,err=pcall(function()
    local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(uri))
    local pixels=img:ReadPixelsBuffer(Vector2.zero,img.Size);local w,h=480,320;local chunks={}
    for y=0,h-1 do for x=0,w-1 do
     local offset=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
     for channel=0,2 do chunks[#chunks+1]=string.format('%02x',buffer.readu8(pixels,offset+channel))end
    end end
    local hex=table.concat(chunks)
    print('ART_META '..game.HttpService:JSONEncode({index=sampleIndex,id=id,name=d.name,variant=variant,age=age,pulse=pulse,clockTime=game.Lighting.ClockTime,extent=extent,width=w,height=h}))
    for i=1,#hex,20000 do print('ART_RGB '..sampleIndex..' '..variant..' '..hex:sub(i,i+19999))end
    img:Destroy();captured=true
   end)
   if not ok then print('ART_CAPTURE_ERROR '..id..' '..tostring(err))end
   done=true
  end)
  local deadline=os.clock()+10;while not done and os.clock()<deadline do task.wait(.05)end
  assert(captured,'capture failed '..id);snapshot:Destroy()
 end
end end
actor:Destroy();floor:Destroy();camera.CFrame=oldCamera
print('ART_CAPTURE_COMPLETE '..sampleIndex)
