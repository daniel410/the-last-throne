-- Repeatable Roblox RPG VFX comparison; frozen stills are not timing/device acceptance.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.PixelFX)
local Curated=require(Client.CuratedVFX)
local Visual=require(Client.AdvancedSkillVisual)
local Hero=require(Client.HeroVFX)
local Wind=require(Client.WindLanceVisual)
if not game.RunService:IsRunning()then game.RunService:Run()end
task.wait(.3)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=48
game.Lighting.ClockTime=12;game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(150,153,165)
local floor=Instance.new('Part');floor.Name='CuratedReviewFloor';floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Color=Color3.fromRGB(44,53,63);floor.Material=Enum.Material.Slate;floor.Parent=workspace
local char=Instance.new('Model');char.Name='CuratedReviewActor';char.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(1.4,2,1);root.Position=Vector3.new(0,3,0);root.Anchored=true;root.CanCollide=false;root.Color=Color3.fromRGB(125,135,148);root.Parent=char
local head=Instance.new('Part');head.Anchored=true;head.CanCollide=false;head.Shape=Enum.PartType.Ball;head.Size=Vector3.one;head.Position=Vector3.new(0,4.5,0);head.Color=root.Color;head.Parent=char
char:SetAttribute('K0State','Attack');char:SetAttribute('K0AttackSeq',8000)
local samples={{'mage.pyro.ember_lance','Fire',.14},{'mage_tidal_ring','Water',.14},{'mage_wind_lance','Wind',.14},{'mage.cryo.lightning_line','Lightning',.1},{'mage.cryo.frost_lance','Ice',.14},{'mage.pyro.earth_rise','Earth',.14},{'knight.paladin.shield_verdict','Holy Gold',.14},{'knight.paladin.dawn_burst','Holy Seal',.14},{'knight_crescent_cut','Blade Sweep',.14},{'dwarf.gunner.shell_burst','Shell Burst',.14},{'knight.paladin.oathblade','Holy Impact',.1,true}}
for index,row in ipairs(samples)do
 if _G.CuratedCaptureGroup and math.ceil(index/2)~=_G.CuratedCaptureGroup then continue end
 FX.clear();Hero.clear();Wind.clear()
 local center=(index==2 or index==8)and root.Position or root.Position+Vector3.new(0,0,-8)
 local focus=(root.Position+center)*.5-Vector3.new(0,1.2,0)
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(8,7,11),focus)
 task.wait(.1)
 char:SetAttribute('K0AttackSeq',8000+index)
 local before={};for _,node in ipairs(workspace:GetChildren())do before[node]=true end
 local now=workspace:GetServerTimeNow()
 if row[4]then Hero.contact(center,'knight',row[1],Vector3.new(0,0,-1),1)
 elseif index==9 then Hero.skill(char,row[1],root.Position,center,1,{})
 else Visual.play(char,row[1],root.Position,center,1,{},8000+index,now,now-1)end
 if index~=3 then assert(Hero.count()==1,'production event reaches school geometry')end
 task.wait(row[3])
 FX.step(row[3]);Hero.step(now+row[3]);Wind.step(now+row[3])
 -- Freeze the generated instances while UI images finish decoding. This is a
 -- still-image review, not evidence of live animation timing or first-use latency.
 local originals={};local clones={}
 for _,node in ipairs(workspace:GetChildren())do if not before[node]then
  table.insert(originals,node);table.insert(clones,node:Clone())
 end end
 FX.clear();Hero.clear();Wind.clear()
 for _,node in ipairs(originals)do node:Destroy()end
 local snapshot=Instance.new('Folder');snapshot.Name='CuratedReviewSnapshot';snapshot.Parent=workspace
 for _,node in ipairs(clones)do node.Parent=snapshot end
 local imageDeadline=os.clock()+5
 local function imagesReady()
  for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ImageLabel')and not node.IsLoaded then return false end end
  return true
 end
 while not imagesReady()and os.clock()<imageDeadline do task.wait(.05)end
 for _,node in ipairs(snapshot:GetDescendants())do
  if node:IsA('BillboardGui')and node.Name=='CuratedSprite'then Curated.step({sprite=node,duration=Curated.duration(index==3 and'frost'or'blast')},row[3])end
  if node:IsA('ParticleEmitter')then node:Clear();node:Emit(node:GetAttribute('ReviewBurstCount')or 0)end
 end
 task.wait(index==1 and .22 or .07)
 for _,node in ipairs(snapshot:GetDescendants())do if node:IsA('ParticleEmitter')then node.TimeScale=0 end end
 local diagnostics={}
 for _,holder in ipairs(snapshot:GetChildren())do if holder:GetAttribute('CuratedVFXKey')then
  local gui=holder:FindFirstChild('CuratedSprite')
  table.insert(diagnostics,{key=holder:GetAttribute('CuratedVFXKey'),position=tostring(holder.Position),image=gui and gui.Frame.Image,loaded=gui and gui.Frame.IsLoaded,frame=gui and tostring(gui.Frame.ImageRectOffset)})
 end end
 print('CURATED_RENDER_STATE '..game.HttpService:JSONEncode(diagnostics))
 local captured=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pix=img:ReadPixelsBuffer(Vector2.zero,img.Size);local hex={};local w,h=320,240
   for y=0,h-1 do for x=0,w-1 do
    local offset=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
    for channel=0,2 do hex[#hex+1]=string.format('%02x',buffer.readu8(pix,offset+channel))end
   end end
   local data=table.concat(hex)
   print('CURATED_META '..game.HttpService:JSONEncode({index=index,id=row[1],name=row[2],width=w,height=h}))
   for i=1,#data,20000 do print('CURATED_RGB '..index..' '..data:sub(i,i+19999))end
   img:Destroy()
  end)
  if not ok then print('CURATED_CAPTURE_ERROR '..tostring(err))end
  captured=true
 end)
 local timeout=os.clock()+8;while not captured and os.clock()<timeout do task.wait(.05)end
 assert(captured,'capture timeout')
 snapshot:Destroy()
end
FX.clear();Hero.clear();Wind.clear();char:Destroy();floor:Destroy()
print('CURATED_CAPTURE_COMPLETE')
