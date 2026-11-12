-- Frozen production geometry in an isolated scene; not a gameplay acceptance capture.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
game:GetService('RunService'):Run();task.wait(1)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local V=require(Client.EnemySpellVFX)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=40
camera.CFrame=CFrame.lookAt(Vector3.new(0,18,31),Vector3.new(0,1,0))
game.Lighting.ClockTime=12;game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(160,165,175)
local stage=Instance.new('Folder');stage.Name='SpellComparison';stage.Parent=workspace
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(65,1,55);floor.Position=Vector3.new(0,-1,0);floor.Color=Color3.fromRGB(42,47,58);floor.Material=Enum.Material.SmoothPlastic;floor.Parent=stage
local samples={{'Shaman',1},{'KingShaman',1},{'IceElf',1},{'QueenIceElf',2},{'IceTroll',2},{'Imp',1},{'CalderaTitan',1},{'VolcanoShaman',1},{'Silkweaver',1},{'VenomcoilKing',1},{'Lich',1},{'Veyr',4}}
local positions={}
for i,row in ipairs(samples)do
 local position=Vector3.new(((i-1)%4-1.5)*6.5,1.7,(math.floor((i-1)/4)-1)*6.5);positions[i]=position
 local anchor=Instance.new('Part');anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.Size=Vector3.one*.05;anchor.Position=position;anchor.Parent=stage
 local b=Instance.new('BillboardGui');b.Size=UDim2.fromOffset(240,36);b.StudsOffsetWorldSpace=Vector3.new(0,-1.8,0);b.Adornee=anchor;b.Parent=anchor
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=row[1];t.TextSize=24;t.TextColor3=Color3.new(1,1,1);t.TextStrokeTransparency=.35;t.Parent=b
end
local function capture(name)
 task.wait(.15)
 local done=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id));local pix=img:ReadPixelsBuffer(Vector2.zero,img.Size)
   local w,h=560,300;local hex={}
   for y=0,h-1 do for x=0,w-1 do
    local at=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
    for c=0,2 do hex[#hex+1]=string.format('%x',math.floor(buffer.readu8(pix,at+c)/16))end
   end end
   local data=table.concat(hex);print('SPELL_META '..game.HttpService:JSONEncode({name=name,width=w,height=h,bits=4}))
   for i=1,#data,20000 do print('SPELL_RGB16 '..name..' '..data:sub(i,i+19999))end
   img:Destroy()
  end)
  if not ok then print('SPELL_CAPTURE_ERROR',err)end
  done=true
 end)
 local deadline=os.clock()+12;while not done and os.clock()<deadline do task.wait(.05)end
 assert(done,'capture timeout')
end
local old=Instance.new('Folder');old.Parent=stage
for i,row in ipairs(samples)do
 local d=Patterns.get(row[1]).attacks[row[2]];local rgb=require(game.ReplicatedStorage.Shared.EnemySpellProfiles).get(d).color
 local p=Instance.new('Part');p.Anchored=true;p.Shape=Enum.PartType.Ball;p.Material=Enum.Material.Neon;p.Size=Vector3.one*1.1;p.Position=positions[i];p.Color=Color3.fromRGB(table.unpack(rgb));p.Parent=old
end
capture('before');old:Destroy()
for i,row in ipairs(samples)do
 local d=Patterns.get(row[1]).attacks[row[2]];local p=positions[i]
 local r=V.projectile(d,nil,nil,p,Vector3.new(-.5,0,-1).Unit,workspace:GetServerTimeNow())
 V.pose(r,CFrame.lookAt(p,p+Vector3.new(-.5,0,-1))*CFrame.Angles(.25,0,.2),0,1.8)
end
capture('after');V.clear();stage:Destroy();print('SPELL_CAPTURE_COMPLETE')
