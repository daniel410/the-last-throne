-- Engine instances and pixel buffers, isolated from the user's scene and assets.
-- The runner may provide candidate sources without editing any game modules.
local client=game.StarterPlayer.StarterPlayerScripts.Client
local plateSource=ATLAS_PLATE_SOURCE or client.AtlasPlate.Source
local canvasSource=ATLAS_CANVAS_SOURCE or client.DeepwoodMapCanvas.Source
local encoding=game:GetService('EncodingService')
local assets=game:GetService('AssetService')
local realPlates=client.AtlasPlates
local checks=0
local function check(ok,message)checks+=1;assert(ok,message)end
local function plate(folder, imageService, studio, optIn)
 local fn=assert(loadstring(plateSource))
 local owner={FindFirstChild=function(_,name)return name=='AtlasPlates' and folder end}
 local module={Parent=owner,GetAttribute=function(_,name)
  assert(name=='EnableAtlasTextures')
  return optIn
 end}
 local services={EncodingService=encoding,AssetService=imageService or assets,RunService={IsStudio=function()return studio end}}
 setfenv(fn,setmetatable({script=module,game={GetService=function(_,name)return assert(services[name],name) end}},{__index=getfenv()}))
 return fn()
end
local function canvas(p)
 local fn=assert(loadstring(canvasSource))
 setfenv(fn,setmetatable({script=client.DeepwoodMapCanvas,require=function(module)
  if module==client.AtlasPlate then return p end
  return require(module)
 end},{__index=getfenv()}))
 return fn()
end
local host=Instance.new('Frame')
local partial=Instance.new('Folder')
local ok,err=xpcall(function()
 -- Menu construction must complete before image siblings have replicated.
 local p=plate(nil)
 local view=canvas(p).create(host,'DW-01',false)
 view.present(500,false);view.update({journal=require(game.ReplicatedStorage.Shared.DeepwoodProgress).new()})
 check(view.rows['DW-01'] and host:FindFirstChild('SurveyGround_DW-01'),'missing folder retains map geography and region')
 host:ClearAllChildren()
 p=plate(partial)
 check(p.draw(host,'DW-01',true)==nil,'missing individual plate is recoverable')
 local entry=Instance.new('StringValue');entry.Name='Relief_DW-01';entry.Parent=partial
 check(p.draw(host,'DW-01',true)==nil,'empty replicated value is recoverable')
 entry.Value='not base64'
 check(p.draw(host,'DW-01',true)==nil,'bad encoded value is recoverable')
 for _,raw in ipairs({buffer.create(4),buffer.create(772)})do
  entry.Value=buffer.tostring(encoding:Base64Encode(encoding:CompressBuffer(raw,Enum.CompressionAlgorithm.Zstd)))
  check(p.draw(host,'DW-01',true)==nil,'truncated or invalid dimensions are recoverable')
 end
 entry.Value=realPlates['Relief_DW-01'].Value
 local recovered=p.draw(host,'DW-01',true)
 check(recovered and recovered.Name=='Relief' and recovered:IsA('Frame') and #recovered:GetChildren()>0,
  'late valid data restores the surveyed terrain on reopening')
 host:ClearAllChildren()
 local calls=0
 local denied={CreateEditableImage=function()calls+=1;error('Image APIs unavailable')end}
 p=plate(realPlates,denied)
 local fallback=p.draw(host,'GW-05',false)
 check(fallback:IsA('Frame') and calls==0,'default published settings never call the image API')
 check(#fallback:GetChildren()>54 and #fallback:GetChildren()<=288,'overview fallback has a denser bounded grid')
 local band=fallback:GetChildren()[1]
 local overlay=Instance.new('Frame')
 overlay.Name='FogCell';overlay.Parent=fallback
 local overlayColor=overlay.BackgroundColor3
 local tint=Color3.new(.2,.25,.30)
 p.shade(fallback,tint)
 check(band.BackgroundColor3==tint,'default-security terrain accepts fog tint')
 check(overlay.BackgroundColor3==overlayColor,'terrain shading leaves nested fog untouched')
 p.shade(fallback,Color3.new(1,1,1))
 check(band.BackgroundColor3==Color3.new(1,1,1),'clearing fallback tint restores the original terrain colors')
 fallback:Destroy()
 fallback=plate(realPlates,denied,false,true).draw(host,'GW-05',false)
 check(fallback:IsA('Frame') and calls==1,'opt-in with unavailable API falls back')
 fallback:Destroy()
 for _,stage in ipairs({'budget','pixels','binding'}) do
  local released=false
  local failing={CreateEditableImage=function()
   if stage=='budget' then return nil end
   return {WritePixelsBuffer=function()if stage=='pixels' then error('Write failed') end end,
    Destroy=function()released=true end}
  end}
  fallback=plate(realPlates,failing,true).draw(host,'GW-05',false)
  check(fallback:IsA('Frame') and (stage=='budget' or released),stage..' failure releases image and keeps terrain')
  fallback:Destroy()
 end
 -- Compare the actual engine pixel buffer with the stored survey indices.
 p=plate(realPlates,nil,true)
 local count=0
 for _,entry in ipairs(realPlates:GetChildren())do
  local data=encoding:DecompressBuffer(encoding:Base64Decode(buffer.fromstring(entry.Value)),Enum.CompressionAlgorithm.Zstd)
  local size=Vector2.new(buffer.readu16(data,0),buffer.readu16(data,2))
  local drawn=p.draw(host,entry.Name:sub(8),false)
  check(drawn and drawn.Name=='Relief' and drawn:IsA('ImageLabel'),entry.Name..' draws as a texture')
  local image=drawn.ImageContent.Object
  check(image.Size==size,entry.Name..' keeps native overview resolution')
  local pixels=image:ReadPixelsBuffer(Vector2.zero,size)
  local mismatch=entry.Name..' pixel or alpha mismatch'
  for i=0,size.X*size.Y-1 do
   local index=buffer.readu8(data,772+i)
   local offset=4+index*3
   local expected=index==255 and 0 or buffer.readu8(data,offset)+256*buffer.readu8(data,offset+1)+65536*buffer.readu8(data,offset+2)+0xFF000000
   assert(buffer.readu32(pixels,i*4)==expected,mismatch)
  end
  check(true,entry.Name..' matches all source pixels')
  drawn:Destroy()
  count+=1;task.wait()
 end
 check(count==44,'all 44 region sources checked')
 local detail=p.draw(host,'GW-05',true)
 check(detail:IsA('ImageLabel') and detail.ImageContent.Object.Size.X>0,'field map uses the surveyed texture')
 local screen=Instance.new('ScreenGui')
 screen.Parent=game.CoreGui
 host.Parent=screen
 host.Size=UDim2.fromOffset(100,100)
 task.wait()
 check(detail.AbsoluteSize==Vector2.new(100,100),'overview image fits the map frame')
 check(detail.ResampleMode==Enum.ResamplerMode.Default,'overview downscales with smooth sampling')
 host.Size=UDim2.fromOffset(900,900)
 for _=1,10 do
  if detail.AbsoluteSize==Vector2.new(900,900) and detail.ResampleMode==Enum.ResamplerMode.Pixelated then break end
  task.wait()
 end
 check(detail.ResampleMode==Enum.ResamplerMode.Pixelated,'zoom beyond native size preserves pixel edges')
 host:Destroy()
 screen:Destroy()
 host=Instance.new('Frame')
 local world=canvas(p).create(host,{['GW-01']=true,['GW-02']=true},false)
 world.present(500,false)
 world.present(1250,false)
 check(host:FindFirstChild('Relief'):IsA('ImageLabel') and world.rows['GW-02'],'zoom keeps textures and map markers')
end,debug.traceback)
host:Destroy();partial:Destroy()
assert(ok,err)
return {checks=checks,pass=true}
