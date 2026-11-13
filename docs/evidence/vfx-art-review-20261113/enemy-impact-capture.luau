-- ART-only close contact supplement. Correct front-facing gray target; not real hero/contact timing acceptance.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')
for _,node in ipairs(game:GetDescendants())do if node:IsA('BaseScript')then node.Enabled=false end end
local baseplate=workspace:FindFirstChild('Baseplate');if baseplate then baseplate:Destroy()end
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run()end;task.wait(.2)
local V=require(game.StarterPlayer.StarterPlayerScripts.Client.EnemySpellVFX)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local Profiles=require(game.ReplicatedStorage.Shared.EnemySpellProfiles)
local encoding=game:GetService('EncodingService')
local camera=workspace.CurrentCamera;local old=camera.CFrame
camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=40
camera.CFrame=CFrame.lookAt(Vector3.new(4,6,11),Vector3.new(0,2.2,1))
local light=game.Lighting;light.ClockTime=14;light.Brightness=2;light.Ambient=Color3.fromRGB(150,155,165)
local stage=Instance.new('Folder');stage.Name='EnemyArtReviewStage';stage.Parent=workspace
local floor=Instance.new('Part');floor.Name='EnemyArtReviewFloor';floor.Size=Vector3.new(80,.5,60);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Color=Color3.fromRGB(43,51,59);floor.Material=Enum.Material.Slate;floor.Parent=stage
local function actor(x,name)
 local model=Instance.new('Model');model.Name=name;model.Parent=stage
 for _,row in ipairs({{'Body',Vector3.new(1.4,2,1),Vector3.new(x,2,1)},{'Head',Vector3.one,Vector3.new(x,3.5,1)}})do
  local p=Instance.new('Part');p.Name=row[1];p.Anchored=true;p.CanCollide=false;p.Size=row[2];p.Position=row[3];p.Color=Color3.fromRGB(125,138,150);p.Parent=model
 end
end
actor(0,'TargetScaleGuide')
local species={};for kind in pairs(Patterns.profiles)do species[#species+1]=kind end;table.sort(species)
local samples={};local signatures={}
for _,kind in ipairs(species)do
 for _,d in ipairs(Patterns.get(kind).attacks)do
  local p=Profiles.get(d);local magic=p.family~='physical'and p.family~='earth'and p.family~='web'
  local key=p.family..'/'..table.concat(p.color,',')..'/'..(magic and tostring(d.heavy)or 'shared')
  if not signatures[key]then signatures[key]=true;samples[#samples+1]={kind=kind,attack=d,isBase=false,signature=key}end
 end
end
local function capture(index,sample,profile)
 local done=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pixels=img:ReadPixelsBuffer(Vector2.zero,img.Size);local width=640;local height=math.floor(width*img.Size.Y/img.Size.X+.5);local rgb=buffer.create(width*height*3)
   for y=0,height-1 do for x=0,width-1 do
    local offset=(math.floor(y/height*img.Size.Y)*img.Size.X+math.floor(x/width*img.Size.X))*4
    for c=0,2 do buffer.writeu8(rgb,(y*width+x)*3+c,buffer.readu8(pixels,offset+c))end
   end end
   print('ENEMY_ART_META '..game.HttpService:JSONEncode({index=index,id=sample.attack.id,kind=sample.kind,motif=profile.motif,ornament=profile.ornament,family=profile.family,shape=sample.attack.shape,isSpeciesBase=sample.isBase,width=width,height=height,stages={'impact'},scales={1.4},runtimeCharge=false,normalized=true,isImpactSupplement=true,signature=sample.signature,encoding='zstd-hex'}))
   local compressed=encoding:CompressBuffer(rgb,Enum.CompressionAlgorithm.Zstd,9);local hex={}
   for i=0,buffer.len(compressed)-1 do hex[#hex+1]=string.format('%02x',buffer.readu8(compressed,i))end
   local data=table.concat(hex);for at=1,#data,20000 do print('ENEMY_ART_RGB '..index..' '..data:sub(at,at+19999))end
   img:Destroy()
  end)
  if not ok then print('ENEMY_ART_CAPTURE_ERROR '..tostring(err))end
  done=true
 end)
 local deadline=os.clock()+12;while not done and os.clock()<deadline do task.wait(.05)end
 assert(done,'capture timeout')
end
for index,sample in ipairs(samples)do
 if _G.EnemyArtFirst and index<_G.EnemyArtFirst or _G.EnemyArtLast and index>_G.EnemyArtLast then continue end
 V.clear();local d=sample.attack;local profile=Profiles.get(d);local now=workspace:GetServerTimeNow()
 local before={};for _,node in ipairs(workspace:GetChildren())do before[node]=true end
 local impact=assert(V.impact(d,Vector3.new(0,2.3,1),now,nil,nil,Vector3.new(0,0,1)));V.pose(impact,impact.cf,.12,1.4)
 local frozen=Instance.new('Folder');frozen.Name='EnemyArtFrozen';local clones={}
 for _,node in ipairs(workspace:GetChildren())do if not before[node]and node~=frozen then clones[#clones+1]=node:Clone()end end
 V.clear();frozen.Parent=workspace;for _,node in ipairs(clones)do node.Parent=frozen end
 local deadline=os.clock()+3
 local function ready()for _,node in ipairs(frozen:GetDescendants())do if node:IsA('ImageLabel')and not node.IsLoaded then return false end end;return true end
 while not ready()and os.clock()<deadline do task.wait(.05)end
 for _,node in ipairs(frozen:GetDescendants())do if node:IsA('ParticleEmitter')then
  local amount=node:GetAttribute('ReviewBurstCount')or 0
  if amount==0 and node.Enabled then amount=math.ceil(node.Rate*.14)end
  node.Enabled=false;node:Clear();node:Emit(amount)
 end end
 task.wait(.09)
 for _,node in ipairs(frozen:GetDescendants())do if node:IsA('ParticleEmitter')then node.TimeScale=0 end end
 capture(index,sample,profile);frozen:Destroy()
end
V.clear();stage:Destroy();camera.CFrame=old
print('ENEMY_ART_CAPTURE_COMPLETE '..#samples)
