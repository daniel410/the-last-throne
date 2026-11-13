assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
-- Actual authored attack warnings on an isolated walkable floor; no server gameplay.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')
for _,node in ipairs(game:GetDescendants())do if node:IsA('BaseScript')then node.Enabled=false end end
local baseplate=workspace:FindFirstChild('Baseplate');if baseplate then baseplate:Destroy()end
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run()end;task.wait(.2)
local Effects=require(game.StarterPlayer.StarterPlayerScripts.Client.EnemyPatternEffects)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local V=require(game.StarterPlayer.StarterPlayerScripts.Client.EnemySpellVFX)
local world=Instance.new('Folder');world.Name='DeepwoodK0';world.Parent=workspace
local floor=Instance.new('Part');floor.Name='Ground';floor.Size=Vector3.new(180,.5,180);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Color=Color3.fromRGB(43,51,59);floor.Material=Enum.Material.Slate;floor.Parent=world
local encoding=game:GetService('EncodingService')
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=45
local light=game.Lighting;light.ClockTime=14;light.Brightness=2;light.Ambient=Color3.fromRGB(150,155,165)
local samples={{'KingShaman',1},{'Veyr',4},{'Goblin',1},{'Ghoul',2},{'Orc',1},{'IceWolf',2},{'Slime',1},{'Shaman',2},{'Veyr',3},{'KingShaman',4},{'CalderaTitan',2},{'LavaSlime',2}}
local function capture(index,d)
 local done=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id));local raw=img:ReadPixelsBuffer(Vector2.zero,img.Size)
   local width=640;local height=math.floor(width*img.Size.Y/img.Size.X+.5);local rgb=buffer.create(width*height*3)
   for y=0,height-1 do for x=0,width-1 do local at=(math.floor(y/height*img.Size.Y)*img.Size.X+math.floor(x/width*img.Size.X))*4
    for c=0,2 do buffer.writeu8(rgb,(y*width+x)*3+c,buffer.readu8(raw,at+c))end
   end end
   print('ENEMY_WARNING_META '..game.HttpService:JSONEncode({index=index,id=d.id,shape=d.shape,blockable=d.blockable,width=width,height=height,normalized=false,windupFraction=.8,actualMap=false,encoding='zstd-hex'}))
   local compressed=encoding:CompressBuffer(rgb,Enum.CompressionAlgorithm.Zstd,9);local hex={}
   for i=0,buffer.len(compressed)-1 do hex[#hex+1]=string.format('%02x',buffer.readu8(compressed,i))end
   local data=table.concat(hex);for at=1,#data,20000 do print('ENEMY_WARNING_RGB '..index..' '..data:sub(at,at+19999))end
   img:Destroy()
  end)
  if not ok then print('ENEMY_WARNING_CAPTURE_ERROR '..tostring(err))end
  done=true
 end)
 local deadline=os.clock()+12;while not done and os.clock()<deadline do task.wait(.05)end;assert(done,'capture timeout')
end
for index,row in ipairs(samples)do
 local d=Patterns.get(row[1]).attacks[row[2]];local now=workspace:GetServerTimeNow();local sequence=12000+index
 local actor=Instance.new('Model');actor.Name='WarningCaster';local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(1.4,2,1);root.Position=Vector3.new(0,2,0);root.Anchored=true;root.Color=Color3.fromRGB(125,138,150);root.Parent=actor
 local head=Instance.new('Part');head.Name='Head';head.Size=Vector3.one;head.Position=Vector3.new(0,3.5,0);head.Anchored=true;head.Color=root.Color;head.Parent=actor
 local humanoid=Instance.new('Humanoid');humanoid.Health=100;humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;humanoid.Parent=actor;actor.Parent=world
 actor:SetAttribute('EnemyKind',row[1]);actor:SetAttribute('K0AttackSeq',sequence);actor:SetAttribute('K0PatternId',d.id)
 actor:SetAttribute('K0EnemyAttackClock',string.format('%d|%.6f|%.6f|%.6f|%.6f|%d',sequence,now,d.windup,d.active,d.recovery,d.heavy and 1 or 0))
 actor:SetAttribute('K0PatternOrigin',Vector3.new(0,2,0));actor:SetAttribute('K0PatternDirection',Vector3.new(0,0,-1));actor:SetAttribute('K0PatternAim',Vector3.new(0,2,-8))
 local center=Vector3.new(0,0,-8);local extent=12
 if d.shape=='ring'then center=Vector3.zero;extent=d.radius*1.8
 elseif d.shape=='cone'then center=Vector3.new(0,0,-d.range*.45);extent=math.max(12,d.range*1.2)
 elseif d.shape=='line'or d.shape=='projectile'then local length=d.motion=='dash'and d.dashDistance or d.range;center=Vector3.new(0,0,-length*.5);extent=math.max(12,length*.9)
 elseif d.shape=='trail'then extent=math.max(12,(d.radius*2+d.radius*2.5*(d.pulses-1))*.85)end
 camera.CFrame=CFrame.lookAt(center+Vector3.new(extent*.7,extent*.95,extent*1.15),center)
 Effects.observe(actor,now);Effects.render(now+d.windup*.8);task.wait(.1)
 local warning=assert(workspace:FindFirstChild('EnemyPatternWarning'),'warning geometry missing')
 assert(#warning:GetChildren()>0,'empty warning geometry');capture(index,d)
 Effects.receive({kind='cancel',model=actor,sequence=sequence});actor:Destroy();V.clear()
end
world:Destroy();camera.CFrame=old
print('ENEMY_WARNING_CAPTURE_COMPLETE '..#samples)
