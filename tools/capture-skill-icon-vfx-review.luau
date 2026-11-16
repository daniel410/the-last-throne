-- Before/after stills at identical times and camera; not a live timing test.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Before=require(Client.HeroVFXBefore)
local After=require(Client.HeroVFX)
local WindBefore=require(Client.WindLanceVisualBefore)
local WindAfter=require(Client.WindLanceVisual)
if not game.RunService:IsRunning()then game.RunService:Run()end
task.wait(.3)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=44
local floor=Instance.new('Part');floor.Size=Vector3.new(50,.5,50);floor.Position=Vector3.new(0,-.25,0);floor.Anchored=true;floor.Color=Color3.fromRGB(47,55,65);floor.Material=Enum.Material.Slate;floor.Parent=workspace
local samples={
 {'Kite Shield','knight','knight.common.bash',.08},
 {'Dawn Aegis','knight','knight.paladin.oath_of_dawn',.08},
 {'Armor Split','dwarf','dwarf.iron_axe.armor_splitter',.08},
 {'Skipping Charge','dwarf','dwarf.gunner.skipping_charge',.08},
 {'Bloom Shot','elf','elf.magic_archer.bloom_shot',.08},
 {'Echo Arrows','elf','elf.magic_archer.echo_arrows',.08},
 {'Glacial Spike','mage','mage.cryo.glacial_spike',.08},
 {'Water Ball','mage','mage.common.water_ball',.08},
 {'Gravity Field','mage','mage.common.gravity',.08},
 {'Wind Lance','mage','mage_wind_lance',.08},
 {'Vine Trap','elf','elf.magic_archer.vine_trap',.08},
 {'Dawn Spiral','knight','knight.paladin.dawn_spiral',.08},
}
for index,row in ipairs(samples)do
 Before.clear();After.clear();WindBefore.clear();WindAfter.clear()
 game.Lighting.ClockTime=index%2==0 and 0 or 12
 game.Lighting.Brightness=2;game.Lighting.Ambient=Color3.fromRGB(95,100,115)
 camera.CFrame=CFrame.lookAt(Vector3.new(0,14,17),Vector3.new(0,1.6,-2))
 local snapshot=Instance.new('Folder');snapshot.Name='IconVFXComparison';snapshot.Parent=workspace
 for side,fx in ipairs({Before,After})do
  local first=Vector3.new(side==1 and -5 or 5,3,0)
  local target=Instance.new('Part');target.Name='Target';target.Size=Vector3.new(1,1.8,.6);target.Position=first+Vector3.zAxis*.8-Vector3.yAxis*1;target.Anchored=true;target.Color=Color3.fromRGB(110,128,136);target.Parent=snapshot
  local tag=Instance.new('BillboardGui');tag.Size=UDim2.fromOffset(240,35);tag.StudsOffsetWorldSpace=Vector3.new(0,3,0);tag.Adornee=target;tag.AlwaysOnTop=false;tag.Parent=snapshot
  local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=(side==1 and'Before - 'or'After - ')..row[1];label.TextColor3=Color3.new(1,1,1);label.TextSize=18;label.Font=Enum.Font.GothamBold;label.Parent=tag
  local now=workspace:GetServerTimeNow()
  local model
  local last=first-Vector3.zAxis*5
  if row[3]=='mage_wind_lance'then
   local wind=side==1 and WindBefore or WindAfter
   model=wind.play(nil,first,last,1,{},nil,now,nil,.25,now)
   wind.step(now+row[4])
  else
   local d=game.ReplicatedStorage.Shared.K0Config
   local def
   for _,list in pairs(require(d).Skills)do for _,skill in ipairs(list)do if skill.id==row[3]then def=skill end end end
   if def.form=='area' or def.form=='self'then last=first end
   model=fx.skill(nil,row[3],first,last,1,{last})
   fx.step(now+row[4])
  end
  assert(model,'missing comparison sample')
  local copy=model:Clone();copy.Parent=snapshot
  fx.clear();WindBefore.clear();WindAfter.clear()
 end
 task.wait(.15)
 local captured=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local img=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id))
   local pixels=img:ReadPixelsBuffer(Vector2.zero,img.Size);local hex={};local w,h=480,270
   for y=0,h-1 do for x=0,w-1 do
    local offset=(math.floor(y/h*img.Size.Y)*img.Size.X+math.floor(x/w*img.Size.X))*4
    for channel=0,2 do hex[#hex+1]=string.format('%02x',buffer.readu8(pixels,offset+channel))end
   end end
   local data=table.concat(hex)
   print('ICON_VFX_META '..game.HttpService:JSONEncode({index=index,name=row[1],width=w,height=h,time=row[4],clockTime=game.Lighting.ClockTime}))
   for i=1,#data,20000 do print('ICON_VFX_RGB '..index..' '..data:sub(i,i+19999))end
   img:Destroy()
  end)
  if not ok then print('ICON_VFX_CAPTURE_ERROR '..tostring(err))end
  captured=true
 end)
 local deadline=os.clock()+10;while not captured and os.clock()<deadline do task.wait(.05)end
 assert(captured,'capture timed out');snapshot:Destroy()
end
Before.clear();After.clear();WindBefore.clear();WindAfter.clear();floor:Destroy()
print('ICON_VFX_CAPTURE_COMPLETE')
